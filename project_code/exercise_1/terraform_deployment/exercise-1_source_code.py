import json # Needed because AWS Lambda outputs JSON objects
import requests # Needed because the project deals with HTTP requests, to fetch the fortune
import os # Needed to interact with the operating system specific commands.
import sys # Needed to interact with the Python interpreter directly for deug info.
import logging # Needed to capture debug and detailed logging info.
import traceback # Needed to interact with traceback info.

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

'''
Example Application Load Balancer request event

{
    "requestContext": {
        "elb": {
            "targetGroupArn": "arn:aws:elasticloadbalancing:us-east-2:123456789012:targetgroup/lambda-279XGJDqGZ5rsrHC2Fjr/49e9d65c45c6791a"
        }
    },
    "httpMethod": "GET",
    "path": "/lambda",
    "queryStringParameters": {
        "query": "1234ABCD"
    },
    "headers": {
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "accept-encoding": "gzip",
        "accept-language": "en-US,en;q=0.9",
        "connection": "keep-alive",
        "host": "lambda-alb-123578498.us-east-2.elb.amazonaws.com",
        "upgrade-insecure-requests": "1",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
        "x-amzn-trace-id": "Root=1-5c536348-3d683b8b04734faae651f476",
        "x-forwarded-for": "72.12.164.125",
        "x-forwarded-port": "80",
        "x-forwarded-proto": "http",
        "x-imforwards": "20"
    },
    "body": "",
    "isBase64Encoded": false
}

'''


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

'''

'''


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
