resource "aws_launch_template" "backend" {
  name_prefix   = "backend-lt"
  image_id      = "ami-0f9de6e2d2f067fca"
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.backend_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<html><body><h1>Backend server</h1></body></html>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.private_subnets
  health_check_type     = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "backend-server"
    propagate_at_launch = true
  }
}