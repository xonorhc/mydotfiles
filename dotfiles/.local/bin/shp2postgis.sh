#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./shp2postgres.sh <arquivo.shp|diretorio> [schema] [tabela] [srid]
#
# Exemplos:
#   ./shp2postgres.sh arquivo.shp
#   ./shp2postgres.sh arquivo.shp ingest table_name 31982
#   ./shp2postgres.sh ./shapefiles ingest table_name 31982

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.shp|diretorio> [schema] [tabela] [srid]"
  echo
  echo "Exemplos:"
  echo "  $0 arquivo.shp"
  echo "  $0 arquivo.shp ingest table_name 31982"
  echo "  $0 ./shapefiles ingest table_name 31982"
  exit 1
}

if [ $# -lt 1 ] || [ $# -gt 4 ]; then
  usage
fi

# --- Variáveis Globais de Conexão ---
DB_HOST="${POSTGRES_HOST:-127.0.0.1}"
DB_PORT="${POSTGRES_PORT:-5435}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-postgis}"
export PGPASSWORD="${POSTGRES_PASSWORD:-secret}"

PG_CONN_STR="host=${DB_HOST} user=${DB_USER} dbname=${DB_NAME} port=${DB_PORT}"

# --- Parâmetros ---
INPUT="$1"
SCHEMA="${2:-ingest}"
NEW_TABLE="${3:-table_name}"
SRID="${4:-31982}"

declare -a SHP_FILES

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "ERR: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

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

  echo ">> [ETL] Processando layer: ${layer_name}"
  echo ">> [ETL] Arquivo: ${shp_path}"

  local mode_flag="-append"

  if [ "$is_first" = true ]; then
    mode_flag="-overwrite"
    echo ">> [ETL] Criando/Sobrescrevendo tabela: ${SCHEMA}.${NEW_TABLE}"
  else
    echo ">> [ETL] Anexando dados em: ${SCHEMA}.${NEW_TABLE}"
  fi

  ogr2ogr \
    -f PostgreSQL PG:"${PG_CONN_STR}" \
    "${shp_path}" \
    -sql "
      SELECT
        *
      FROM \"${layer_name}\"
    " \
    -nln "${SCHEMA}.${NEW_TABLE}" \
    -t_srs "EPSG:${SRID}" \
    -nlt PROMOTE_TO_MULTI \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco SPATIAL_INDEX=GIST \
    -skipfailures \
    ${mode_flag}
}

main() {
  echo ">> [ETL] Entrada: ${INPUT}"
  echo ">> [ETL] Banco: ${DB_NAME}"
  echo ">> [ETL] Host: ${DB_HOST}:${DB_PORT}"
  echo ">> [ETL] Usuário: ${DB_USER}"
  echo ">> [ETL] Tabela destino: ${SCHEMA}.${NEW_TABLE}"
  echo ">> [ETL] SRID destino: EPSG:${SRID}"

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
  echo ">> [ETL] Dados consolidados em: ${SCHEMA}.${NEW_TABLE}"
}

main "$@"
