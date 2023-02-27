resource "aws_sfn_state_machine" "judgment_packer_sf" {
  name     = local.step_function_name
  role_arn = aws_iam_role.judgement_packer.arn
  definition = templatefile("${path.module}/templates/step-function-definition.json.tftpl", {
    arn_lambda_judgment_packer        = aws_lambda_function.judgment_packer.arn
    arn_sns_topic_tre_slack_alerts    = var.common_tre_slack_alerts_topic_arn
    arn_sns_topic_packed_judgment_out = var.common_tre_internal_topic_arn
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.judgment_packer.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tracing_configuration {
    enabled = true
  }
}
