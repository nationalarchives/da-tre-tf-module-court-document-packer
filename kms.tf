
resource "aws_kms_key" "tre_court_document_pack_out_key" {
  description              = "This key is used to encrypt ${var.env}-${var.prefix}-tre_court_document_pack_out s3"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = true
  policy                   = data.aws_iam_policy_document.court_document_pack_out_bucket_kms.json
  deletion_window_in_days  = 30
}

# Add an alias to the key
resource "aws_kms_alias" "tre_court_document_pack_out_key_alias" {
  name          = "alias/s3/${var.env}/${var.prefix}-tre_court_document_pack_out"
  target_key_id = aws_kms_key.tre_court_document_pack_out_key
}
