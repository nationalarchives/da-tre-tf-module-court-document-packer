locals {
  resource_prefix                        = "${var.env}-${var.prefix}"
  step_function_name                     = "${local.resource_prefix}-judgment-packer-sf"
  lambda_name_judgment_packer            = "${local.resource_prefix}-judgment-packer"
  lambda_name_judgment_packer_sf_trigger = "${local.resource_prefix}-judgment-packer-trigger"
}
