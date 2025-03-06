# Secrets Managerのシークレット作成 ############################################################
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds-password"
  description = "Password for RDS instance"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({ username = "naoki", password = "yourpassword" })
}

# RDSサブネットグループの作成 ############################################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.name_prefix}-rds-subnet-group"
  subnet_ids =  [aws_subnet.private_1a.id, aws_subnet.private_1c.id] # プライベートサブネットのIDを指定

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group"
  }
}

# RDSインスタンスの作成 ############################################################
resource "aws_db_instance" "rds" {
  identifier             = "${local.name_prefix}-rds"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.3"
  instance_class         = "db.t3.micro"
  username               = jsondecode(aws_secretsmanager_secret_version.rds_password_version.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.rds_password_version.secret_string)["password"]
  parameter_group_name   = "default.postgres14"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name  # 作成したサブネットグループを指定
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}