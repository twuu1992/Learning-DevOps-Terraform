output "alb_DNS" {
  value = module.app_lb.alb_DNS
}
output "user_app_ip_address" {
  value = aws_instance.my_user_app.public_ip
}
output "user_mongodb_ip_address" {
  value = aws_instance.my_user_db.public_ip
}
output "user_app_public_dns" {
  value = aws_instance.my_user_app.public_dns
}
