################################################################################
# EC2 Module
################################################################################
module "ec2_complete" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance/"

  ami                         = var.ami
  instance_type               = var.instance_type[terraform.workspace]
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  disable_api_stop            = false

  create_iam_instance_profile = true
  iam_role_name               = var.ec2_atlantis_ssm_role
  iam_role_description        = var.ec2_atlantis_ssm_role_description
  iam_role_policies = {
    AmazonSSMAutomationRole   = var.amazonssm_role
  }

  user_data_base64            = base64encode(file("./modules/user_data_atlantis.tpl"))
  user_data_replace_on_change = true


  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 20
      tags = {
        Name = "atlantis-root-disk"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      tags = {
        MountPoint = "/mnt/data"
      }
    }
  ]

  tags = {
    Name = "${var.tag_ec2}"
  }

}
