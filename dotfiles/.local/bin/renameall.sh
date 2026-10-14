#!/usr/bin/env bash

set -euo pipefail

usage() {
  local exit_code="${1:-1}"

  cat <<EOF
Usage: $0 [options] <directory>

Options:
  -n, --dry-run
      Show changes without renaming anything.

  --case MODE
      Name capitalization mode:
        lower (default)
        upper
        title

  --prefix-date MODE
      Add a date at the beginning of the name:
        current
        created
        modified

  --suffix-date MODE
      Add a date at the end of the name, before the extension:
        current
        created
        modified

  --rename-directories
      Also normalize and rename subdirectories.
      By default, only files are renamed.

  -h, --help
      Show this help.

Default behavior:
  - Normalize file names.
  - Replace spaces, hyphens and special characters with underscores.
  - Convert names to lowercase.
  - Do not add a date.
  - Do not rename subdirectories.
  - Do not duplicate an existing date prefix or suffix.

Date modes:
  current
      Current date.

  created
      Creation date, falling back to modification date when unavailable.

  modified
      Last modification date.

Case modes:
  lower
      example_file.txt

  upper
      EXAMPLE_FILE.txt

  title
      Example_File.txt

Examples:
  # Normalize file names without adding dates:
  $0 /data

  # Preview changes:
  $0 --dry-run /data

  # Use uppercase names:
  $0 --case upper /data

  # Add creation date as prefix:
  $0 --prefix-date created /data

  # Add current date as prefix:
  $0 --prefix-date current /data

  # Add modification date as suffix:
  $0 --suffix-date modified /data

  # Add creation date as suffix:
  $0 --suffix-date created /data

  # Add dates at both ends:
  $0 --prefix-date created --suffix-date modified /data

  # Also normalize subdirectory names:
  $0 --rename-directories /data

  # Normalize subdirectories and add a creation-date prefix:
  $0 --rename-directories --prefix-date created /data
EOF

  exit "$exit_code"
}

###############################################################################
# CONFIGURAÇÃO PADRÃO
###############################################################################

DRY_RUN=false
CASE_MODE="lower"
PREFIX_DATE=""
SUFFIX_DATE=""
RENAME_DIRECTORIES=false

###############################################################################
# VALIDAÇÃO DOS MODOS DE DATA
###############################################################################

validate_date_mode() {
  local option="$1"
  local mode="$2"

  case "$mode" in
  current | created | modified)
    return 0
    ;;
  esac

  echo "Error: invalid $option value: '$mode'." >&2
  echo "Valid values: current, created, modified." >&2
  exit 1
}

###############################################################################
# PARÂMETROS
###############################################################################

while [[ $# -gt 0 ]]; do
  case "$1" in
  -n | --dry-run)
    DRY_RUN=true
    shift
    ;;

  --case)
    [ $# -ge 2 ] || usage

    CASE_MODE="$2"

    case "$CASE_MODE" in
    lower | upper | title)
      ;;
    *)
      echo "Error: invalid --case value: '$CASE_MODE'." >&2
      echo "Valid values: lower, upper, title." >&2
      exit 1
      ;;
    esac

    shift 2
    ;;

  --prefix-date)
    [ $# -ge 2 ] || usage

    PREFIX_DATE="$2"
    validate_date_mode "--prefix-date" "$PREFIX_DATE" true

    shift 2
    ;;

  --suffix-date)
    [ $# -ge 2 ] || usage

    SUFFIX_DATE="$2"
    validate_date_mode "--suffix-date" "$SUFFIX_DATE"

    shift 2
    ;;

  --rename-directories)
    RENAME_DIRECTORIES=true
    shift
    ;;

  -h | --help)
    usage 0
    ;;

  -*)
    echo "Error: unknown option: '$1'." >&2
    usage
    ;;

  *)
    break
    ;;
  esac
done

###############################################################################
# DIRETÓRIO DE DESTINO
###############################################################################

