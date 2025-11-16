variable "github_repo" {
  description = "GitHub repo to monitor (format: owner/repo)"
  default     = "ProgrammingOperative/confluent-selfservice-requests"
}

variable "github_branch" {
  description = "Branch to trigger pipeline"
  default     = "main"
}

variable "kafka_api_key" {
  description = "Confluent Cloud API key"
  sensitive   = true
}

variable "kafka_api_secret" {
  description = "Confluent Cloud API secret"
  sensitive   = true
}

variable "github_token" {
  description = "GitHub token for CodePipeline source stage"
  type        = string
}


variable "kafka_id" {
  description = "Confluent Cloud Kafka cluster ID"
  type        = string
  sensitive   = true
}

variable "kafka_env" {
  description = "Confluent Cloud environment ID"
  type        = string
  sensitive   = true
}

variable "kafka_rest_endpoint" {
  description = "Confluent Cloud Kafka cluster REST endpoint"
  type        = string
  sensitive   = true
  
}
