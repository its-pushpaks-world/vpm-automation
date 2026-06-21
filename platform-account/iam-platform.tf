# -------------------------------------------------------------------------
# 0. Prevent 409 Errors: Automatically import the role if it already exists
# -------------------------------------------------------------------------
import {
  to = aws_iam_role.github_actions_platform_role
  id = "GitHubActionsPlatformRole"
}

# -------------------------------------------------------------------------
# 1. Fetch the EXISTING GitHub OIDC Provider in the Platform Account
# -------------------------------------------------------------------------
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# -------------------------------------------------------------------------
# 2. The Platform OIDC IAM Role and Trust Policy
# -------------------------------------------------------------------------
resource "aws_iam_role" "github_actions_platform_role" {
  name = "GitHubActionsPlatformRole"

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
# 3. The Comprehensive, Bulletproof Policy for Platform Infrastructure
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "platform_terraform_permissions" {
  name = "PlatformTerraformDeploymentPermissions"
  role = aws_iam_role.github_actions_platform_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GlobalOidcProviderDiscovery"
        Effect   = "Allow"
        Action   = [
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ]
        Resource = "*"
      },
      {
        Sid      = "FullPlatformIAMRoleAndPolicyManagement"
        Effect   = "Allow"
        Action   = "iam:*"
        Resource = [
          "arn:aws:iam::*:role/CrossAccountAMIReaderRole",
          "arn:aws:iam::*:role/EventBridgeInvokeGitHubRole",
          "arn:aws:iam::*:role/GitHubActionsPlatformRole",
          "arn:aws:iam::*:policy/*"
        ]
      },
      {
        Sid      = "FullPlatformS3RemoteStateManagement"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::vpm-platform-tfstate-prod",
          "arn:aws:s3:::vpm-platform-tfstate-prod/*"
        ]
      },
      {
        Sid      = "FullSSMParameterManagement"
        Effect   = "Allow"
        Action   = "ssm:*"
        Resource = "*"
      },
      {
        Sid      = "FullEventBridgeAutomationManagement"
        Effect   = "Allow"
        Action   = "events:*"
        Resource = "*"
      },
      {
        Sid      = "FullSecretsManagerWebhookStorage"
        Effect   = "Allow"
        Action   = "secretsmanager:*"
        Resource = "arn:aws:secretsmanager:ap-south-1:*:secret:aws.events/*"
      }
    ]
  })
}
