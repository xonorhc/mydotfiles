#!/usr/bin/env bash

# Uso:
# ./ogrinfo_md.sh [-i arquivo] [-d diretorio] [-r] [-o saida.md]
#
# Opções:
# -i  Arquivo específico
# -d  Diretório (processa múltiplos arquivos)
# -r  Inclui subdiretórios
# -o  Arquivo de saída (default: ogrinfo_report.md)

set -e

OUTPUT="ogrinfo_report.md"
INPUT_FILE=""
INPUT_DIR=""
RECURSIVE=false

# Parse de argumentos
while getopts "i:d:o:r" opt; do
  case $opt in
    i) INPUT_FILE="$OPTARG" ;;
    d) INPUT_DIR="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    r) RECURSIVE=true ;;
    *) echo "Uso inválido"; exit 1 ;;
  esac
done

# Validação
if [[ -z "$INPUT_FILE" && -z "$INPUT_DIR" ]]; then
  echo "Erro: informe -i (arquivo) ou -d (diretório)"
  exit 1
fi

# Tipos suportados (ajuste conforme necessário)
EXTENSIONS=("shp" "gpkg" "geojson" "json" "kml" "gml")

# Função para verificar extensão
is_valid_file() {
  local file="$1"
  for ext in "${EXTENSIONS[@]}"; do
    if [[ "$file" == *.$ext ]]; then
      return 0
    fi
  done
  return 1
}

# Inicializa saída
echo "# Relatório OGRINFO" > "$OUTPUT"
echo "Gerado em: $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Função principal
process_file() {
  local file="$1"

  echo "Processando: $file"

  echo "## Arquivo: $file" >> "$OUTPUT"
  echo '```' >> "$OUTPUT"

  if [[ "$file" == *.kmz ]]; then
    ogrinfo -al -so "/vsizip/$file" >> "$OUTPUT" 2>&1
  else
    ogrinfo -al -so "$file" >> "$OUTPUT" 2>&1
  fi

  echo '```' >> "$OUTPUT"
  echo "" >> "$OUTPUT"
}

# Execução para arquivo único
if [[ -n "$INPUT_FILE" ]]; then
  process_file "$INPUT_FILE"
fi

# Execução para diretório
if [[ -n "$INPUT_DIR" ]]; then
  if $RECURSIVE; then
    FILES=$(find "$INPUT_DIR" -type f)
  else
    FILES=$(find "$INPUT_DIR" -maxdepth 1 -type f)
  fi

  while IFS= read -r file; do
    if is_valid_file "$file"; then
      process_file "$file"
    fi
  done <<< "$FILES"
fi

echo "Concluído. Saída em: $OUTPUT"
