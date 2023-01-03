variable "sg_id_list" {
  type        = list(string)
  description = "The security group id list for user app load balancer"
}

variable "subnet_id_list" {
  type        = list(any)
  description = "The subnet id list created from the vpc for load balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "app_target_id" {
  type        = string
  description = "Id for the registered target of app"
}
