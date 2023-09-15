
# AKS  cluster variables.
variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster, resources will be created for."
}

variable "cluster_region" {
  type        = string
  description = "Region of the AKS cluster, resources will be created for."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name, resources will be created for."
}

variable "vnet_name" {
  type        = string
  description = "vNet name"
}

variable "second_vnet_name" {
  type        = string
  description = "vNet name"
}

variable "cluster_version" {
  type        = string
  description = "AKS cluster version."
  default     = "1.26"
}

variable "node_count" {
  type        = string
  description = "Node count"
  default     = "1"
}

variable "node_size" {
  type        = string
  description = "Node VM Size"
  default     = "Standard_D2s_v5"
}