[ $# -eq 1 ] || usage

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: '$TARGET_DIR' is not a valid directory." >&2
  exit 1
fi

###############################################################################
# DEPENDÊNCIAS
###############################################################################

for required_command in \
  iconv \
  stat \
  date \
  find \
  sed \
  awk \
  tr \
  locale \
  grep \
  dirname \
  basename \
  mv; do

  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Error: command '$required_command' is required." >&2
    exit 1
  fi
done

###############################################################################
# LOCALE UTF-8
###############################################################################

configure_utf8_locale() {
  local available_locales
  local locale_name

  available_locales=$(locale -a 2>/dev/null || true)

  for locale_name in \
    C.UTF-8 \
    C.utf8 \
    en_US.UTF-8 \
    en_US.utf8 \
    pt_BR.UTF-8 \
    pt_BR.utf8; do

    if printf '%s\n' "$available_locales" |
      grep -Fxiq "$locale_name"; then

      export LC_CTYPE="$locale_name"
      return 0
    fi
  done

  echo "Error: no UTF-8 locale is available." >&2
  echo "Available locales:" >&2
  printf '%s\n' "$available_locales" >&2

  return 1
}

configure_utf8_locale

###############################################################################
# NORMALIZAÇÃO DE MAIÚSCULAS E MINÚSCULAS
###############################################################################

normalize_case() {
  local value="$1"

  case "$CASE_MODE" in
  lower)
    printf '%s\n' "$value" |
      LC_ALL=C tr '[:upper:]' '[:lower:]'
    ;;

  upper)
    printf '%s\n' "$value" |
      LC_ALL=C tr '[:lower:]' '[:upper:]'
    ;;

  title)
    printf '%s\n' "$value" |
      LC_ALL=C awk '
        {
          result = ""
          capitalize = 1

          for (i = 1; i <= length($0); i++) {
            char = substr($0, i, 1)

            if (char == "_") {
              result = result char
              capitalize = 1
            } else if (capitalize) {
              result = result toupper(char)
              capitalize = 0
            } else {
              result = result tolower(char)
            }
          }

          print result
        }
      '
    ;;
  esac
}

###############################################################################
# NORMALIZAÇÃO DO NOME
###############################################################################

normalize_part() {
  local value

  # Todos os caracteres diferentes de letras, números e underscore
  # são convertidos em underscore.
  #
  # Isso inclui hífens, espaços e demais sinais de pontuação.
  value=$(
    printf '%s' "$1" |
      iconv -f UTF-8 -t 'ASCII//TRANSLIT' |
      LC_ALL=C sed -E '
        s/[^A-Za-z0-9_]/_/g;
        s/_+/_/g;
        s/^_+//;
        s/_+$//
      '
  )

  normalize_case "$value"
}

normalize_extension() {
  local extension="$1"

  extension=$(
    printf '%s' "$extension" |
      iconv -f UTF-8 -t 'ASCII//TRANSLIT'
  )

  printf '%s\n' "$extension" |
    LC_ALL=C tr '[:upper:]' '[:lower:]'
}

###############################################################################
# DATAS
###############################################################################

get_date_value() {
  local path="$1"
  local mode="$2"
  local timestamp

  case "$mode" in
  current)
    date '+%Y%m%d'
    ;;

  modified)
    timestamp=$(stat -c '%Y' -- "$path")
    date -d "@$timestamp" '+%Y%m%d'
    ;;

  created)
    timestamp=$(stat -c '%W' -- "$path" 2>/dev/null || printf '0')

    if [[ "$timestamp" =~ ^[0-9]+$ ]] &&
      [ "$timestamp" -gt 0 ]; then

      date -d "@$timestamp" '+%Y%m%d'
    else
      # Alguns sistemas de arquivos não disponibilizam a data de criação.
      # Nesses casos, usa a data da última modificação.
      timestamp=$(stat -c '%Y' -- "$path")
      date -d "@$timestamp" '+%Y%m%d'
    fi
    ;;
  esac
}

has_date_prefix() {
  local name="$1"

  [[ "$name" =~ ^[0-9]{8}_ ]] && return 0
  [[ "$name" =~ ^\.[0-9]{8}_ ]] && return 0

  return 1
}

has_date_suffix() {
  local stem="$1"

  [[ "$stem" =~ _[0-9]{8}$ ]]
}

###############################################################################
# SEPARAÇÃO DO NOME E DA EXTENSÃO
###############################################################################

