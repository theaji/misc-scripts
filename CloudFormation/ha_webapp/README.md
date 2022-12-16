# Objective

Use ALB + ASG + Launch Templates to run a specific number of instances of a website

## Services covered

VPC | EC2 | Auto Scaling | Elastic Load Balancing

# Summary

The [ha_webapp.yml](https://github.com/theaji/projects/blob/main/ha_webapp/ha_webapp.yml) Cloudformation template was used to complete this lab

The template launches the specified amount of instances and uses healthchecks to monitor their status.

[v2](https://github.com/theaji/projects/blob/main/ha_webapp/ha_webapp_v2.yml) of this template adds scaling policies. 

## Commands used

To validate the template: `aws cloudformation validate-template --template-body file://ha_webapp.yml`

To deploy stack: `aws cloudformation create-stack --stack-name webapp-stack --template-body file://ha_webapp.yml`

To check stack status and view outputs: `aws cloudformation describe-stacks --stack-name webapp-stack`

To delete stack: `aws cloudformation delete-stack --stack-name ha_webapp-stack`
