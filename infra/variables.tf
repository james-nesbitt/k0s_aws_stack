
variable "aws" {
  description = "AWS configuration"
  type = object({
    region = string
  })
  default = {
    region = "us-east-1"
  }
}

variable "name" {
  description = "stack/cluster name, used in labelling across the stack."
  type        = string
}

variable "custom_platforms" {
  description = "Platform/AMI that can be used. Can override the built in libraryy list."
  type = map(object({
    ami_name   = string
    owner      = string
    user       = string
    interface  = string
    connection = string
  }))
  default = {}
}

variable "network" {
  description = "Network configuration"
  type = object({
    cidr                 = string
    public_subnet_count  = number
    private_subnet_count = number
  })
  default = {
    cidr                 = "172.31.0.0/16"
    public_subnet_count  = 3
    private_subnet_count = 3
  }
}

variable "nodegroups" {
  description = "A map of machine group definitions"
  type = map(object({
    platform    = string
    type        = string
    count       = number
    volume_size = number
    role        = string
    public      = bool
    user_data   = string
  }))
}

variable "k0sctl" {
  description = "K0sctl install configuration"
  type = object({
    version = string

    no_wait  = bool
    no_drain = bool

    force = bool

    disable_downgrade_check = bool

    restore_from = string

    skip_create  = bool
    skip_destroy = bool
  })
}

variable "extra_tags" {
  description = "Extra tags that will be added to all provisioned resources, where possible."
  type        = map(string)
  default     = {}
}
