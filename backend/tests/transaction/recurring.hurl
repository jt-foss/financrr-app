# Try to get all recurring transactions with out a token
GET {{api_v1}}/transaction/recurring
HTTP 401
[Asserts]
body == "{\"api_code\":{\"code\":1006,\"message\":\"No bearer token provided!\"},\"details\":\"No token provided!\",\"reference\":null}"

# Assert that there are no recurring transactions
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 0

# Create a test account
POST {{api_v1}}/account
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "name": "Test Account",
  "description": null,
  "iban": null,
  "original_balance": 10000,
  "currency_id": 2
}
HTTP 201
[Captures]
test_acc_id: jsonpath "$['id']"

# Create a template
POST {{api_v1}}/transaction/template
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "source_id": null,
  "destination_id": {{test_acc_id}},
  "amount": 1000,
  "currency_id": 2,
  "name": "10€ Deposit",
  "description": "A longer description bla bla",
  "budget_id": null
}
HTTP 201
[Captures]
template_id: jsonpath "$['id']"

# Create a recurring transaction (Every monday)
POST {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "template_id": {{template_id}},
  "recurring_rule": {
    "cron_pattern": {
      "day_of_month": "*",
      "month": "*",
      "day_of_week": "1"
    }
  }
}
HTTP 201
[Captures]
recurring_id: jsonpath "$['id']"

# Assert that there is one recurring transaction
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 1

# Update the recurring transaction (Every monday and tuesday)
PATCH {{api_v1}}/transaction/recurring/{{recurring_id}}
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
    "template_id": {{template_id}},
    "recurring_rule": {
        "cron_pattern": {
        "day_of_month": "*",
        "month": "*",
        "day_of_week": "1,2"
        }
    }
}
HTTP 200

# Assert that there is one recurring transaction
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 1

# Delete the template
DELETE {{api_v1}}/transaction/template/{{template_id}}
Authorization: Bearer {{admin_token}}
HTTP 204

# Assert that there are no recurring transactions
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 0

# Create a new template
POST {{api_v1}}/transaction/template
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "source_id": null,
  "destination_id": {{test_acc_id}},
  "amount": 1000,
  "currency_id": 2,
  "name": "10€ Deposit",
  "description": "A longer description bla bla",
  "budget_id": null
}
HTTP 201
[Captures]
template_id: jsonpath "$['id']"

# Create a recurring transaction (Every monday)
POST {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "template_id": {{template_id}},
  "recurring_rule": {
    "cron_pattern": {
      "day_of_month": "*",
      "month": "*",
      "day_of_week": "1"
    }
  }
}
HTTP 201
[Captures]
recurring_id: jsonpath "$['id']"

# Assert that there is one recurring transaction
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 1

# Delete the recurring transaction
DELETE {{api_v1}}/transaction/recurring/{{recurring_id}}
Authorization: Bearer {{admin_token}}
HTTP 204

# Assert that there are no recurring transactions
GET {{api_v1}}/transaction/recurring
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 0

# Delete the template
DELETE {{api_v1}}/transaction/template/{{template_id}}
Authorization: Bearer {{admin_token}}
HTTP 204

# Delete the test account
DELETE {{api_v1}}/account/{{test_acc_id}}
Authorization: Bearer {{admin_token}}
HTTP 204
