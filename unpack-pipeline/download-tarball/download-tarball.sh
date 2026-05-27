#!/bin/bash

# Download a tarball or other type compressed dataset and the hope to save off the dataset into a shared directory for future steps to use
echo "Download tarball function"
mkdir -p /var/run/argo/outputs/artifacts/tmp/
wget https://maven-datasets.s3.amazonaws.com/Airbnb/Airbnb+Data.zip -O /var/run/argo/outputs/artifacts/tmp/Airbnb+Data.zip
