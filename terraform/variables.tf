variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "service_account_id" {
  description = "Service Account ID for Instance Group"
  type        = string
}

variable "service_account_key_file" {
  type    = string
  default = "~/key.json"
}

variable "ssh_public_key" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "vm_user" {
  type = string
  default = "user"
}

variable "vm_sizes" {
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  default = {
    small  = { cores = 2, memory = 2, disk = 10 }
    medium = { cores = 2, memory = 4, disk = 20 }
    large  = { cores = 4, memory = 8, disk = 30 }
  }
}
