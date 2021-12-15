
## This allows usage of the built-in default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

## This allows usage of the default subnet for a given AZ
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
   tags = {
   Name = "Default subnet for us-east-1a"
  }
}

## This creates one subnet for use by the ALB linked to the Lambda function
resource "aws_subnet" "lambda-subnet-1" {
  vpc_id                  = aws_default_vpc.default.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lambda-subnet-1"
  }
}


## This creates another subnet for use by the ALB linked to the Lambda function
resource "aws_subnet" "lambda-subnet-2" {
  vpc_id                  = aws_default_vpc.default.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lambda-subnet-2"
  }
}



## This creates the security group that will be associated with the ALB
resource "aws_default_security_group" "allow_lambda_traffic" {
  vpc_id = aws_default_vpc.default.id

  ingress {
    description = "all incoming HTTP traffic allowed"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  egress {
    description = "all outgoing HTTP traffic allowed"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  tags = {
    Name = "sg-allow-lambda-traffic"
  }
}



## This creates the ALB that the Lambda function will point to
resource "aws_lb" "lambda-alb" {
  name                       = "lambda-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_default_security_group.allow_lambda_traffic.id]
  subnets                    = ["${aws_subnet.lambda-subnet-1.id}", "${aws_subnet.lambda-subnet-2.id}"]
  enable_deletion_protection = false

  tags = {
    Name = "lambda-alb"
  }
}

/*The following resources are for the ALB attached to the Lambda function
*/

## This explicitly allows Lambda execution from the ALB
resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.target-lambda.arn
}

## This explicitly sets the ALB to target the Lambda function
resource "aws_lb_target_group" "target-lambda" {
  name        = "target-lambda"
  target_type = "lambda"
}

## This does the actual attachment of the ALB to the Lamda
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.target-lambda.arn
  target_id        = aws_lambda_function.lambda.arn
  depends_on       = [aws_lambda_permission.with_lb]
}

## This allows the ALB to listen for HTTP requests
resource "aws_lb_listener" "lambda-listener" {
  load_balancer_arn = aws_lb.lambda-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-lambda.arn
  }
}
