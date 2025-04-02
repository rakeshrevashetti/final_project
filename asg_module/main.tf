resource "aws_security_group" "launch_template_sg" {
    vpc_id = var.vpc_id_reference
    name = "launch_template_sg"
    description = "Security group for launch template"
    tags = {
        Name = "${terraform.workspace}-lt-security-group"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"    
        cidr_blocks = ["0.0.0.0/0"] 
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
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

resource "aws_instance" "custom_ami_instance" {
  ami           = var.base_ami_id  
  instance_type = var.instance_type_for_custom_ami
  subnet_id     = var.public_subnet_ID[0]
  vpc_security_group_ids = [aws_security_group.launch_template_sg.id]
  key_name = "rakeshrr"

  tags = {
    Name = "${terraform.workspace}-custom-server"
  }

  provisioner "remote-exec" {
    connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = file("./rakeshrr")  
    host        = self.public_ip
  }

    inline = [
      "sudo yum update -y",              
      "sudo yum install -y httpd",       
      "sudo systemctl enable httpd",     
      "sudo systemctl start httpd",      
       
      "echo 'Hey guys we successfully auto scaled' | sudo tee /var/www/html/index.html"
    ]
  }
}


resource "aws_ami_from_instance" "custom_ami" {
  name               = "customised-ami-with-httpd-and-code"
  source_instance_id        = aws_instance.custom_ami_instance.id
    tags = {
        Name = "customised-ami-with-httpd-and-code"
    }
    depends_on = [aws_instance.custom_ami_instance]
}


resource "aws_launch_template" "custom_lt" {
  name          = "custom-launch-template"
  image_id      = aws_ami_from_instance.custom_ami.id  
  instance_type = var.instance_type_for_lt
  key_name      = var.my_key
  vpc_security_group_ids = [aws_security_group.launch_template_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "custom-instance"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"  
    ebs {
      volume_size = 8  
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

}

resource "aws_autoscaling_group" "devops_asg" {
    name = "${terraform.workspace}-asg"
    desired_capacity = var.desired
    max_size = var.maximum
    min_size = var.minimum
    vpc_zone_identifier = var.private_subnet_ID
    
    launch_template {
         id = aws_launch_template.custom_lt.id
         version = "$Latest"
    }
    target_group_arns = [var.aws_lb_target_group_arn]
    health_check_type = "ELB"
    health_check_grace_period = 300
    termination_policies = ["OldestInstance"]
    tag {
            key = "Name"
            value = "${terraform.workspace}-application"
            propagate_at_launch = true
        }
    depends_on = [ aws_launch_template.custom_lt ]
}