
variable "aws_access_key" {
    type = string
    description = "AWS Access Key"
    sensitive = true
}

variable "aws_secret_key" {
    type = string
    description = "AWS Secret Key"
    sensitive = true
}

# reference with: var.aws_instance_sizes["small"]
variable "aws_instance_sizes" {
    type = map(string) 
    description = "Instance sizes to use in AWS"
    default = {
        small = "t2.micro"
        medium = "t3.micro"
        large = "m4.large"
    }
}

# reference with var.aws_regions[0]
variable "aws_regions" {
    type = list(string)
    description = "Regions to use for AWS resources"
    default = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]

}


variable "company" {
    type = string
    default = "thv"    
}

# set in terraform.tfvars
variable "business_unit" {
    type = string
}

variable "enable_dns_hostnames" {
    type = bool
    description = "Enable DNS hostnames in VPC"
    default = true
}

variable "vpc_cidr_block" {
    type = string
    description = "Base VPC Cidr block"
    default = "10.0.0.0/16"
}

variable "vpc_public_subnet1_cidr" {
    type = string
    description = "CIDR Block for public1 subnet"
    default = "10.0.0.0/24"
}

variable "map_public_ip" {
    type = bool
    description = "Map a public IP address for instances in subnet"
    default = true
}
