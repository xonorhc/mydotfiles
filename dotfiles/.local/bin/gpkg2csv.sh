#!/bin/bash

# --- Validação dos Argumentos ---
# Verifica se os dois argumentos obrigatórios foram passados
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Erro: Parâmetros ausentes."
    echo "Uso correto: $0 <caminho_do_geopackage> <nome_da_camada>"
    echo "Exemplo:    $0 dados/mapa.gpkg estradas_principais"
    exit 1
fi

# Captura os parâmetros dos argumentos de entrada
GEOPACKAGE="$1"
CAMADA="$2"

# Valida se o arquivo GeoPackage realmente existe no caminho informado
if [ ! -f "$GEOPACKAGE" ]; then
    echo "Erro: O arquivo GeoPackage '$GEOPACKAGE' não foi encontrado."
    exit 1
fi

# --- Padronização da Saída ---
# Extrai o nome do arquivo sem a extensão .gpkg e sem o caminho de pastas
NOME_BASE=$(basename "$GEOPACKAGE" .gpkg)
# Define o nome do CSV combinando o nome do arquivo original + o nome da camada
CSV_SAIDA="${NOME_BASE}_${CAMADA}.csv"

# --- Execução do Comando GDAL/OGR ---
echo "--------------------------------------------------"
echo "Processando: $GEOPACKAGE"
echo "Camada:      $CAMADA"
echo "Exportando para: $CSV_SAIDA"
echo "--------------------------------------------------"

ogr2ogr -f "CSV" "$CSV_SAIDA" "$GEOPACKAGE" "$CAMADA" \
  -lco GEOMETRY=AS_WKT \
  -lco SEPARATOR=COMMA \
  -overwrite

# --- Verificação de Sucesso ---
if [ $? -eq 0 ]; then
    echo "Sucesso! Arquivo exportado com êxito."
else
    echo "Erro na exportação. Verifique se o nome da camada está correto."
    exit 1
fi
