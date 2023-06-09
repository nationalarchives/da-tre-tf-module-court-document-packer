output "court_document_pack_in_queue_arn" {
  value       = aws_sqs_queue.court_document_pack_in_sqs.arn
  description = "ARN of the TRE-court-document-pack SQS Queue"
}

output "court_document_pack_lambda_role" {
  value       = aws_iam_role.court_document_pack_sf_lambda_role.arn
  description = "ARN of the judgment packer Lamda Role"
}

output "court_document_pack_role_arn" {
  value       = aws_sfn_state_machine.court_document_pack_sf.role_arn
  description = "ARN of the Judgment Pack Step Function Role"

}
