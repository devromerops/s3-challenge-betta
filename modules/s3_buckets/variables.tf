variable "bucket_names" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "Enable replication for the S3 bucket"
  type        = bool
  default     = true
}

variable "replication_role" {
  description = "ARN of the IAM role for replication"
  type        = string
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the S3 bucket"
  type        = list(object({
    id              = string
    enabled         = bool
    transition_days = number
    storage_class   = string
    expiration_days = number
  }))
}

variable "bucket_websites" {
  description = "Configuration for S3 bucket website"
  type        = object({
    index_document = string
    error_document = string
  })
  default = null
}

variable "secondary_region" {
  description = "Secondary AWS region for replication"
  type        = string
}
