GET http://rust:8080/api/status/health
HTTP 200

POST http://rust:8080/api/v1/session
{
  "username": "admin",
  "password": "Financrr123",
  "session_name": "test_session"
}
HTTP 201
