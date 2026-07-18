#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./shp2csv.sh <arquivo.shp|diretorio> [diretorio_saida]
#
# Exemplos:
#   ./shp2csv.sh arquivo.shp
#   ./shp2csv.sh arquivo.shp ./csv
#   ./shp2csv.sh ./shapefiles
#   ./shp2csv.sh ./shapefiles ./csv

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.shp|diretorio> [diretorio_saida]"
  echo
  echo "Exemplos:"
  echo "  $0 arquivo.shp"
  echo "  $0 arquivo.shp ./csv"
  echo "  $0 ./shapefiles"
  echo "  $0 ./shapefiles ./csv"
  exit 1
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
fi

INPUT="$1"
OUTPUT_DIR="${2:-.}"

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "Erro: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

mkdir -p "$OUTPUT_DIR"

declare -a SHP_FILES

collect_shapefiles() {
  local input_path="$1"

  if [ -f "$input_path" ]; then
    case "${input_path,,}" in
      *.shp)
        SHP_FILES+=("$input_path")
        ;;
      *)
        echo "Erro: o arquivo informado não é um Shapefile (.shp)."
        exit 1
        ;;
    esac

  elif [ -d "$input_path" ]; then
    while IFS= read -r -d '' shp; do
      SHP_FILES+=("$shp")
    done < <(find "$input_path" -maxdepth 1 -type f -iname "*.shp" -print0)

  else
    echo "Erro: entrada não encontrada: $input_path"
    exit 1
  fi
}

process_shapefile() {
  local shp_path="$1"

  local base_name
  base_name="$(basename "$shp_path")"
  base_name="${base_name%.*}"

  local csv_destino="${OUTPUT_DIR}/${base_name}.csv"

  echo ">> [CSV] Processando: $shp_path"
  echo ">> [CSV] Saída: $csv_destino"

  rm -f "$csv_destino"

  ogr2ogr \
    -f CSV \
    "$csv_destino" \
    "$shp_path" \
    -lco GEOMETRY=AS_WKT \
    -lco CREATE_CSVT=YES \
    -skipfailures

  echo ">> [CSV] Concluído: $csv_destino"
}

main() {
  collect_shapefiles "$INPUT"

  if [ "${#SHP_FILES[@]}" -eq 0 ]; then
    echo ">> [CSV] Nenhum arquivo .shp foi encontrado."
    exit 0
  fi

  echo ">> [CSV] Total de Shapefiles encontrados: ${#SHP_FILES[@]}"
  echo ">> [CSV] Diretório de saída: $OUTPUT_DIR"

  for shp in "${SHP_FILES[@]}"; do
    process_shapefile "$shp"
  done

  echo ">> [CSV] Sucesso! Exportação concluída."
}

main "$@"
