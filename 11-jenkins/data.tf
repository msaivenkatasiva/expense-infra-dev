data "aws_ami" "ami_info" {

    most_recent = true
    owners = ["973714476881"]

    filter {
        name   = "name"
        values = ["RHEL-9-DevOps-Practice"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "nexus_ami_info" {

    most_recent = true
    owners = ["679593333241"]

    filter {
        name   = "name"
        values = ["SolveDevOps-Nexus-Server-Ubuntu20.04-20240511-*"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "jenkins_tf_sg_id" {
    name = "/${var.project_name}/${var.environment}/jenkins_tf_sg_id"
}

data "aws_ssm_parameter" "jenkins_agent_sg_id" {
    name = "/${var.project_name}/${var.environment}/jenkins_agent_sg_id"
}

data "aws_ssm_parameter" "nexus_sg_id" {
    name = "/${var.project_name}/${var.environment}/nexus_sg_id"
}