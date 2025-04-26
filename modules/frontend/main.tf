resource "aws_instance" "bastion" {
  ami                    = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = "terraform-key"
}

resource "aws_instance" "nginx" {
  count                  = 2
  ami                    = "ami-0dba2c7f21e8a38b1"  
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.nginx_sg_id]
  
  user_data = <<-EOF
              #!/bin/bash
              # Update the package list
              apt-get update -y
              # Install Nginx
              apt-get install -y nginx
              # Start Nginx service
              systemctl start nginx
              # Enable Nginx to start on boot
              systemctl enable nginx
              # Create a custom index.html page
              echo "<html><body><h1>front end server</h1></body></html>" > /var/www/html/index.html
              EOF
}

resource "aws_lb" "nlb" {
  name               = "frontend-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_id]
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "nginx_attach" {
  count            = 2
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

