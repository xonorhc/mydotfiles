#!/usr/bin/env bash

set -euo pipefail

# ==============================
# Uso
# ==============================
# ./dump_repo_md.sh <diretorio_projeto> [arquivo_saida]

if [ "$#" -lt 1 ]; then
  echo "Uso: $(basename "$0") <diretorio_projeto> [arquivo_saida]"
  exit 1
fi

PROJECT_DIR="$1"
OUTPUT_FILE="${2:-dump_projeto.md}"

PROJECT_DIR="$(realpath "$PROJECT_DIR")"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Erro: diretório não encontrado -> $PROJECT_DIR"
  exit 1
fi

# ==============================
# Configuração de limites
# ==============================
MAX_FILE_SIZE_BYTES=$((1024 * 1024)) # 1 MiB
MAX_LINES=200
MAX_CHARS=20000
TRUNCATE_ALWAYS=false

# ==============================
# Extensões consideradas texto
# ==============================
TEXT_EXTENSIONS=(
  "*.md"
  "*.txt"
  "*.sql"
  "*.py"
  "*.sh"
  "*.js"
  "*.ts"
  "*.json"
  "*.yaml"
  "*.yml"
  "*.xml"
  "*.html"
  "*.css"
  ".env"
  "*.ini"
  "*.cfg"
  "*.toml"
  "*.csv"
)

# ==============================
# Caminhos ignorados
# ==============================
EXCLUDE_PATHS=(
  "*/.git/*"
  "*/node_modules/*"
  "*/dist/*"
  "*/build/*"
  "*/.venv/*"
  "*/venv/*"
  "*/__pycache__/*"
  "*/.mypy_cache/*"
  "*/.pytest_cache/*"
  "*/.idea/*"
  "*/.vscode/*"
)

# Opcional:
# Descomente se quiser ignorar os SQLs gigantes de ingest
# EXCLUDE_PATHS+=("*/data/ingest/*")

# ==============================
# Extensões ignoradas
# ==============================
EXCLUDE_EXTENSIONS=(
  "*.gz"
  "*.zip"
  "*.7z"
  "*.rar"
  "*.gpkg"
  "*.sqlite"
  "*.db"
  "*.jpg"
  "*.jpeg"
  "*.png"
  "*.gif"
  "*.webp"
  "*.pdf"
)

# ==============================
# Funções utilitárias
# ==============================
is_text_file() {
  local file="$1"

  if file --brief --mime "$file" | grep -qiE 'text/|application/(json|xml|x-sh|javascript)'; then
    return 0
  fi

  case "$file" in
  *.md | *.txt | *.sql | *.py | *.sh | *.js | *.ts | *.json | *.yaml | *.yml | *.xml | *.html | *.css | *.env | *.ini | *.cfg | *.toml | *.csv)
    return 0
    ;;
  esac

  return 1
}

write_file_full() {
  local file="$1"
  cat "$file" >>"$OUTPUT_FILE"
}

write_file_truncated() {
  local file="$1"

  local total_lines="N/A"
  local total_bytes="N/A"

  total_lines=$(wc -l <"$file" 2>/dev/null || echo "N/A")
  total_bytes=$(wc -c <"$file" 2>/dev/null || echo "N/A")

  awk -v max_lines="$MAX_LINES" -v max_chars="$MAX_CHARS" '
    BEGIN {
      char_count = 0
    }
    NR > max_lines {
      exit
    }
    {
      line = $0
      line_len = length(line)

      # Considera quebra de linha como 1 caractere
      needed = line_len + 1

      if ((char_count + needed) > max_chars) {
        remaining = max_chars - char_count

        if (remaining > 0) {
          if (remaining == 1) {
            printf "\n"
          } else {
            printf "%s\n", substr(line, 1, remaining - 1)
          }
        }

        exit
      }

      print line
      char_count += needed
    }
  ' "$file" >>"$OUTPUT_FILE"

  echo "" >>"$OUTPUT_FILE"
  echo "[TRUNCADO]" >>"$OUTPUT_FILE"
  echo "- linhas_exibidas_max: ${MAX_LINES}" >>"$OUTPUT_FILE"
  echo "- caracteres_exibidos_max: ${MAX_CHARS}" >>"$OUTPUT_FILE"
  echo "- linhas_totais_aprox: ${total_lines}" >>"$OUTPUT_FILE"
  echo "- tamanho_bytes: ${total_bytes}" >>"$OUTPUT_FILE"
}

