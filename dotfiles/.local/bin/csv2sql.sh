#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Uso:"
  echo "  $0 --input arquivo.csv --output saida.sql --x-col LONGITUDE --y-col LATITUDE --source-srid 4326 --target-srid 31982 [opções]"
  echo
  echo "Opções:"
  echo "  --input          CSV de entrada"
  echo "  --output         SQL de saída"
  echo "  --x-col          Coluna X, normalmente Longitude"
  echo "  --y-col          Coluna Y, normalmente Latitude"
  echo "  --source-srid    SRID das coordenadas originais"
  echo "  --target-srid    SRID final no SQL"
  echo "  --schema         Schema PostGIS. Padrão: ingest"
  echo "  --table          Nome da tabela. Padrão: pontos_csv"
  echo "  --delimiter      Delimitador do CSV. Padrão: ;"
  echo
  echo "Exemplo:"
  echo "  $0 --input cidades.csv --output cidades.sql --x-col LONGITUDE --y-col LATITUDE --source-srid 4326 --target-srid 31982 --schema ingest --table cidades"
  exit 1
}

INPUT_CSV=""
OUTPUT_SQL=""
X_COL=""
Y_COL=""
SOURCE_SRID=""
TARGET_SRID=""
SCHEMA="ingest"
TABLE_NAME="pontos_csv"
DELIMITER=";"

while [ $# -gt 0 ]; do
  case "$1" in
    --input)
      INPUT_CSV="$2"
      shift 2
      ;;
    --output)
      OUTPUT_SQL="$2"
      shift 2
      ;;
    --x-col)
      X_COL="$2"
      shift 2
      ;;
    --y-col)
      Y_COL="$2"
      shift 2
      ;;
    --source-srid)
      SOURCE_SRID="$2"
      shift 2
      ;;
    --target-srid)
      TARGET_SRID="$2"
      shift 2
      ;;
    --schema)
      SCHEMA="$2"
      shift 2
      ;;
    --table)
      TABLE_NAME="$2"
      shift 2
      ;;
    --delimiter)
      DELIMITER="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Parâmetro inválido: $1"
      usage
      ;;
  esac
done

if [ -z "$INPUT_CSV" ] || [ -z "$OUTPUT_SQL" ] || [ -z "$X_COL" ] || [ -z "$Y_COL" ] || [ -z "$SOURCE_SRID" ] || [ -z "$TARGET_SRID" ]; then
  usage
fi

if [ ! -f "$INPUT_CSV" ]; then
  echo "Erro: arquivo CSV não encontrado: $INPUT_CSV"
  exit 1
fi

command -v ogr2ogr >/dev/null 2>&1 || {
  echo "Erro: ogr2ogr não encontrado. Instale o GDAL."
  exit 1
}

command -v python3 >/dev/null 2>&1 || {
  echo "Erro: python3 não encontrado."
  exit 1
}

TMP_DIR="$(mktemp -d)"
CLEAN_CSV="${TMP_DIR}/coord_decimal.csv"
VRT_FILE="${TMP_DIR}/temp_file.vrt"

trap 'rm -rf "$TMP_DIR"' EXIT

echo ">> [CSV2SQL] Entrada: $INPUT_CSV"
echo ">> [CSV2SQL] Saída SQL: $OUTPUT_SQL"
echo ">> [CSV2SQL] Coluna X: $X_COL"
echo ">> [CSV2SQL] Coluna Y: $Y_COL"
echo ">> [CSV2SQL] SRID origem: EPSG:$SOURCE_SRID"
echo ">> [CSV2SQL] SRID destino: EPSG:$TARGET_SRID"
echo ">> [CSV2SQL] Tabela: ${SCHEMA}.${TABLE_NAME}"
echo ">> [CSV2SQL] Delimitador: $DELIMITER"

python3 - "$INPUT_CSV" "$CLEAN_CSV" "$X_COL" "$Y_COL" "$DELIMITER" <<'PY'
import csv
import re
import sys

