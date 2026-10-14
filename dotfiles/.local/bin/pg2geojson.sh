#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
USO
  $0 [<CONN>] [opcoes]

CONEXAO
  Se <CONN> nao for informada, usa DATABASE_URL, POSTGIS_URL ou PG_URL.

SELECAO
  --schema <schema>           Exporta as tabelas espaciais do schema
  --table <schema.tabela>     Exporta uma tabela; pode ser repetido
  --sql <SQL|@arquivo.sql>    Exporta o resultado de uma consulta
  --where <expressao>         Filtro para exportacao direta de tabela
  --bbox xmin ymin xmax ymax  Filtro espacial

SISTEMA DE REFERENCIA
  --srid <EPSG>               SRID de saida; padrao: 4326
  --source-srid <EPSG>        SRID de entrada para SQL complexo
  --src-srid <EPSG>           Alias de --source-srid

O driver PostgreSQL detecta automaticamente o SRS de tabelas e consultas que
preservam os metadados da geometria. Para SQL, o script tambem tenta detectar o
SRS pelo resultado do ogrinfo e, em consultas simples, pela tabela do FROM.
Use --source-srid quando uma consulta complexa produzir geometria sem SRS.

EXEMPLOS
  $0 --table stage.sabesp_rede_agua
  $0 --table stage.sabesp_rede_agua --srid 31983
  $0 --sql @query_linestring_raw_agua.sql
  $0 --sql @query_complexa.sql --source-srid 31983
  $0 --sql "SELECT * FROM stage.sabesp_rede_agua" --srid 4674
USAGE
}

die() {
  echo "ERRO: $*" >&2
  exit 1
}

