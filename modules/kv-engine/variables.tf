variable "cas_required" {
  description = "Whether check-and-set is required for writes to the KV v2 secrets engine."
  type        = bool
  default     = false
}

variable "delete_version_after" {
  description = "Duration after which deleted KV v2 versions are permanently deleted."
  type        = string
  default     = "0s"
}

variable "description" {
  description = "Description for the KV v2 secrets engine mount."
  type        = string
  default     = "KV v2 secrets engine"
}

variable "max_versions" {
  description = "Maximum number of versions retained for each KV v2 secret."
  type        = number
  default     = 10
}

variable "path" {
  description = "Mount path for the KV v2 secrets engine."
  type        = string
}
