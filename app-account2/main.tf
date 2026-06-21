terraform {
  backend "s3" {
    bucket       = "vpm-app-tfstate-dev"
    key          = "app/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "state_backend" {
  source      = "../modules/remote-backend"
  bucket_name = "vpm-app-tfstate-dev"
}

# 2. Dynamic Aliased Provider pointing directly to your variable block
provider "aws" {
  alias  = "platform_reader"
  region = "ap-south-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.platform_account_id}:role/CrossAccountAMIReaderRole"
  }
}

data "aws_ssm_parameter" "frontend_ami" {
  provider = aws.platform_reader
  name     = "/platform/amis/frontend/latest"
}

# 3. Call your module
module "frontend_instance" {
  source = "./../modules/ec2-instance"

  name          = "frontend-app"
  environment   = "dev"
  instance_type = "t3.micro"
  ami_id        = data.aws_ssm_parameter.frontend_ami.value

  providers = {
    aws          = aws
    aws.platform = aws.platform_reader
  }
}
