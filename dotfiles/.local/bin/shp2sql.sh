#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./shp2sql.sh <arquivo.shp|diretorio> [saida.sql] [schema] [tabela] [srid]
#
# Exemplos:
#   ./shp2sql.sh arquivo.shp
#   ./shp2sql.sh arquivo.shp saida.sql
#   ./shp2sql.sh ./shapefiles consolidado.sql ingest table_name 31982

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.shp|diretorio> [saida.sql] [schema] [tabela] [srid]"
  echo
  echo "Exemplos:"
  echo "  $0 arquivo.shp"
  echo "  $0 arquivo.shp saida.sql"
  echo "  $0 ./shapefiles consolidado.sql ingest table_name 31982"
  exit 1
}

if [ $# -lt 1 ] || [ $# -gt 5 ]; then
  usage
fi

# --- Parâmetros ---
INPUT="$1"
OUTPUT_SQL="${2:-sabesp_ligacao.sql}"
SCHEMA="${3:-ingest}"
NEW_TABLE="${4:-table_name}"
SRID="${5:-31982}"

tmp_gpkg=""

trap 'if [ -n "${tmp_gpkg:-}" ] && [ -f "${tmp_gpkg}" ]; then rm -f "${tmp_gpkg}"; fi' EXIT

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

  echo ">> [Script] Consolidando Shapefile: ${layer_name}"

  local mode_flags=()

  if [ "$is_first" = true ]; then
    echo ">> [Script] Criando GeoPackage temporário..."
  else
    mode_flags=(-update -append -addfields)
    echo ">> [Script] Anexando dados ao GeoPackage temporário..."
  fi

  ogr2ogr \
    -f GPKG "${tmp_gpkg}" \
    "${shp_path}" \
    -nln "${NEW_TABLE}" \
    -t_srs "EPSG:${SRID}" \
    -nlt PROMOTE_TO_MULTI \
    -skipfailures \
    "${mode_flags[@]}"
}

main() {
  echo ">> [Script] Entrada: ${INPUT}"
  echo ">> [Script] SQL de saída: ${OUTPUT_SQL}"
  echo ">> [Script] Schema: ${SCHEMA}"
  echo ">> [Script] Tabela: ${NEW_TABLE}"
  echo ">> [Script] SRID: ${SRID}"

  collect_shapefiles "$INPUT"

  if [ "${#SHP_FILES[@]}" -eq 0 ]; then
    echo ">> [Script] Nenhum arquivo .shp foi encontrado."
    exit 0
  fi

  echo ">> [Script] Total de Shapefiles encontrados: ${#SHP_FILES[@]}"

  tmp_gpkg="$(mktemp --suffix=.gpkg)"
  rm -f "$tmp_gpkg"

  local first_file=true

  for shp in "${SHP_FILES[@]}"; do
    process_shapefile "$shp" "$first_file"
    first_file=false
  done

  echo ">> [Script] Gerando SQL consolidado: ${OUTPUT_SQL}"

  rm -f "$OUTPUT_SQL"

  ogr2ogr \
    -f PGDump "${OUTPUT_SQL}" \
    "${tmp_gpkg}" \
    "${NEW_TABLE}" \
    -nln "${SCHEMA}.${NEW_TABLE}" \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco SPATIAL_INDEX=GIST

  sed -i \
    "s/CREATE TABLE \"${SCHEMA}\"\.\"${NEW_TABLE}\"/CREATE TABLE IF NOT EXISTS \"${SCHEMA}\"\.\"${NEW_TABLE}\"/g" \
    "${OUTPUT_SQL}"

  echo ">> [Script] Sucesso!"
  echo ">> [Script] SQL gerado: ${OUTPUT_SQL}"
  echo ">> [Script] Tabela destino: ${SCHEMA}.${NEW_TABLE}"
  echo ">> [Script] SRID: EPSG:${SRID}"
}

main "$@"
