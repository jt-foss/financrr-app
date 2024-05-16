#!/usr/bin/env bash

# prepare
set -x  # Add this line
WORK_DIR="$(pwd)"
cd "$(dirname "$0")"
cd ../../

# Execute the curl command inside the hurl container and capture the response
RESPONSE=$(docker compose -f compose.yml -f compose.test.yml run -T --entrypoint curl hurl -s -X POST 'http://rust:8080/api/v1/session' \
    -H 'Content-Type: application/json' \
    -d '{"username": "admin", "password": "Financrr123", "session_name": "test_session"}' -w "\n%{http_code}")

# Extract the HTTP status code from the response
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

# Extract the response body from the response
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Extract the token from the response body
TOKEN=$(echo "$RESPONSE_BODY" | jq -r '.token')

if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ] && [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
    # Set the HURL_admin_token environment variable on the host machine
    export HURL_admin_token="$TOKEN"
    echo "Token set successfully."
    echo "Token: $HURL_admin_token" # This line has been added to show the token
else
    echo "Failed to extract token."
    echo "HTTP status code: $HTTP_STATUS"
    echo "Response body: $RESPONSE_BODY"
fi

cd "${WORK_DIR}"
