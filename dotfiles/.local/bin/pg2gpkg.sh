#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# UTIL
###############################################################################

die() {
  echo "ERRO: $*" >&2
  exit 1
}

usage() {
  cat <<EOF
USO

Banco inteiro:
  $0 <CONN>

Schema:
  $0 <CONN> --schema stage

Tabela:
  $0 <CONN> --table stage.sabesp_ligacao

SQL:
  $0 <CONN> --sql "SELECT * FROM stage.sabesp_ligacao"

Filtros:
  --where
  --bbox
  --clip-table
  --clip-where
  --cut

Se <CONN> não for informada:
  DATABASE_URL
  POSTGIS_URL
  PG_URL
EOF
}

layer_name() {
  printf "%s" "$1" | tr '.' '_'
}

###############################################################################
# CONEXÃO
###############################################################################

if [[ $# -eq 0 || "$1" == --* ]]; then

  INPUT_CONN="${DATABASE_URL:-${POSTGIS_URL:-${PG_URL:-}}}"

  [[ -n "${INPUT_CONN:-}" ]] || die \
    "Nenhuma conexão informada."

else

  INPUT_CONN="$1"
  shift

fi

###############################################################################
# URL PostgreSQL
###############################################################################

if [[ "$INPUT_CONN" =~ ^postgresql:// ]] ||
  [[ "$INPUT_CONN" =~ ^postgres:// ]]; then

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

  DBNAME=$(
    echo "$CONN" |
      sed -n 's/.*dbname=\([^ ]*\).*/\1/p'
  )

else

  die "Formato de conexão não suportado."

fi

DBNAME="${DBNAME:-export}"

###############################################################################
# PARÂMETROS
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

TABLES=()

while [[ $# -gt 0 ]]; do

  case "$1" in

  --schema)
    SCHEMA="$2"
    shift 2
    ;;

  --table)
    TABLES+=("$2")
    shift 2
    ;;

  --sql)
    SQL="$2"
    shift 2
    ;;

  --where)
    WHERE="$2"
    shift 2
    ;;

  --bbox)
    XMIN="$2"
    YMIN="$3"
    XMAX="$4"
    YMAX="$5"
    shift 5
    ;;

  --clip-table)
    CLIP_TABLE="$2"
    shift 2
    ;;

  --clip-where)
    CLIP_WHERE="$2"
    shift 2
    ;;

  --cut)
    CUT=true
    shift
    ;;

  -h | --help)
    usage
    exit 0
    ;;

  *)
    die "Parâmetro inválido: $1"
    ;;

  esac

done

###############################################################################
# ARQUIVO DE SAÍDA
###############################################################################

OUTFILE="${DBNAME}.gpkg"

###############################################################################
# FUNÇÃO DE EXPORTAÇÃO
###############################################################################

export_layer() {

  local layer="$1"
  shift

  if [[ -f "$OUTFILE" ]]; then

    if ogrinfo "$OUTFILE" "$layer" >/dev/null 2>&1; then

      echo "Layer já existe, ignorando: $layer"
      return 0

    fi

    ogr2ogr \
      -update \
      -f GPKG \
      "$OUTFILE" \
      "$@"

  else

    ogr2ogr \
      -f GPKG \
      "$OUTFILE" \
      "$@"

  fi
}

###############################################################################
# SQL
###############################################################################

if [[ -n "$SQL" ]]; then

  echo "Exportando SQL..."

  export_layer \
    "sql_result" \
    "$CONN" \
    -sql "$SQL" \
    -dialect PostgreSQL \
    -nln sql_result

  echo "Arquivo atualizado: $OUTFILE"
  exit 0

fi

###############################################################################
# BANCO COMPLETO
###############################################################################

