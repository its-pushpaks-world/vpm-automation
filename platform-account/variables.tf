variable "app_account_id" {
  description = "The AWS Account ID of the Application Team"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for CloudWatch/EventBridge connection"
  type        = string
  sensitive   = true
}
