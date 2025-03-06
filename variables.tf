variable "env" {
  description = "Name of the environment to deploy"
  type        = string
}

variable "prefix" {
  description = "Transformation Engine prefix"
  type        = string
}


variable "account_id" {
  description = "Account ID where Image for the Lambda function will be"
  type        = string
}

variable "court_document_pack_sf_version" {
  description = "judgment pack version (update if Step Function flow or called Lambda function versions change)"
  type        = string

}

variable "court_document_pack_image_versions" {
  description = "Latest version of Images for Lambda Functions"
  type = object({
    tre_court_document_pack = string
    tre_sqs_sf_trigger      = string
  })
}

variable "notification_topic_arn" {
  description = "The ARN of the topic to notify"
  type        = string
}

variable "tre_dlq_alerts_lambda_function_name" {
  description = "TRE DLQ Alerts Lambda Function Name"
  type        = string
}

variable "tre_permission_boundary_arn" {
  description = "ARN of the TRE permission boundary policy"
  type        = string
}

variable "ecr_uri_host" {
  description = "The hostname part of the management account ECR repository; e.g. ACCOUNT.dkr.ecr.REGION.amazonaws.com"
  type        = string
}

variable "ecr_uri_repo_prefix" {
  description = "The prefix for Docker image repository names to use; e.g. foo/ in ACCOUNT.dkr.ecr.REGION.amazonaws.com/foo/tre-bar"
  type        = string
}

variable "external_court_document_pack_out_bucket_readers" {
  description = "The accounts that are allowed to read from the court document packed out bucket"
  type        = list(string)
}

variable "wiz_access_roles" {
  description = "ARNs of wiz roles used to allow scanning of all the resources in the TRE system"
  type        = list(string)
  default     = []
}

variable "limit_s3_data_retention" {
  description = "Whether s3 bucket data retention should be limited in this module"
  type        = bool
}
