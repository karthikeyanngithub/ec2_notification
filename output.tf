output "aws_iam_role_arn" {
  value = "${aws_iam_role.ec2_monitoring_role.arn}"
}


output "lambda_function_arn" {
  value = "${aws_lambda_function.monitor_ec2_function.arn}"
}

output "cloud_watch_rule_arn" {
  value = "${aws_cloudwatch_event_rule.monitor_ec2_rule.arn}"
}

