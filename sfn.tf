resource "aws_sfn_state_machine" "court_document_pack_sf" {
  name     = local.step_function_name
  role_arn = aws_iam_role.court-document-pack.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
    arn_lambda_court_document_pack            = aws_lambda_function.court_document_pack.arn
    arn_sns_topic_tre_slack_alerts            = var.common_tre_slack_alerts_topic_arn
    arn_sns_topic_tre_court_document_pack_out = var.common_da_eventbus_topic_arn
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.court_document_pack.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}
