module "my_modules" {
    source = "./vpc_module"
    my_region = "eu-west-1"
    vpc_cidr = "10.0.0.0/24"
    subnet1_cidr = "10.0.0.0/26"
    subnet2_cidr = "10.0.0.64/26"
    subnet3_cidr = "10.0.0.128/26"
    subnet4_cidr = "10.0.0.192/26"
    my_az_region1 = "eu-west-1a"
    my_az_region2 = "eu-west-1b"
}

module "my_modules" {
    source = "./lb_module"
    my_region = "eu-west-1"
    vpc_id_reference = module.vpc_module.vpc_id_reference
    public_subnet_ID = module.vpc_module.public_subnet_ID
}

module "my_modules" {
    source = "./asg_module"
    my_region = "eu-west-1"
    base_ami_id = "ami-08f9a9c699d2ab3f9"
    instance_type_for_custom_ami = "t2.small"
    instance_type_for_lt = "t2.small"   
    my_key = "rakeshrr"
    desired = "1"
    maximum = "1"
    minimum = "1"
    vpc_id_reference = module.vpc_module.vpc_id_reference
    public_subnet_ID = module.vpc_module.public_subnet_ID
    private_subnet_ID = module.vpc_module.private_subnet_ID
    aws_lb_target_group_arn = module.lb_module.aws_lb_target_group_arn
}

module "my_modules" {
    source = "./s3_module"
    my_region = "eu-west"
}

module "my_modules" {
    source = "./cdn_module"
    my_region = "eu-west-1"
    domain_name = module.s3_module.bucket_regional_domain_name
    bucket_id = module.s3_module.bucket_id
}