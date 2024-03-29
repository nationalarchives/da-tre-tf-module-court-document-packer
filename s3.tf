resource "aws_s3_bucket" "tre_court_document_pack_out" {
  bucket = "${var.env}-${var.prefix}-court-document-pack-out"
}

resource "aws_s3_bucket_policy" "tre_court_document_pack_out" {
  bucket = aws_s3_bucket.tre_court_document_pack_out.bucket
  policy = data.aws_iam_policy_document.court_document_pack_out_bucket.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tre_court_document_pack_out" {
  bucket = aws_s3_bucket.tre_court_document_pack_out.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "alias/s3/${var.env}/${var.prefix}-tre_court_document_pack_out"
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tre_court_document_pack_out" {
  bucket = aws_s3_bucket.tre_court_document_pack_out.id
  versioning_configuration {
    status = var.limit_s3_data_retention ? "Suspended" : "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tre_court_document_pack_out" {
  bucket = aws_s3_bucket.tre_court_document_pack_out.id
  rule {
    id = "${aws_s3_bucket.tre_court_document_pack_out.id}-expiry"
    expiration {
      days = 7
    }
    status = var.limit_s3_data_retention ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tre_court_document_pack_out" {
  bucket                  = aws_s3_bucket.tre_court_document_pack_out.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
