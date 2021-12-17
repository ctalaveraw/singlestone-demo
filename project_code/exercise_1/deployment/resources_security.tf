## Resources for Identity Access Management; roles and policies

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
  tags = {
    Name = "random-fortune-iam-role"
  }
}


# This creates an IAM policy for Lambda to enable logging
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    Name = "random-fortune-logging-policy"
  }
}



# This attaches the created IAM Lamda role to the IAM policy for CloudWatch logging
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda-iam.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

