#!/usr/bin/env bash

# Configurações de segurança do Bash
set -euo pipefail

# Quantidade máxima de feições exibidas.
# Pode ser sobrescrita, por exemplo:
#   FEATURE_LIMIT=1000 ./visualizar-espacial.sh arquivo.gpkg
FEATURE_LIMIT="${FEATURE_LIMIT:-500}"

show_help() {
  cat >&2 <<EOF
Uso:
  $0 <arquivo_espacial> [nome_da_camada]

Formatos suportados:
  .gpkg, .shp, .kmz, .kml

Se o arquivo tiver múltiplas camadas, o nome da camada pode ser
informado como segundo argumento.

Exemplos:
  $0 dados.gpkg
  $0 dados.gpkg municipios
  FEATURE_LIMIT=1000 $0 dados.gpkg municipios
EOF

  exit 1
}

# Exige pelo menos o caminho do arquivo.
if [ "$#" -lt 1 ]; then
  show_help
fi

FILE="$1"
LAYER="${2:-}"

# Verifica as dependências.
for cmd in ogrinfo ogr2ogr vd; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Erro: o utilitário '$cmd' não está instalado." >&2

    if [ "$cmd" = "vd" ]; then
      echo "Instale o VisiData e verifique se o comando 'vd' está no PATH." >&2
    fi

    exit 1
  fi
done

# Verifica se o arquivo existe.
if [ ! -f "$FILE" ]; then
  echo "Erro: o arquivo '$FILE' não foi encontrado." >&2
  exit 1
fi

# Obtém a extensão em letras minúsculas.
EXT="${FILE##*.}"
EXT="${EXT,,}"

# Valida a extensão.
case "$EXT" in
gpkg | shp | kmz | kml)
  ;;
*)
  echo "Erro: extensão '.${EXT}' não suportada." >&2
  echo "Use GPKG, SHP, KMZ ou KML." >&2
  exit 1
  ;;
esac

echo "Analisando metadados de: $FILE..." >&2

# Lê as camadas em um array.
#
# Exemplo de saída esperada do ogrinfo:
#   1: municipios (Multi Polygon)
#   2: rodovias (Line String)
#
# O sed remove apenas a indicação do tipo geométrico no final.
mapfile -t LAYERS < <(
  ogrinfo -ro -q "$FILE" |
    awk -F': ' '/^[[:space:]]*[0-9]+:/ {
            sub(/^[[:space:]]*[0-9]+:[[:space:]]*/, "")
            print
        }' |
    sed -E 's/[[:space:]]+\([^()]*(\([^()]*\))?[^()]*\)$//'
)

LAYER_COUNT="${#LAYERS[@]}"

if [ "$LAYER_COUNT" -eq 0 ]; then
  echo "Erro: nenhuma camada espacial foi encontrada no arquivo." >&2
  exit 1
fi

# Seleciona uma camada automaticamente quando nenhuma foi informada.
if [ -z "$LAYER" ]; then
  LAYER="${LAYERS[0]}"

  if [ "$LAYER_COUNT" -gt 1 ]; then
    echo "--------------------------------------------------" >&2
    echo "Aviso: o arquivo possui $LAYER_COUNT camadas:" >&2

    for AVAILABLE_LAYER in "${LAYERS[@]}"; do
      printf '  - %s\n' "$AVAILABLE_LAYER" >&2
    done

    echo "--------------------------------------------------" >&2
    echo "Selecionando automaticamente: '$LAYER'" >&2
    printf 'Para abrir outra camada:\n  %q %q %q\n' \
      "$0" "$FILE" "nome_da_camada" >&2
    echo "--------------------------------------------------" >&2
  fi
else
  # Valida se a camada informada realmente existe.
  LAYER_FOUND=false

  for AVAILABLE_LAYER in "${LAYERS[@]}"; do
    if [ "$AVAILABLE_LAYER" = "$LAYER" ]; then
      LAYER_FOUND=true
      break
    fi
  done

  if [ "$LAYER_FOUND" = false ]; then
    echo "Erro: a camada '$LAYER' não foi encontrada." >&2
    echo "Camadas disponíveis:" >&2

    for AVAILABLE_LAYER in "${LAYERS[@]}"; do
      printf '  - %s\n' "$AVAILABLE_LAYER" >&2
    done

    exit 1
  fi
fi

echo "Carregando a camada '$LAYER' no VisiData..." >&2
echo "Limite de feições: $FEATURE_LIMIT" >&2

# Converte a camada para TSV e envia o resultado ao VisiData.
#
# -f tsv:
#   força o VisiData a usar o leitor de TSV, mesmo recebendo dados
#   pela entrada padrão.
#
# GEOMETRY=AS_WKT:
#   inclui a geometria como uma coluna textual WKT.
#
# O argumento "-" faz o VisiData ler da entrada padrão.
ogr2ogr \
  -f CSV \
  /vsistdout/ \
  "$FILE" \
  "$LAYER" \
  -lco SEPARATOR=TAB \
  -lco GEOMETRY=AS_WKT \
  -limit "$FEATURE_LIMIT" |
  vd -f tsv -
