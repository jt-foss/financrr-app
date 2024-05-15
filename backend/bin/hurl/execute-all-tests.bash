#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ../../

# Setting admin token
echo "Setting admin token..."
TOKEN_OUTPUT=$(bash bin/hurl/set-admin-token.bash)
TOKEN=$(echo "$TOKEN_OUTPUT" | grep "Token:" | cut -d ' ' -f 2)
if [ -n "$TOKEN" ]; then
    export HURL_admin_token="$TOKEN"
    echo "HURL_admin_token set to $HURL_admin_token"
else
    echo "Failed to set HURL_admin_token."
    exit 1
fi

echo "Running the tests..."
docker compose -f compose.yml -f compose.test.yml run --rm -T hurl --test --color --glob "/tests/**/*.hurl"
wait

cd "${WORK_DIR}"
