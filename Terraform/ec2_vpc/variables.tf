variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "ec2_volume_size" {

  description = "Volume size"
  type        = number
  default     = 10

}

variable "instances_per_subnet" {

  description = "EC2 instances per private subnet"
  type        = number
  default     = 1

}

variable "instance_type" {

  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

}
