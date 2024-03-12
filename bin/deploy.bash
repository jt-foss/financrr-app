#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Installing..."
bin/install.bash

echo "Stopping containers"
docker compose down -v

echo "Building containers"
bin/build.bash

echo "Starting containers"
docker compose up -d

cd "${WORK_DIR}"
