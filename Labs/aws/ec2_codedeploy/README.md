# Objective

Bootstrap the codedeploy agent to an EC2 instance

## Services covered

CodeDeploy | EC2 | VPC


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://ec2_codedeploy.yml`

To deploy stack: `aws cloudformation create-stack --stack-name ec2-codedeploy-stack --template-body file://ec2_codedeploy.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name ec2-codedeploy-stack`

To delete stack: `aws cloudformation delete-stack --stack-name ec2-codedeploy-stack`
