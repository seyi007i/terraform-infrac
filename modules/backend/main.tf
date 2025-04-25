resource "aws_launch_template" "backend" {
  name_prefix   = "backend-lt"
  image_id      = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-1.8.0-openjdk wget tar

              useradd -m -U -d /opt/tomcat -s /bin/false tomcat

              wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.78/bin/apache-tomcat-9.0.78.tar.gz
              mkdir -p /opt/tomcat
              tar xzf apache-tomcat-9.0.78.tar.gz -C /opt/tomcat --strip-components=1

              chown -R tomcat: /opt/tomcat
              chmod +x /opt/tomcat/bin/*.sh

              cat <<EOT > /etc/systemd/system/tomcat.service
              [Unit]
              Description=Apache Tomcat Web Application Container
              After=network.target

              [Service]
              Type=forking

              Environment=JAVA_HOME=/usr/lib/jvm/jre
              Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
              Environment=CATALINA_HOME=/opt/tomcat
              Environment=CATALINA_BASE=/opt/tomcat
              Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
              Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

              ExecStart=/opt/tomcat/bin/startup.sh
              ExecStop=/opt/tomcat/bin/shutdown.sh

              User=tomcat
              Group=tomcat
              UMask=0007
              RestartSec=10
              Restart=always

              [Install]
              WantedBy=multi-user.target
              EOT

              systemctl daemon-reexec
              systemctl daemon-reload
              systemctl start tomcat
              systemctl enable tomcat
              EOF
)


  vpc_security_group_ids = [var.backend_sg_id]
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
