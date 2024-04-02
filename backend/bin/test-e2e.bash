#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Installing python dependencies..."
pip install -r e2e-tests/requirements.txt

echo "Installing project..."
bin/install.bash

echo "Building docker containers..."
docker compose build

echo "Starting docker containers..."
docker compose up -d

echo "Running e2e tests..."
pytest e2e-tests

cd "${WORK_DIR}"
