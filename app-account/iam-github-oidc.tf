# -------------------------------------------------------------------------
# 1. Fetch the EXISTING GitHub OIDC Provider
# -------------------------------------------------------------------------
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# -------------------------------------------------------------------------
# 2. The IAM Role and Trust Policy
# -------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# 2. The IAM Role and Trust Policy
resource "aws_iam_role" "github_actions_terraform_role" {
  name = "GitHubActionsTerraformRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # CHANGE THIS LINE: Add 'data.' to the beginning
          Federated = data.aws_iam_openid_connect_provider.github.arn 
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:its-pushpaks-world/*:*"
          }
        }
      }
    ]
  })
}

# -------------------------------------------------------------------------
# 3. The Permissions Policy for Terraform
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "terraform_permissions" {
  name = "TerraformDeploymentPermissions"
  role = aws_iam_role.github_actions_terraform_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Permissions to assume the Cross-Account reader role in the Platform account
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/CrossAccountAMIReaderRole"
      },
      {
        # Permissions to manage Auto Scaling Groups
        Effect = "Allow"
        Action = [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:DeleteScheduledAction",
          "autoscaling:DescribeScheduledActions"
        ]
        Resource = "*"
      },
      {
        # Permissions to manage EC2 Launch Templates
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        # Read-only permissions for the networking Data blocks in your module
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
      # NOTE: If you are using an S3 backend for Terraform state, 
      # add s3:GetObject, s3:PutObject, and dynamodb:PutItem permissions here.
    ]
  })
}
