variable "app_account_ids" {
  description = "List of AWS Account IDs for Application Teams allowed to read AMIs"
  type        = list(string)
}

variable "github_pat" {
  description = "GitHub Personal Access Token for CloudWatch/EventBridge connection"
  type        = string
  sensitive   = true
}
