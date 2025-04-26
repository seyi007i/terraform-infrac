resource "aws_launch_template" "backend" {
  name_prefix   = "backend-lt"
  image_id      = "ami-0dba2c7f21e8a38b1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.backend_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              # Start Nginx service
              systemctl start nginx
              # Enable Nginx to start on boot
              systemctl enable nginx
              # Create a custom index.html page
              echo "<html><body><h1>Backend server</h1></body></html>" > /var/www/html/index.html
              EOF
              
              }

resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.private_subnets
  
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}
