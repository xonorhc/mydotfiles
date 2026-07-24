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
  $0 "<CONN>" \\
      --table stage.sabesp_ligacao \\
      --table stage.sabesp_rede_agua

Where:
  $0 "<CONN>" \\
      --table stage.sabesp_ligacao \\
      --where "situacao = 'ATIVA'"

BBox:
  $0 "<CONN>" \\
      --table stage.sabesp_ligacao \\
      --bbox xmin ymin xmax ymax

Clip por camada:
  $0 "<CONN>" \\
      --schema stage \\
      --clip-table base.municipios \\
      --clip-where "nm_mun='BOTUCATU'"

Recorte geométrico:
  $0 "<CONN>" \\
      --schema stage \\
      --clip-table base.municipios \\
      --clip-where "nm_mun='BOTUCATU'" \\
      --cut

SQL livre:
  $0 "<CONN>" \\
      --sql "SELECT * FROM stage.sabesp_ligacao" \\
      --out saida.geojson

Opções de redução:
  --precision N              Casas decimais. Padrão: 5
  --simplify-meters N        Simplificação em metros. Padrão: 1.0
  --no-simplify              Desativa simplificação
  --keep-z                   Mantém coordenada Z
  --attrs "col1,col2,col3"   Exporta apenas estes atributos
  --exclude-columns "a,b,c"  Remove atributos informados
  --fid-col coluna           Define coluna usada como Feature.id
  --write-bbox               Escreve bbox no GeoJSON
  --target-srid SRID         SRID final. Padrão: 4326
  --out caminho              Diretório ou arquivo .geojson
  --bbox-srid SRID           SRID do bbox informado. Padrão: 4326

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
# URL PostgreSQL -> GDAL + PSQL
###############################################################################

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

    HOST="${HOSTPORT%%:*}"

    if [[ "$HOSTPORT" == *:* ]]; then
        PORT="${HOSTPORT##*:}"
    else
        PORT="5432"
    fi

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
# DEPENDÊNCIAS
###############################################################################

command -v ogr2ogr >/dev/null 2>&1 || {
    echo "Erro: ogr2ogr não encontrado. Instale o GDAL."
    exit 1
}

command -v psql >/dev/null 2>&1 || {
    echo "Erro: psql não encontrado."
    exit 1
}

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

OUT=""
TARGET_SRID="4326"
BBOX_SRID="4326"

PRECISION="5"
SIMPLIFY_METERS="1.0"
SIMPLIFY_SRID="3857"

DROP_Z=true
WRITE_BBOX=false

FID_COL=""
ATTRS=""
EXCLUDE_COLUMNS=""

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

        --bbox-srid)
            BBOX_SRID="$2"
            shift 2
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

        --out)
            OUT="$2"
            shift 2
            ;;

        --target-srid)
            TARGET_SRID="$2"
            shift 2
            ;;

        --precision)
            PRECISION="$2"
            shift 2
            ;;

        --simplify-meters)
            SIMPLIFY_METERS="$2"
            shift 2
            ;;

        --no-simplify)
            SIMPLIFY_METERS="0"
            shift
            ;;

        --keep-z)
            DROP_Z=false
            shift
            ;;

        --write-bbox)
            WRITE_BBOX=true
            shift
            ;;

        --fid-col)
            FID_COL="$2"
            shift 2
            ;;

        --attrs)
            ATTRS="$2"
            shift 2
            ;;

        --exclude-columns)
            EXCLUDE_COLUMNS="$2"
            shift 2
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        *)
            echo "Parâmetro inválido: $1"
            usage
            exit 1
            ;;
    esac

done

###############################################################################
# FUNÇÕES AUXILIARES
###############################################################################

safe_name() {
    echo "$1" | tr '.' '_' | tr '/' '_' | tr ' ' '_'
}

single_output_file_requested() {
    [[ -n "$OUT" && "$OUT" =~ \.geojson$ ]]
}

sql_quote_literal() {
    local value="$1"
    value="${value//\'/\'\'}"
    printf "'%s'" "$value"
}

