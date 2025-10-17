resource "aws_instance" "jenkins_tf" {
  ami           = data.aws_ami.ami_info.id
  instance_type = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.jenkins_tf_sg_id.value]
  subnet_id = local.public_subnet_id
  user_data = file("jenkins.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-jenkins"
    }
  )
}

resource "aws_instance" "jenkins_agent" {
  ami           = data.aws_ami.ami_info.id
  instance_type = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.jenkins_agent_sg_id.value]
  subnet_id = local.public_subnet_id
  user_data = file("jenkins-agent.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-jenkins-agent"
    }
  )
}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm2omUjv1fe0olcppgRP0qJmUzXJBpKxngDZFZbCKO6 msaiv@msvsiva"
  public_key = file("~/.ssh/tools.pub")
}

resource "aws_instance" "nexus" {
  ami           = data.aws_ami.nexus_ami_info.id
  instance_type = "t3.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.nexus_sg_id.value]
  subnet_id = local.public_subnet_id
  #key_name = "daws-84s" # make sure this key exist in AWS
  key_name = aws_key_pair.tools.key_name
  user_data = file("jenkins.sh")
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    }
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-nexus"
    }
  )
}







module "records" {
    source = "terraform-aws-modules/route53/aws//modules/records"
    version = "~> 2.0"
    zone_name = var.zone_name
    records = [
        {
            name = "jenkins"
            type = "A"
            ttl = 1
            records = [aws_instance.jenkins_tf.public_ip]
            allow_overwrite = true           
        },
        {
            name = "jenkins-agent"
            type = "A"
            ttl = 1
            records = [aws_instance.jenkins_agent.private_ip]
            allow_overwrite = true
        },
        {
            name = "nexus"
            type = "A"
            ttl = 1
            records = [aws_instance.nexus.private_ip]
            allow_overwrite = true
        }
    ]
}
