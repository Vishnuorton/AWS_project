// we are getting data of exisiting aws resources here using data blocks.


// getting latest ami data of ubuntu 22.04 from aws using filter defined below.
data "aws_ami" "myami"{
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter { 
         name = "architecture"
         values = ["x86_64"]
    }   
}

// getting aws managed rds_full access policy from aws for our IAM _ role.
data "aws_iam_policy" "policy_rds_fullaccess" {
   name = "AmazonRDSFullAccess"
}

// getting aws managed s3_full access policy from aws for our IAM _ role.
data "aws_iam_policy" "policy_s3_fullaccess" {
   name = "AmazonS3FullAccess"
}