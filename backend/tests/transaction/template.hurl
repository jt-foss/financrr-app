# Try to get all templates without supplying a token
GET {{api_v1}}/transaction/template
HTTP 401
[Asserts]
body == "{\"api_code\":{\"code\":1006,\"message\":\"No bearer token provided!\"},\"details\":\"No token provided!\",\"reference\":null}"

# Assert that there are now templates
GET {{api_v1}}/transaction/template
Authorization: Bearer {{admin_token}}
HTTP 200
[Asserts]
jsonpath "$['_metadata']['total']" == 0

# Create first test account
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
test_acc1_id: jsonpath "$['id']"

# Create second test account
POST {{api_v1}}/account
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "name": "Test Account 2",
  "description": null,
  "iban": null,
  "original_balance": 10000,
  "currency_id": 2
}
HTTP 201
[Captures]
test_acc2_id: jsonpath "$['id']"

# Create a deposit template
POST {{api_v1}}/transaction/template
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
  "source_id": null,
  "destination_id": {{test_acc1_id}},
  "amount": 1000,
  "currency_id": 2,
  "name": "10€ Deposit",
  "description": "A longer description bla bla",
  "budget_id": null
}
HTTP 201
[Captures]
template_id: jsonpath "$['id']"

# Create a deposit transaction
POST {{api_v1}}/transaction/from-template
Authorization: Bearer {{admin_token}}
Content-Type: application/json
{
    "template": {{template_id}},
    "executed_at": "2024-05-21T21:03:23.251Z"
}
HTTP 201
[Captures]
deposit_transaction_id: jsonpath "$['id']"

# Delete the deposit transaction
DELETE {{api_v1}}/transaction/{{deposit_transaction_id}}
Authorization: Bearer {{admin_token}}
HTTP 204
