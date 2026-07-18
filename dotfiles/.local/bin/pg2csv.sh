#!/usr/bin/env bash
set -euo pipefail

# Uso:
#   ./pg2csv.sh "QUERY SQL" [saida.csv]
#
# Exemplos:
#   ./pg2csv.sh "SELECT * FROM ingest_temp.linhas" linhas.csv
#   ./pg2csv.sh "SELECT id, nome, ST_AsText(geom) AS wkt FROM ingest_temp.pontos" pontos.csv

usage() {
  echo "Uso:"
  echo "  $0 \"QUERY SQL\" [saida.csv]"
  echo
  echo "Exemplos:"
  echo "  $0 \"SELECT * FROM ingest_temp.linhas\" linhas.csv"
  echo "  $0 \"SELECT id, nome, ST_AsText(geom) AS wkt FROM ingest_temp.pontos\" pontos.csv"
  exit 1
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
fi

QUERY="$1"
OUTPUT_CSV="${2:-export_pg.csv}"

# --- Variáveis de conexão ---
DB_HOST="${POSTGRES_HOST:-127.0.0.1}"
DB_PORT="${POSTGRES_PORT:-5435}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-postgis}"
export PGPASSWORD="${POSTGRES_PASSWORD:-secret}"

command -v psql >/dev/null 2>&1 || {
  echo "ERR: psql não encontrado. Instale o cliente PostgreSQL."
  exit 1
}

# Validação simples para evitar comandos destrutivos
QUERY_TRIMMED="$(echo "$QUERY" | sed 's/^[[:space:]]*//')"

if ! echo "$QUERY_TRIMMED" | grep -Eiq '^(select|with)[[:space:]]'; then
  echo "ERR: por segurança, a query deve começar com SELECT ou WITH."
  exit 1
fi

echo ">> [PG2CSV] Banco: ${DB_NAME}"
echo ">> [PG2CSV] Host: ${DB_HOST}:${DB_PORT}"
echo ">> [PG2CSV] Usuário: ${DB_USER}"
echo ">> [PG2CSV] Saída: ${OUTPUT_CSV}"

rm -f "$OUTPUT_CSV"

psql \
  "host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER}" \
  -v ON_ERROR_STOP=1 \
  -c "\copy (${QUERY}) TO '${OUTPUT_CSV}' WITH CSV HEADER ENCODING 'UTF8';"

echo ">> [PG2CSV] Sucesso!"
echo ">> [PG2CSV] CSV gerado: ${OUTPUT_CSV}"