build_not_in_clause() {
    local csv="$1"

    if [[ -z "$csv" ]]; then
        echo ""
        return
    fi

    local result=""
    local first=true

    IFS=',' read -ra parts <<< "$csv"

    for item in "${parts[@]}"; do
        item="$(echo "$item" | xargs)"
        [[ -z "$item" ]] && continue

        if $first; then
            result="$(sql_quote_literal "$item")"
            first=false
        else
            result="${result}, $(sql_quote_literal "$item")"
        fi
    done

    if [[ -n "$result" ]]; then
        echo "AND column_name NOT IN (${result})"
    fi
}

get_geom_column() {
    local full_table="$1"
    local table_schema="${full_table%%.*}"
    local table_name="${full_table##*.}"

    psql "$PSQL_CONN" -Atc "
        SELECT f_geometry_column
        FROM geometry_columns
        WHERE f_table_schema='${table_schema}'
          AND f_table_name='${table_name}'
        LIMIT 1
    "
}

get_geom_srid() {
    local full_table="$1"
    local table_schema="${full_table%%.*}"
    local table_name="${full_table##*.}"

    psql "$PSQL_CONN" -Atc "
        SELECT srid
        FROM geometry_columns
        WHERE f_table_schema='${table_schema}'
          AND f_table_name='${table_name}'
        LIMIT 1
    "
}

get_columns_from_attrs() {
    local attrs="$1"
    local geom_col="$2"

    local result=""
    local first=true

    IFS=',' read -ra parts <<< "$attrs"

    for item in "${parts[@]}"; do
        item="$(echo "$item" | xargs)"
        [[ -z "$item" ]] && continue
        [[ "$item" == "$geom_col" ]] && continue

        if $first; then
            result="a.\"${item}\""
            first=false
        else
            result="${result}, a.\"${item}\""
        fi
    done

    echo "$result"
}

get_columns_except_geom() {
    local full_table="$1"
    local geom_col="$2"
    local exclude_clause

    exclude_clause="$(build_not_in_clause "$EXCLUDE_COLUMNS")"

    local table_schema="${full_table%%.*}"
    local table_name="${full_table##*.}"

    psql "$PSQL_CONN" -Atc "
        SELECT string_agg(format('a.%I', column_name), ', ' ORDER BY ordinal_position)
        FROM information_schema.columns
        WHERE table_schema='${table_schema}'
          AND table_name='${table_name}'
          AND column_name <> '${geom_col}'
          ${exclude_clause}
    "
}

optimize_geom_sql() {
    local geom_expr="$1"

    local base_expr="$geom_expr"

    if $DROP_Z; then
        base_expr="ST_Force2D(${base_expr})"
    fi

    if [[ "$SIMPLIFY_METERS" != "0" && "$SIMPLIFY_METERS" != "0.0" ]]; then
        echo "ST_Transform(ST_SimplifyPreserveTopology(ST_Transform(${base_expr}, ${SIMPLIFY_SRID}), ${SIMPLIFY_METERS}), ${TARGET_SRID})"
    else
        echo "ST_Transform(${base_expr}, ${TARGET_SRID})"
    fi
}

build_lco_args() {
    LCO_ARGS=()

    if [[ "$TARGET_SRID" == "4326" ]]; then
        LCO_ARGS+=(-lco RFC7946=YES)
    fi

    LCO_ARGS+=(-lco COORDINATE_PRECISION="$PRECISION")

    if $WRITE_BBOX; then
        LCO_ARGS+=(-lco WRITE_BBOX=YES)
    fi

    if [[ -n "$FID_COL" ]]; then
        LCO_ARGS+=(-lco ID_FIELD="$FID_COL")
    fi
}

export_geojson() {
    local outfile="$1"
    local sql_export="$2"

    mkdir -p "$(dirname "$outfile")"
    rm -f "$outfile"

    build_lco_args

    echo "Gerando arquivo: $outfile"

    DIM_ARGS=()
    if $DROP_Z; then
        DIM_ARGS=(-dim XY)
    fi

    ogr2ogr \
        -f GeoJSON \
        "$outfile" \
        "$CONN" \
        -sql "$sql_export" \
        -dialect PostgreSQL \
        -t_srs "EPSG:${TARGET_SRID}" \
        "${LCO_ARGS[@]}" \
        "${DIM_ARGS[@]}" \
        -skipfailures

    if [[ ! -f "$outfile" ]]; then
        echo "Erro: o GeoJSON não foi criado: $outfile"
        exit 1
    fi

    if [[ ! -s "$outfile" ]]; then
        echo "Erro: o GeoJSON foi criado vazio: $outfile"
        exit 1
    fi

    echo "Criado com sucesso: $outfile"
}

