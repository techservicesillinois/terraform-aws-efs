# Required variables.

variable "name" {
  description = "Name of file system"
}

variable "subnet_type" {
  description = "Subnet type (e.g., 'campus', 'private', 'public') for resource placement"
}

variable "vpc" {
  description = "Name of VPC for resource placement"
}

# Optional variables.

variable "encrypted" {
  description = "Encrypt data on volume at rest"
  default     = true
}

variable "performance_mode" {
  description = "File system performance mode (generalPurpose or maxIO)"
  default     = "generalPurpose"
}

variable "tags" {
  description = "Tags to be applied to resources where supported"
  type        = map(string)
  default     = {}
}

variable "throughput_mode" {
  description = "Throughput mode for the file system (bursting or provisioned)"
  default     = "bursting"
}
