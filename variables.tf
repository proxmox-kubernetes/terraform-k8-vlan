variable "opnsense_key" {
  type      = string
  sensitive = true
}

variable "opnsense_secret" {
  type      = string
  sensitive = true
}

variable "subnet_ip" {
  type = string
}

variable "subnet_desc" {
  type = string
}

variable "subnet_pool" {
  type = string
}


