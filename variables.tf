variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(list(string))
  default     = [["10.0.0.0/16"], ["10.1.0.0/16"]]
}

variable "vnet_public_subnet_prefixes" {
  description = "The address prefixes for the public subnets."
  type        = list(list(string))
  default     = [["10.0.1.0/24"], ["10.1.1.0/24"]]
  
}

variable "vnet_private_subnet_prefixes" {
  description = "The address prefixes for the private subnets."
  type        = list(list(string))
  default     = [["10.0.2.0/24"], ["10.1.2.0/24"]]
}

variable "admin_password" {
  description = "The admin password for the Linux VM."
  type        = string
  sensitive = true
}