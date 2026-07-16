#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
Uso:
  $0 "<CONN_STRING>"
  $0 "<CONN_STRING>" <schema>
  $0 "<CONN_STRING>" <schema.tabela>

Exemplos:

Banco inteiro:
  $0 "PG:host=localhost port=5432 dbname=gis user=postgres password=123"

Esquema:
  $0 "PG:host=localhost port=5432 dbname=gis user=postgres password=123" public

Tabela:
  $0 "PG:host=localhost port=5432 dbname=gis user=postgres password=123" public.lotes
EOF
}

[[ $# -lt 1 || $# -gt 2 ]] && usage && exit 1

CONN="$1"
TARGET="${2:-}"

DBNAME=$(echo "$CONN" | sed -n 's/.*dbname=\([^ ]*\).*/\1/p')
[[ -z "$DBNAME" ]] && DBNAME="export"

if [[ -z "$TARGET" ]]; then
    OUTFILE="${DBNAME}.gpkg"

    echo "Exportando banco completo..."
    ogr2ogr \
        -f GPKG \
        "$OUTFILE" \
        "$CONN"

    echo "Arquivo gerado: $OUTFILE"
    exit 0
fi

if [[ "$TARGET" =~ ^[^.]+\.[^.]+$ ]]; then

    SCHEMA="${TARGET%%.*}"
    TABLE="${TARGET##*.}"
    OUTFILE="${SCHEMA}_${TABLE}.gpkg"

    echo "Exportando tabela ${SCHEMA}.${TABLE}..."

    ogr2ogr \
        -f GPKG \
        "$OUTFILE" \
        "$CONN" \
        "${SCHEMA}.${TABLE}"

    echo "Arquivo gerado: $OUTFILE"
    exit 0
fi

SCHEMA="$TARGET"
OUTFILE="${SCHEMA}.gpkg"

echo "Exportando esquema ${SCHEMA}..."

rm -f "$OUTFILE"

LAYERS=$(ogrinfo "$CONN" \
    | grep -E "^[0-9]+:" \
    | awk '{print $2}' \
    | grep "^${SCHEMA}\.")

if [[ -z "$LAYERS" ]]; then
    echo "Nenhuma camada encontrada no esquema ${SCHEMA}"
    exit 1
fi

FIRST=true

while read -r LAYER; do

    [[ -z "$LAYER" ]] && continue

    echo "Exportando ${LAYER}..."

    if $FIRST; then
        ogr2ogr \
            -f GPKG \
            "$OUTFILE" \
            "$CONN" \
            "$LAYER"

        FIRST=false
    else
        ogr2ogr \
            -f GPKG \
            "$OUTFILE" \
            "$CONN" \
            "$LAYER" \
            -append
    fi

done <<< "$LAYERS"

echo "Arquivo gerado: $OUTFILE"
