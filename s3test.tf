provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "dockingbay" {
  bucket_prefix = "docking-bay-storage-"

  tags = {
    Name                 = "Docking Bay"
    Environment          = "Dev"
  }
}


resource "aws_s3_bucket_versioning" "dockingbay" {
  bucket = aws_s3_bucket.dockingbay.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  bucket = aws_s3_bucket.dockingbay.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name = "aws-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_replication_configuration" "dockingbay" {
  depends_on = [aws_s3_bucket_versioning.dockingbay]
  role   = aws_iam_role.dockingbay.arn
  bucket = aws_s3_bucket.dockingbay.id
  rule {
    id = "foobar"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dockingbay" {
  bucket = aws_s3_bucket.dockingbay.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}