split_filename() {
  local base="$1"
  local lower_base

  lower_base=$(
    printf '%s' "$base" |
      LC_ALL=C tr '[:upper:]' '[:lower:]'
  )

  # Arquivos ocultos sem extensão, como .env e .gitignore.
  if [[ "$base" =~ ^\.[^.]+$ ]]; then
    printf 'HIDDEN|%s|\n' "${base#.}"
    return
  fi

  case "$lower_base" in
  *.tar.gz)
    printf 'FILE|%s|tar.gz\n' \
      "${base:0:${#base}-7}"
    ;;

  *.tar.bz2)
    printf 'FILE|%s|tar.bz2\n' \
      "${base:0:${#base}-8}"
    ;;

  *.tar.xz)
    printf 'FILE|%s|tar.xz\n' \
      "${base:0:${#base}-7}"
    ;;

  *.tar.zst)
    printf 'FILE|%s|tar.zst\n' \
      "${base:0:${#base}-8}"
    ;;

  *.sql.gz)
    printf 'FILE|%s|sql.gz\n' \
      "${base:0:${#base}-7}"
    ;;

  *.*)
    printf 'FILE|%s|%s\n' \
      "${base%.*}" \
      "${base##*.}"
    ;;

  *)
    printf 'FILE|%s|\n' "$base"
    ;;
  esac
}

split_candidate_suffix() {
  local candidate="$1"
  local lower_candidate

  lower_candidate=$(
    printf '%s' "$candidate" |
      LC_ALL=C tr '[:upper:]' '[:lower:]'
  )

  # Arquivo oculto sem extensão adicional.
  if [[ "$candidate" =~ ^\.[^.]+$ ]]; then
    printf '%s|\n' "$candidate"
    return
  fi

  case "$lower_candidate" in
  *.tar.gz)
    printf '%s|%s\n' \
      "${candidate:0:${#candidate}-7}" \
      "${candidate:${#candidate}-7}"
    ;;

  *.tar.bz2)
    printf '%s|%s\n' \
      "${candidate:0:${#candidate}-8}" \
      "${candidate:${#candidate}-8}"
    ;;

  *.tar.xz)
    printf '%s|%s\n' \
      "${candidate:0:${#candidate}-7}" \
      "${candidate:${#candidate}-7}"
    ;;

  *.tar.zst)
    printf '%s|%s\n' \
      "${candidate:0:${#candidate}-8}" \
      "${candidate:${#candidate}-8}"
    ;;

  *.sql.gz)
    printf '%s|%s\n' \
      "${candidate:0:${#candidate}-7}" \
      "${candidate:${#candidate}-7}"
    ;;

  *.*)
    printf '%s|.%s\n' \
      "${candidate%.*}" \
      "${candidate##*.}"
    ;;

  *)
    printf '%s|\n' "$candidate"
    ;;
  esac
}

###############################################################################
# ADIÇÃO DA DATA
###############################################################################

add_date_prefix() {
  local name="$1"
  local date_value="$2"
  local hidden_name

  # Por padrão, não duplica um prefixo YYYYMMDD_ já existente.
  if has_date_prefix "$name"; then
    printf '%s\n' "$name"
    return 0
  fi

  case "$name" in
  .*)
    hidden_name="${name#.}"
    printf '.%s_%s\n' "$date_value" "$hidden_name"
    ;;

  *)
    printf '%s_%s\n' "$date_value" "$name"
    ;;
  esac
}

add_date_suffix() {
  local name="$1"
  local date_value="$2"
  local hidden=false
  local content
  local type
  local stem
  local extension

  case "$name" in
  .*)
    hidden=true
    content="${name#.}"
    ;;

  *)
    content="$name"
    ;;
  esac

  IFS='|' read -r type stem extension \
    <<<"$(split_filename "$content")"

  # Evita adicionar novamente uma data no sufixo.
  if has_date_suffix "$stem"; then
    printf '%s\n' "$name"
    return 0
  fi

  stem="${stem}_${date_value}"

  if [ -n "$extension" ]; then
    content="${stem}.${extension}"
  else
    content="$stem"
  fi

  if $hidden; then
    printf '.%s\n' "$content"
  else
    printf '%s\n' "$content"
  fi
}

###############################################################################
# TRATAMENTO DE COLISÕES
###############################################################################

path_exists() {
  local path="$1"

  [ -e "$path" ] || [ -L "$path" ]
}

same_file() {
  local source="$1"
  local destination="$2"

  path_exists "$destination" || return 1

  [ "$source" -ef "$destination" ]
}

unique_name() {
  local dir="$1"
  local candidate="$2"

  local original_stem
  local suffix
  local current_candidate
  local counter=1

  IFS='|' read -r original_stem suffix \
    <<<"$(split_candidate_suffix "$candidate")"

  original_stem=$(
    printf '%s\n' "$original_stem" |
      LC_ALL=C sed -E 's/_[0-9]+$//'
  )

  current_candidate="$candidate"

  while path_exists "$dir/$current_candidate"; do
    current_candidate="${original_stem}_${counter}${suffix}"
    counter=$((counter + 1))
  done

  printf '%s\n' "$current_candidate"
}

