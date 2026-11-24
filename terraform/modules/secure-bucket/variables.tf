variable "bucket_name" {
  type        = string
  description = "Name of the bucket. It must be unique in the whole world."
}

variable "tags" {
  type        = map(string)
  description = "Optional tags for the bucket"
  default     = {}
}
