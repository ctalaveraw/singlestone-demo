import pytest

import json
import requests
from mock import patch

from fortune_handler import app


@pytest.fixture()
def alb_event():
    return {}


def test_lambda_handler(alb_event, mocker):
    """Test ideal scenario that returns a fortune with a prefix."""
    # First, we'll want to mock the request to make the response strictly assertable
    with patch('requests.get') as mock_request:
        # Also, an environment variable will need to be mocked to test the prefix functionality
        with patch.dict('os.environ', values={"MSG_PREFIX": "Heres a witty fortune prefix:"}):
            # Set the return type to something static
            mock_request.return_value.json.return_value = {
                "fortune": "This is a valid fortune."
            }

            # Make calls
            ret = app.lambda_handler(alb_event, "")
            data = json.loads(ret["body"])

            assert ret["statusCode"] == 200
            assert "fortune" in data
            assert data["fortune"] == "Heres a witty fortune prefix: This is a valid fortune."


def test_lambda_handler_with_whitespace_after_prefix(alb_event, mocker):
    """Test that trailing whitespace is trimmed from the prefix message."""
    with patch('requests.get') as mock_request:
        with patch.dict('os.environ', values={"MSG_PREFIX": "Strip white space after: "}):
            mock_request.return_value.json.return_value = {
                "fortune": "This is a valid fortune."
            }

            ret = app.lambda_handler(alb_event, "")
            data = json.loads(ret["body"])

            assert ret["statusCode"] == 200
            assert "fortune" in data
            assert data["fortune"] == "Strip white space after: This is a valid fortune."


def test_lambda_handler_with_whitespace_before_prefix(alb_event, mocker):
    """Test that leading whitespace is trimmed from the prefix message."""
    with patch('requests.get') as mock_request:
        with patch.dict('os.environ', values={"MSG_PREFIX": " Strip white space before:"}):
            mock_request.return_value.json.return_value = {
                "fortune": "This is a valid fortune."
            }

            ret = app.lambda_handler(alb_event, "")
            data = json.loads(ret["body"])

            assert ret["statusCode"] == 200
            assert "fortune" in data
            assert data["fortune"] == "Strip white space before: This is a valid fortune."


def test_lambda_handler_with_whitespace_before_and_after_prefix(alb_event, mocker):
    """Test that leading & trailing whitespace is trimmed from the prefix message."""
    with patch('requests.get') as mock_request:
        with patch.dict('os.environ', values={"MSG_PREFIX": " Strip white space before and after: "}):
            mock_request.return_value.json.return_value = {
                "fortune": "This is a valid fortune."
            }

            ret = app.lambda_handler(alb_event, "")
            data = json.loads(ret["body"])

            assert ret["statusCode"] == 200
            assert "fortune" in data
            assert data["fortune"] == "Strip white space before and after: This is a valid fortune."


def test_lambda_handler_with_no_envvar(alb_event, mocker):
    """Test returning non-prefixed fortune."""
    with patch('requests.get') as mock_request:
        mock_request.return_value.json.return_value = {
            "fortune": "This is a valid fortune."
        }

        ret = app.lambda_handler(alb_event, "")
        data = json.loads(ret["body"])

        assert ret["statusCode"] == 200
        assert "fortune" in data
        assert data["fortune"] == "This is a valid fortune."


def test_lambda_handler_with_fortune_api_error(alb_event, mocker):
    """Test behavior when fortune API is unavailable.

    Confirm that the lambda will catch an error if the fortune API is down/moved
    """
    with patch('requests.get') as mock_request:
        # In the case of the 3rd party API going down, the app should catch that error.
        mock_request.side_effect = requests.exceptions.ConnectionError()

        ret = app.lambda_handler(alb_event, "")
        data = json.loads(ret["body"])

        assert ret["statusCode"] == 503
        assert "error" in data
        assert data["error"] == "3rd party fortune API is down. Check server logs for more information."
