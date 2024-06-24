resource "aws_s3_bucket" "this" {
  bucket = var.bucket_names
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  dynamic "index_document" {
    for_each = var.bucket_websites != null ? [var.bucket_websites] : []
    content {
      suffix = index_document.value.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.bucket_websites != null ? [var.bucket_websites] : []
    content {
      key = error_document.value.error_document
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id      = rule.value.id
      status  = rule.value.enabled ? "Enabled" : "Disabled"

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.this.id

  role = var.replication_role

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
}

resource "aws_s3_bucket" "replica" {
  provider = aws.secondary
  bucket   = "${var.bucket_names}-dr"
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.replica.bucket

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_website_configuration" "replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.replica.bucket

  dynamic "index_document" {
    for_each = var.bucket_websites != null ? [var.bucket_websites] : []
    content {
      suffix = index_document.value.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.bucket_websites != null ? [var.bucket_websites] : []
    content {
      key = error_document.value.error_document
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.replica.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id      = rule.value.id
      status  = rule.value.enabled ? "Enabled" : "Disabled"

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.storage_class
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.replica.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
