# Output the Role ARN so the App team knows what to assume

output "cross_account_role_arn" {
  value = aws_iam_role.app_cross_account_role.arn
}
