# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
  tags = {
    Name = "random-fortune-lg"
  }
}

