resource "aws_iam_role" "court-document-pack" {
  name                 = "${var.env}-${var.prefix}-court-document-pack-role"
  assume_role_policy   = data.aws_iam_policy_document.court_document_pack_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "court-document-pack-policies"
    policy = data.aws_iam_policy_document.court_document_pack_sf_machine_policy.json
  }
}

data "aws_iam_policy_document" "court_document_pack_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "court_document_pack_sf_machine_policy" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid     = "InvokeLambdaPolicy"
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.court_document_pack.arn
    ]
  }
}

# Lambda Roles

# Role for the lambda functions in judgment pack step-function
resource "aws_iam_role" "court_document_pack_sf_lambda_role" {
  name                 = "${var.env}-${var.prefix}-court-document-pack-sf-lambda-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
}

resource "aws_iam_role_policy_attachment" "court_document_pack_lambda_logs" {
  role       = aws_iam_role.court_document_pack_sf_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

# Role for the judgment pack step-function trigger
resource "aws_iam_role" "court_document_pack_sf_trigger_role" {
  name                 = "${var.env}-${var.prefix}-court-document-pack-sf-trigger-lambda-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "${var.env}-${var.prefix}-court-document-pack-sf-trigger"
    policy = data.aws_iam_policy_document.court_document_pack_sf_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "court_document_pack_sqs_lambda_trigger" {
  role       = aws_iam_role.court_document_pack_sf_trigger_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Lambda policy documents

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "packer_lambda_kms_policy_data" {
  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.tre_court_document_pack_out_key.arn]
  }
}

resource "aws_iam_policy" "packer_lambda_kms_policy" {
  name        = "${var.env}-${var.prefix}-packer-s3-key"
  description = "The KMS key policy for packer lambda"
  policy      = data.aws_iam_policy_document.packer_lambda_kms_policy_data.json
}

resource "aws_iam_role_policy_attachment" "packer_lambda_key" {
  role       = aws_iam_role.court_document_pack_sf_lambda_role.name
  policy_arn = aws_iam_policy.packer_lambda_kms_policy.arn
}

data "aws_iam_policy_document" "court_document_pack_sf_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [aws_sfn_state_machine.court_document_pack_sf.arn]
  }
}

# SQS Polciy

data "aws_iam_policy_document" "tre_court_document_pack_in_queue" {
  statement {
    actions = ["sqs:SendMessage"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
    resources = [
      aws_sqs_queue.court_document_pack_in_sqs.arn
    ]
  }
}

# S3 Policy

data "aws_iam_policy_document" "court_document_pack_out_bucket" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.court_document_pack_sf_lambda_role.arn]
    }

    resources = ["${aws_s3_bucket.tre_court_document_pack_out.arn}/*", aws_s3_bucket.tre_court_document_pack_out.arn]
  }
  statement {
    actions = [
      "s3:GetObject"
    ]

    principals {
      type        = "AWS"
      identifiers = var.external_court_document_pack_out_bucket_readers
    }

    resources = ["${aws_s3_bucket.tre_court_document_pack_out.arn}/*", aws_s3_bucket.tre_court_document_pack_out.arn]
  }
}

data "aws_iam_policy_document" "court_document_pack_out_bucket_kms" {

  statement {
    sid     = "Allow access for Key Administrators"
    actions = ["kms:*"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow court doc readers key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.external_court_document_pack_out_bucket_readers
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.wiz_access_roles) == 0 ? [] : ["wiz_access_roles"]
    content {
      sid = "Allow access for Wiz"
      principals {
        type        = "AWS"
        identifiers = var.wiz_access_roles
      }
      actions = [
        "kms:Describe*",
        "kms:Decrypt",
        "kms:CreateGrant",
        "kms:GenerateDataKey"
      ]
      resources = ["*"]
    }
  }
}
