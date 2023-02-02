# Objective

Create an EC2 instance that signals back to CloudFormation once the bootstrap process has been completed. The instance should also be aware of any changes to the userdata configuration.

## Services covered

CloudFormation | EC2 | VPC

# Summary

This template creates a VPC and an EC2 instance. The template then installs apache and php before sending a success status message to CloudFormation


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://ec2_cfn.yml`

To deploy stack: `aws cloudformation create-stack --stack-name ec2_cfn-stack --template-body file://ec2_cfn.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name ec2_cfn-stack`

To delete stack: `aws cloudformation delete-stack --stack-name ec2_cfn-stack`
