resource "aws_ses_email_identity" "sender" {
  email = var.sender_mail
}

resource "aws_iam_user" "sender" {
  name = element(split("@", var.sender_mail), 0)
  path = "/SESSMTP/"
}

resource "aws_iam_access_key" "sender" {
  user = aws_iam_user.sender.name
}

//output "aws_iam_smtp_password_v4_support" {
//  value = aws_iam_access_key.sender.ses_smtp_password
//}
//output "aws_iam_smtp_key" {
//  value = aws_iam_access_key.sender.id
//}
//
//output "aws_iam_smtp_user" {
//  value = aws_iam_access_key.sender.user
//}


resource "aws_iam_policy" "ses_policy_support" {
  name        = "ses_policy"
  path        = "/SESSMTP/"
  description = "policy to use ses to sent emails"

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}


resource "aws_iam_policy_attachment" "ses_policy-attach" {
  name       = "ses_policy-attach"
  users      = ["${aws_iam_user.sender.name}"]
  policy_arn = aws_iam_policy.ses_policy_support.arn
}
