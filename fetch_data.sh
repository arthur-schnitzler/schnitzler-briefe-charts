#!/bin/bash

# PMB listplace.xml lokal cachen (wird von den XSLTs verwendet)
mkdir -p ./temp/indices
echo "Downloading PMB listplace.xml..."
if wget -q -O ./temp/indices/listplace.xml.tmp https://pmb.acdh.oeaw.ac.at/media/listplace.xml; then
    mv ./temp/indices/listplace.xml.tmp ./temp/indices/listplace.xml
    echo "listplace.xml erfolgreich heruntergeladen."
elif [ -f ./temp/indices/listplace.xml ]; then
    echo "Download fehlgeschlagen – verwende gecachte listplace.xml."
    rm -f ./temp/indices/listplace.xml.tmp
else
    echo "FEHLER: listplace.xml konnte nicht geladen werden und kein Cache vorhanden."
    exit 1
fi

rm -rf ./data/editions
mkdir -p ./data/editions
rm -rf ./data/indices
mkdir -p ./data/indices
rm -rf ./data/meta
mkdir -p ./data/meta
rm -rf ./data/tocs
mkdir -p ./data/tocs

rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-briefe-data/archive/refs/heads/main.zip
unzip main

mv ./schnitzler-briefe-data-main/data .
rm -rf ./data/xslts
rm main.zip
rm -rf ./schnitzler-briefe-data-main

echo "Generating statistics JSON files (before ant deletes data/)"
cd statistiken/allgemeiner-text
python3 generate_gesamtstatistik.py
python3 generate_statistiken_visualizations.py
cd ../..

echo "and now some XSLTs"
ant
