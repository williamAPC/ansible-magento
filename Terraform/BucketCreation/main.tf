# # Create S3 bucket for storing terraform state
# resource "aws_s3_bucket" "zzzzzzzz" {
#   bucket = "zzzzzzzzzzz"
#   acl = "private"
#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "Terraform state bucket"
#   }
# }