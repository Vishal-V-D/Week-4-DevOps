variable "project_name" {}
variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "user_container_port" {}
variable "course_container_port" {}
variable "tags" {
  type    = map(string)
  default = {}
}
