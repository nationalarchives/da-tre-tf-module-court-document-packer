resource "aws_cloudwatch_log_group" "judgment_packer" {
  name = "/aws/vendedlogs/states/${var.env}-${var.prefix}-judgment-packer"
}
