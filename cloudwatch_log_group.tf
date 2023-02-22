resource "aws_cloudwatch_log_group" "judgment_packer" {
  name = "${var.env}-${var.prefix}-judgment-packer"
}
