# Objective

Create a static website in S3

## Services covered

S3


## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://s3website.yml`

To deploy the template: `aws cloudformation create-stack --stack-name s3website --template-body file://s3website.yml`

To check template status and view outputs: `aws cloudformation describe-stacks --stack-name s3website`

To copy image files to s3: `aws s3 cp -r img/ s3://s3website-bucket`

To copy index.html to s3: `aws s3 cp index.html s3://s3website-bucket`

To empty bucket: `aws s3 rm s3://s3website-bucket --recursive`

To delete stack: `aws cloudformation delete-stack --stack-name s3website`
