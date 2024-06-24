variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-east-2"
}

variable "bucket_names" {
  description = "Names of the S3 buckets"
  type        = map(string)
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for S3 buckets"
  type = map(list(object({
    id              = string
    enabled         = bool
    transition_days = number
    storage_class   = string
    expiration_days = number
  })))
}

variable "bucket_websites" {
  description = "Configuration for S3 bucket websites"
  type        = map(object({
    index_document = string
    error_document = string
  }))
  default = {}  # Valor predeterminado vacío
}
