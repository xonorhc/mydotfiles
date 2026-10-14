#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# CONFIGURAÇÃO
###############################################################################

readonly PROGRAM_NAME="${0##*/}"

INPUT=""
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

declare -a LAYERS=()

###############################################################################
# AJUDA
###############################################################################

usage() {
  local exit_code="${1:-0}"

  cat <<EOF
Converte dados geoespaciais para GeoJSON usando GDAL/OGR.

USO

  ${PROGRAM_NAME} ARQUIVO_ENTRADA [opções]

EXEMPLOS

  # Shapefile, layer detectada automaticamente
  ${PROGRAM_NAME} municipios.shp

  # GeoPackage com apenas uma layer
  ${PROGRAM_NAME} municipios.gpkg

  # GeoPackage com múltiplas layers
  ${PROGRAM_NAME} base.gpkg --layer municipios

  # Consulta SQL usando OGRSQL
  ${PROGRAM_NAME} base.gpkg \\
      --sql "SELECT * FROM municipios WHERE uf = 'SP'"

  # Consulta SQL usando SQLite
  ${PROGRAM_NAME} base.gpkg \\
      --sql "SELECT * FROM municipios WHERE uf = 'SP'" \\
      --dialect SQLite

  # Arquivo de saída personalizado
  ${PROGRAM_NAME} base.gpkg \\
      --layer municipios \\
      --out municipios_sp.geojson

  # Listar as layers disponíveis
  ${PROGRAM_NAME} base.gpkg --list-layers

OPÇÕES

  --layer NOME
      Layer de origem.

      É obrigatória quando o datasource possui mais de uma layer e nenhuma
      consulta SQL foi informada.

      No modo --sql, a layer é opcional e não é passada diretamente ao
      ogr2ogr. Quando informada, é apenas validada e pode ser utilizada na
      consulta SQL.

  --sql QUERY
      Consulta SQL utilizada na exportação.

  --dialect DIALETO
      Dialeto utilizado pela consulta SQL.

      Valores disponíveis:
        OGRSQL
        SQLite

      Padrão: OGRSQL

  --out ARQUIVO
      Caminho do arquivo GeoJSON de saída.

      A extensão .geojson é adicionada automaticamente quando não informada.

  --target-srid SRID
      SRID de saída.

      Padrão: 4326

  --precision N
      Quantidade de casas decimais das coordenadas.

      Padrão: 6

  --keep-z
      Mantém a coordenada Z.

      Por padrão, as geometrias são convertidas para XY.

  --write-bbox
      Escreve a propriedade bbox nas feições GeoJSON.

  --skip-failures
      Continua a conversão quando uma feição apresenta erro.

  --list-layers
      Lista as layers disponíveis e encerra o programa.

  -h, --help
      Exibe esta ajuda.

COMPORTAMENTO

  Quando o datasource contém apenas uma layer, ela é selecionada
  automaticamente.

  Quando o datasource contém múltiplas layers, deve ser utilizada a opção:

    --layer NOME

  Essa exigência não se aplica ao modo --sql, pois a própria consulta define
  quais layers ou tabelas serão utilizadas.

  Quando o SRID de destino é 4326, o GeoJSON é criado conforme o RFC 7946.

  Se o sistema de coordenadas da layer não estiver definido, pode ser
  necessário atribuí-lo previamente com ferramentas do GDAL.
EOF

  exit "$exit_code"
}

###############################################################################
# MENSAGENS
###############################################################################

info() {
  printf '%s\n' "$*"
}

warning() {
  printf 'Aviso: %s\n' "$*" >&2
}

error() {
  printf 'Erro: %s\n' "$*" >&2
  exit 1
}

###############################################################################
# DEPENDÊNCIAS
###############################################################################

check_dependencies() {
  local command_name

  for command_name in ogr2ogr ogrinfo sed grep basename dirname mkdir rm; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      error "comando obrigatório não encontrado: ${command_name}"
    fi
  done
}

###############################################################################
# VALIDAÇÃO DE ARGUMENTOS
###############################################################################

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" || "$value" == -* ]]; then
    error "a opção ${option} exige um valor."
  fi
}

is_non_negative_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

