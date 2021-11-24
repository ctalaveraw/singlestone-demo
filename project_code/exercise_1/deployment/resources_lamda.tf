## Several different resources will need to be created.
## This is required to get the Lambda function working

## This creates an IAM role for the Lamda function to assume
resource "aws_iam_role" "lambda-iam" {
  name = "lambda-iam"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
        "Sid" : ""
      }
    ]
  })
}

# This creates the actual Lambda function itself
resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_zip
  function_name    = "lambda-random-fortune"
  role             = "aws_iam_role.lambda-iam.arn"
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
}
