variable "aws_api_key" {
  description = "AWS API Key "
  type        = string
}

variable "aws_api_secret" {
  description = "AWS API Key "
  type        = string
  sensitive = true
}

