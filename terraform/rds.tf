#########################################
# DB subnet Group
#########################################
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "My DB subnet group"
  }
}

#########################################
# DB Instance
#########################################

resource "aws_db_instance" "this" {
  db_name                = "db"
  identifier             = local.name
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  username               = "admin"
  password               = "adminadmin1"
  allocated_storage      = 20
}