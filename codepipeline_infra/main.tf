##############################################
# PROVIDERS
##############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "confluent-state-bucket-wachira"
    key            = "infra/codepipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}



##############################################
# SECRETS MANAGER FOR CONFLUENT CREDENTIALS
##############################################

resource "aws_secretsmanager_secret" "confluent_kafka_creds" {
  name        = "confluent/kafka_creds6"
  description = "Confluent Cloud API credentials for Terraform provider"
}

resource "aws_secretsmanager_secret_version" "confluent_creds_ver" {
  secret_id = aws_secretsmanager_secret.confluent_kafka_creds.id

  secret_string = jsonencode({
    kafka_api_key    = var.kafka_api_key
    kafka_api_secret = var.kafka_api_secret
    kafka_id = var.kafka_id
    kafka_env = var.kafka_env
    kafka_rest_endpoint = var.kafka_rest_endpoint
  })
}

##############################################
# IAM ROLE FOR CODEBUILD
##############################################

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-confluent-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-confluent-apply-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*",
          "s3:*",
          "dynamodb:*",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

##############################################
# CODEBUILD PROJECT
##############################################

resource "aws_codebuild_project" "confluent_apply" {
  name          = "confluent-topic-apply"
  service_role  = aws_iam_role.codebuild_role.arn
  description   = "Runs terraform apply for Confluent topics"
  build_timeout = 20

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "TF_IN_AUTOMATION"
      value = "true"
    }

    # Secrets from Secrets Manager (auto injected)
    environment_variable {
      name      = "CONFLUENT_CREDENTIALS"
      value     = aws_secretsmanager_secret.confluent_kafka_creds.arn
      type      = "SECRETS_MANAGER"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_repo}.git"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }
}

##############################################
# CODEPIPELINE
##############################################

resource "aws_iam_role" "codepipeline_confluent_role" {
  name = "codepipeline-confluent-kafka-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-confluent-policy"
  role = aws_iam_role.codepipeline_confluent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket_prefix = "confluent-pipeline-artifacts-"
  force_destroy = true
}

resource "aws_codepipeline" "confluent_pipeline" {
  name     = "confluent-topic-pipeline"
  role_arn = aws_iam_role.codepipeline_confluent_role.arn
  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner  = split("/", var.github_repo)[0]
        Repo   = split("/", var.github_repo)[1]
        Branch = var.github_branch
        OAuthToken = var.github_token 
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "TerraformApply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.confluent_apply.name
      }
    }
  }
}
