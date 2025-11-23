variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "aws_api_key" {
  description = "AWS API Key "
  type        = string
}

variable "aws_api_secret" {
  description = "AWS API Key "
  type        = string
  sensitive   = true
}

