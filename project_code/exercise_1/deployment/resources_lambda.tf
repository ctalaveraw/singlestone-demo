## Several different resources will need to be created.
## This is required to get the Lambda function working



# This creates the actual Lambda function itself
resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda-iam.arn
  handler          = "random-fortune.lambda_handler" # The format for this is "code_file_name.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_cloudwatch,
  ]
  tags = {
    Name = "random-fortune"
  }
}

# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
  tags = {
    Name = "random-fortune-lg"
  }
}


