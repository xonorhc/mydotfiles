#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# CONFIGURAÇÃO
###############################################################################

readonly PROGRAM_NAME="${0##*/}"

GEOPACKAGE=""
LAYER=""
SQL=""
SQL_DIALECT="SQLite"
OUTPUT=""

SEPARATOR="COMMA"
OVERWRITE=false
LIST_LAYERS=false

declare -a LAYERS=()

###############################################################################
# AJUDA
###############################################################################

usage() {
  local exit_code="${1:-0}"

  cat <<EOF
Exporta os atributos de uma camada GeoPackage para CSV usando GDAL/OGR.

A geometria não é incluída no arquivo CSV.

USO

  ${PROGRAM_NAME} GEOPACKAGE [LAYER] [opções]

EXEMPLOS

  # Exportar uma camada
  ${PROGRAM_NAME} dados.gpkg enderecos

  # Definir o arquivo de saída
  ${PROGRAM_NAME} dados.gpkg enderecos \\
      --out enderecos.csv

  # Executar uma consulta SQL
  ${PROGRAM_NAME} dados.gpkg \\
      --sql "SELECT id, nome, endereco FROM enderecos"

  # Consulta SQL com filtro
  ${PROGRAM_NAME} dados.gpkg \\
      --sql "SELECT id, nome FROM enderecos WHERE municipio = 'BOTUCATU'"

  # Consulta SQL e arquivo de saída
  ${PROGRAM_NAME} dados.gpkg \\
      --sql "SELECT id, nome FROM enderecos WHERE ativo = 1" \\
      --out enderecos_ativos.csv

  # Usar o dialeto OGRSQL
  ${PROGRAM_NAME} dados.gpkg \\
      --sql "SELECT id, nome FROM enderecos" \\
      --dialect OGRSQL

  # Usar ponto e vírgula como separador
  ${PROGRAM_NAME} dados.gpkg enderecos \\
      --separator SEMICOLON

  # Sobrescrever o arquivo de saída
  ${PROGRAM_NAME} dados.gpkg enderecos \\
      --overwrite

  # Listar as camadas disponíveis
  ${PROGRAM_NAME} dados.gpkg --list-layers

OPÇÕES

  --layer NOME
      Nome da camada de origem.

      Pode ser usado no lugar do segundo argumento posicional:

        ${PROGRAM_NAME} dados.gpkg --layer enderecos

  --sql CONSULTA
      Consulta SQL utilizada na exportação.

      Quando esta opção é utilizada, a camada não precisa ser informada.
      As colunas exportadas são determinadas pela cláusula SELECT.

  --dialect DIALETO
      Dialeto usado pela consulta SQL.

      Valores aceitos:
        SQLite
        OGRSQL

      Padrão:
        SQLite

  --out ARQUIVO
      Caminho do arquivo CSV de saída.

      Sem --sql, o padrão é:
        <geopackage>_<layer>.csv

      Com --sql, o padrão é:
        <geopackage>_sql.csv

  --separator TIPO
      Separador utilizado no CSV.

      Valores aceitos:
        COMMA
        SEMICOLON
        TAB
        SPACE

      Padrão:
        COMMA

  --overwrite
      Sobrescreve o arquivo de saída caso ele já exista.

  --list-layers
      Lista as camadas disponíveis e encerra o programa.

  -h, --help
      Exibe esta ajuda.

OBSERVAÇÕES

  A geometria não é incluída no CSV.

  No modo normal, todos os atributos da camada são exportados.

  No modo SQL, prefira informar explicitamente as colunas:

    --sql "SELECT id, nome, endereco FROM enderecos"

  O dialeto SQLite é usado por padrão porque oferece mais recursos para
  consultas em GeoPackage.
EOF

  exit "$exit_code"
}

###############################################################################
# MENSAGENS
###############################################################################

info() {
  printf '%s\n' "$*"
}

error() {
  printf 'Erro: %s\n' "$*" >&2
  exit 1
}

###############################################################################
# DEPENDÊNCIAS
###############################################################################

check_dependencies() {
  local required_command

  for required_command in \
    ogr2ogr \
    ogrinfo \
    sed \
    grep \
    basename \
    dirname \
    mkdir \
    rm; do

    if ! command -v "$required_command" >/dev/null 2>&1; then
      error "comando obrigatório não encontrado: ${required_command}"
    fi
  done
}

###############################################################################
# FUNÇÕES DE VALIDAÇÃO
###############################################################################

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" || "$value" == --* ]]; then
    error "a opção ${option} exige um valor."
  fi
}

normalize_dialect() {
  case "${SQL_DIALECT^^}" in
  SQLITE)
    SQL_DIALECT="SQLite"
    ;;

  OGRSQL)
    SQL_DIALECT="OGRSQL"
    ;;

  *)
    error \
      "dialeto inválido: ${SQL_DIALECT}. Use SQLite ou OGRSQL."
    ;;
  esac
}

