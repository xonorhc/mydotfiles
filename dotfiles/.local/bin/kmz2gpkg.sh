#!/usr/bin/env bash

set -Eeuo pipefail

PROGRAM_NAME="$(basename "$0")"
APPEND_MODE=0
KEEP_TEMP=0
BASE_LAYER_NAME="dados"
OUTPUT=""
INPUT=""
TEMP_DIR=""

declare -a INPUT_FILES=()
declare -A CREATED_LAYERS=()

usage() {
  cat <<EOF
Uso:
  $PROGRAM_NAME [opcoes] <arquivo.kml|arquivo.kmz|diretorio> [saida.gpkg]

Opcoes:
  -a, --append             Adiciona ao GeoPackage existente.
  -n, --layer-name NOME    Nome-base das camadas de saida.
                           Gera NOME_ponto, NOME_linha e NOME_poligono.
  -k, --keep-temp          Mantem arquivos temporarios para diagnostico.
  -h, --help               Exibe esta ajuda.

Exemplos:
  $PROGRAM_NAME arquivo.kmz resultado.gpkg
  $PROGRAM_NAME --layer-name levantamento arquivo.kmz resultado.gpkg
  $PROGRAM_NAME --append --layer-name levantamento diretorio resultado.gpkg
EOF
}

die() {
  echo "Erro: $*" >&2
  exit 1
}

warn() {
  echo "Aviso: $*" >&2
}

cleanup() {
  if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
    if ((KEEP_TEMP)); then
      echo
      echo "Arquivos temporarios mantidos em:"
      echo "  $TEMP_DIR"
    else
      rm -rf "$TEMP_DIR"
    fi
  fi
}

trap cleanup EXIT
trap 'die "falha na linha $LINENO."' ERR

while (($# > 0)); do
  case "$1" in
  -a | --append)
    APPEND_MODE=1
    shift
    ;;
  -n | --layer-name)
    (($# >= 2)) || die "a opcao $1 exige um nome."
    BASE_LAYER_NAME="$2"
    shift 2
    ;;
  -k | --keep-temp)
    KEEP_TEMP=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    break
    ;;
  -*)
    die "opcao desconhecida: $1"
    ;;
  *)
    break
    ;;
  esac
done

(($# >= 1 && $# <= 2)) || {
  usage
  exit 1
}

INPUT="$1"
OUTPUT="${2:-kml_kmz_consolidado.gpkg}"

[[ -n "$BASE_LAYER_NAME" ]] || die "o nome-base da camada nao pode ser vazio."

case "${OUTPUT,,}" in
*.gpkg) ;;
*) OUTPUT="${OUTPUT}.gpkg" ;;
esac