###############################################################################
# INFORMAÇÕES
###############################################################################

echo "Configuração de exportação:"
echo "  Banco: ${DBNAME}"
echo "  SRID saída: EPSG:${TARGET_SRID}"
echo "  Precisão coordenadas: ${PRECISION}"
echo "  Simplificação: ${SIMPLIFY_METERS} m"
echo "  Simplificação SRID: EPSG:${SIMPLIFY_SRID}"
echo "  Remover Z/M: ${DROP_Z}"
echo "  Escrever bbox: ${WRITE_BBOX}"

###############################################################################
# SQL LIVRE
###############################################################################

if [[ -n "$SQL" ]]; then

    OUTFILE="${OUT:-${DBNAME}_sql.geojson}"

    if [[ ! "$OUTFILE" =~ \.geojson$ ]]; then
        mkdir -p "$OUTFILE"
        OUTFILE="${OUTFILE}/${DBNAME}_sql.geojson"
    fi

    echo
    echo "Aviso: em modo --sql, a simplificação automática não altera sua SQL."
    echo "Use ST_SimplifyPreserveTopology diretamente na query quando necessário."
    echo

    export_geojson "$OUTFILE" "$SQL"

    echo
    echo "Exportação concluída:"
    echo "$OUTFILE"
    exit 0
fi

###############################################################################
# BANCO INTEIRO
###############################################################################

