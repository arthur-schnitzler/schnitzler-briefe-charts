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
echo "Checking data directory structure..."
ls -la data/ || echo "data/ not found"
ls -la data/editions/ || echo "data/editions/ not found"
ls -la data/indices/ || echo "data/indices/ not found"
cd statistiken/allgemeiner-text
echo "Current directory: $(pwd)"
echo "Looking for ../../data/editions:"
ls -la ../../data/editions/ || echo "../../data/editions/ not found"
python3 generate_gesamtstatistik.py
python3 generate_statistiken_visualizations.py
cd ../..