normalize_sql_dialect() {
  case "${SQL_DIALECT^^}" in
  OGRSQL)
    SQL_DIALECT="OGRSQL"
    ;;

  SQLITE)
    SQL_DIALECT="SQLite"
    ;;

  *)
    error \
      "dialeto SQL inválido: ${SQL_DIALECT}. Use OGRSQL ou SQLite."
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
    error "informe o arquivo ou datasource de entrada antes das opções."
    ;;
  esac

  INPUT="$1"
  shift

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

    -h | --help)
      usage 0
      ;;

    --)
      shift

      if [[ $# -gt 0 ]]; then
        error "argumento posicional inesperado: $1"
      fi
      ;;

    -*)
      error "opção inválida: $1"
      ;;

    *)
      error "argumento posicional inesperado: $1"
      ;;
    esac
  done
}

###############################################################################
# VALIDAÇÃO DA CONFIGURAÇÃO
###############################################################################

validate_configuration() {
  if [[ ! -e "$INPUT" ]]; then
    error "arquivo ou datasource não encontrado: $INPUT"
  fi

  if ! is_non_negative_integer "$TARGET_SRID"; then
    error "o SRID deve ser um número inteiro positivo: $TARGET_SRID"
  fi

  if [[ "$TARGET_SRID" -eq 0 ]]; then
    error "o SRID deve ser maior que zero."
  fi

  if ! is_non_negative_integer "$PRECISION"; then
    error "a precisão deve ser um número inteiro: $PRECISION"
  fi

  normalize_sql_dialect
}

###############################################################################
# LEITURA DE LAYERS
###############################################################################

read_layers() {
  local line
  local layer_name

  LAYERS=()

  while IFS= read -r line; do
    # Exemplos de saída do ogrinfo:
    #
    #   1: municipios (Multi Polygon)
    #   2: rede_agua (Line String)
    #
    # Remove:
    #   - o índice inicial;
    #   - o tipo geométrico final.
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
    ogrinfo -ro "$INPUT" 2>/dev/null |
      grep -E '^[[:space:]]*[0-9]+:[[:space:]]*' ||
      true
  )
}

print_layers() {
  local layer_name

  if [[ ${#LAYERS[@]} -eq 0 ]]; then
    info "Nenhuma layer encontrada."
    return
  fi

  info "Layers disponíveis:"

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

###############################################################################
# SELEÇÃO DA LAYER
###############################################################################

select_layer() {
  # Uma layer informada explicitamente sempre deve existir.
  if [[ -n "$LAYER" ]]; then
    if ! layer_exists "$LAYER"; then
      printf 'Erro: layer não encontrada: %s\n\n' "$LAYER" >&2
      print_layers >&2
      exit 1
    fi

    return
  fi

  # No modo SQL não é necessário selecionar uma layer.
  if [[ -n "$SQL" ]]; then
    return
  fi

  case "${#LAYERS[@]}" in
  0)
    error "não foi possível identificar nenhuma layer em: $INPUT"
    ;;

  1)
    LAYER="${LAYERS[0]}"
    ;;

  *)
    printf '%s\n' \
      "Erro: o datasource possui mais de uma layer." \
      "Informe a layer desejada usando --layer." \
      >&2

    printf '\n' >&2
    print_layers >&2
    exit 1
    ;;
  esac
}

###############################################################################
# NOME DO ARQUIVO
###############################################################################

safe_name() {
  local value="$1"

  value="$(
    printf '%s' "$value" |
      sed -E '
                s/[[:space:]]+/_/g
                s/[^[:alnum:]_.-]+/_/g
                s/_+/_/g
                s/^_+//
                s/_+$//
            '
  )"

  printf '%s\n' "$value"
}

get_input_name() {
  local input_name

  input_name="$(basename -- "$INPUT")"

  # Remove apenas a última extensão.
  #
  # Exemplos:
  #   municipios.shp -> municipios
  #   base.gpkg      -> base
  #   dados.gdb      -> dados
  input_name="${input_name%.*}"

  input_name="$(safe_name "$input_name")"

  if [[ -z "$input_name" ]]; then
    input_name="export"
  fi

  printf '%s\n' "$input_name"
}

