#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# AJUDA
###############################################################################

usage() {
    cat <<EOF

Converte dados geoespaciais para GeoJSON usando GDAL/OGR.

USO

  $0 ARQUIVO_ENTRADA [opções]

EXEMPLOS

  # Shapefile, layer detectada automaticamente
  $0 municipios.shp

  # GeoPackage com apenas uma layer
  $0 municipios.gpkg

  # GeoPackage com múltiplas layers
  $0 base.gpkg --layer municipios

  # Consulta SQL
  $0 base.gpkg \\
      --layer municipios \\
      --sql "SELECT * FROM municipios WHERE uf = 'SP'"

  # Arquivo de saída personalizado
  $0 base.gpkg \\
      --layer municipios \\
      --out municipios_sp.geojson

OPÇÕES

  --layer NOME           Layer de origem
  --sql QUERY            Consulta SQL
  --dialect DIALETO      Dialeto SQL: OGRSQL ou SQLite
                         Padrão: OGRSQL
  --out ARQUIVO          Arquivo GeoJSON de saída
  --target-srid SRID     SRID de saída. Padrão: 4326
  --precision N          Casas decimais. Padrão: 6
  --keep-z               Mantém a coordenada Z
  --write-bbox           Escreve bbox nas feições
  --skip-failures        Ignora feições com erro
  --list-layers          Lista as layers disponíveis
  -h, --help             Exibe esta ajuda

OBSERVAÇÕES

  Quando o arquivo possui apenas uma layer, ela é detectada automaticamente.

  Quando o arquivo possui múltiplas layers, informe uma delas com:

    --layer NOME

  No modo --sql, o nome informado em --layer não é passado diretamente ao
  ogr2ogr. Ele pode ser utilizado na consulta SQL.

EOF
}

###############################################################################
# MENSAGENS
###############################################################################

error() {
    printf 'Erro: %s\n' "$*" >&2
    exit 1
}

###############################################################################
# DEPENDÊNCIAS
###############################################################################

command -v ogr2ogr >/dev/null 2>&1 ||
    error "ogr2ogr não encontrado. Instale o GDAL."

command -v ogrinfo >/dev/null 2>&1 ||
    error "ogrinfo não encontrado. Instale o GDAL."

###############################################################################
# VALIDAÇÃO DE ARGUMENTOS
###############################################################################

require_value() {
    local option="$1"
    local value="${2:-}"

    if [[ -z "$value" || "$value" == --* ]]; then
        error "a opção ${option} exige um valor."
    fi
}

is_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

###############################################################################
# PARÂMETROS
###############################################################################

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

INPUT="$1"
shift

LAYER=""
SQL=""
SQL_DIALECT="OGRSQL"
OUT=""
TARGET_SRID="4326"
PRECISION="6"

KEEP_Z=false
WRITE_BBOX=false
SKIP_FAILURES=false
LIST_LAYERS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --layer)
            require_value "$1" "${2:-}"
            LAYER="$2"
            shift 2
            ;;

        --sql)
            require_value "$1" "${2:-}"
            SQL="$2"
            shift 2
            ;;

        --dialect)
            require_value "$1" "${2:-}"
            SQL_DIALECT="$2"
            shift 2
            ;;

        --out)
            require_value "$1" "${2:-}"
            OUT="$2"
            shift 2
            ;;

        --target-srid)
            require_value "$1" "${2:-}"
            TARGET_SRID="$2"
            shift 2
            ;;

        --precision)
            require_value "$1" "${2:-}"
            PRECISION="$2"
            shift 2
            ;;

        --keep-z)
            KEEP_Z=true
            shift
            ;;

        --write-bbox)
            WRITE_BBOX=true
            shift
            ;;

        --skip-failures)
            SKIP_FAILURES=true
            shift
            ;;

        --list-layers)
            LIST_LAYERS=true
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        *)
            error "parâmetro inválido: $1"
            ;;
    esac
done

###############################################################################
# VALIDAÇÕES
###############################################################################

if [[ ! -e "$INPUT" ]]; then
    error "arquivo ou datasource não encontrado: $INPUT"
fi

if ! is_integer "$TARGET_SRID"; then
    error "o SRID deve ser um número inteiro: $TARGET_SRID"
fi

if ! is_integer "$PRECISION"; then
    error "a precisão deve ser um número inteiro: $PRECISION"
fi

case "${SQL_DIALECT^^}" in
    OGRSQL)
        SQL_DIALECT="OGRSQL"
        ;;
    SQLITE)
        SQL_DIALECT="SQLite"
        ;;
    *)
        error "dialeto SQL inválido: ${SQL_DIALECT}. Use OGRSQL ou SQLite."
        ;;
esac

###############################################################################
# DETECÇÃO DE LAYERS
###############################################################################

declare -a LAYERS=()

read_layers() {
    local line
    local layer_name

    LAYERS=()

    while IFS= read -r line; do
        # Exemplos de saída do ogrinfo:
        #
        # 1: OMMS_ADU (Line String)
        # 2: municipios (Multi Polygon)
        #
        # Remove o índice inicial e o tipo geométrico final.
        layer_name="$(
            printf '%s\n' "$line" |
                sed -E \
                    's/^[[:space:]]*[0-9]+:[[:space:]]*//;
                     s/[[:space:]]+\([^()]*\)[[:space:]]*$//'
        )"

        if [[ -n "$layer_name" ]]; then
            LAYERS+=("$layer_name")
        fi
    done < <(
        ogrinfo -ro "$INPUT" 2>/dev/null |
            grep -E '^[[:space:]]*[0-9]+:[[:space:]]*' || true
    )
}

