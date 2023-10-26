 
##########
#PROVIDERS
##########

provider "aws" {

#    access_key = var.aws_access_key
#    secret_key = var.aws_secret_key
    region = var.aws_regions[0]
    profile = "default"
}

# reference with provider: aws.west
provider "aws" {

#    access_key = var.aws_access_key
#    secret_key = var.aws_secret_key
    region = var.aws_regions[1]
    alias = west
    assume_role {
        role_arn = "arn:aws:iam::####:/role/OrganizationAccountAccessRole"
    }
}
