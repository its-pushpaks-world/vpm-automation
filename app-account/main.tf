terraform {
  # The remote backend destination for App Account
  backend "s3" {
    bucket       = "vpm-app-tfstate-prod" # Choose a unique name
    key          = "app/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}

# 1. The default provider (Deploys the EC2 instance here)
provider "aws" {
  region = "ap-south-1"
}

# Call the shared module to manage the app state bucket local to this account
module "state_backend" {
  source      = "../modules/remote-backend"
  bucket_name = "vpm-app-tfstate-prod"
}

# 2. The aliased provider (Assumes the role in the Platform account)
provider "aws" {
  alias  = "platform_reader"
  region = "ap-south-1"
  assume_role {
    # The ARN outputted from Part 1
    role_arn = "arn:aws:iam::242655703609:role/CrossAccountAMIReaderRole"
  }
}

data "aws_ssm_parameter" "frontend_ami" {
  provider = aws.platform_reader
  name     = "/platform/amis/frontend/latest"
}

# 3. Call your module, passing the aliased provider
module "frontend_instance" {
  source = "./../modules/ec2-instance"

  name          = "frontend-app"
  environment   = "prod"
  instance_type = "t3.micro"
  ami_id        = data.aws_ssm_parameter.frontend_ami.value

  # Pass the providers explicitly!
  providers = {
    aws          = aws
    aws.platform = aws.platform_reader
  }
}
