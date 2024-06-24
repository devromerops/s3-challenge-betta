bucket_names = {
  dev-bucket1 = "dev-bucket1-johanromero"
  dev-bucket2 = "dev-bucket2-johanromero"
}

lifecycle_rules = {
  dev-bucket1 = [{
    id              = "rule1"
    enabled         = true
    transition_days = 30
    storage_class   = "STANDARD_IA"
    expiration_days = 365
  }]
  dev-bucket2 = [{
    id              = "rule2"
    enabled         = true
    transition_days = 60
    storage_class   = "GLACIER"
    expiration_days = 730
  }]
}

bucket_websites = {
  dev-bucket1 = {
    index_document = "index.html"
    error_document = "error.html"
  }
  dev-bucket2 = {
    index_document = "index.html"
    error_document = "error.html"
  }
}
