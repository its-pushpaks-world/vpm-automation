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
# 3. The Comprehensive Permissions Policy for Platform Infrastructure
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "platform_terraform_permissions" {
  name = "PlatformTerraformDeploymentPermissions"
  role = aws_iam_role.github_actions_platform_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
        Sid      = "PlatformIAMRoleAndPolicyManagement"
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
        Resource = [
          "arn:aws:iam::*:role/CrossAccountAMIReaderRole",
          "arn:aws:iam::*:role/EventBridgeInvokeGitHubRole",
          "arn:aws:iam::*:role/GitHubActionsPlatformRole"
        ]
      },
      {
        Sid      = "PlatformS3RemoteStateManagement"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::vpm-platform-tfstate-prod",
          "arn:aws:s3:::vpm-platform-tfstate-prod/*"
        ]
      },
      {
        Sid      = "CentralRegistrySSMManagement"
        Effect   = "Allow"
        Action   = [
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListTagsForResource"
        ]
        Resource = "arn:aws:ssm:ap-south-1:*:parameter/platform/*"
      },
      {
        Sid      = "SSMGlobalDiscoveryAction"
        Effect   = "Allow"
        Action   = [
          "ssm:DescribeParameters"
        ]
        # Required by AWS API design for discovery/listing actions
        Resource = "*"
      },
      {
        Sid      = "EventBridgeAutomationManagement"
        Effect   = "Allow"
        Action   = [
          "events:PutRule",
          "events:DeleteRule",
          "events:DescribeRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:PutConnection",
          "events:DeleteConnection",
          "events:DescribeConnection",
          "events:PutApiDestination",
          "events:DeleteApiDestination",
          "events:DescribeApiDestination"
        ]
        Resource = "*"
      },
      {
        Sid      = "EventBridgeSecretStorageBehindTheScenes"
        Effect   = "Allow"
        Action   = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:ap-south-1:*:secret:aws.events/*"
      }
    ]
  })
}
