# Objective

Create a VPC and a publicly accessible EC2 instance running docker engine

## Services covered

EC2 | VPC


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://ec2_bootstrap_docker.yml`

To deploy stack: `aws cloudformation create-stack --stack-name ec2_docker-stack --template-body file://ec2_bootstrap_docker.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name ec2_docker-stack`

To delete stack: `aws cloudformation delete-stack --stack-name ec2_docker-stack`
