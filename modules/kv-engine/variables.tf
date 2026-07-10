variable "cas_required" {
  description = "Whether check-and-set is required for writes to the KV v2 secrets engine."
  type        = bool
  default     = false
}

variable "delete_version_after" {
  description = "Number of seconds after which deleted KV v2 versions are permanently deleted. 0 disables automatic deletion."
  type        = number
  default     = 0
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
