# Objective

Create an EC2 launch template to quickly launch web server instances

## Services covered

EC2 | IAM | SSM

# Summary

This template creates a simple web server launch template configuration that displays the instances' AZ, instance type and instance id.

## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://launch_template.yml`

To deploy stack: `aws cloudformation create-stack --stack-name launchtemp-stack --template-body file://launch_template.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name launchtemp-stack`

To delete stack: `aws cloudformation delete-stack --stack-name launchtemp-stack`
