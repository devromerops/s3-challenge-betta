variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
}

variable "bucket_names" {
  description = "Map of bucket names"
  type        = map(string)
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for S3 buckets"
  type        = map(list(object({
    id              = string
    enabled         = bool
    transition_days = number
    storage_class   = string
    expiration_days = number
  })))
}

variable "bucket_websites" {
  description = "Website configurations for S3 buckets"
  type        = map(object({
    index_document = string
    error_document = string
  }))
  default = null
}
