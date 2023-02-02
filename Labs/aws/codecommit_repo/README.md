# Objective

Create an empty CodeCommit Repository.

## Services covered

CodeCommit

## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://codecommit.yml`

To deploy stack: `aws cloudformation create-stack --stack-name codecommit-stack --template-body file://codecommit.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name codecommit-stack`

To delete stack: `aws cloudformation delete-stack --stack-name codecommit-stack`
