###creating database security-group(firewall)
module "db" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for DB MYSQL Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "db"
}

###creating backend security-group(firewall)
module "backend" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for Backend Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "backend"
}

###creating app_alb security-group(firewall)
module "app_alb" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for app_alb Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "app_alb"
}

###creating frontend security-group(firewall)
module "frontend" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for Frontend Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "frontend"
}

###creating app_alb security-group(firewall)
module "web_alb" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for web_alb Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "web_alb"
}

###creating bastion security-group(firewall)
module "bastion" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for bastion Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "bastion"
}

###creating ansible security-group(firewall)
module "vpn" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for vpn Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "vpn"
    ingress_rules = var.vpn_sg_rules
}

module "jenkins_tf" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for jenkins Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "jenkins_tf"
}

module "jenkins_agent" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for jenkins-agent Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "jenkins_agent"
}

module "nexus" {
    source = "../../terraform-aws-security_group"
    project_name = var.project_name
    environment = var.environment
    sg_description = "SG for nexus Instances"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_name = "nexus"
}

###DB servers are accepting traffic from backend servers
resource "aws_security_group_rule" "db_from_backend" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.backend.sg_id
    security_group_id = module.db.sg_id
} 

resource "aws_security_group_rule" "db_from_bastion" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion.sg_id
    security_group_id = module.db.sg_id
} 

resource "aws_security_group_rule" "db_from_vpn" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.db.sg_id
}

###backend servers are accepting traffic from frontend
resource "aws_security_group_rule" "backend_from_app_alb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.app_alb.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_from_vpn_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_from_vpn_http" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

###app_alb servers are accepting traffic from frontend
resource "aws_security_group_rule" "app_alb_vpn" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_bastion" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.app_alb.sg_id
}

###frontend servers are accepting traffic from public
resource "aws_security_group_rule" "frontend_from_web_alb" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.web_alb.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_from_vpn" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.frontend.sg_id
}

###web_alb servers are accepting traffic from public
resource "aws_security_group_rule" "web_alb_from_public" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

resource "aws_security_group_rule" "web_alb_from_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}


###bastion servers are accepting traffic from public
resource "aws_security_group_rule" "bastion_from_public" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

#added as part of Jenkins CICD
resource "aws_security_group_rule" "backend_default_vpc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["172.31.0.0/16"]
  security_group_id = module.backend.sg_id
}

#added as part of Jenkins CICD
resource "aws_security_group_rule" "frontend_default_vpc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["172.31.0.0/16"]
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "jenkins_tf_public" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.jenkins_tf.sg_id
}

resource "aws_security_group_rule" "jenkins_tf_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.jenkins_tf.sg_id
}
resource "aws_security_group_rule" "jenkins_agent_public" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.jenkins_agent.sg_id
}

resource "aws_security_group_rule" "jenkins_agent_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.jenkins_agent.sg_id
}
resource "aws_security_group_rule" "nexus_public" {
  type              = "ingress"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.nexus.sg_id
}

resource "aws_security_group_rule" "nexus_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.nexus.sg_id
}


# note: As we've created SGs and created ingressrules which traffic have to be allowed to related server.Now right after creating the SGs, update those in the parameter store. So, those'd be used by the team who gonna create servers using these SG IDs.
