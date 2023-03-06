output "judgment_packer_in_queue_arn" {
  value       = aws_sqs_queue.judgment_packer_in_sqs.arn
  description = "ARN of the TRE-judgment-packer SQS Queue"
}

output "judgment_packer_lambda_role" {
  value       = aws_iam_role.judgement_packer.arn
  description = "ARN of the judgment packer Lamda Role"
}

output "judgment_packer_role_arn" {
  value       = aws_sfn_state_machine.judgment_packer_sf.role_arn
  description = "ARN of the Judgment Packer Step Function Role"

}
