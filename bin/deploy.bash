#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ..

echo "Checking sudo permissions!"
# check if executed with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Creating directories..."
mkdir -p "system/postgres-data"

echo "Creating .env file..."
cp -n .env.dist .env

echo "Building containers"
bin/build.bash

cd "${WORK_DIR}"