build_default_output() {
  local input_name
  local safe_layer

  input_name="$(get_input_name)"

  if [[ -n "$SQL" ]]; then
    if [[ -n "$LAYER" ]]; then
      safe_layer="$(safe_name "$LAYER")"
      OUT="${input_name}_${safe_layer}_sql.geojson"
    else
      OUT="${input_name}_sql.geojson"
    fi

    return
  fi

  OUT="${input_name}.geojson"
}

prepare_output() {
  if [[ -z "$OUT" ]]; then
    build_default_output
  fi

  if [[ "${OUT,,}" != *.geojson ]]; then
    OUT="${OUT}.geojson"
  fi

  mkdir -p -- "$(dirname -- "$OUT")"
}

###############################################################################
# CONFIGURAÇÃO DO OGR2OGR
###############################################################################

build_ogr_arguments() {
  local -n args_reference="$1"

  args_reference=(
    -f "GeoJSON"
    -overwrite
    -t_srs "EPSG:${TARGET_SRID}"
    -lco "COORDINATE_PRECISION=${PRECISION}"
  )

  # O RFC 7946 exige coordenadas geográficas em WGS 84.
  if [[ "$TARGET_SRID" == "4326" ]]; then
    args_reference+=(
      -lco "RFC7946=YES"
    )
  fi

  if $WRITE_BBOX; then
    args_reference+=(
      -lco "WRITE_BBOX=YES"
    )
  fi

  if ! $KEEP_Z; then
    args_reference+=(
      -dim "XY"
    )
  fi

  if $SKIP_FAILURES; then
    args_reference+=(
      -skipfailures
    )
  fi

  # O arquivo de saída e o datasource devem vir depois das opções gerais.
  args_reference+=(
    "$OUT"
    "$INPUT"
  )

  if [[ -n "$SQL" ]]; then
    args_reference+=(
      -sql "$SQL"
      -dialect "$SQL_DIALECT"
    )
  else
    args_reference+=(
      "$LAYER"
    )
  fi
}

###############################################################################
# RELATÓRIO
###############################################################################

print_configuration() {
  info "Conversão iniciada"
  printf 'Entrada       : %s\n' "$INPUT"

  if [[ -n "$LAYER" ]]; then
    printf 'Layer         : %s\n' "$LAYER"
  elif [[ -n "$SQL" ]]; then
    printf 'Layer         : definida pela consulta SQL\n'
  fi

  printf 'Saída         : %s\n' "$OUT"
  printf 'SRID          : EPSG:%s\n' "$TARGET_SRID"
  printf 'Precisão      : %s\n' "$PRECISION"
  printf 'Manter Z      : %s\n' "$KEEP_Z"
  printf 'Escrever bbox : %s\n' "$WRITE_BBOX"
  printf 'Ignorar falhas: %s\n' "$SKIP_FAILURES"

  if [[ -n "$SQL" ]]; then
    printf 'Dialeto       : %s\n' "$SQL_DIALECT"
    printf 'SQL           : %s\n' "$SQL"
  fi

  printf '\n'
}

###############################################################################
# EXPORTAÇÃO
###############################################################################

convert_to_geojson() {
  local -a ogr_arguments=()

  build_ogr_arguments ogr_arguments

  rm -f -- "$OUT"

  if ! ogr2ogr "${ogr_arguments[@]}"; then
    rm -f -- "$OUT"
    error "falha durante a conversão."
  fi
}

###############################################################################
# VALIDAÇÃO DO RESULTADO
###############################################################################

validate_output() {
  if [[ ! -f "$OUT" ]]; then
    error "o arquivo GeoJSON não foi criado: $OUT"
  fi

  if [[ ! -s "$OUT" ]]; then
    rm -f -- "$OUT"
    error "o arquivo GeoJSON foi criado vazio: $OUT"
  fi

  if ! ogrinfo -ro -so "$OUT" >/dev/null 2>&1; then
    rm -f -- "$OUT"
    error "o arquivo criado não pôde ser validado pelo GDAL: $OUT"
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

  if [[ ${#LAYERS[@]} -eq 0 ]]; then
    error "não foi possível identificar nenhuma layer em: $INPUT"
  fi

  select_layer
  prepare_output
  print_configuration
  convert_to_geojson
  validate_output

  info "Conversão concluída com sucesso."
  info "Arquivo gerado: $OUT"
}

main "$@"