[[ "$OUTPUT" == */* ]] || OUTPUT="./$OUTPUT"

command -v ogrinfo >/dev/null 2>&1 || die "ogrinfo nao encontrado. Instale o GDAL/OGR."
command -v ogr2ogr >/dev/null 2>&1 || die "ogr2ogr nao encontrado. Instale o GDAL/OGR."
command -v mktemp >/dev/null 2>&1 || die "mktemp nao encontrado."

abs_path() {
  local path="$1"
  (
    cd "$(dirname "$path")" >/dev/null 2>&1 || exit 1
    printf '%s/%s\n' "$(pwd -P)" "$(basename "$path")"
  )
}

OUTPUT_DIR="$(dirname "$OUTPUT")"
[[ -d "$OUTPUT_DIR" ]] || die "o diretorio de saida nao existe: $OUTPUT_DIR"
OUTPUT="$(abs_path "$OUTPUT")"

if [[ -f "$INPUT" ]]; then
  case "${INPUT,,}" in
  *.kml | *.kmz) INPUT_FILES+=("$(abs_path "$INPUT")") ;;
  *) die "informe um arquivo KML, KMZ ou um diretorio." ;;
  esac
elif [[ -d "$INPUT" ]]; then
  while IFS= read -r -d '' file; do
    INPUT_FILES+=("$(abs_path "$file")")
  done < <(
    find "$INPUT" -type f \( -iname "*.kml" -o -iname "*.kmz" \) -print0 | sort -z
  )
else
  die "entrada nao encontrada: $INPUT"
fi

((${#INPUT_FILES[@]} > 0)) || die "nenhum arquivo KML ou KMZ encontrado."

if [[ -e "$OUTPUT" ]]; then
  if ((APPEND_MODE)); then
    ogrinfo -ro "$OUTPUT" >/dev/null 2>&1 || die "o arquivo existente nao e um GeoPackage valido: $OUTPUT"
    echo "Modo append ativado."
    echo "GeoPackage existente:"
    echo "  $OUTPUT"
  else
    echo "Substituindo GeoPackage existente:"
    echo "  $OUTPUT"
    rm -f "$OUTPUT"
  fi
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/kml-kmz-gpkg.XXXXXX")"

layer_exists() {
  local layer="$1"

  if [[ -n "${CREATED_LAYERS[$layer]+x}" ]]; then
    return 0
  fi

  if [[ -f "$OUTPUT" ]] && ogrinfo -ro "$OUTPUT" "$layer" >/dev/null 2>&1; then
    CREATED_LAYERS["$layer"]=1
    return 0
  fi

  return 1
}

feature_count() {
  local datasource="$1"
  local layer="$2"
  local count

  count="$(
    ogrinfo -ro -so "$datasource" "$layer" 2>/dev/null |
      sed -nE 's/^[[:space:]]*Feature Count:[[:space:]]*([0-9]+).*$/\1/p' |
      head -n 1
  )"

  count="${count:-0}"
  [[ "$count" =~ ^[0-9]+$ ]] || count=0
  printf '%s\n' "$count"
}

sql_identifier() {
  local value="$1"
  value="${value//\"/\"\"}"
  printf '"%s"' "$value"
}

list_layers() {
  local datasource="$1"
  local entry
  local layer

  ogrinfo -ro "$datasource" 2>/dev/null |
    sed -nE 's/^[[:space:]]*[0-9]+:[[:space:]]*(.*)$/\1/p' |
    while IFS= read -r entry; do
      layer="$entry"
      layer="$(
        printf '%s\n' "$layer" |
          sed -E 's/[[:space:]]+\((Unknown \(any\)|None|Point|Multi Point|Line String|Multi Line String|Polygon|Multi Polygon|Geometry Collection|Circular String|Compound Curve|Curve Polygon|Multi Curve|Multi Surface|Polyhedral Surface|TIN|Triangle|3D Point|3D Multi Point|3D Line String|3D Multi Line String|3D Polygon|3D Multi Polygon|3D Geometry Collection)\)$//'
      )"
      [[ -n "$layer" ]] && printf '%s\n' "$layer"
    done
}

check_collection_extract_support() {
  local datasource="$1"
  local layer="$2"
  local quoted_layer

  quoted_layer="$(sql_identifier "$layer")"

  ogrinfo -ro "$datasource" -dialect SQLITE -sql "
    SELECT ST_CollectionExtract(geometry, 2) AS geometry
    FROM $quoted_layer
    LIMIT 1
  " >/dev/null 2>&1 || die "o GDAL nao possui suporte funcional a ST_CollectionExtract via SQLite/SpatiaLite."
}

extracted_geometry_count() {
  local datasource="$1"
  local layer="$2"
  local type_number="$3"
  local quoted_layer
  local count

  quoted_layer="$(sql_identifier "$layer")"

  count="$(
    ogrinfo -ro "$datasource" -dialect SQLITE -sql "
      SELECT ST_CollectionExtract(geometry, $type_number) AS geometry
      FROM $quoted_layer
      WHERE geometry IS NOT NULL
        AND ST_IsEmpty(ST_CollectionExtract(geometry, $type_number)) = 0
    " 2>/dev/null |
      sed -nE 's/^[[:space:]]*Feature Count:[[:space:]]*([0-9]+).*$/\1/p' |
      head -n 1
  )"

  count="${count:-0}"
  [[ "$count" =~ ^[0-9]+$ ]] || count=0
  printf '%s\n' "$count"
}

extracted_component_count() {
  local datasource="$1"
  local layer="$2"
  local type_number="$3"
  local quoted_layer
  local count

  quoted_layer="$(sql_identifier "$layer")"

  count="$(
    ogrinfo -ro "$datasource" -dialect SQLITE -sql "
      SELECT SUM(
        ST_NumGeometries(
          ST_CollectionExtract(geometry, $type_number)
        )
      ) AS component_count
      FROM $quoted_layer
      WHERE geometry IS NOT NULL
        AND ST_IsEmpty(ST_CollectionExtract(geometry, $type_number)) = 0
    " 2>/dev/null |
      sed -nE 's/^[[:space:]]*component_count[^=]*=[[:space:]]*([0-9]+).*$/\1/p' |
      head -n 1
  )"

  count="${count:-0}"
  [[ "$count" =~ ^[0-9]+$ ]] || count=0
  printf '%s\n' "$count"
}

export_geometry_family() {
  local datasource="$1"
  local source_layer="$2"
  local geometry_type_number="$3"
  local destination_layer="$4"
  local expected_source_count="$5"
  local expected_component_count="$6"

  local quoted_layer
  local temporary_file
  local temporary_layer="extracted"
  local sql
  local staged_count
  local before_count=0
  local after_count=0
  local appended_count=0

  quoted_layer="$(sql_identifier "$source_layer")"
  temporary_file="$TEMP_DIR/extracted-${BASHPID}-${RANDOM}-${geometry_type_number}.gpkg"
  rm -f "$temporary_file"

  sql="
    SELECT
      ST_CollectionExtract(geometry, $geometry_type_number) AS geometry,
      Name,
      Description
    FROM $quoted_layer
    WHERE geometry IS NOT NULL
      AND ST_IsEmpty(ST_CollectionExtract(geometry, $geometry_type_number)) = 0
  "

  echo "      Extraindo familia geometrica..."

  if ! ogr2ogr \
    -f GPKG \
    "$temporary_file" \
    "$datasource" \
    -dialect SQLITE \
    -sql "$sql" \
    -nln "$temporary_layer" \
    -nlt CONVERT_TO_LINEAR \
    -dim XYZ \
    -unsetFid \
    -lco SPATIAL_INDEX=NO \
    -skipfailures; then
    warn "falha ao extrair geometrias da camada: $source_layer"
    rm -f "$temporary_file"
    return 1
  fi

  if ! ogrinfo -ro "$temporary_file" "$temporary_layer" >/dev/null 2>&1; then
    warn "a camada temporaria nao foi criada corretamente: $source_layer"
    rm -f "$temporary_file"
    return 1
  fi

  staged_count="$(feature_count "$temporary_file" "$temporary_layer")"
  echo "      Feicoes extraidas: $staged_count"
  echo "      Componentes esperados: $expected_component_count"

  if [[ -f "$OUTPUT" ]] && layer_exists "$destination_layer"; then
    before_count="$(feature_count "$OUTPUT" "$destination_layer")"
  fi

  echo "      Separando componentes individuais..."

  if [[ ! -f "$OUTPUT" ]]; then
    ogr2ogr \
      -f GPKG \
      "$OUTPUT" \
      "$temporary_file" \
      "$temporary_layer" \
      -nln "$destination_layer" \
      -explodecollections \
      -nlt PROMOTE_TO_MULTI \
      -dim XYZ \
      -unsetFid \
      -lco SPATIAL_INDEX=YES \
      -skipfailures || {
      warn "falha ao criar a camada: $destination_layer"
      rm -f "$temporary_file"
      return 1
    }
  elif layer_exists "$destination_layer"; then
    ogr2ogr \
      -f GPKG \
      -update \
      -append \
      -addfields \
      -relaxedFieldNameMatch \
      "$OUTPUT" \
      "$temporary_file" \
      "$temporary_layer" \
      -nln "$destination_layer" \
      -explodecollections \
      -nlt PROMOTE_TO_MULTI \
      -dim XYZ \
      -unsetFid \
      -skipfailures || {
      warn "falha no append da camada: $destination_layer"
      rm -f "$temporary_file"
      return 1
    }
  else
    ogr2ogr \
      -f GPKG \
      -update \
      "$OUTPUT" \
      "$temporary_file" \
      "$temporary_layer" \
      -nln "$destination_layer" \
      -explodecollections \
      -nlt PROMOTE_TO_MULTI \
      -dim XYZ \
      -unsetFid \
      -lco SPATIAL_INDEX=YES \
      -skipfailures || {
      warn "falha ao adicionar a camada: $destination_layer"
      rm -f "$temporary_file"
      return 1
    }
  fi

  CREATED_LAYERS["$destination_layer"]=1
  after_count="$(feature_count "$OUTPUT" "$destination_layer")"
  appended_count=$((after_count - before_count))

  echo "      Feicoes originais selecionadas: $expected_source_count"
  echo "      Componentes esperados: $expected_component_count"
  echo "      Feicoes adicionadas: $appended_count"
  echo "      Total atual na camada: $after_count"

  if ((appended_count != expected_component_count)); then
    warn "quantidade diferente em $destination_layer: esperado $expected_component_count; adicionado $appended_count."
  fi

  if ((!KEEP_TEMP)); then
    rm -f "$temporary_file"
  fi
}

process_layer() {
  local datasource="$1"
  local source_layer="$2"
  local point_source_count
  local line_source_count
  local polygon_source_count
  local point_component_count=0
  local line_component_count=0
  local polygon_component_count=0

  echo
  echo "  Camada de origem: $source_layer"

  point_source_count="$(extracted_geometry_count "$datasource" "$source_layer" 1)"
  line_source_count="$(extracted_geometry_count "$datasource" "$source_layer" 2)"
  polygon_source_count="$(extracted_geometry_count "$datasource" "$source_layer" 3)"

  if ((point_source_count > 0)); then
    point_component_count="$(extracted_component_count "$datasource" "$source_layer" 1)"
  fi
  if ((line_source_count > 0)); then
    line_component_count="$(extracted_component_count "$datasource" "$source_layer" 2)"
  fi
  if ((polygon_source_count > 0)); then
    polygon_component_count="$(extracted_component_count "$datasource" "$source_layer" 3)"
  fi

  echo "    Pontos: $point_source_count feicoes de origem; $point_component_count componentes"
  echo "    Linhas: $line_source_count feicoes de origem; $line_component_count componentes"
  echo "    Poligonos: $polygon_source_count feicoes de origem; $polygon_component_count componentes"

  if ((point_source_count > 0)); then
    export_geometry_family "$datasource" "$source_layer" 1 "${BASE_LAYER_NAME}_ponto" "$point_source_count" "$point_component_count"
  fi
  if ((line_source_count > 0)); then
    export_geometry_family "$datasource" "$source_layer" 2 "${BASE_LAYER_NAME}_linha" "$line_source_count" "$line_component_count"
  fi
  if ((polygon_source_count > 0)); then
    export_geometry_family "$datasource" "$source_layer" 3 "${BASE_LAYER_NAME}_poligono" "$polygon_source_count" "$polygon_component_count"
  fi

  if ((point_source_count == 0 && line_source_count == 0 && polygon_source_count == 0)); then
    warn "nenhuma geometria exportavel encontrada em: $source_layer"
    ogrinfo -ro -al -so "$datasource" "$source_layer" 2>/dev/null |
      grep -E 'Geometry:|Feature Count:' |
      sed 's/^/      /' || true
  fi
}

process_file() {
  local file="$1"
  local datasource
  local layer
  local total_layers=0

  case "${file,,}" in
  *.kmz) datasource="/vsizip/$file" ;;
  *.kml) datasource="$file" ;;
  *) return ;;
  esac

  echo
  echo "Processando:"
  echo "  $file"

  if ! ogrinfo -ro "$datasource" >/dev/null 2>&1; then
    warn "o GDAL nao conseguiu abrir: $datasource"
    return
  fi

  while IFS= read -r layer; do
    [[ -n "$layer" ]] || continue
    ((total_layers += 1))

    if ((total_layers == 1)); then
      check_collection_extract_support "$datasource" "$layer"
    fi

    process_layer "$datasource" "$layer"
  done < <(list_layers "$datasource")

  if ((total_layers == 0)); then
    warn "nenhuma camada vetorial encontrada em: $file"
  fi
}

echo "Arquivos encontrados: ${#INPUT_FILES[@]}"
echo "Nome-base das camadas: $BASE_LAYER_NAME"

if ((APPEND_MODE)); then
  echo "Operacao de saida: append"
else
  echo "Operacao de saida: substituir"
fi

for file in "${INPUT_FILES[@]}"; do
  process_file "$file"
done

[[ -f "$OUTPUT" ]] || die "nenhum dado foi exportado."
ogrinfo -ro "$OUTPUT" >/dev/null 2>&1 || die "o arquivo de saida foi criado, mas nao pode ser validado."

echo
echo "Concluido."
echo "GeoPackage:"
echo "  $OUTPUT"

echo
echo "Camadas geradas ou atualizadas:"
ogrinfo -ro "$OUTPUT" | grep -E '^[[:space:]]*[0-9]+:[[:space:]]' || true

echo
echo "Contagem final:"
for destination_layer in \
  "${BASE_LAYER_NAME}_ponto" \
  "${BASE_LAYER_NAME}_linha" \
  "${BASE_LAYER_NAME}_poligono"; do
  if ogrinfo -ro "$OUTPUT" "$destination_layer" >/dev/null 2>&1; then
    count="$(feature_count "$OUTPUT" "$destination_layer")"
    printf '  %-40s %s feicoes\n' "$destination_layer" "$count"
  fi
done
