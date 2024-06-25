resource "aws_s3_bucket" "this" {
  bucket = var.bucket_names

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [
      bucket,
      acl,
      tags,
    ]
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      versioning_configuration,
    ]
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      index_document,
      error_document,
    ]
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      rule,
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      rule,
    ]
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
      replica_kms_key_id = var.replica_kms_key_id
    }

    filter {
      prefix = ""
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "replica" {
  provider = aws.secondary
  bucket   = "${var.bucket_names}-dr"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [
      bucket,
      acl,
      tags,
    ]
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.replica.bucket

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      versioning_configuration,
    ]
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      index_document,
      error_document,
    ]
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      rule,
    ]
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      rule,
    ]
  }
}
