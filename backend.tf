# Configure Terraform to use an S3 backend
terraform {
  backend "s3" {
    bucket = "file-upload-terraform-state-bucket"  # Unique S3 bucket for state storage
    key    = "file-upload/terraform.tfstate"  # Path to store the state in the bucket
    region = "us-east-1"  # AWS region where the S3 bucket is located
  }
}