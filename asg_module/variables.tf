variable "my_region" {}

variable "vpc_id_reference" {}

variable "public_subnet_ID" {
    type = list(string)
}

variable "private_subnet_ID" {}

variable "aws_lb_target_group_arn" {}

variable "base_ami_id" {}

variable "instance_type_for_custom_ami" {}

variable "instance_type_for_lt" {}

variable "my_key" {}

variable "desired" {}

variable "maximum" {}

variable "minimum" {}