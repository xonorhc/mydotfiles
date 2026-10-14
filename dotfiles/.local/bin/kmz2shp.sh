#!/usr/bin/env bash

set -u

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.kml|arquivo.kmz|diretorio> [diretorio_saida]"
  exit 1
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage

INPUT="$1"
OUTPUT_DIR="${2:-shapefiles}"

mkdir -p "$OUTPUT_DIR"

command -v ogrinfo >/dev/null 2>&1 || {
  echo "Erro: ogrinfo não encontrado."
  exit 1
}

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "Erro: ogr2ogr não encontrado."
  exit 1
}

declare -a INPUT_FILES
declare -A CREATED_LAYERS

abs_path() {
  (
    cd "$(dirname "$1")" >/dev/null 2>&1 || exit 1
    printf "%s/%s" "$(pwd -P)" "$(basename "$1")"
  )
}

###############################################################################
# Entrada
###############################################################################

if [ -f "$INPUT" ]; then

  case "${INPUT,,}" in
  *.kml | *.kmz)
    INPUT_FILES+=("$(abs_path "$INPUT")")
    ;;
  *)
    echo "Erro: informe um arquivo KML, KMZ ou diretório."
    exit 1
    ;;
  esac

elif [ -d "$INPUT" ]; then

  while IFS= read -r -d '' file; do
    INPUT_FILES+=("$(abs_path "$file")")
  done < <(
    find "$INPUT" \
      -type f \
      \( -iname "*.kml" -o -iname "*.kmz" \) \
      -print0
  )

else
  echo "Erro: entrada não encontrada: $INPUT"
  exit 1
fi

[ ${#INPUT_FILES[@]} -gt 0 ] || {
  echo "Erro: nenhum arquivo KML/KMZ encontrado."
  exit 1
}

###############################################################################
# Utilidades
###############################################################################

classify_geometry() {

  local geom
  geom="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

  if [[ "$geom" == *point* ]]; then
    echo "pontos"

  elif [[ "$geom" == *line* ]]; then
    echo "linhas"

  elif [[ "$geom" == *polygon* ]]; then
    echo "poligonos"

  else
    echo ""
  fi
}

shp_exists() {

  local layer="$1"

  [ -f "$OUTPUT_DIR/${layer}.shp" ]
}

ogr_append() {

  local src="$1"
  local layer="$2"
  local dst="$3"

  if shp_exists "$dst"; then

    ogr2ogr \
      -f "ESRI Shapefile" \
      -update \
      -append \
      "$OUTPUT_DIR/${dst}.shp" \
      "$src" \
      "$layer" \
      -explodecollections \
      -skipfailures

  else

    ogr2ogr \
      -f "ESRI Shapefile" \
      "$OUTPUT_DIR/${dst}.shp" \
      "$src" \
      "$layer" \
      -explodecollections \
      -skipfailures
  fi
}

ogr_append_sql() {

  local src="$1"
  local sql="$2"
  local dst="$3"

  if shp_exists "$dst"; then

    ogr2ogr \
      -f "ESRI Shapefile" \
      -update \
      -append \
      "$OUTPUT_DIR/${dst}.shp" \
      "$src" \
      -dialect OGRSQL \
      -sql "$sql" \
      -explodecollections \
      -skipfailures

  else

    ogr2ogr \
      -f "ESRI Shapefile" \
      "$OUTPUT_DIR/${dst}.shp" \
      "$src" \
      -dialect OGRSQL \
      -sql "$sql" \
      -explodecollections \
      -skipfailures
  fi
}

###############################################################################
# Camadas Unknown(any)
###############################################################################

export_unknown_layer() {

  local src="$1"
  local layer="$2"

  local geom_type
  local dst
  local sql
  local count

  for geom_type in \
    POINT \
    MULTIPOINT \
    LINESTRING \
    MULTILINESTRING \
    POLYGON \
    MULTIPOLYGON; do

    sql="SELECT * FROM \"$layer\" WHERE OGR_GEOMETRY='$geom_type'"

    count=$(
      ogrinfo \
        -ro \
        "$src" \
        -dialect OGRSQL \
        -sql "$sql" 2>/dev/null |
        sed -n 's/^Feature Count: //p' |
        head -1
    )

    count="${count:-0}"

    [[ "$count" =~ ^[0-9]+$ ]] || count=0

    [ "$count" -eq 0 ] && continue

    dst="$(classify_geometry "$geom_type")"

    echo "  -> $layer => $dst ($count feições)"

    ogr_append_sql "$src" "$sql" "$dst"

  done
}

###############################################################################
# Processamento
###############################################################################

process_file() {

  local file="$1"
  local src

  case "${file,,}" in
  *.kmz) src="/vsizip/$file" ;;
  *.kml) src="$file" ;;
  *) return ;;
  esac

  echo
  echo "Processando: $file"

  ogrinfo -ro "$src" >/dev/null 2>&1 || {
    echo "Aviso: GDAL não conseguiu abrir: $src"
    return
  }

  while IFS= read -r line; do

    local layer_line
    local layer
    local geom
    local dst

    layer_line="$(echo "$line" | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*//')"

    geom=""

    if [[ "$layer_line" =~ ^(.*)[[:space:]]+\((.*)\)$ ]]; then

      layer="${BASH_REMATCH[1]}"
      geom="${BASH_REMATCH[2]}"

    else

      layer="$layer_line"

      geom=$(
        ogrinfo -ro "$src" "$layer" 2>/dev/null |
          sed -n 's/^Geometry:[[:space:]]*//p' |
          head -1
      )
    fi

    echo "Camada: $layer${geom:+ ($geom)}"

    if [[ "$geom" != "Unknown (any)" ]] &&
      [ -n "$geom" ]; then

      dst="$(classify_geometry "$geom")"

      if [ -n "$dst" ]; then

        echo "  -> $layer => $dst"

        ogr_append "$src" "$layer" "$dst"
      fi

      continue
    fi

    export_unknown_layer "$src" "$layer"

  done < <(
    ogrinfo -ro "$src" |
      grep -E '^[[:space:]]*[0-9]+: '
  )
}

###############################################################################
# Execução
###############################################################################

for file in "${INPUT_FILES[@]}"; do
  process_file "$file"
done

echo
echo "Concluído."
echo "Arquivos gerados em:"
echo "  $OUTPUT_DIR"

echo
echo "Shapefiles gerados:"
find "$OUTPUT_DIR" -maxdepth 1 -name "*.shp" -printf "  %f\n"
