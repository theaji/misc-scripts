# Objective

Create a CloudWatch alarm that sends an email if account bill is over $3

## Services covered

CloudWatch | SNS

## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://cw_billing.yml`

To deploy stack: `aws cloudformation create-stack --stack-name billingstack --template-body file://cw_billing.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name billingstack`

To delete stack: `aws cloudformation delete-stack --stack-name billingstack`
