#!/usr/bin/env bash

set -euo pipefail

usage() {
cat <<EOF

USO

Usando DATABASE_URL do ambiente:
  $0 --schema stage

URL explícita:
  $0 "postgresql://postgres:secret@localhost:5432/postgis" --schema stage

Banco inteiro:
  $0 "<CONN>"

Schema:
  $0 "<CONN>" --schema stage

Tabela:
  $0 "<CONN>" --table stage.sabesp_ligacao

Múltiplas tabelas:
  $0 "<CONN>" \
      --table stage.sabesp_ligacao \
      --table stage.sabesp_rede_agua \
      --table stage.sabesp_rede_esgoto

Where:
  $0 "<CONN>" \
      --table stage.sabesp_ligacao \
      --where "situacao = 'ATIVA'"

BBox:
  $0 "<CONN>" \
      --table stage.sabesp_ligacao \
      --bbox xmin ymin xmax ymax

Filtro através de camada:
  $0 "<CONN>" \
      --schema stage \
      --clip-table base.municipios \
      --clip-where "nm_mun='BOTUCATU'"

Recorte geométrico:
  $0 "<CONN>" \
      --schema stage \
      --clip-table base.municipios \
      --clip-where "nm_mun='BOTUCATU'" \
      --cut

SQL:
  $0 "<CONN>" \
      --sql "SELECT * FROM stage.sabesp_ligacao"

EOF
}

###############################################################################
# CONEXÃO
###############################################################################

if [[ $# -eq 0 || "$1" == --* ]]; then

    INPUT_CONN="${DATABASE_URL:-${POSTGIS_URL:-${PG_URL:-}}}"

    if [[ -z "${INPUT_CONN:-}" ]]; then
        echo "Nenhuma conexão informada."
        echo "Defina DATABASE_URL ou passe a conexão como parâmetro."
        exit 1
    fi

else

    INPUT_CONN="$1"
    shift

fi

###############################################################################
# URL PostgreSQL → GDAL + PSQL
###############################################################################

if [[ "$INPUT_CONN" =~ ^postgresql:// ]] || \
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

    HOST="${HOSTPORT%%:*}"
    PORT="${HOSTPORT#*:}"

    CONN="PG:host=${HOST} port=${PORT} dbname=${DBNAME} user=${USER} password=${PASS}"

elif [[ "$INPUT_CONN" =~ ^PG: ]]; then

    CONN="$INPUT_CONN"
    PSQL_CONN="${INPUT_CONN#PG:}"

    DBNAME=$(
        echo "$CONN" |
        sed -n 's/.*dbname=\([^ ]*\).*/\1/p'
    )

else

    echo "Formato de conexão não suportado."
    exit 1

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

        *)
            echo "Parâmetro inválido: $1"
            exit 1
            ;;
    esac

done

###############################################################################
# SQL LIVRE
###############################################################################

if [[ -n "$SQL" ]]; then

    OUTFILE="${DBNAME}_sql.gpkg"

    ogr2ogr \
        -f GPKG \
        "$OUTFILE" \
        "$CONN" \
        -sql "$SQL" \
        -dialect PostgreSQL

    echo "Arquivo criado: $OUTFILE"
    exit 0
fi

###############################################################################
# BANCO INTEIRO
###############################################################################

if [[ -z "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then

    OUTFILE="${DBNAME}.gpkg"

    echo "Exportando banco completo..."

    ogr2ogr \
        -f GPKG \
        "$OUTFILE" \
        "$CONN"

    echo "Arquivo criado: $OUTFILE"
    exit 0
fi

###############################################################################
# ESQUEMA
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

if [[ ${#TABLES[@]} -eq 0 ]]; then
    echo "Nenhuma tabela encontrada."
    exit 1
fi

###############################################################################
# EXPORTAÇÃO
###############################################################################

OUTFILE="${DBNAME}.gpkg"
rm -f "$OUTFILE"

FIRST=true

for TABLE in "${TABLES[@]}"; do

    echo "Exportando ${TABLE}"

    LAYER_NAME=$(echo "$TABLE" | tr '.' '_')

    APPEND_ARGS=()

    if ! $FIRST; then
        APPEND_ARGS=(-append)
    fi

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

        ogr2ogr \
            -f GPKG \
            "$OUTFILE" \
            "$CONN" \
            -sql "$SQL_EXPORT" \
            -dialect PostgreSQL \
            -nln "$LAYER_NAME" \
            "${APPEND_ARGS[@]}"

    ###########################################################################
    # EXPORTAÇÃO PADRÃO
    ###########################################################################

    else

        OGR_ARGS=()

        [[ -n "$WHERE" ]] &&
            OGR_ARGS+=(-where "$WHERE")

        [[ -n "$XMIN" ]] &&
            OGR_ARGS+=(
                -spat
                "$XMIN"
                "$YMIN"
                "$XMAX"
                "$YMAX"
            )

        ogr2ogr \
            -f GPKG \
            "$OUTFILE" \
            "$CONN" \
            "$TABLE" \
            "${OGR_ARGS[@]}" \
            "${APPEND_ARGS[@]}"

    fi

    FIRST=false

done

echo
echo "Exportação concluída:"
echo "$OUTFILE"
