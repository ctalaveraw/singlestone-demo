## This creates the ALB that the Lambda function will point to
resource "aws_lb" "fortune-webapp-alb" {
  name                       = "fortune-webapp-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.fortune-security-group.id]
  subnets                    = ["${aws_subnet.fortune-subnet-public-1.id}", "${aws_subnet.fortune-subnet-public-2.id}"]
  enable_deletion_protection = false

  tags = {
    Name = "fortune-webapp-alb"
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.fortune-group-autoscale.id
  alb_target_group_arn   = aws_lb_target_group.target-fortune-webapp.arn
}


/*
The following resources are for the ALB attached to the Lambda function
*/



## This creates a target group related to the instances created from the autoscale group
resource "aws_lb_target_group" "target-fortune-webapp" {
  vpc_id      = aws_vpc.fortune-vpc.id
  name        = "target-fortune-webapp"
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
}



## This allows the ALB to listen for HTTP requests
resource "aws_lb_listener" "fortune-webapp-listener" {
  load_balancer_arn = aws_lb.fortune-webapp-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-fortune-webapp.arn
  }
}
