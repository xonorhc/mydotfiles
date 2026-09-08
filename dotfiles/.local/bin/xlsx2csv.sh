#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Uso: $0 arquivo.xlsx"
  exit 1
fi

XLSX_FILE="$1"

if [ ! -f "$XLSX_FILE" ]; then
  echo "Arquivo não encontrado: $XLSX_FILE"
  exit 1
fi

CSV_FILE="${XLSX_FILE%.xlsx}.csv"

xlsx2csv "$XLSX_FILE" "$CSV_FILE"

echo "Arquivo gerado: $CSV_FILE"
