output "address" {
  value = aws_db_instance.my_db.address
  description = "connect to the db here"
}

output "port" {
  value = aws_db_instance.my_db.port
  description = "the db is listening here"
}
