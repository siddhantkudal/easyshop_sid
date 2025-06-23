terraform {
    backend "s3" {
        bucket = "primarybucket232000"
        region = "us-east-1"
        key = "easyshop/terraform.tfstate"

    }


}