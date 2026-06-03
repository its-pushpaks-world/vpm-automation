# Output declaration

output "drift_status" {
  type        = string
  value       = local.status_message
  description = "Human readable status variable that presents if there's a drift in current ami and approved ami from registry"
}

output "drift_detected" {
  type        = bool
  value       = local.is_drifted
  description = "Boolean flag used by downstream automations where true means drift exists and false means no drift detected"
}
