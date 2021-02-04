



resource "aws_iam_role" "ec2_monitoring_role" {
  name = "${var.lambda_role_name}"
  assume_role_policy = file("${path.module}/policy/iam_role_policy.json")
}


resource "aws_iam_role_policy" "ec2_monitoring_role_lambdapolicy" {
  name = "${var.lambda_role_policy}"
  role = aws_iam_role.ec2_monitoring_role.id
  policy = file("${path.module}/policy/iam_policy.json")
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/tmp"
  output_path = "${path.module}/lambda_function/${var.lambda_file_name}.zip"
}


resource "aws_lambda_function" "monitor_ec2_function" {
  function_name     = "${var.lambda_function_name}"
  filename          = "${path.module}/lambda_function/${var.lambda_file_name}.zip"
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  role              = aws_iam_role.ec2_monitoring_role.arn
  runtime           = "python3.7"
  handler           = "ec2_monitoring_function.lambda_handler"
  timeout           = "60"
  publish           = true

  environment {
    variables = {
      SENDER = "${var.sender_mail}",
      RECIPIENTS = "${var.recipient_mails}",
      SENDER_AWS_REGION = "${var.aws_region}"
    }
  }
}


resource "aws_cloudwatch_event_rule" "monitor_ec2_rule" {
  name = "${var.cloud_watch_rule_name}"
  description = "monitor ec2 status changes"
  event_pattern = file("${path.module}/policy/event_pattern.json")
}


resource "aws_cloudwatch_event_target" "cloudwatch_target" {
    rule = aws_cloudwatch_event_rule.monitor_ec2_rule.name
    arn = aws_lambda_function.monitor_ec2_function.arn
    depends_on = [aws_lambda_function.monitor_ec2_function]
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor_ec2_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.monitor_ec2_rule.arn
}