build_text_find_args() {
  local -n out_ref=$1
  out_ref=("$PROJECT_DIR" -type f "(")

  for i in "${!TEXT_EXTENSIONS[@]}"; do
    if [ "$i" -gt 0 ]; then
      out_ref+=(-o)
    fi
    out_ref+=(-iname "${TEXT_EXTENSIONS[$i]}")
  done

  out_ref+=(")")

  for path in "${EXCLUDE_PATHS[@]}"; do
    out_ref+=(! -path "$path")
  done

  for ext in "${EXCLUDE_EXTENSIONS[@]}"; do
    out_ref+=(! -iname "$ext")
  done
}

build_tree_find_args() {
  local -n out_ref=$1
  out_ref=("$PROJECT_DIR" "(" -type d -o -type f ")")

  for path in "${EXCLUDE_PATHS[@]}"; do
    out_ref+=(! -path "$path")
  done

  for ext in "${EXCLUDE_EXTENSIONS[@]}"; do
    out_ref+=(! -iname "$ext")
  done
}

write_project_tree() {
  local tree_args=()
  build_tree_find_args tree_args

  echo "## Árvore do projeto" >>"$OUTPUT_FILE"
  echo "" >>"$OUTPUT_FILE"
  echo '```text' >>"$OUTPUT_FILE"
  echo "$(basename "$PROJECT_DIR")/" >>"$OUTPUT_FILE"

  find "${tree_args[@]}" | sort | while read -r path; do
    local rel
    rel="${path#${PROJECT_DIR}/}"

    if [ -z "$rel" ] || [ "$rel" = "$PROJECT_DIR" ]; then
      continue
    fi

    local depth
    depth=$(awk -F/ '{print NF-1}' <<<"$rel")

    local name
    name=$(basename "$rel")

    local indent=""
    for ((i = 0; i < depth; i++)); do
      indent+="    "
    done

    if [ -d "$path" ]; then
      printf "%s- %s/\n" "$indent" "$name" >>"$OUTPUT_FILE"
    else
      printf "%s- %s\n" "$indent" "$name" >>"$OUTPUT_FILE"
    fi
  done

  echo '```' >>"$OUTPUT_FILE"
  echo "" >>"$OUTPUT_FILE"
}

# ==============================
# Inicialização do arquivo
# ==============================
: >"$OUTPUT_FILE"

echo "# Dump completo do repositório" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"
echo "_Diretório: ${PROJECT_DIR}_" >>"$OUTPUT_FILE"
echo "_Gerado em: $(date)_" >>"$OUTPUT_FILE"
echo "" >>"$OUTPUT_FILE"

# ==============================
# Árvore do projeto
# ==============================
write_project_tree

# ==============================
# Processamento dos arquivos
# ==============================
find_args=()
build_text_find_args find_args

find "${find_args[@]}" | sort | while read -r file; do
  if ! is_text_file "$file"; then
    continue
  fi

  rel_path="${file#${PROJECT_DIR}/}"
  file_size=$(wc -c <"$file" 2>/dev/null || echo 0)

  echo "## Arquivo: ${rel_path}" >>"$OUTPUT_FILE"
  echo "" >>"$OUTPUT_FILE"
  echo '````' >>"$OUTPUT_FILE"

  if [ "$TRUNCATE_ALWAYS" = true ]; then
    write_file_truncated "$file"
  else
    if [ "$file_size" -le "$MAX_FILE_SIZE_BYTES" ]; then
      write_file_full "$file"
    else
      write_file_truncated "$file"
    fi
  fi

  echo "" >>"$OUTPUT_FILE"
  echo '````' >>"$OUTPUT_FILE"
  echo "" >>"$OUTPUT_FILE"
done

echo "Dump gerado com sucesso: $OUTPUT_FILE"
