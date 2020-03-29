variable "name" {
  description = "The long name to use on resources"
  type        = string
}

variable "short_name" {
  description = "The short name to use on resources"
  type        = string
}

variable "github_org" {
  description = "The name of the organization in GitHub"
  type        = string
}

variable "github_repo" {
  description = "The name of the repository in GitHub"
  type        = string
}

variable "domain_name" {
  description = "The primary domain name to launch the app on"
  type        = string
  default     = null
}

variable "enable_ssl" {
  description = "Whether the app should be served over SSL"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "The public key for the SSH key to use in the SSHable group to access servers"
  type        = string
}
