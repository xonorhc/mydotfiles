#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./csv2gpkg.sh <arquivo.csv|diretorio> <saida.gpkg> <coluna_x> <coluna_y> <srid> [camada]
#
# Exemplos:
#   ./csv2gpkg.sh pontos.csv pontos.gpkg X Y 31982
#   ./csv2gpkg.sh pontos.csv pontos.gpkg Longitude Latitude 4326
#   ./csv2gpkg.sh ./csvs consolidado.gpkg Longitude Latitude 4326 pontos

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.csv|diretorio> <saida.gpkg> <coluna_x> <coluna_y> <srid> [camada]"
  echo
  echo "Exemplos:"
  echo "  $0 pontos.csv pontos.gpkg X Y 31982"
  echo "  $0 pontos.csv pontos.gpkg Longitude Latitude 4326"
  echo "  $0 ./csvs consolidado.gpkg Longitude Latitude 4326 pontos"
  exit 1
}

if [ $# -lt 5 ] || [ $# -gt 6 ]; then
  usage
fi

INPUT="$1"
OUTPUT_GPKG="$2"
X_COL="$3"
Y_COL="$4"
SRID="$5"
LAYER_NAME="${6:-pontos}"

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "Erro: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

command -v ogrinfo >/dev/null 2>&1 || {
  echo "Erro: ogrinfo não encontrado. Instale o GDAL."
  exit 1
}

declare -a CSV_FILES

collect_csv_files() {
  local input_path="$1"

  if [ -f "$input_path" ]; then
    case "${input_path,,}" in
      *.csv)
        CSV_FILES+=("$input_path")
        ;;
      *)
        echo "Erro: o arquivo informado não é CSV."
        exit 1
        ;;
    esac

  elif [ -d "$input_path" ]; then
    while IFS= read -r -d '' csv; do
      CSV_FILES+=("$csv")
    done < <(find "$input_path" -maxdepth 1 -type f -iname "*.csv" -print0)

  else
    echo "Erro: entrada não encontrada: $input_path"
    exit 1
  fi
}

process_csv() {
  local csv_path="$1"
  local is_first="$2"

  local file_name
  file_name="$(basename "$csv_path")"

  echo ">> [CSV2GPKG] Processando: $file_name"

  local mode_flags=()

  if [ "$is_first" = true ]; then
    mode_flags=(-overwrite)
    echo ">> [CSV2GPKG] Criando GeoPackage: $OUTPUT_GPKG"
  else
    mode_flags=(-update -append -addfields)
    echo ">> [CSV2GPKG] Anexando na camada: $LAYER_NAME"
  fi

  ogr2ogr \
    -f GPKG "$OUTPUT_GPKG" \
    "$csv_path" \
    -oo X_POSSIBLE_NAMES="$X_COL" \
    -oo Y_POSSIBLE_NAMES="$Y_COL" \
    -oo AUTODETECT_TYPE=YES \
    -oo KEEP_GEOM_COLUMNS=YES \
    -a_srs "EPSG:${SRID}" \
    -nln "$LAYER_NAME" \
    -nlt POINT \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco SPATIAL_INDEX=YES \
    -skipfailures \
    "${mode_flags[@]}"
}

main() {
  echo ">> [CSV2GPKG] Entrada: $INPUT"
  echo ">> [CSV2GPKG] Saída: $OUTPUT_GPKG"
  echo ">> [CSV2GPKG] Coluna X: $X_COL"
  echo ">> [CSV2GPKG] Coluna Y: $Y_COL"
  echo ">> [CSV2GPKG] SRID: EPSG:$SRID"
  echo ">> [CSV2GPKG] Camada: $LAYER_NAME"

  collect_csv_files "$INPUT"

  if [ "${#CSV_FILES[@]}" -eq 0 ]; then
    echo ">> [CSV2GPKG] Nenhum arquivo CSV encontrado."
    exit 0
  fi

  rm -f "$OUTPUT_GPKG"

  local first_file=true

  for csv in "${CSV_FILES[@]}"; do
    process_csv "$csv" "$first_file"
    first_file=false
  done

  echo
  echo ">> [CSV2GPKG] Conversão concluída."
  echo ">> [CSV2GPKG] GeoPackage gerado: $OUTPUT_GPKG"

  echo
  echo ">> [CSV2GPKG] Camadas geradas:"
  ogrinfo -ro "$OUTPUT_GPKG" | grep -E '^[[:space:]]*[0-9]+: ' || true
}

main "$@"
