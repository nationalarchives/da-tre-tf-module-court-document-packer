resource "aws_lambda_function" "court_document_pack" {
  image_uri     = "${var.ecr_uri_host}/${var.ecr_uri_repo_prefix}${var.prefix}-judgment-packer:${var.court_document_pack_image_versions.tre_court_document_pack}"
  package_type  = "Image"
  function_name = local.lambda_name_court_document_pack
  role          = aws_iam_role.court_document_pack_sf_lambda_role.arn
  timeout       = 300

  environment {
    variables = {
      "TRE_S3_COURT_DOCUMENT_PACK_OUT_BUCKET" = aws_s3_bucket.tre_court_document_pack_out.bucket
      "TRE_ENVIRONMENT"                       = var.env
      "TRE_PARENT_STEP_FUNCTION"              = local.step_function_name
      "TRE_PROCESS_NAME"                      = local.lambda_name_court_document_pack
      "TRE_SYSTEM_NAME"                       = upper(var.prefix)
    }
  }

}

resource "aws_lambda_function_event_invoke_config" "packer_success_failure_destinations" {
  function_name = local.lambda_name_court_document_pack
  destination_config {
    on_success {
      destination = var.success_handler_lambda_arn
    }
    on_failure {
      destination = var.success_handler_lambda_arn
    }
  }
}

# court_document_pack_step_function_trigger
resource "aws_lambda_function" "court_document_pack_sf_trigger" {
  image_uri     = "${var.ecr_uri_host}/${var.ecr_uri_repo_prefix}${var.prefix}-sqs-sf-trigger:${var.court_document_pack_image_versions.tre_sqs_sf_trigger}"
  package_type  = "Image"
  function_name = local.lambda_name_court_document_pack_sf_trigger
  role          = aws_iam_role.court_document_pack_sf_trigger_role.arn
  timeout       = 30

  environment {
    variables = {
      "TRE_STATE_MACHINE_ARN"    = aws_sfn_state_machine.court_document_pack_sf.arn
      "TRE_CONSIGNMENT_KEY_PATH" = "parameters.reference"
      "TRE_RETRY_KEY_PATH"       = "parameters.court_document_pack.number-of-retries"
    }
  }
}

resource "aws_lambda_event_source_mapping" "court_document_pack_in_sqs" {
  batch_size                         = 1
  function_name                      = aws_lambda_function.court_document_pack_sf_trigger.function_name
  event_source_arn                   = aws_sqs_queue.court_document_pack_in_sqs.arn
  maximum_batching_window_in_seconds = 0
}