if [[ -z "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then

    OUTDIR="${OUT:-${DBNAME}_geojson}"
    mkdir -p "$OUTDIR"

    echo "Exportando banco completo para diretório: $OUTDIR"

    mapfile -t TABLES < <(
        psql "$PSQL_CONN" -Atc "
            SELECT f_table_schema || '.' || f_table_name
            FROM geometry_columns
            ORDER BY 1
        "
    )
fi

###############################################################################
# ESQUEMA
###############################################################################

if [[ -n "$SCHEMA" && ${#TABLES[@]} -eq 0 ]]; then

    OUTDIR="${OUT:-${DBNAME}_${SCHEMA}_geojson}"
    mkdir -p "$OUTDIR"

    mapfile -t TABLES < <(
        psql "$PSQL_CONN" -Atc "
            SELECT f_table_schema || '.' || f_table_name
            FROM geometry_columns
            WHERE f_table_schema='${SCHEMA}'
            ORDER BY 1
        "
    )
fi

###############################################################################
# VALIDAÇÃO
###############################################################################

if [[ ${#TABLES[@]} -eq 0 ]]; then
    echo "Nenhuma tabela encontrada."
    exit 1
fi

if [[ -z "${OUTDIR:-}" ]]; then

    if single_output_file_requested && [[ ${#TABLES[@]} -eq 1 ]]; then
        OUTDIR="$(dirname "$OUT")"
        mkdir -p "$OUTDIR"
    else
        OUTDIR="${OUT:-${DBNAME}_geojson}"
        mkdir -p "$OUTDIR"
    fi

fi

###############################################################################
# EXPORTAÇÃO
###############################################################################

for TABLE in "${TABLES[@]}"; do

    echo
    echo "Exportando ${TABLE}"

    GEOM_COL="$(get_geom_column "$TABLE")"
    GEOM_SRID="$(get_geom_srid "$TABLE")"

    if [[ -z "$GEOM_COL" ]]; then
        echo "Aviso: geometria não encontrada para ${TABLE}. Ignorando."
        continue
    fi

    if [[ -z "$GEOM_SRID" || "$GEOM_SRID" == "0" ]]; then
        GEOM_SRID="$TARGET_SRID"
    fi

    if [[ -n "$ATTRS" ]]; then
        ATTR_COLS="$(get_columns_from_attrs "$ATTRS" "$GEOM_COL")"
    else
        ATTR_COLS="$(get_columns_except_geom "$TABLE" "$GEOM_COL")"
    fi

    if [[ -z "$ATTR_COLS" ]]; then
        SELECT_ATTRS=""
    else
        SELECT_ATTRS="${ATTR_COLS},"
    fi

    LAYER_NAME="$(safe_name "$TABLE")"

    if single_output_file_requested && [[ ${#TABLES[@]} -eq 1 ]]; then
        OUTFILE="$OUT"
    else
        OUTFILE="${OUTDIR}/${LAYER_NAME}.geojson"
    fi

    ###########################################################################
    # CLIP / CUT
    ###########################################################################

    if [[ -n "$CLIP_TABLE" ]]; then

        CLIP_GEOM="$(get_geom_column "$CLIP_TABLE")"
        CLIP_SRID="$(get_geom_srid "$CLIP_TABLE")"

        if [[ -z "$CLIP_GEOM" ]]; then
            echo "Erro: geometria não encontrada para clip-table ${CLIP_TABLE}."
            exit 1
        fi

        if [[ -z "$CLIP_SRID" || "$CLIP_SRID" == "0" ]]; then
            CLIP_SRID="$GEOM_SRID"
        fi

        if [[ "$CLIP_SRID" != "$GEOM_SRID" ]]; then
            CLIP_GEOM_EXPR="ST_Transform(b.${CLIP_GEOM}, ${GEOM_SRID})"
        else
            CLIP_GEOM_EXPR="b.${CLIP_GEOM}"
        fi

        if $CUT; then

            GEOM_EXPORT="$(
                optimize_geom_sql "ST_Intersection(a.${GEOM_COL}, ${CLIP_GEOM_EXPR})"
            )"

            SQL_EXPORT="
                SELECT
                    ${SELECT_ATTRS}
                    ${GEOM_EXPORT} AS geom
                FROM ${TABLE} a
                JOIN ${CLIP_TABLE} b
                  ON ST_Intersects(a.${GEOM_COL}, ${CLIP_GEOM_EXPR})
            "

            if [[ -n "$CLIP_WHERE" ]]; then
                SQL_EXPORT+=" WHERE ${CLIP_WHERE}"
            fi

        else

            GEOM_EXPORT="$(optimize_geom_sql "a.${GEOM_COL}")"

            SQL_EXPORT="
                SELECT
                    ${SELECT_ATTRS}
                    ${GEOM_EXPORT} AS geom
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
                    ST_Intersects(a.${GEOM_COL}, ${CLIP_GEOM_EXPR})
                )
            "

        fi

        export_geojson "$OUTFILE" "$SQL_EXPORT"

    ###########################################################################
    # EXPORTAÇÃO PADRÃO
    ###########################################################################

    else

        GEOM_EXPORT="$(optimize_geom_sql "a.${GEOM_COL}")"

        SQL_EXPORT="
            SELECT
                ${SELECT_ATTRS}
                ${GEOM_EXPORT} AS geom
            FROM ${TABLE} a
        "

        WHERE_PARTS=()

        if [[ -n "$WHERE" ]]; then
            WHERE_PARTS+=("(${WHERE})")
        fi

        if [[ -n "$XMIN" ]]; then
            WHERE_PARTS+=("
                a.${GEOM_COL} && ST_Transform(
                    ST_MakeEnvelope(${XMIN}, ${YMIN}, ${XMAX}, ${YMAX}, ${BBOX_SRID}),
                    ${GEOM_SRID}
                )
            ")
        fi

        if [[ ${#WHERE_PARTS[@]} -gt 0 ]]; then
            SQL_EXPORT+=" WHERE "

            local_first=true
            for part in "${WHERE_PARTS[@]}"; do
                if $local_first; then
                    SQL_EXPORT+=" ${part} "
                    local_first=false
                else
                    SQL_EXPORT+=" AND ${part} "
                fi
            done
        fi

        export_geojson "$OUTFILE" "$SQL_EXPORT"

    fi

done

echo
echo "Exportação concluída."
echo "Saída:"
if single_output_file_requested && [[ ${#TABLES[@]} -eq 1 ]]; then
    echo "$OUT"
else
    echo "$OUTDIR"
fi

