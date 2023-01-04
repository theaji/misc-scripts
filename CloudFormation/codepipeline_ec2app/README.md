# Objective

This project uses codepipeline for continuous delivery of an EC2 webapp -  using CodeCommit as a source provider

## Services covered

EC2 | CodeCommit | CodeDeploy | CodePipeline | S3 | VPC

## Template explanation

### Section 1

Creates a VPC, Internet Gateway, Route table  and Subnet necessary for the EC2 instance

### Section 2

Creates an EC2 instance using cfn-init, cfn-hup and userdata to install the codedeploy agent and ensure it is running

This section also creates the EC2 Security Group for http access

### Section 3

Creates CodeCommit repository to use as a source provider. Also creates S3 bucket to store pipeline artifacts

### Section 4

Creates service roles to be assumed by CodePipeline, CodeDeploy and EC2

### Section 5

Creates the CodeDeploy Application and Deployment Group

### Section 6

Creates the 2 stage pipeline (source, deploy) and specifies the bucket to store artifacts


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://codepipeline.yml`

To deploy stack: `aws cloudformation create-stack --stack-name codepipeline-stack --template-body file://codepipeline.yml` --capabilities CAPABILITY_IAM

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name codepipeline-stack`

To delete stack: `aws cloudformation delete-stack --stack-name codepipeline-stack`


