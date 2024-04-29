# Define AWS provider and region
provider "aws" {
  region = "us-east-1" 
}

# Create an S3 bucket
resource "aws_s3_bucket" "s3_report_bucket" {
  bucket = "pre-signed-url-bucket-ada"

  cors_rule {
    allowed_methods = ["PUT"]  # Add required methods
    allowed_origins = ["*"]  # Allow your frontend origin
    allowed_headers = ["*"]  # Headers allowed in the request
    expose_headers  = []  # Headers to expose to the client
}

# Create IAM role for EC2 with S3 permissions
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }],
  })
}

# Create an IAM Instance Profile and attach the role
resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name  # Associate the role with the instance profile
}

# Attach S3 read/write policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" 
}

# Security group allowing SSH
resource "aws_security_group" "web_access" {
  name        = "fileupload_access"
  description = "Allow SSH, HTTP, and HTTPS access"

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

# EC2 instance with Docker and GitHub repo cloned
resource "aws_instance" "docker_instance" {
  ami           = "ami-080e1f13689e07408" 
  instance_type = "t2.medium" 
  key_name      = "file-upload-key-pair"  # SSH key pair already created in AWS
  security_groups = [aws_security_group.web_access.name]  # Security group setup

  # Give the instance a name using tags
  tags = {
    Name = "file_upload_website_ec2" 
  }

  user_data = "${file("docker_github_script.sh")}"
}