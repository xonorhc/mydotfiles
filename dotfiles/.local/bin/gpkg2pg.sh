#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./gpkg2postgres.sh <arquivo.gpkg> <camada> [schema] [tabela]
#
# Exemplos:
#   ./gpkg2postgres.sh dados.gpkg linhas
#   ./gpkg2postgres.sh dados.gpkg linhas ingest_temp trechos
#   ./gpkg2postgres.sh dados.gpkg pontos ingest pontos_coletados

usage() {
  echo "Uso:"
  echo "  $0 <arquivo.gpkg> <camada> [schema] [tabela]"
  echo
  echo "Exemplos:"
  echo "  $0 dados.gpkg linhas"
  echo "  $0 dados.gpkg linhas ingest_temp trechos"
  echo "  $0 dados.gpkg pontos ingest pontos_coletados"
  exit 1
}

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
  usage
fi

# --- Variáveis de conexão ---
DB_HOST="${POSTGRES_HOST:-127.0.0.1}"
DB_PORT="${POSTGRES_PORT:-5435}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-postgis}"
export PGPASSWORD="${POSTGRES_PASSWORD:-secret}"

PG_CONN_STR="host=${DB_HOST} user=${DB_USER} dbname=${DB_NAME} port=${DB_PORT}"

# --- Parâmetros ---
INPUT_GPKG="$1"
SOURCE_LAYER="$2"
SCHEMA="${3:-ingest_temp}"
TARGET_TABLE="${4:-$SOURCE_LAYER}"

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "ERR: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

command -v ogrinfo >/dev/null 2>&1 || {
  echo "ERR: ogrinfo não encontrado. Instale o GDAL."
  exit 1
}

command -v psql >/dev/null 2>&1 || {
  echo "ERR: psql não encontrado. Instale o cliente PostgreSQL."
  exit 1
}

if [ ! -f "$INPUT_GPKG" ]; then
  echo "ERR: GeoPackage não encontrado: $INPUT_GPKG"
  exit 1
fi

validate_identifier() {
  local value="$1"
  local label="$2"

  if [[ ! "$value" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "ERR: ${label} inválido: ${value}"
    echo "Use apenas letras, números e underscore, iniciando por letra ou underscore."
    exit 1
  fi
}

validate_identifier "$SCHEMA" "schema"
validate_identifier "$TARGET_TABLE" "tabela"

echo ">> [GPKG2PG] Entrada: $INPUT_GPKG"
echo ">> [GPKG2PG] Camada origem: $SOURCE_LAYER"
echo ">> [GPKG2PG] Banco: $DB_NAME"
echo ">> [GPKG2PG] Host: $DB_HOST:$DB_PORT"
echo ">> [GPKG2PG] Usuário: $DB_USER"
echo ">> [GPKG2PG] Destino: ${SCHEMA}.${TARGET_TABLE}"

# Verifica se a camada existe no GeoPackage
if ! ogrinfo -ro "$INPUT_GPKG" "$SOURCE_LAYER" >/dev/null 2>&1; then
  echo "ERR: camada não encontrada no GeoPackage: $SOURCE_LAYER"
  echo
  echo "Camadas disponíveis:"
  ogrinfo -ro "$INPUT_GPKG" | grep -E '^[[:space:]]*[0-9]+: ' || true
  exit 1
fi

# Cria o schema se não existir
psql "host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER}" \
  -v ON_ERROR_STOP=1 \
  -c "CREATE SCHEMA IF NOT EXISTS \"${SCHEMA}\";"

# Envia a camada para o PostGIS
ogr2ogr \
  -f PostgreSQL PG:"${PG_CONN_STR}" \
  "$INPUT_GPKG" \
  "$SOURCE_LAYER" \
  -nln "${SCHEMA}.${TARGET_TABLE}" \
  -overwrite \
  -nlt PROMOTE_TO_MULTI \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco SPATIAL_INDEX=GIST \
  -skipfailures

echo
echo ">> [GPKG2PG] Sucesso!"
echo ">> [GPKG2PG] Camada enviada para: ${SCHEMA}.${TARGET_TABLE}"
