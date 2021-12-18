# This creates the actual Lambda function itself
resource "aws_lambda_function" "lambda" {
  description      = "A Lambda function to fetch a 'random fortune' via HTTP request from an API"
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
