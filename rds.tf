#####################################################################
# ssm
#####################################################################
data "aws_ssm_parameter" "rds_credentials" {
  name = "/naoki/terraform/rds"
}

#####################################################################
# subnet froup
#####################################################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.name_prefix}-rds-subnet-group"
  subnet_ids =  [aws_subnet.private_1a.id, aws_subnet.private_1c.id]

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group"
  }
}

#####################################################################
# RDS
######################################################################
resource "aws_db_instance" "rds" {
  identifier             = "${local.name_prefix}-rds"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.40"
  instance_class         = "db.t4g.micro"
  username               = jsondecode(data.aws_ssm_parameter.rds_credentials.value)["username"]
  password               = jsondecode(data.aws_ssm_parameter.rds_credentials.value)["password"]
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
    tags = merge(local.common_tags, {
    Environment = "${local.name_prefix}-rds"
  })
}