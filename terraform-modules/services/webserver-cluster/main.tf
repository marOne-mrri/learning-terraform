resource "aws_security_group" "sg" {
  name = "my-sec-grp"
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.all_ips
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.all_ips
  }
  egress {
    description = "access internet"
    protocol    = "all"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = local.all_ips
  }
}

resource "aws_launch_configuration" "launch_configuration_test" {
  image_id        = "ami-08c40ec9ead489470"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.id]
  user_data       = <<-EOF
                      #!/bin/bash
                      sudo apt update -y
                      sudo apt install -y nginx
                      sudo echo "${data.terraform_remote_state.db.outputs.address}" >> /usr/share/nginx/html/index.html
                      sudo service restart nginx
                    EOF
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_autoscaling_group" "auto_grp_test" {
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  launch_configuration = aws_launch_configuration.launch_configuration_test.name
  target_group_arns    = [aws_lb_target_group.target_grp.arn]
  health_check_type    = "ELB"
  min_size             = 2
  max_size             = 10
  tag {
    key                 = "name"
    value               = "auto_grp_test"
    propagate_at_launch = true
  }
}

resource "aws_lb" "lb_test" {
  name               = "lbtest"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb_test.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"404\": \"page not found\"}"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "lb_sg" {
  name = var.cluster_name #* "my-lb-sec-grp"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.lb_sg.id
  description = "http"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.lb_sg.id
  description = "access internet"
  protocol    = "all"
  from_port   = 0
  to_port     = 0
  cidr_blocks = local.all_ips
}

resource "aws_lb_target_group" "target_grp" {
  name     = "target-group-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule_test" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_grp.arn
  }
}

output "alb_dns_name" {
  value       = aws_lb.lb_test.dns_name
  description = "lb domain name"
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-managment-bucket"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-state-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket #* "terraform-up-and-running-state-managment-bucket"
    key    = var.db_remote_state_key #* "stage/data-store/mysql/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  all_ips = ["0.0.0.0/0"]
}
