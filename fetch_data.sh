#!/bin/bash

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

echo "and now some XSLTs"
ant

echo "Generating statistics JSON files"
cd statistiken/allgemeiner-text
python3 generate_gesamtstatistik.py
python3 generate_statistiken_visualizations.py
cd ../..
