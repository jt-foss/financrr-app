#!/usr/bin/env bash

# prepare
set -e
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ../../

# Function to clean up
cleanup() {
    bash bin/hurl/clean-up.bash
}

# Trap EXIT signal to ensure cleanup is always executed
trap cleanup EXIT

bash bin/hurl/clean-up.bash

bash bin/hurl/start-up.bash

echo "Waiting for the server to start..."
sleep 10
wait

set +e
# Execute the curl command inside the hurl container and capture the response
RESPONSE=$(docker compose -f compose.yml -f compose.test.yml run -T --entrypoint curl hurl -s -X POST 'http://rust:8080/api/v1/session' \
    -H 'Content-Type: application/json' \
    -d '{"username": "admin", "password": "Financrr123", "session_name": "test_session"}' -w "\n%{http_code}" 2>&1)
echo "Curl output: $RESPONSE"
set -e

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

set +e
echo "Running the tests..."
docker compose -f compose.yml -f compose.test.yml run --rm -T hurl --test --color --glob "/tests/**/*.hurl"
TEST_EXIT_CODE=$?
wait
set -e

# Check if tests failed and exit with the test exit code if they did
if [ $TEST_EXIT_CODE -ne 0 ]; then
    exit $TEST_EXIT_CODE
fi

cd "${WORK_DIR}"