is_epsg() {
  [[ "$1" =~ ^[0-9]+$ ]] && ((10#$1 > 0))
}

sql_literal() {
  printf "%s" "$1" | sed "s/'/''/g"
}

# Retorna um unico SRID valido da geometry_columns, se existir.
table_srid() {
  local table="$1" schema name schema_q name_q
  if [[ "$table" == *.* ]]; then
    schema="${table%%.*}"
    name="${table#*.}"
  else
    schema="public"
    name="$table"
  fi
  schema="${schema//\"/}"
  name="${name//\"/}"
  schema_q=$(sql_literal "$schema")
  name_q=$(sql_literal "$name")
  psql "$PSQL_CONN" -X -q -A -t -c "
    SELECT CASE WHEN count(DISTINCT srid) = 1 THEN min(srid)::text ELSE '' END
    FROM geometry_columns
    WHERE f_table_schema='${schema_q}'
      AND f_table_name='${name_q}'
      AND srid > 0;
  " | head -n 1 | tr -d '[:space:]'
}

# Le o texto apenas para deteccao. O argumento original continua sendo passado
# ao GDAL, inclusive no formato @arquivo.sql.
sql_text_for_detection() {
  if [[ "$SQL" == @* ]]; then
    local file="${SQL#@}"
    [[ -r "$file" ]] || die "Arquivo SQL nao encontrado ou sem leitura: $file"
    cat "$file"
  else
    printf "%s" "$SQL"
  fi
}

# Tenta obter EPSG diretamente dos metadados apresentados pelo ogrinfo.
detect_srid_with_ogrinfo() {
  local info srid
  info=$(ogrinfo "$CONN" -ro -so -q -sql "$SQL" -dialect PostgreSQL 2>/dev/null || true)
  srid=$(printf "%s\n" "$info" | sed -nE \
    -e 's/.*AUTHORITY\["EPSG","([0-9]+)"\].*/\1/p' \
    -e 's/.*ID\["EPSG",([0-9]+)\].*/\1/p' | tail -n 1)
  [[ -n "$srid" ]] && printf "%s" "$srid"
}

# Fallback para SELECT simples com exatamente uma tabela no FROM e sem JOIN,
# UNION, INTERSECT ou EXCEPT. Nesses casos consulta geometry_columns.
detect_srid_from_simple_sql() {
  local text normalized table
  text=$(sql_text_for_detection)
  normalized=$(printf "%s" "$text" | tr '\n\r\t' '   ')

  if printf "%s" "$normalized" | grep -Eiq '\b(join|union|intersect|except)\b'; then
    return 0
  fi

  table=$(printf "%s" "$normalized" | sed -nE \
    's/.*[Ff][Rr][Oo][Mm][[:space:]]+(("[^"]+"|[A-Za-z_][A-Za-z0-9_$]*)(\.("[^"]+"|[A-Za-z_][A-Za-z0-9_$]*))?).*/\1/p' | head -n 1)

  [[ -n "$table" ]] && table_srid "$table"
}

resolve_sql_source_srid() {
  local srid=""
  if [[ -n "$SOURCE_SRID" ]]; then
    printf "%s" "$SOURCE_SRID"
    return 0
  fi

  srid=$(detect_srid_with_ogrinfo)
  if [[ -z "$srid" ]]; then
    srid=$(detect_srid_from_simple_sql)
  fi
  printf "%s" "$srid"
}

###############################################################################
# AJUDA (nao exige conexao)
###############################################################################
for arg in "$@"; do
  if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
    usage
    exit 0
  fi
done

###############################################################################
# CONEXAO
###############################################################################
if [[ $# -eq 0 || "$1" == --* ]]; then
  INPUT_CONN="${DATABASE_URL:-${POSTGIS_URL:-${PG_URL:-}}}"
  [[ -n "${INPUT_CONN:-}" ]] || die "Nenhuma conexao informada. Defina DATABASE_URL ou passe a conexao."
else
  INPUT_CONN="$1"
  shift
fi

if [[ "$INPUT_CONN" =~ ^postgresql:// ]] || [[ "$INPUT_CONN" =~ ^postgres:// ]]; then
  PSQL_CONN="$INPUT_CONN"
  URI="${INPUT_CONN#postgresql://}"
  URI="${URI#postgres://}"
  USERPASS="${URI%%@*}"
  HOSTDB="${URI#*@}"
  USER="${USERPASS%%:*}"
  PASS="${USERPASS#*:}"
  HOSTPORT="${HOSTDB%%/*}"
  DBNAME="${HOSTDB#*/}"
  DBNAME="${DBNAME%%\?*}"
  HOST="${HOSTPORT%%:*}"
  PORT="${HOSTPORT#*:}"
  [[ "$PORT" != "$HOSTPORT" ]] || PORT=5432
  CONN="PG:host=${HOST} port=${PORT} dbname=${DBNAME} user=${USER} password=${PASS}"
elif [[ "$INPUT_CONN" =~ ^PG: ]]; then
  CONN="$INPUT_CONN"
  PSQL_CONN="${INPUT_CONN#PG:}"
  DBNAME=$(printf "%s" "$CONN" | sed -n 's/.*dbname=\([^ ]*\).*/\1/p')
else
  die "Formato de conexao nao suportado."
fi
DBNAME="${DBNAME:-export}"

###############################################################################
# PARAMETROS
###############################################################################
SCHEMA=""
SQL=""
WHERE=""
CLIP_TABLE=""
CLIP_WHERE=""
CUT=false
XMIN=""
YMIN=""
XMAX=""
YMAX=""
TARGET_SRID="${TARGET_SRID:-4326}"
SOURCE_SRID="${SOURCE_SRID:-}"
TABLES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  --schema)
    [[ $# -ge 2 ]] || die "--schema exige um valor"
    SCHEMA="$2"
    shift 2
    ;;
  --table)
    [[ $# -ge 2 ]] || die "--table exige um valor"
    TABLES+=("$2")
    shift 2
    ;;
  --sql)
    [[ $# -ge 2 ]] || die "--sql exige um valor"
    SQL="$2"
    shift 2
    ;;
  --where)
    [[ $# -ge 2 ]] || die "--where exige um valor"
    WHERE="$2"
    shift 2
    ;;
  --bbox)
    [[ $# -ge 5 ]] || die "--bbox exige quatro valores"
    XMIN="$2"
    YMIN="$3"
    XMAX="$4"
    YMAX="$5"
    shift 5
    ;;
  --clip-table)
    [[ $# -ge 2 ]] || die "--clip-table exige um valor"
    CLIP_TABLE="$2"
    shift 2
    ;;
  --clip-where)
    [[ $# -ge 2 ]] || die "--clip-where exige um valor"
    CLIP_WHERE="$2"
    shift 2
    ;;
  --cut)
    CUT=true
    shift
    ;;
  --srid)
    [[ $# -ge 2 ]] || die "--srid exige um valor"
    TARGET_SRID="$2"
    shift 2
    ;;
  --source-srid | --src-srid)
    [[ $# -ge 2 ]] || die "$1 exige um valor"
    SOURCE_SRID="$2"
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *) die "Parametro invalido: $1" ;;
  esac
done

is_epsg "$TARGET_SRID" || die "SRID de saida invalido: $TARGET_SRID"
[[ -z "$SOURCE_SRID" ]] || is_epsg "$SOURCE_SRID" || die "SRID de entrada invalido: $SOURCE_SRID"

TARGET_ARGS=(-t_srs "EPSG:${TARGET_SRID}")

###############################################################################
# SQL LIVRE
###############################################################################
if [[ -n "$SQL" ]]; then
  OUTFILE="${DBNAME}_sql.geojson"
  DETECTED_SOURCE_SRID=$(resolve_sql_source_srid)
  SOURCE_ARGS=()

  if [[ -n "$DETECTED_SOURCE_SRID" ]]; then
    SOURCE_ARGS=(-s_srs "EPSG:${DETECTED_SOURCE_SRID}")
    echo "SRID de entrada: EPSG:${DETECTED_SOURCE_SRID}"
  else
    die "Nao foi possivel detectar o SRID da consulta. Para SQL complexo, informe --source-srid <EPSG>."
  fi

  echo "SRID de saida: EPSG:${TARGET_SRID}"
  ogr2ogr -f GeoJSON "$OUTFILE" "$CONN" \
    -sql "$SQL" -dialect PostgreSQL \
    "${SOURCE_ARGS[@]}" "${TARGET_ARGS[@]}"
  echo "Arquivo criado: $OUTFILE"
  exit 0
fi

###############################################################################
# BANCO INTEIRO / SCHEMA
###############################################################################
if [[ -z "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then
  echo "Obtendo todas as tabelas espaciais..."
  mapfile -t TABLES < <(psql "$PSQL_CONN" -X -q -A -t -c "
    SELECT f_table_schema || '.' || f_table_name
    FROM geometry_columns ORDER BY 1;")
fi

if [[ -n "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then
  SCHEMA_Q=$(sql_literal "$SCHEMA")
  mapfile -t TABLES < <(psql "$PSQL_CONN" -X -q -A -t -c "
    SELECT f_table_schema || '.' || f_table_name
    FROM geometry_columns
    WHERE f_table_schema='${SCHEMA_Q}' ORDER BY 1;")
fi

[[ ${#TABLES[@]} -gt 0 ]] || die "Nenhuma tabela encontrada."

###############################################################################
# EXPORTACAO
###############################################################################
OUTDIR="${DBNAME}_geojson"
rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

for TABLE in "${TABLES[@]}"; do
  echo "Exportando ${TABLE} para EPSG:${TARGET_SRID}"
  LAYER_NAME=$(printf "%s" "$TABLE" | tr '.' '_')
  OUTFILE="${OUTDIR}/${LAYER_NAME}.geojson"

  if [[ -n "$CLIP_TABLE" ]]; then
    TABLE_SCHEMA="${TABLE%%.*}"
    TABLE_NAME="${TABLE##*.}"
    CLIP_SCHEMA="${CLIP_TABLE%%.*}"
    CLIP_NAME="${CLIP_TABLE##*.}"

    GEOM_COL=$(psql "$PSQL_CONN" -X -q -A -t -c "
      SELECT f_geometry_column FROM geometry_columns
      WHERE f_table_schema='$(sql_literal "$TABLE_SCHEMA")'
        AND f_table_name='$(sql_literal "$TABLE_NAME")' LIMIT 1;")
    CLIP_GEOM=$(psql "$PSQL_CONN" -X -q -A -t -c "
      SELECT f_geometry_column FROM geometry_columns
      WHERE f_table_schema='$(sql_literal "$CLIP_SCHEMA")'
        AND f_table_name='$(sql_literal "$CLIP_NAME")' LIMIT 1;")

    [[ -n "$GEOM_COL" ]] || die "Geometria nao encontrada para $TABLE"
    [[ -n "$CLIP_GEOM" ]] || die "Geometria nao encontrada para $CLIP_TABLE"

    if $CUT; then
      SQL_EXPORT="SELECT a.*, ST_Intersection(a.${GEOM_COL}, b.${CLIP_GEOM}) AS ${GEOM_COL}
        FROM ${TABLE} a JOIN ${CLIP_TABLE} b
        ON ST_Intersects(a.${GEOM_COL}, b.${CLIP_GEOM})"
      [[ -n "$CLIP_WHERE" ]] && SQL_EXPORT+=" WHERE ${CLIP_WHERE}"
    else
      SQL_EXPORT="SELECT a.* FROM ${TABLE} a WHERE EXISTS (
        SELECT 1 FROM ${CLIP_TABLE} b WHERE "
      [[ -n "$CLIP_WHERE" ]] && SQL_EXPORT+="(${CLIP_WHERE}) AND "
      SQL_EXPORT+="ST_Intersects(a.${GEOM_COL}, b.${CLIP_GEOM}))"
    fi

    CLIP_SOURCE_SRID="${SOURCE_SRID:-$(table_srid "$TABLE")}"
    [[ -n "$CLIP_SOURCE_SRID" ]] || die "Nao foi possivel detectar o SRID de $TABLE. Use --source-srid <EPSG>."

    ogr2ogr -f GeoJSON "$OUTFILE" "$CONN" \
      -sql "$SQL_EXPORT" -dialect PostgreSQL \
      -s_srs "EPSG:${CLIP_SOURCE_SRID}" "${TARGET_ARGS[@]}"
  else
    TABLE_ARGS=()
    [[ -n "$WHERE" ]] && TABLE_ARGS+=(-where "$WHERE")
    [[ -n "$XMIN" ]] && TABLE_ARGS+=(-spat "$XMIN" "$YMIN" "$XMAX" "$YMAX")

    # Exportacao direta: o driver PostgreSQL fornece o SRS da camada.
    # --source-srid pode sobrescreve-lo quando solicitado.
    SOURCE_ARGS=()
    [[ -n "$SOURCE_SRID" ]] && SOURCE_ARGS=(-s_srs "EPSG:${SOURCE_SRID}")

    ogr2ogr -f GeoJSON "$OUTFILE" "$CONN" "$TABLE" \
      "${TABLE_ARGS[@]}" "${SOURCE_ARGS[@]}" "${TARGET_ARGS[@]}"
  fi
done

echo
echo "Exportacao concluida."
echo "Diretorio: ${OUTDIR}"
