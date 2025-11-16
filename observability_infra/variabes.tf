variable "vpc_id" {
  description = "VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS worker nodes"
  type        = list(string)
}

variable "aws_api_key" {
  description = "AWS API Key "
  type        = string
}

variable "aws_api_secret" {
  description = "AWS API Key "
  type        = string
  sensitive = true
}

