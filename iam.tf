resource "aws_iam_role" "judgement_packer" {
  name                 = "${var.env}-${var.prefix}-judgement-packer-role"
  assume_role_policy   = data.aws_iam_policy_document.judgment_packer_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "judgment-packer-policies"
    policy = data.aws_iam_policy_document.judgment_packer_sf_machine_policy.json
  }
}

data "aws_iam_policy_document" "judgment_packer_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "judgment_packer_sf_machine_policy" {
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
      aws_lambda_function.judgment_packer.arn
    ]
  }
}

# Lambda Roles

# Role for the lambda functions in judgment packer step-function
resource "aws_iam_role" "judgment_packer_sf_lambda_role" {
  name                 = "${var.env}-${var.prefix}-judgment-packer-sf-lambda-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
}

resource "aws_iam_role_policy_attachment" "judgment_packer_lambda_logs" {
  role       = aws_iam_role.judgment_packer_sf_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

# Role for the judgment packer step-function trigger
resource "aws_iam_role" "judgment_packer_trigger_role" {
  name                 = "${var.env}-${var.prefix}-judgment-packer-trigger-lambda-role"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  permissions_boundary = var.tre_permission_boundary_arn
  inline_policy {
    name   = "${var.env}-${var.prefix}-judgment-packer-trigger"
    policy = data.aws_iam_policy_document.judgment_packer_trigger.json
  }
}

resource "aws_iam_role_policy_attachment" "judgment_packer_sqs_lambda_trigger" {
  role       = aws_iam_role.judgment_packer_trigger_role.name
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

data "aws_iam_policy_document" "judgment_packer_trigger" {
  statement {
    actions   = ["states:StartExecution"]
    effect    = "Allow"
    resources = [aws_sfn_state_machine.judgment_packer_sf.arn]
  }
}

# SQS Polciy

data "aws_iam_policy_document" "tre_judgment_packer_in_queue" {
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
      aws_sqs_queue.judgment_packer_in_sqs.arn
    ]
  }
}

# S3 Policy

data "aws_iam_policy_document" "judgment_packer_out_bucket" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.judgment_packer_sf_lambda_role.arn]
    }

    resources = ["${aws_s3_bucket.packed-judgment-out.arn}/*", aws_s3_bucket.packed-judgment-out.arn]
  }
}
