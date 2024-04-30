# Define AWS provider and region
provider "aws" {
  region = "us-east-1" 
}

# Create an S3 bucket
resource "aws_s3_bucket" "s3_report_bucket" {
  bucket = "pre-signed-url-bucket-ada"

  lifecycle {
    ignore_changes = [
      cors_rule
    ]
  }
}

resource "aws_s3_bucket_cors_configuration" "s3_report_bucket_cors" {
  bucket = aws_s3_bucket.s3_report_bucket.id

  cors_rule {
    allowed_methods = ["PUT"] 
    allowed_origins = ["*"]  # Add all necessary origins
    allowed_headers = ["*"]
    expose_headers  = []  # Headers that should be exposed
    max_age_seconds = 3600  # Cache duration for preflight requests
  }
}

# Security group allowing SSH
resource "aws_security_group" "web_access" {
  name        = "fileupload_access"
  description = "Allow SSH, HTTP, HTTPS and 3000 port access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS from anywhere
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Define an IAM role with an appropriate policy to grant access to S3
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM Instance Profile and attach the role
resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "ec2-s3-file-upload-profile"
  role = aws_iam_role.ec2_s3_access_role.name  # Associate the role with the instance profile
}

# Create an IAM policy that allows your EC2 instance to interact with S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2-s3-access-policy"
  description = "Policy for EC2 instance to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::pre-signed-url-bucket-ada",
          "arn:aws:s3:::pre-signed-url-bucket-ada/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM role created earlier to grant the EC2 instance S3 access
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# EC2 instance with Docker and GitHub repo cloned
resource "aws_instance" "docker_instance" {
  ami           = "ami-080e1f13689e07408" 
  instance_type = "t2.medium" 
  key_name      = "file-upload-key-pair"  # SSH key pair already created in AWS
  security_groups = [aws_security_group.web_access.name]  # Security group setup
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_instance_profile.name  # Attach the IAM role to EC2 instance

  # Give the instance a name using tags
  tags = {
    Name = "file_upload_website_ec2" 
  }

  user_data = "${file("docker_github_script.sh")}"
}
