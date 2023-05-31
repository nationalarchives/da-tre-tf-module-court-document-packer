resource "aws_cloudwatch_log_group" "court_document_pack" {
  name = "/aws/vendedlogs/states/${var.env}-${var.prefix}-court-document-pack"
}
