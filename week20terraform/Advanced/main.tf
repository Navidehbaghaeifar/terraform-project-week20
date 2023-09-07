
resource "aws_instance" "jenkins-ec2" {
  ami           = var.ami_id 
  instance_type = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  user_data                   = file("install_jenkins.sh")


  tags = {
    Name = "Myweek20project"
  }
}


#Jenkins Security Group Resource
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow Port 22 and 8080"

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8080 Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = var.bucket

  tags = {
    Name = "Myweek20project"
  }
}


resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}