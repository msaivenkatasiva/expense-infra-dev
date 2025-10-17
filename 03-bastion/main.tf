module "bastion" {
    source = "terraform-aws-modules/ec2-instance/aws"
    create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
    name = "${var.project_name}-${var.environment}-bastion"
    ami = data.aws_ami.ami_info.id
    user_data = file("bastion.sh")
    subnet_id = local.public_subnet_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-bastion"
        }
    )
}