if [[ -z "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then

  echo "Obtendo tabelas espaciais..."

  mapfile -t TABLES < <(
    psql "$PSQL_CONN" -Atc "
            SELECT f_table_schema || '.' || f_table_name
            FROM geometry_columns
            ORDER BY 1
        "
  )

fi

###############################################################################
# SCHEMA
###############################################################################

if [[ -n "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then

  mapfile -t TABLES < <(
    psql "$PSQL_CONN" -Atc "
            SELECT f_table_schema || '.' || f_table_name
            FROM geometry_columns
            WHERE f_table_schema='${SCHEMA}'
            ORDER BY 1
        "
  )

fi

[[ ${#TABLES[@]} -gt 0 ]] || die "Nenhuma tabela encontrada."

###############################################################################
# EXPORTAÇÃO
###############################################################################

for TABLE in "${TABLES[@]}"; do

  echo "Exportando ${TABLE}"

  LAYER_NAME=$(layer_name "$TABLE")

  ###########################################################################
  # CLIP / CUT
  ###########################################################################

  if [[ -n "$CLIP_TABLE" ]]; then

    TABLE_SCHEMA="${TABLE%%.*}"
    TABLE_NAME="${TABLE##*.}"

    CLIP_SCHEMA="${CLIP_TABLE%%.*}"
    CLIP_NAME="${CLIP_TABLE##*.}"

    GEOM_COL=$(
      psql "$PSQL_CONN" -Atc "
                SELECT f_geometry_column
                FROM geometry_columns
                WHERE f_table_schema='${TABLE_SCHEMA}'
                  AND f_table_name='${TABLE_NAME}'
                LIMIT 1
            "
    )

    CLIP_GEOM=$(
      psql "$PSQL_CONN" -Atc "
                SELECT f_geometry_column
                FROM geometry_columns
                WHERE f_table_schema='${CLIP_SCHEMA}'
                  AND f_table_name='${CLIP_NAME}'
                LIMIT 1
            "
    )

    [[ -n "$GEOM_COL" ]] || die "Geometria não encontrada: $TABLE"
    [[ -n "$CLIP_GEOM" ]] || die "Geometria não encontrada: $CLIP_TABLE"

    if $CUT; then

      SQL_EXPORT="
            SELECT
                a.*,
                ST_Intersection(
                    a.${GEOM_COL},
                    b.${CLIP_GEOM}
                ) AS ${GEOM_COL}
            FROM ${TABLE} a
            JOIN ${CLIP_TABLE} b
              ON ST_Intersects(
                    a.${GEOM_COL},
                    b.${CLIP_GEOM}
                 )
            "

      [[ -n "$CLIP_WHERE" ]] &&
        SQL_EXPORT+=" WHERE ${CLIP_WHERE}"

    else

      SQL_EXPORT="
            SELECT a.*
            FROM ${TABLE} a
            WHERE EXISTS (
                SELECT 1
                FROM ${CLIP_TABLE} b
            "

      if [[ -n "$CLIP_WHERE" ]]; then
        SQL_EXPORT+=" WHERE (${CLIP_WHERE}) AND "
      else
        SQL_EXPORT+=" WHERE "
      fi

      SQL_EXPORT+="
                ST_Intersects(
                    a.${GEOM_COL},
                    b.${CLIP_GEOM}
                )
            )"

    fi

    export_layer \
      "$LAYER_NAME" \
      "$CONN" \
      -sql "$SQL_EXPORT" \
      -dialect PostgreSQL \
      -nln "$LAYER_NAME"

  ###########################################################################
  # EXPORTAÇÃO DIRETA
  ###########################################################################

  else

    OGR_ARGS=()

    [[ -n "$WHERE" ]] &&
      OGR_ARGS+=(
        -where
        "$WHERE"
      )

    [[ -n "$XMIN" ]] &&
      OGR_ARGS+=(
        -spat
        "$XMIN"
        "$YMIN"
        "$XMAX"
        "$YMAX"
      )

    export_layer \
      "$LAYER_NAME" \
      "$CONN" \
      "$TABLE" \
      -nln "$LAYER_NAME" \
      "${OGR_ARGS[@]}"

  fi

done

echo
echo "Exportação concluída."
echo "Arquivo: $OUTFILE"
