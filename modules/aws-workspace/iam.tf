### Data Sources
# Get current AWS account information for policy construction
data "aws_caller_identity" "current" {}

### Local Variables
locals {
  # VPC creation flag
  final_create_vpc = var.create_vpc

  # Determine which role ARN to use - either provided or newly created
  final_role_arn = var.aws_role_arn != null ? var.aws_role_arn : aws_iam_role.databricks_cross_account_role[0].arn
}

### IAM Role for Databricks Cross-Account Access
# Creates IAM role for Databricks cross-account access when aws_role_arn is not provided
# Reference: https://docs.databricks.com/aws/en/admin/account-settings-e2/credentials.html
resource "aws_iam_role" "databricks_cross_account_role" {
  count = var.aws_role_arn == null ? 1 : 0

  name = "${var.prefix}-databricks-cross-account-role"

  # Trust policy allowing Databricks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::414351767826:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.prefix}-databricks-cross-account-role"
  })
}

### IAM Policy for Databricks Cross-Account Access
resource "aws_iam_role_policy" "databricks_cross_account_policy" {
  count = var.aws_role_arn == null ? 1 : 0

  name = "${var.prefix}-databricks-cross-account-policy"
  role = aws_iam_role.databricks_cross_account_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Ec2RunInstancesPermissions"
        Effect = "Allow"
        Action = [
          "ec2:AssociateIamInstanceProfile",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CancelSpotInstanceRequests",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribePrefixLists",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DetachVolume",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ReplaceIamInstanceProfileAssociation",
          "ec2:RequestSpotInstances",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeFleetHistory",
          "ec2:ModifyFleet",
          "ec2:DeleteFleets",
          "ec2:DescribeFleetInstances",
          "ec2:DescribeFleets",
          "ec2:CreateFleet",
          "ec2:DeleteLaunchTemplate",
          "ec2:GetLaunchTemplateData",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:ModifyLaunchTemplate",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:AssignPrivateIpAddresses",
          "ec2:GetSpotPlacementScores"
        ]
        Resource = ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : ["iam:CreateServiceLinkedRole", "iam:PutRolePolicy"],
        "Resource" : "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "spot.amazonaws.com"
          }
        }
      },
    ]
  })
}
