# Objective

Create a VPC with 1 public subnet and 1 private subnet. Also create a publicly accessible EC2 instance.

## Services covered

EC2 | VPC


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://vpc_ec2.yml`

To deploy stack: `aws cloudformation create-stack --stack-name vpc-ec2-stack --template-body file://vpc_ec2.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name vpc-ec2-stack`

To delete stack: `aws cloudformation delete-stack --stack-name vpc-ec2-stack`
