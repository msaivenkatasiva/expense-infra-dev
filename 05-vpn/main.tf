resource "aws_key_pair" "vpn" {
  key_name   = "vpn"
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm2omUjv1fe0olcppgRP0qJmUzXJBpKxngDZFZbCKO6 msaiv@msvsiva"
  public_key = file("~/.ssh/openvpn.pub")
}

resource "aws_instance" "vpn" {
  ami           = data.aws_ami.ami_info.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  subnet_id = local.public_subnet_id
  #key_name = "daws-84s" # make sure this key exist in AWS
  key_name = aws_key_pair.vpn.key_name
  user_data = file("openvpn.sh")

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

# module "vpn" {
#     source = "terraform-aws-modules/ec2-instance/aws"
#     key_name = aws_key_pair.vpn.key_name
#     create_security_group = false #as the module is taken from internet it already contains it's own SG, but we already have our own SGs, in order to avoid new SG, setting the new SG to false
#     name = "${var.project_name}-${var.environment}-vpn"
#     ami = data.aws_ami.ami_info.id
#     #ami = "ami-06e5a963b2dadea6f"
#     subnet_id = local.public_subnet_id
#     user_data = file("openvpn.sh")
#     instance_type = "t3.micro"
#     vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
#     tags = merge(
#         var.common_tags,
#         {
#             Name = "${var.project_name}-${var.environment}-vpn"
#         }
#     )
# }

