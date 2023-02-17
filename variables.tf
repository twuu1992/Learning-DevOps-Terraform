variable "region" {
  type        = string
  description = "Default region"
  default     = "ap-southeast-2"
}

variable "ami" {
  type        = string
  description = "Ubuntu AMI for EC2 instance"
  default     = "ami-09a5c873bc79530d9"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "infra_env" {
  type        = string
  description = "Environment variable of the infra"
  default     = "dev"
}

// TODO: replace the ip address to CI/CD server's ip
variable "my_ip_addr" {
  type        = string
  description = "My IP Address"
  default     = ""
}
variable "jenkins_ip_addr" {
  type        = string
  description = "Jenkins IP Address"
  default     = ""
}
