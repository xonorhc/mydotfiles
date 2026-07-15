#!/usr/bin/env bash

# Configurações de segurança do Bash
set -euo pipefail

# Função para exibir ajuda
show_help() {
    echo "Uso: $0 <arquivo_espacial> [nome_da_camada]"
    echo ""
    echo "Formatos suportados: .gpkg, .shp, .kmz, .kml"
    echo "Se o arquivo tiver múltiplas camadas, você pode passar o nome da camada como segundo argumento."
    exit 1
}

# Verifica se o arquivo foi passado como argumento
if [ "$#" -lt 1 ]; then
    show_help
fi

FILE="$1"
LAYER="${2:-}"

# Verifica se os utilitários necessários estão instalados
for cmd in ogrinfo ogr2ogr pspg; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Erro: O utilitário '$cmd' não está instalado." >&2
        exit 1
    fi
done

# Verifica se o arquivo físico existe
if [ ! -f "$FILE" ]; then
    echo "Erro: O arquivo '$FILE' não foi encontrado." >&2
    exit 1
fi

# Extrai a extensão em letras minúsculas
EXT="${FILE##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

# Valida se a extensão é suportada pelo script
case "$EXT" in
    gpkg|shp|kmz|kml)
        ;;
    *)
        echo "Erro: Extensão '.${EXT}' não suportada. Use GPKG, SHP, KMZ ou KML." >&2
        exit 1
        ;;
esac

echo "Analisando metadados de: $FILE..." >&2

# Obtém a lista de camadas usando o ogrinfo
LAYERS_LIST=$(ogrinfo -ro -q "$FILE" | awk -F': ' '/^[0-9]+:/ {print $2}' | sed 's/ (.*)$//')
LAYER_COUNT=$(echo "$LAYERS_LIST" | grep -c '^' || true)

if [ "$LAYER_COUNT" -eq 0 ]; then
    echo "Erro: Nenhuma camada espacial encontrada no arquivo." >&2
    exit 1
fi

# Se o usuário não especificou uma camada e o arquivo tem mais de uma
if [ -z "$LAYER" ] && [ "$LAYER_COUNT" -gt 1 ]; then
    echo "--------------------------------------------------" >&2
    echo "Aviso: O arquivo possui múltiplas camadas ($LAYER_COUNT):" >&2
    echo "$LAYERS_LIST" | sed 's/^/  - /' >&2
    echo "--------------------------------------------------" >&2
    # Seleciona automaticamente a primeira camada, mas avisa o usuário
    LAYER=$(echo "$LAYERS_LIST" | head -n 1)
    echo "Selecionando automaticamente a primeira camada: '$LAYER'" >&2
    echo "Para ver outra camada, execute: $0 \"$FILE\" \"nome_da_camada\"" >&2
    echo "--------------------------------------------------" >&2
    sleep 1
elif [ -z "$LAYER" ]; then
    # Se só existe uma camada, seleciona ela por padrão
    LAYER=$(echo "$LAYERS_LIST" | head -n 1)
fi

echo "Carregando a camada '$LAYER' no pspg..." >&2

# Executa a extração via GDAL e joga para o pspg
ogr2ogr -f CSV /vsistdout/ "$FILE" "$LAYER" \
    -lco SEPARATOR=TAB \
    -limit 500 | \
    pspg --tsv --border 2
