/*
Either the API Gateway or the ALB can be used;
The ALB can handle unlimited RPS (requests per second)
so it will be used.

*/


/* Uncomment this block out to use the API Gateway deployment

  # This creates the API gateway for the Lambda function
  resource "aws_apigatewayv2_api" "lambda-api" {
    name          = "v2-http-api"
    protocol_type = "HTTP"
  }

  # This defines the staging of the Lambda function to the API gateway
  resource "aws_apigatewayv2_stage" "lambda-stage" {
    api_id      = aws_apigatewayv2_api.lambda-api.id
    name        = "$default"
    auto_deploy = "true"
  }
  # This integrates the Lambda function into the API gateway
  resource "aws_apigatewayv2_integration" "lambda-integration" {
    api_id               = aws_apigatewayv2_api.lambda-api.id
    integration_type     = "AWS_PROXY"
    integration_method   = "POST"
    integration_uri      = aws_lambda_function.lambda.invoke_arn
    passthrough_behavior = "WHEN_NO_MATCH"
  }

  # This defines the route of the Lambda function to the API gateway
  resource "aws_apigatewayv2_route" "lambda-route" {
    api_id    = aws_apigatewayv2_api.lambda-api.id
    route_key = "GET /{proxy+}"
    target    = "integrations/${aws_apigatewayv2_integration.lambda-integration.id}"
  }

  # This permits the Lambda function to interact with the API gateway
  resource "aws_lambda_permission" "api-gw" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.arn
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.lambda-api.execution_arn}\*\*\*"
  }
*/

