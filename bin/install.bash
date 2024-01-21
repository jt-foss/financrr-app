#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Creating .env file..."
cp -n .env.dist .env

cd "${WORK_DIR}"
