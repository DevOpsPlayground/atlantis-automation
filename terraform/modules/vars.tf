################################################################################
# VPC Vars
################################################################################
variable "cidr_block" {
  description = "CIDR Block used by VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "whitelisted_ip" {
  description = "IP whitelisted"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project" {
    description = "Name of the project"
    type        = string
    default     = "alantis-ec2-test"
}

################################################################################
# EC2 Vars
################################################################################
variable "ami" {
  description = "AMI used for Atlantis EC2"
  type        = string
  default     = "ami-062155e74028d4358"
}


variable "instance_type" {
  description = "Size of EC2"
  type        = map(string)
  default     = {
    default   = "t3.large"
    dev       = "t3.medium"
    prod      = "t3.large" 
  }
}

variable "ec2_atlantis_ssm_role" {
  description = "Role used for Atlantis EC2, SSM"
  type = string
  default = "atlantis-ssm-role"
}

variable "ec2_atlantis_ssm_role_description" {
  description = "Description of what the role is for"
  type = string
  default = "IAM role for EC2 Atlantis"
}

variable "amazonssm_role" {
  description = "Role ARN for Amazon SSM Automation Role"
  type = string
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

variable "tag_ec2" {
  description = "Name tag for EC2 instance"
  type = string
  default = "atlantis-ec2-github"
  
}

################################################################################
# Security Group Vars
################################################################################
variable "security_group_name" {
  description = "Name of the security group"
  type = string
  default = "atlantis-ec2-sg"
}

variable "security_group_description" {
  description = "description of security group"
  type = string
  default = "Security group for for EC2 Atlantis" 
}

variable "security_group_nametag" {
  description = "Name tag of security group"
  type = string
  default = "Atlantis Security Group"  
}