print_layers() {
    if [[ ${#LAYERS[@]} -eq 0 ]]; then
        echo "Nenhuma layer encontrada."
        return
    fi

    echo "Layers disponíveis:"

    local item

    for item in "${LAYERS[@]}"; do
        printf '  - %s\n' "$item"
    done
}

layer_exists() {
    local requested="$1"
    local item

    for item in "${LAYERS[@]}"; do
        if [[ "$item" == "$requested" ]]; then
            return 0
        fi
    done

    return 1
}

read_layers

if $LIST_LAYERS; then
    print_layers
    exit 0
fi

if [[ ${#LAYERS[@]} -eq 0 ]]; then
    error "não foi possível identificar nenhuma layer em: $INPUT"
fi

###############################################################################
# SELEÇÃO DA LAYER
###############################################################################

if [[ -n "$LAYER" ]]; then
    if ! layer_exists "$LAYER"; then
        echo "Erro: layer não encontrada: $LAYER" >&2
        echo >&2
        print_layers >&2
        exit 1
    fi
elif [[ ${#LAYERS[@]} -eq 1 ]]; then
    LAYER="${LAYERS[0]}"
else
    echo "Erro: o datasource possui mais de uma layer." >&2
    echo "Informe a layer desejada usando --layer." >&2
    echo >&2
    print_layers >&2
    exit 1
fi

###############################################################################
# NOME DO ARQUIVO DE SAÍDA
###############################################################################

safe_name() {
    printf '%s' "$1" |
        sed -E \
            's/[[:space:]]+/_/g;
             s/[^[:alnum:]_.-]+/_/g;
             s/^_+//;
             s/_+$//'
}

input_basename="$(basename "$INPUT")"

# Remove extensões comuns e o sufixo .gdb.
input_basename="${input_basename%.*}"

if [[ -z "$OUT" ]]; then
    safe_layer="$(safe_name "$LAYER")"

    if [[ -z "$SQL" ]]; then
        OUT="${input_basename}.geojson"
    else
        OUT="${input_basename}_${safe_layer}_sql.geojson"
    fi
fi

if [[ "${OUT,,}" != *.geojson ]]; then
    OUT="${OUT}.geojson"
fi

mkdir -p "$(dirname "$OUT")"

###############################################################################
# CONFIGURAÇÃO DO OGR2OGR
###############################################################################

OGR_ARGS=(
    -f GeoJSON
    "$OUT"
    "$INPUT"
    -overwrite
    -t_srs "EPSG:${TARGET_SRID}"
    -lco "COORDINATE_PRECISION=${PRECISION}"
)

# RFC 7946 utiliza coordenadas no sistema WGS 84.
if [[ "$TARGET_SRID" == "4326" ]]; then
    OGR_ARGS+=(
        -lco RFC7946=YES
    )
fi

if $WRITE_BBOX; then
    OGR_ARGS+=(
        -lco WRITE_BBOX=YES
    )
fi

if ! $KEEP_Z; then
    OGR_ARGS+=(
        -dim XY
    )
fi

if $SKIP_FAILURES; then
    OGR_ARGS+=(
        -skipfailures
    )
fi

###############################################################################
# LAYER OU SQL
###############################################################################

if [[ -n "$SQL" ]]; then
    OGR_ARGS+=(
        -sql "$SQL"
        -dialect "$SQL_DIALECT"
    )
else
    OGR_ARGS+=(
        "$LAYER"
    )
fi

###############################################################################
# INFORMAÇÕES
###############################################################################

echo "Conversão iniciada"
echo "Arquivo : $INPUT"
echo "Layer   : $LAYER"
echo "Saída   : $OUT"
echo "SRID    : EPSG:$TARGET_SRID"
echo "Precisão: $PRECISION"
echo "Manter Z: $KEEP_Z"

if [[ -n "$SQL" ]]; then
    echo "Dialeto : $SQL_DIALECT"
    echo "SQL     : $SQL"
fi

###############################################################################
# EXPORTAÇÃO
###############################################################################

rm -f "$OUT"

if ! ogr2ogr "${OGR_ARGS[@]}"; then
    rm -f "$OUT"
    error "falha durante a conversão."
fi

###############################################################################
# VALIDAÇÃO DA SAÍDA
###############################################################################

if [[ ! -f "$OUT" ]]; then
    error "o arquivo GeoJSON não foi criado: $OUT"
fi

if [[ ! -s "$OUT" ]]; then
    rm -f "$OUT"
    error "o arquivo GeoJSON foi criado vazio: $OUT"
fi

if ! ogrinfo -ro -so "$OUT" >/dev/null 2>&1; then
    error "o arquivo criado não pôde ser validado pelo GDAL: $OUT"
fi

echo
echo "Conversão concluída com sucesso."
echo "Arquivo gerado: $OUT"
