# Drift Evaluation between the current AMI ID of a running AWS EC2 and approved AMI ID

locals {
  is_drifted = var.current_ami_id != var.approved_ami_id

  status_message = local.is_drifted ? "DRIFT DETECTED — instance AMI does not match approved image. Repave required." : "No drift detected — instance is running the approved image"

}
