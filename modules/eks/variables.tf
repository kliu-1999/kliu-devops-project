variable "cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}
variable "cluster_version" {
  description = "The version of the EKS cluster"
  type = string
  default = "1.24"
}
variable "vpc_id" {
  description = "The id for the VPC"
  type = string
}
variable "subnet_ids" {
  description = "The ids for the subnets"
  type = list(string)
}
variable "node_groups" {
  description = "The node groups for the EKS cluster"
  type = map(object({
    instance_types = list(string)
    capacity_type = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}
    