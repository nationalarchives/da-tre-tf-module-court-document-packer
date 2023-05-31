locals {
  resource_prefix                        = "${var.env}-${var.prefix}"
  step_function_name                     = "${local.resource_prefix}-court-document-pack"
  lambda_name_court_document_pack            = "${local.resource_prefix}-court-document-pack-lambda"
  lambda_name_court_document_pack_sf_trigger = "${local.resource_prefix}-court-document-pack-trigger"
}