###############################################################################
# RENOMEAÇÃO SENSÍVEL A MAIÚSCULAS E MINÚSCULAS
###############################################################################

make_temporary_path() {
  local dir="$1"
  local temporary_path

  while true; do
    temporary_path="$dir/.rename_tmp_${$}_${RANDOM}_${RANDOM}"

    if ! path_exists "$temporary_path"; then
      printf '%s\n' "$temporary_path"
      return 0
    fi
  done
}

rename_case_only() {
  local old_path="$1"
  local new_path="$2"
  local temporary_path

  temporary_path=$(make_temporary_path "$(dirname -- "$old_path")")

  mv -- "$old_path" "$temporary_path"

  if ! mv -v -- "$temporary_path" "$new_path"; then
    echo "Error: could not rename '$old_path' to '$new_path'." >&2

    if path_exists "$temporary_path"; then
      mv -- "$temporary_path" "$old_path" 2>/dev/null || true
    fi

    return 1
  fi
}

###############################################################################
# PROCESSAMENTO
###############################################################################

process_item() {
  local item="$1"
  local dir
  local base
  local new_base
  local new_path

  local type
  local stem
  local extension

  local prefix_value
  local suffix_value

  dir=$(dirname -- "$item")
  base=$(basename -- "$item")

  ###########################################################################
  # DIRETÓRIOS
  ###########################################################################

  if [ -d "$item" ]; then
    if ! $RENAME_DIRECTORIES; then
      return 0
    fi

    new_base=$(normalize_part "$base")

  ###########################################################################
  # ARQUIVOS
  ###########################################################################

  else
    IFS='|' read -r type stem extension \
      <<<"$(split_filename "$base")"

    if [ "$type" = "HIDDEN" ]; then
      stem=$(normalize_part "$stem")

      if [ -n "$stem" ]; then
        new_base=".$stem"
      else
        new_base="$base"
      fi
    else
      stem=$(normalize_part "$stem")

      if [ -n "$extension" ]; then
        extension=$(normalize_extension "$extension")
        new_base="${stem}.${extension}"
      else
        new_base="$stem"
      fi
    fi
  fi

  if [ -z "$new_base" ]; then
    echo "Warning: skipped '$item' because the normalized name is empty." >&2
    return 0
  fi

  ###########################################################################
  # PREFIXO DE DATA
  ###########################################################################

  if [ -n "$PREFIX_DATE" ]; then
    prefix_value=$(get_date_value "$item" "$PREFIX_DATE")

    if [ -n "$prefix_value" ]; then
      new_base=$(add_date_prefix "$new_base" "$prefix_value")
    fi
  fi

  ###########################################################################
  # SUFIXO DE DATA
  ###########################################################################

  if [ -n "$SUFFIX_DATE" ]; then
    suffix_value=$(get_date_value "$item" "$SUFFIX_DATE")

    if [ -n "$suffix_value" ]; then
      new_base=$(add_date_suffix "$new_base" "$suffix_value")
    fi
  fi

  ###########################################################################
  # RENOMEAÇÃO
  ###########################################################################

  # O nome já está correto.
  if [ "$base" = "$new_base" ]; then
    return 0
  fi

  new_path="$dir/$new_base"

  if path_exists "$new_path"; then
    if same_file "$item" "$new_path"; then
      # Alteração apenas entre maiúsculas e minúsculas,
      # comum em caminhos do Windows acessados pelo WSL2.
      if $DRY_RUN; then
        printf '[DRY-RUN] %s -> %s\n' "$item" "$new_path"
      else
        rename_case_only "$item" "$new_path"
      fi

      return 0
    fi

    # Existe outro arquivo ou diretório com o nome pretendido.
    new_base=$(unique_name "$dir" "$new_base")
    new_path="$dir/$new_base"
  fi

  if $DRY_RUN; then
    printf '[DRY-RUN] %s -> %s\n' "$item" "$new_path"
  else
    mv -v -- "$item" "$new_path"
  fi
}

###############################################################################
# EXECUÇÃO
###############################################################################

# Processa os filhos antes dos diretórios pais.
#
# O diretório informado em TARGET_DIR nunca é renomeado.
# Os subdiretórios somente são renomeados quando
# --rename-directories for utilizado.
#
# -print0 permite nomes com espaços e quebras de linha.
while IFS= read -r -d '' item; do
  process_item "$item"
done < <(
  find "$TARGET_DIR" \
    -mindepth 1 \
    -depth \
    -print0
)
