#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Creating .env file..."
set +e
cp -n .env.dist .env
set -e

cd "${WORK_DIR}"
