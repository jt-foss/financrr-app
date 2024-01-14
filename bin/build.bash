#!/usr/bin/env bash
# This script exists due to Postgres creating directories with root permissions
# We mount these directories to the docker container, so we need to change the permissions

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

echo "Changing permissions..."
sudo chmod -R 777 system/postgres-data

echo "Building containers."
docker compose build

cd "${WORK_DIR}"
