import json
import boto3
import os
from botocore.exceptions import ClientError


SENDER = os.environ["SENDER"]
RECIPIENTS = os.environ["RECIPIENTS"].strip('][').split(",")
AWS_REGION = os.environ["SENDER_AWS_REGION"]
SUBJECT = "EC2 instance change-state notification"
CHARSET = "UTF-8"


def lambda_handler(event, context):
    ec2 = boto3.resource('ec2')
    alias = boto3.client('iam').list_account_aliases()['AccountAliases']
    account_alias = alias[0] if alias else "account_alias"
    client = boto3.client('ses',region_name=AWS_REGION)
    state = event.get("detail").get("state")
    instance_id = event.get("detail").get("instance-id")
    account_id = event.get("account")
    instance = ec2.Instance(instance_id)
    tags = instance.tags or []
    names = [tag.get('Value') for tag in tags if tag.get('Key') == 'Name']
    instance_name = names[0] if names else None
    body_text = (f"Hi All,\r\nThe below EC2 instance state has been changed \r\n \
    EC2_instance_name \t : {instance_name} \r\n \
    EC2_instance_id \t : {instance_id} \r\n \
    EC2_instance_type \t : {instance.instance_type} \r\n \
    Status \t \t \t \t : {state} \r\n \
    AWS_Account_Name  : {account_alias} \r\n \
    AWS account-id \t \t : {account_id}  \r\n \
    \r \
    Please escalate, if this action is not a expected one.")
    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': RECIPIENTS
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': CHARSET,
                        'Data': body_text,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }