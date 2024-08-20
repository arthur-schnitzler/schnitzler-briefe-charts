#!/bin/bash

rm -rf ./data/editions
mkdir -p ./data/editions
rm -rf ./data/indices
mkdir -p ./data/indices
rm -rf ./data/meta
mkdir -p ./data/meta
rm -rf ./data/tocs
mkdir -p ./data/tocs

rm main.zip

wget https://github.com/arthur-schnitzler/schnitzler-briefe-data/archive/refs/heads/main.zip
unzip main
rm main.zip
mv ./schnitzler-briefe-data/data/editions ./data
mv ./schnitzler-briefe-data/data/indices ./data
mv ./schnitzler-briefe-data/data/meta ./data
mv ./schnitzler-briefe-data/data/tocs ./data

rm -rf ./schnitzler-briefe-data

echo "and now some XSLTs"
ant
