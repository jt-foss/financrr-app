import requests


def test_status_endpoint():
    response = requests.get("http://127.0.0.1:8080/api/status/health")
    assert response.status_code == 200
