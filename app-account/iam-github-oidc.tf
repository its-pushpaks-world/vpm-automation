import {
  to = aws_iam_role.github_actions_terraform_role
  id = "GitHubActionsTerraformRole"
}

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

resource "aws_iam_role" "github_actions_terraform_role" {
  name = "GitHubActionsTerraformRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
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
        Sid      = "CrossAccountPlatformRoleAssumption"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::242655703609:role/CrossAccountAMIReaderRole"
      },
      {
        Sid      = "OidcProviderDiscovery"
        Effect   = "Allow"
        Action   = [
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ]
        Resource = "*"
      },
      {
        Sid      = "IAMRoleSelfManagement"
        Effect   = "Allow"
        Action   = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "arn:aws:iam::*:role/GitHubActionsTerraformRole"
      },
      {
        Sid      = "TerraformS3RemoteStateAndResourceManagement"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::vpm-app-tfstate-prod",
          "arn:aws:s3:::vpm-app-tfstate-prod/*"
        ]
      },
      {
        Sid      = "AutoScalingAndSchedulingOperations"
        Effect   = "Allow"
        Action   = [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:DeleteScheduledAction",
          "autoscaling:DescribeScheduledActions"
        ]
        Resource = "*"
      },
      {
        Sid      = "LaunchTemplateManagement"
        Effect   = "Allow"
        Action   = [
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
        Sid      = "NetworkAndInfrastructureDiscovery"
        Effect   = "Allow"
        Action   = [
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}
