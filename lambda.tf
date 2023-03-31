resource "aws_lambda_function" "judgment_packer" {
  image_uri     = "${var.ecr_uri_host}/${var.ecr_uri_repo_prefix}${var.prefix}-judgment-packer:${var.judgment_packer_image_versions.tre_judgment_packer}"
  package_type  = "Image"
  function_name = local.lambda_name_judgment_packer
  role          = aws_iam_role.judgment_packer_sf_lambda_role.arn
  timeout       = 300

  environment {
    variables = {
      "TRE_S3_JUDGMENT_OUT_BUCKET" = aws_s3_bucket.packed_judgment_out.bucket
      "TRE_ENVIRONMENT"            = var.env
      "TRE_PRESIGNED_URL_EXPIRY"   = 360
      "TRE_PARENT_STEP_FUNCTION"   = local.step_function_name
      "TRE_PROCESS_NAME"           = local.lambda_name_judgment_packer
      "TRE_SYSTEM_NAME"            = upper(var.prefix)
    }
  }
}

# judgment_packer_step_function_trigger
resource "aws_lambda_function" "judgment_packer_sf_trigger" {
  image_uri     = "${var.ecr_uri_host}/${var.ecr_uri_repo_prefix}${var.prefix}-sqs-sf-trigger:${var.judgment_packer_image_versions.tre_sqs_sf_trigger}"
  package_type  = "Image"
  function_name = local.lambda_name_judgment_packer_sf_trigger
  role          = aws_iam_role.judgment_packer_sf_trigger_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_STATE_MACHINE_ARN"    = aws_sfn_state_machine.judgment_packer_sf.arn
      "TRE_CONSIGNMENT_KEY_PATH" = "parameters.reference"
      "TRE_RETRY_KEY_PATH"       = "parameters.judgment_packer.number-of-retries"
    }
  }
}

resource "aws_lambda_event_source_mapping" "judgment_packer_in_sqs" {
  batch_size                         = 1
  function_name                      = aws_lambda_function.judgment_packer_sf_trigger.function_name
  event_source_arn                   = aws_sqs_queue.judgment_packer_in_sqs.arn
  maximum_batching_window_in_seconds = 0
}
