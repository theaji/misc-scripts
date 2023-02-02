# Objective

Create a reusable SSM parameter template

## Services covered: 

SSM | SNS

# Summary

The template creates an SNS topic and stores the ARN in SSM parameter store

## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://ssm_parameter.yml`

To deploy stack: `aws cloudformation create-stack --stack-name ssm-parameter-stack --template-body file://ssm_parameter.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name ssm-parameter-stack`

To delete stack: `aws cloudformation delete-stack --stack-name ssm-parameter-stack`
