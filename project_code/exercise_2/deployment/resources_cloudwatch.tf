
## A CloudWatch metric will be created for CPU usage to scale up
resource "aws_cloudwatch_metric_alarm" "cpu-overuse-alarm-scaleup" {
  depends_on = [
    aws_autoscaling_group.fortune-group-autoscale,
    aws_autoscaling_policy.cpu-overuse-policy-scaleup
  ]
  alarm_name          = "cpu-overuse-alarm-scaleup"
  alarm_description   = "Alarm when CPU use reaches critical rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.cpu-overuse-policy-scaleup.arn]
  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.fortune-group-autoscale.name
  }
}

## A CloudWatch metric will be created for CPU usage to scale down
resource "aws_cloudwatch_metric_alarm" "cpu-overuse-alarm-scaledown" {
  depends_on = [
    aws_autoscaling_group.fortune-group-autoscale,
    aws_autoscaling_policy.cpu-overuse-policy-scaledown
  ]
  alarm_name          = "cpu-overuse-alarm-scaledown"
  alarm_description   = "Alarm when CPU usage lowers"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "15"
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.cpu-overuse-policy-scaledown.arn]
  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.fortune-group-autoscale.name
  }
}