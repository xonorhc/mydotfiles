#!/usr/bin/env bash
set -u

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.kmz|diretorio> [saida.gpkg]"
  exit 1
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage

INPUT="$1"
OUTPUT="${2:-kmz_consolidado.gpkg}"

if [[ "$OUTPUT" != */* ]]; then
  OUTPUT="./$OUTPUT"
fi

command -v ogrinfo >/dev/null 2>&1 || {
  echo "Erro: ogrinfo não encontrado."
  exit 1
}

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "Erro: ogr2ogr não encontrado."
  exit 1
}

rm -f "$OUTPUT"

declare -a KMZ_FILES
declare -A CREATED_LAYERS

abs_path() {
  local path="$1"
  local dir
  local base

  dir="$(dirname "$path")"
  base="$(basename "$path")"

  cd "$dir" >/dev/null 2>&1 || exit 1
  printf "%s/%s" "$(pwd -P)" "$base"
}

if [ -f "$INPUT" ]; then
  case "${INPUT,,}" in
    *.kmz)
      KMZ_FILES+=("$(abs_path "$INPUT")")
      ;;
    *)
      echo "Erro: informe um arquivo .kmz ou um diretório."
      exit 1
      ;;
  esac
elif [ -d "$INPUT" ]; then
  while IFS= read -r -d '' file; do
    KMZ_FILES+=("$(abs_path "$file")")
  done < <(find "$INPUT" -type f -iname "*.kmz" -print0)
else
  echo "Erro: entrada não encontrada: $INPUT"
  exit 1
fi

if [ "${#KMZ_FILES[@]}" -eq 0 ]; then
  echo "Erro: nenhum KMZ encontrado."
  exit 1
fi

classify_geometry() {
  local geom_lc
  geom_lc="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

  if [[ "$geom_lc" == *point* ]]; then
    echo "pontos"
  elif [[ "$geom_lc" == *line* || "$geom_lc" == *curve* ]]; then
    echo "linhas"
  elif [[ "$geom_lc" == *polygon* || "$geom_lc" == *surface* ]]; then
    echo "poligonos"
  else
    echo ""
  fi
}

layer_exists() {
  local layer="$1"

  if [[ -n "${CREATED_LAYERS[$layer]+x}" ]]; then
    return 0
  fi

  if [ -f "$OUTPUT" ] && ogrinfo -ro "$OUTPUT" "$layer" >/dev/null 2>&1; then
    CREATED_LAYERS["$layer"]=1
    return 0
  fi

  return 1
}

append_layer() {
  local src="$1"
  local src_layer="$2"
  local dst_layer="$3"

  echo "  -> $src_layer  ==>  $dst_layer"

  if [ ! -f "$OUTPUT" ]; then
    ogr2ogr \
      -f GPKG \
      -skipfailures \
      -explodecollections \
      -nln "$dst_layer" \
      -nlt PROMOTE_TO_MULTI \
      "$OUTPUT" \
      "$src" \
      "$src_layer"
  elif layer_exists "$dst_layer"; then
    ogr2ogr \
      -f GPKG \
      -update \
      -append \
      -addfields \
      -skipfailures \
      -explodecollections \
      -nln "$dst_layer" \
      -nlt PROMOTE_TO_MULTI \
      "$OUTPUT" \
      "$src" \
      "$src_layer"
  else
    ogr2ogr \
      -f GPKG \
      -update \
      -skipfailures \
      -explodecollections \
      -nln "$dst_layer" \
      -nlt PROMOTE_TO_MULTI \
      "$OUTPUT" \
      "$src" \
      "$src_layer"
  fi

  CREATED_LAYERS["$dst_layer"]=1
}

process_kmz() {
  local kmz="$1"
  local src="/vsizip/$kmz"
  local count=0

  echo "Processando: $kmz"

  if ! ogrinfo -ro "$src" >/dev/null 2>&1; then
    echo "Aviso: GDAL não conseguiu abrir: $src"
    return
  fi

  while IFS= read -r line; do
    local layer
    local geom
    local dst_layer

    layer="$(echo "$line" | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*(.*)[[:space:]]+\((.*)\)[[:space:]]*$/\1/')"
    geom="$(echo "$line" | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*(.*)[[:space:]]+\((.*)\)[[:space:]]*$/\2/')"

    [ -z "$layer" ] && continue
    [ -z "$geom" ] && continue

    dst_layer="$(classify_geometry "$geom")"

    if [ -z "$dst_layer" ]; then
      echo "  -> ignorado: $layer [$geom]"
      continue
    fi

    append_layer "$src" "$layer" "$dst_layer"
    count=$((count + 1))

  done < <(
    ogrinfo -ro "$src" |
    grep -E '^[[:space:]]*[0-9]+: '
  )

  if [ "$count" -eq 0 ]; then
    echo "Aviso: nenhuma camada com geometria compatível foi encontrada neste KMZ."
  fi
}

for kmz in "${KMZ_FILES[@]}"; do
  process_kmz "$kmz"
done

if [ ! -f "$OUTPUT" ]; then
  echo "Erro: nenhum dado com geometria foi exportado."
  exit 1
fi

echo
echo "Concluído."
echo "GeoPackage gerado em: $OUTPUT"

echo
echo "Camadas geradas:"
ogrinfo -ro "$OUTPUT" | grep -E '^[[:space:]]*[0-9]+: ' || true
