# output "jenkins_public_ip" {
#   description = "Public IP of Jenkins server"
#   value       = aws_instance.jenkins.public_ip
# }

output "magento_public_ip" {
  description = "Public IP of Magento server"
  value       = aws_instance.Magento.public_ip
}

# output "ansible_public_ip" {
#   description = "Public IP of Ansible server"
#   value       = aws_instance.Ansible.public_ip
# }

output "MySQL_public_ip" {
  description = "Public IP of MySQL instance"
  value       = aws_instance.Mysql.public_ip
}