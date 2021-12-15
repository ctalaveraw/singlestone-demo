
## The 'launch configuration' needs to be defined
resource "aws_launch_configuration" "fortune-launch-config" {
  name            = "fortune-launch-config"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t3.micro"
  security_groups = ["${aws_security_group.fortune-security-group.id}"]
  key_name        = aws_key_pair.fortune-keypair.key_name
  user_data       = "${template_file.user_data.rendered}"
}

## The autoscaling group needs to be defined
resource "aws_autoscaling_group" "fortune-group-autoscale" {
  name                      = "fortune-group-autoscale"
  vpc_zone_identifier       = [aws_subnet.fortune-subnet-public-1.id]
  launch_configuration      = aws_launch_configuration.fortune-launch-config.name
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "fortune-web-server"
    propagate_at_launch = true
  }
}

/*
The policy for the autoscaling group needs to be defined
If the CPU gets below a certain threshold, the policy takes effect
*/
resource "aws_autoscaling_policy" "cpu-overuse-policy-scaleup" {
  name                   = "cpu-overuse-policy-scaleup"
  autoscaling_group_name = aws_autoscaling_group.fortune-group-autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}


/*
The policy for the autoscaling group needs to be defined
If the CPU gets above a certain threshold, the policy takes effect
*/
resource "aws_autoscaling_policy" "cpu-overuse-policy-scaledown" {
  name                   = "cpu-overuse-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.fortune-group-autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}
