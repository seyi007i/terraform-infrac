resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL access from backend tier"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.backend_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

resource "aws_dynamodb_table" "app_table" {
  name           = "appdb"
  billing_mode   = "PAY_PER_REQUEST"   # On-demand billing mode
  hash_key       = "id"                 # Partition key for the table
  attribute {
    name = "id"
    type = "S"                         # String type for the 'id' attribute
  }

  # Additional attributes or keys based on your data model
  # If you want, you can add range keys, global secondary indexes, etc.

  tags = {
    Name = "appdb"
  }
}