input_csv = sys.argv[1]
output_csv = sys.argv[2]
x_col = sys.argv[3]
y_col = sys.argv[4]
delimiter = sys.argv[5]

def dms_to_decimal(value):
    if value is None:
        return None

    original = str(value).strip()

    if original == "":
        return None

    text = original.replace(",", ".").strip()

    # Caso já seja decimal simples
    try:
        return float(text)
    except ValueError:
        pass

    # Detecta hemisfério
    hemi = ""
    m = re.search(r"[NnSsEeWwOoLl]", text)
    if m:
        hemi = m.group(0).upper()

    # Extrai números
    nums = re.findall(r"[-+]?\d+(?:\.\d+)?", text)

    if not nums:
        return None

    deg = float(nums[0])
    minutes = float(nums[1]) if len(nums) > 1 else 0.0
    seconds = float(nums[2]) if len(nums) > 2 else 0.0

    sign = -1 if deg < 0 else 1
    dec = abs(deg) + minutes / 60.0 + seconds / 3600.0

    if hemi in ("S", "W", "O"):
        sign = -1

    return sign * dec

with open(input_csv, "r", encoding="utf-8-sig", newline="") as f:
    reader = csv.DictReader(f, delimiter=delimiter)

    if reader.fieldnames is None:
        raise SystemExit("Erro: CSV sem cabeçalho.")

    fields = reader.fieldnames

    if x_col not in fields:
        raise SystemExit(f"Erro: coluna X não encontrada: {x_col}")

    if y_col not in fields:
        raise SystemExit(f"Erro: coluna Y não encontrada: {y_col}")

    output_fields = list(fields)

    if "X_DECIMAL" not in output_fields:
        output_fields.append("X_DECIMAL")

    if "Y_DECIMAL" not in output_fields:
        output_fields.append("Y_DECIMAL")

    with open(output_csv, "w", encoding="utf-8", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=output_fields)
        writer.writeheader()

        total = 0
        validos = 0

        for row in reader:
            total += 1

            x = dms_to_decimal(row.get(x_col))
            y = dms_to_decimal(row.get(y_col))

            if x is None or y is None:
                continue

            row["X_DECIMAL"] = f"{x:.10f}"
            row["Y_DECIMAL"] = f"{y:.10f}"

            writer.writerow(row)
            validos += 1

        print(f">> [CSV2SQL] Registros lidos: {total}")
        print(f">> [CSV2SQL] Registros válidos com coordenadas: {validos}")

        if validos == 0:
            raise SystemExit("Erro: nenhum registro válido com coordenadas foi encontrado.")
PY

cat > "$VRT_FILE" <<EOF
<OGRVRTDataSource>
  <OGRVRTLayer name="csv_decimal">
    <SrcDataSource relativeToVRT="0">${CLEAN_CSV}</SrcDataSource>
    <GeometryType>wkbPoint</GeometryType>
    <LayerSRS>EPSG:${SOURCE_SRID}</LayerSRS>
    <GeometryField encoding="PointFromColumns" x="X_DECIMAL" y="Y_DECIMAL"/>
  </OGRVRTLayer>
</OGRVRTDataSource>
EOF

rm -f "$OUTPUT_SQL"

ogr2ogr \
  -f PGDump "$OUTPUT_SQL" \
  "$VRT_FILE" \
  -s_srs "EPSG:${SOURCE_SRID}" \
  -t_srs "EPSG:${TARGET_SRID}" \
  -nln "${SCHEMA}.${TABLE_NAME}" \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco SPATIAL_INDEX=GIST

sed -i \
  "s/CREATE TABLE \"${SCHEMA}\"\.\"${TABLE_NAME}\"/CREATE TABLE IF NOT EXISTS \"${SCHEMA}\"\.\"${TABLE_NAME}\"/g" \
  "$OUTPUT_SQL"

echo ">> [CSV2SQL] Processo concluído com sucesso."
echo ">> [CSV2SQL] Arquivo SQL gerado: $OUTPUT_SQL"
