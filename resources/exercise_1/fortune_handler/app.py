import json
import requests
import os
import sys
import logging
import traceback

LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO').upper()
logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger()


class ALBEvent:
    def __init__(self,
                 requestContext: object,
                 httpMethod: str,
                 path: str,
                 queryStringParameters: object,
                 headers: object,
                 body: str,
                 isBase64Encoded: bool):
        self.requestContext = requestContext
        self.httpMethod = httpMethod
        self.path = path
        self.queryStringParameters = queryStringParameters
        self.headers = headers
        self.body = body
        self.isBase64Encoded = isBase64Encoded


class ALBContext:
    def __init(self,
               functionName: str,
               functionVersion: str,
               invokedFunctionArn: str,
               memoryLimitInMb: int,
               awsRequestID: str,
               logGroupName: str,
               logStreamName: str,
               identity: object,
               clientContext: object):
        self.function_name = functionName
        self.function_version = functionVersion
        self.invoked_function_arn = invokedFunctionArn
        self.aws_request_id = awsRequestID
        self.memory_limit_in_mb = memoryLimitInMb
        self.log_group_name = logGroupName
        self.log_stream_name = logStreamName
        self.identity = identity
        self.client_context = clientContext


def lambda_handler(event: ALBEvent, context: ALBContext):
    """Lambda function that calls a Fortune API and returns the result.

    Parameters
    ----------
    event: dict, required
        ALB + Lambda Event Format

        Event doc: https://docs.aws.amazon.com/lambda/latest/dg/services-alb.html

    context: object, required
        ALB + Lambda Context Format

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context.html
    """

    # We need to wrap this in a try/except in case the 3rd party API goes down.
    try:
        fortuneResponse = requests.get("http://yerkee.com/api/fortune/computers").json()
    except requests.RequestException as e:
        # Make sure the error gets sent to Lambda Logs
        exception_type, exception_value, exception_traceback = sys.exc_info()
        traceback_string = traceback.format_exception(exception_type, exception_value, exception_traceback)
        err_msg = {
            "errorType": exception_type.__name__,  # type: ignore
            "errorMessage": str(exception_value),
            "stackTrace": traceback_string,
            "err": e
        }

        logger.error(err_msg)

        return {
            # Return 503 as the fortune service was unavailable
            "statusCode": 503,
            "body": json.dumps({
                "error": "3rd party fortune API is down. Check server logs for more information.",
            }),
            "headers": {
                'Content-Type': 'application/json',
            }
        }

    logger.info(fortuneResponse)

    # If no prefix is provided, the app will not supply a default.
    prefix = ''

    # If the MSG_PREFIX is set as an environment variable, set the prefix to it.
    if("MSG_PREFIX" in os.environ):
        prefix = os.environ["MSG_PREFIX"].strip() + " "

    fullFortune = prefix + fortuneResponse["fortune"]

    logger.info("Sending back the fortune \"%s\"" % fullFortune)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "fortune": fullFortune
        }),
        "headers": {
                'Content-Type': 'application/json',
            }
        }
