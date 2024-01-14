#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Creating directories..."
mkdir -p "system/postgres-data"

echo "Creating .env file..."
cp -n .env.dist .env

cd "${WORK_DIR}"