normalize_separator() {
  case "${SEPARATOR^^}" in
  COMMA)
    SEPARATOR="COMMA"
    ;;

  SEMICOLON)
    SEPARATOR="SEMICOLON"
    ;;

  TAB)
    SEPARATOR="TAB"
    ;;

  SPACE)
    SEPARATOR="SPACE"
    ;;

  *)
    error \
      "separador inválido: ${SEPARATOR}. Use COMMA, SEMICOLON, TAB ou SPACE."
    ;;
  esac
}

###############################################################################
# PARÂMETROS
###############################################################################

parse_arguments() {
  if [[ $# -eq 0 ]]; then
    usage 1
  fi

  case "$1" in
  -h | --help)
    usage 0
    ;;

  -*)
    error "informe o GeoPackage antes das opções."
    ;;
  esac

  GEOPACKAGE="$1"
  shift

  # A camada pode ser informada como segundo argumento posicional.
  if [[ $# -gt 0 && "$1" != -* ]]; then
    LAYER="$1"
    shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --layer)
      require_value "$1" "${2:-}"

      if [[ -n "$LAYER" ]]; then
        error "a camada foi informada mais de uma vez."
      fi

      LAYER="$2"
      shift 2
      ;;

    --sql)
      require_value "$1" "${2:-}"
      SQL="$(prepare_sql_argument "$2")"
      shift 2
      ;;

    --dialect)
      require_value "$1" "${2:-}"
      SQL_DIALECT="$2"
      shift 2
      ;;

    --out)
      require_value "$1" "${2:-}"
      OUTPUT="$2"
      shift 2
      ;;

    --separator)
      require_value "$1" "${2:-}"
      SEPARATOR="$2"
      shift 2
      ;;

    --overwrite)
      OVERWRITE=true
      shift
      ;;

    --list-layers)
      LIST_LAYERS=true
      shift
      ;;

    -h | --help)
      usage 0
      ;;

    --)
      shift

      if [[ $# -gt 0 ]]; then
        error "argumento inesperado: $1"
      fi
      ;;

    -*)
      error "opção desconhecida: $1"
      ;;

    *)
      error "argumento inesperado: $1"
      ;;
    esac
  done
}

###############################################################################
# VALIDAÇÃO DA CONFIGURAÇÃO
###############################################################################

validate_configuration() {
  if [[ ! -f "$GEOPACKAGE" ]]; then
    error "GeoPackage não encontrado: $GEOPACKAGE"
  fi

  case "${GEOPACKAGE,,}" in
  *.gpkg)
    ;;
  *)
    error "o arquivo informado não possui extensão .gpkg: $GEOPACKAGE"
    ;;
  esac

  normalize_dialect
  normalize_separator

  if $LIST_LAYERS; then
    return
  fi

  if [[ -z "$LAYER" && -z "$SQL" ]]; then
    error "informe uma camada ou utilize --sql."
  fi
}

###############################################################################
# LEITURA DAS CAMADAS
###############################################################################

read_layers() {
  local line
  local layer_name

  LAYERS=()

  while IFS= read -r line; do
    layer_name="$(
      printf '%s\n' "$line" |
        sed -E '
                    s/^[[:space:]]*[0-9]+:[[:space:]]*//
                    s/[[:space:]]+\([^()]*\)[[:space:]]*$//
                '
    )"

    if [[ -n "$layer_name" ]]; then
      LAYERS+=("$layer_name")
    fi
  done < <(
    ogrinfo -ro "$GEOPACKAGE" 2>/dev/null |
      grep -E '^[[:space:]]*[0-9]+:[[:space:]]*' ||
      true
  )
}

