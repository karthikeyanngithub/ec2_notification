variable "lambda_role_name" {
	default = "lambda_role_for_monitoring"
	description = "IAM role for lambda"
}

variable "lambda_role_policy" {
	default = "ec2_monitoring_policy"
	description = "IAM role policy"
}

variable "lambda_function_name" {
	default = "monitoring_ec2_status"
	description = "lambda function name"
}

variable "lambda_file_name" {
	default = "ec2_monitoring_function"
	description = "lambda file name"
}

variable "cloud_watch_rule_name" {
	default = "monitor_ec2_rule"
	description = "cloud watch rule name"
}

variable "sender_mail" {
	description = "email of the sender"
}

variable "recipient_mails" {
	description = "recipients email addresses"
}

variable "aws_region" {
	description = "aws region"
}
