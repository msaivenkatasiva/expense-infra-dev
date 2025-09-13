module "backend" {
    source = "terraform-aws-modules/ec2-instance/aws"
    create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
    name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    ami = data.aws_ami.ami_info.id
    subnet_id = local.private_subnet_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
        }
    )
}

resource "null_resource" "backend" {
  triggers = {
    instance_id = module.backend.id # this will be triggered everytime instance is created
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "DevOps321"
    host        = module.backend.private_ip
  }

  provisioner "file" {
    source = "${var.common_tags.Component}.sh"
    destination = "/tmp/${var.common_tags.Component}.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${var.common_tags.Component}.sh",
      "sudo sh /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component} ${var.environment}"
    ]
  }
}
