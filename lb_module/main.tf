resource "aws_security_group" "alb_sg" {
    name = "alb_security_group"
    vpc_id = var.vpc_id_reference
    description = "alb sg having rules on port 80 and all traffic"
    tags = {
        Name = "${terraform.workspace}-alb-sg"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "devops_lb" {

    load_balancer_type = "application"
    name = "${terraform.workspace}-alb"
    internal = false
    security_groups = [aws_security_group.alb_sg.id]
    subnets = var.public_subnet_ID
    enable_deletion_protection = false
    idle_timeout = 400
    tags = {
        Name = "${terraform.workspace}-alb"
    }
}

resource "aws_lb_target_group" "devops_target_group" {
    name = "${terraform.workspace}-lb-tg"
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = var.vpc_id_reference
    health_check {
        path = "/"
        port = 80
        protocol = "HTTP"
        timeout = 5
        interval = 30
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "${terraform.workspace}-alb-tg"
    }
}

resource "aws_lb_listener" "devops_listener" {
    load_balancer_arn = aws_lb.devops_lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.devops_target_group.arn
    }
}
