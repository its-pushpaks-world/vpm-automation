terraform {
  backend "s3" {
    bucket       = "vpm-platform-tfstate-prod"
    key          = "platform/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "state_backend" {
  source      = "../modules/remote-backend"
  bucket_name = "vpm-platform-tfstate-prod"
}

# --- 1. Central Registry ---
resource "aws_ssm_parameter" "latest_ami" {
  name  = "/platform/amis/frontend/latest"
  type  = "String"
  value = "ami-0685bcc683dadb6b9" 
}

# --- 2. Cross Account Access (Supports Multiple Accounts) ---
resource "aws_iam_role" "app_cross_account_role" {
  name = "CrossAccountAMIReaderRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        # Dynamically converts the account list into root ARN targets
        AWS = formatlist("arn:aws:iam::%s:root", var.app_account_ids)
      }
    }]
  })
}

resource "aws_iam_role_policy" "ssm_read_policy" {
  name   = "AppTeamSSMReadPolicy"
  role   = aws_iam_role.app_cross_account_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "ssm:GetParameter", Effect = "Allow", Resource = aws_ssm_parameter.latest_ami.arn }]
  })
}

# --- 3. EventBridge to GitHub Webhook ---
resource "aws_cloudwatch_event_connection" "github_connection" {
  name               = "github-actions-connection"
  authorization_type = "API_KEY"
  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${var.github_pat}" 
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "github_workflow" {
  name                = "github-actions-repave-workflow"
  invocation_endpoint = "https://api.github.com/repos/its-pushpaks-world/vpm-automation/actions/workflows/asg-lt-update.yml/dispatches"
  http_method         = "POST"
  connection_arn      = aws_cloudwatch_event_connection.github_connection.arn
}

resource "aws_cloudwatch_event_rule" "ssm_update_rule" {
  name        = "trigger-pipeline-on-ami-update"
  event_pattern = jsonencode({
    source        = ["aws.ssm"],
    "detail-type" = ["Parameter Store Change"],
    detail        = { name = [aws_ssm_parameter.latest_ami.name], operation = ["Create", "Update"] }
  })
}

resource "aws_iam_role" "eventbridge_api_role" {
  name               = "EventBridgeInvokeGitHubRole"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "events.amazonaws.com" } }] })
}

resource "aws_iam_role_policy" "eventbridge_api_policy" {
  name   = "InvokeAPIDestinationPolicy"
  role   = aws_iam_role.eventbridge_api_role.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Action = "events:InvokeApiDestination", Effect = "Allow", Resource = aws_cloudwatch_event_api_destination.github_workflow.arn }] })
}

resource "aws_cloudwatch_event_target" "trigger_github_actions" {
  rule     = aws_cloudwatch_event_rule.ssm_update_rule.name
  arn      = aws_cloudwatch_event_api_destination.github_workflow.arn
  role_arn = aws_iam_role.eventbridge_api_role.arn
  input_transformer {
    input_paths    = {}
    input_template = "{\"ref\": \"main\"}" 
  }
}
