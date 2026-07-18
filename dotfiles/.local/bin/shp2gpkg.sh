#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./shp2gpkg.sh <arquivo.shp|diretorio> [saida.gpkg]
#
# Exemplos:
#   ./shp2gpkg.sh arquivo.shp
#   ./shp2gpkg.sh arquivo.shp resultado.gpkg
#   ./shp2gpkg.sh ./shapefiles
#   ./shp2gpkg.sh ./shapefiles consolidado.gpkg

# --- Parâmetros ---
INPUT="${1:-.}"
OUTPUT_GPKG="${2:-file_name.gpkg}"

# --- Configurações dos Dados ---
NEW_TABLE="output_name_layer"
SRID=31982

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.shp|diretorio> [saida.gpkg]"
  exit 1
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
fi

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "ERR: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

declare -a SHP_FILES

collect_shapefiles() {
  local input_path="$1"

  if [ -f "$input_path" ]; then
    case "${input_path,,}" in
      *.shp)
        SHP_FILES+=("$input_path")
        ;;
      *)
        echo "ERR: O arquivo informado não é um Shapefile (.shp)."
        exit 1
        ;;
    esac

  elif [ -d "$input_path" ]; then
    while IFS= read -r -d '' shp; do
      SHP_FILES+=("$shp")
    done < <(find "$input_path" -maxdepth 1 -type f -iname "*.shp" -print0)

  else
    echo "ERR: Entrada não encontrada: $input_path"
    exit 1
  fi
}

process_shapefile() {
  local shp_path="$1"
  local is_first="$2"

  local layer_name
  layer_name="$(basename "$shp_path" .shp)"

  echo ">> [ETL] Processando arquivo: ${layer_name} (${shp_path})..."

  local mode_flags=()

  if [ "$is_first" = true ]; then
    mode_flags=(-overwrite)
    echo ">> [ETL] Criando novo GeoPackage: ${OUTPUT_GPKG}"
  else
    mode_flags=(-update -append)
    echo ">> [ETL] Anexando dados no GeoPackage existente..."
  fi

  ogr2ogr \
    -f GPKG "${OUTPUT_GPKG}" \
    "${shp_path}" \
    -sql "
      SELECT
        column_name
      FROM \"${layer_name}\"
    " \
    -nln "${NEW_TABLE}" \
    -t_srs "EPSG:${SRID}" \
    -nlt PROMOTE_TO_MULTI \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco SPATIAL_INDEX=YES \
    "${mode_flags[@]}"
}

main() {
  collect_shapefiles "$INPUT"

  if [ "${#SHP_FILES[@]}" -eq 0 ]; then
    echo ">> [ETL] Nenhum arquivo .shp foi encontrado."
    exit 0
  fi

  echo ">> [ETL] Total de Shapefiles encontrados: ${#SHP_FILES[@]}"

  local first_file=true

  for shp in "${SHP_FILES[@]}"; do
    process_shapefile "$shp" "$first_file"
    first_file=false
  done

  echo ">> [ETL] Sucesso total!"
  echo ">> [ETL] GeoPackage gerado: ${OUTPUT_GPKG}"
  echo ">> [ETL] Camada consolidada: ${NEW_TABLE}"
}

main
