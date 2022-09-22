data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
   bucket = "terraform-state-123bkp"
   key = "level1.tfstate"
   region = "ap-south-1"
    }
  }
  