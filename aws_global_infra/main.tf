provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_api_key
  secret_key = var.aws_api_secret
}

# ======================================================== DynamoDB Table for Terraform Lock ===============================

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# ======================================================== S3 Bucket for Terraform State + policy ===============================
resource "aws_s3_bucketinfra/codepipeline/terraform.tfstate" "terraform_state" {
  bucket = "confluent-state-bucket-wachira"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_terraform_access" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowTerraformAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::235484063355:user/cloud_solutions_admin"
        },
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::confluent-state-bucket-wachira",
          "arn:aws:s3:::confluent-state-bucket-wachira/*"
        ]
      }
    ]
  })
}



