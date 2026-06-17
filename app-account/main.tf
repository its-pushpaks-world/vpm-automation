# 1. The default provider (Deploys the EC2 instance here)
provider "aws" {
  region = "ap-south-1"
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
