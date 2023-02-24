output "web_instance_ip" {
  value = aws_instance.web_instance.*.public_ip
}
