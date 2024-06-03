#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Building containers"
docker compose build

echo "Pulling containers"
docker compose pull

echo "Stopping containers"
docker compose down -v

echo "Starting containers"
docker compose up -d

cd "${WORK_DIR}"
