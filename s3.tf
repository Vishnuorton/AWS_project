// we are creating s3 bucket here for storing our production data so that we can achieve DR strategy

resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.bucket_name             // check terraform.tfvars for predefined bucket_name   
    force_destroy = true                 // delete s3 even if it have objects when we use terraform destroy
}