print_layers() {
  local layer_name

  if [[ ${#LAYERS[@]} -eq 0 ]]; then
    info "Nenhuma camada encontrada."
    return
  fi

  info "Camadas disponíveis em ${GEOPACKAGE}:"

  for layer_name in "${LAYERS[@]}"; do
    printf '  - %s\n' "$layer_name"
  done
}

layer_exists() {
  local requested="$1"
  local layer_name

  for layer_name in "${LAYERS[@]}"; do
    if [[ "$layer_name" == "$requested" ]]; then
      return 0
    fi
  done

  return 1
}

validate_layer() {
  if [[ -z "$LAYER" ]]; then
    return
  fi

  if ! layer_exists "$LAYER"; then
    printf 'Erro: camada não encontrada: %s\n\n' "$LAYER" >&2
    print_layers >&2
    exit 1
  fi
}

###############################################################################
# NOME DO ARQUIVO DE SAÍDA
###############################################################################

safe_name() {
  printf '%s' "$1" |
    sed -E '
            s/[[:space:]]+/_/g
            s/[^[:alnum:]_.-]+/_/g
            s/_+/_/g
            s/^_+//
            s/_+$//
        '
}

build_default_output() {
  local geopackage_name
  local safe_layer_name

  geopackage_name="$(basename -- "$GEOPACKAGE")"
  geopackage_name="${geopackage_name%.*}"
  geopackage_name="$(safe_name "$geopackage_name")"

  if [[ -z "$geopackage_name" ]]; then
    geopackage_name="export"
  fi

  if [[ -n "$SQL" ]]; then
    OUTPUT="${geopackage_name}_sql.csv"
    return
  fi

  safe_layer_name="$(safe_name "$LAYER")"

  if [[ -z "$safe_layer_name" ]]; then
    safe_layer_name="layer"
  fi

  OUTPUT="${geopackage_name}_${safe_layer_name}.csv"
}

prepare_output() {
  if [[ -z "$OUTPUT" ]]; then
    build_default_output
  fi

  if [[ "${OUTPUT,,}" != *.csv ]]; then
    OUTPUT="${OUTPUT}.csv"
  fi

  mkdir -p -- "$(dirname -- "$OUTPUT")"

  if [[ -e "$OUTPUT" ]] && ! $OVERWRITE; then
    error \
      "o arquivo já existe: ${OUTPUT}. Use --overwrite para substituí-lo."
  fi
}

###############################################################################
# ARGUMENTOS DO OGR2OGR
###############################################################################

prepare_sql_argument() {
  local sql_input="$1"

  if [[ "$sql_input" == @* ]]; then
    local sql_file="${sql_input#@}"

    if [[ ! -f "$sql_file" ]]; then
      error "arquivo SQL não encontrado: $sql_file"
    fi

    printf '@%s\n' "$sql_file"
    return
  fi

  if [[ -f "$sql_input" ]]; then
    printf '@%s\n' "$sql_input"
    return
  fi

  printf '%s\n' "$sql_input"
}

build_ogr_arguments() {
  local -n arguments_reference="$1"

  arguments_reference=(
    -f "CSV"
    "$OUTPUT"
    "$GEOPACKAGE"
    -lco "GEOMETRY=NONE"
    -lco "SEPARATOR=${SEPARATOR}"
  )

  if $OVERWRITE; then
    arguments_reference+=(
      -overwrite
    )
  fi

  if [[ -n "$SQL" ]]; then
    arguments_reference+=(
      -sql "$SQL"
      -dialect "$SQL_DIALECT"
    )
  else
    arguments_reference+=(
      "$LAYER"
    )
  fi
}

###############################################################################
# RELATÓRIO
###############################################################################

print_configuration() {
  info "Exportação iniciada"

  printf 'GeoPackage : %s\n' "$GEOPACKAGE"

  if [[ -n "$SQL" ]]; then
    printf 'Modo       : consulta SQL\n'
    printf 'Dialeto    : %s\n' "$SQL_DIALECT"
    printf 'SQL        : %s\n' "$SQL"

    if [[ -n "$LAYER" ]]; then
      printf 'Layer      : %s\n' "$LAYER"
    fi
  else
    printf 'Modo       : camada\n'
    printf 'Layer      : %s\n' "$LAYER"
  fi

  printf 'Saída      : %s\n' "$OUTPUT"
  printf 'Separador  : %s\n' "$SEPARATOR"
  printf 'Geometria  : não exportada\n'
  printf '\n'
}

###############################################################################
# EXPORTAÇÃO
###############################################################################

export_csv() {
  local -a ogr_arguments=()

  build_ogr_arguments ogr_arguments

  if [[ -e "$OUTPUT" ]] && $OVERWRITE; then
    rm -f -- "$OUTPUT"
  fi

  if ! ogr2ogr "${ogr_arguments[@]}"; then
    rm -f -- "$OUTPUT"
    error "falha ao exportar o GeoPackage para CSV."
  fi
}

###############################################################################
# VALIDAÇÃO DO RESULTADO
###############################################################################

validate_output() {
  if [[ ! -f "$OUTPUT" ]]; then
    error "o CSV não foi criado: $OUTPUT"
  fi

  if [[ ! -s "$OUTPUT" ]]; then
    rm -f -- "$OUTPUT"
    error "o CSV foi criado vazio: $OUTPUT"
  fi
}

###############################################################################
# EXECUÇÃO PRINCIPAL
###############################################################################

main() {
  parse_arguments "$@"
  check_dependencies
  validate_configuration
  read_layers

  if $LIST_LAYERS; then
    print_layers
    exit 0
  fi

  validate_layer
  prepare_output
  print_configuration
  export_csv
  validate_output

  info "Exportação concluída com sucesso."
  info "Arquivo gerado: $OUTPUT"
}

main "$@"
