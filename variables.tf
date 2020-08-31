variable "flux_namespace" {
  type        = string
  description = "Name of the namespace where releases will be deployed. If empty, the module will attempt to create the namespace"
  default     = "fluxcd"
}

variable "flux_chart_version" {
  type        = string
  description = "Flux chart version"
  default     = "1.5.0"
}

variable "helm_operator_chart_version" {
  type        = string
  description = "Helm operator chart version"
  default     = "1.2.0"
}

variable "flux_values" {
  description = "Helm values for flux release"
  default     = {}
}

variable "helm_operator_values" {
  description = "Helm values for helm operator release"
  default     = {}
}

variable "generate_ssh_key" {
  type        = bool
  description = "Generate SSH key"
  default     = false
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key for flux"
  default     = ""
}

variable "module_depends_on" {
  type        = any
  description = "Terraform may not detect that it should wait for cluster creation, so add your cluster create dependency here"
  default     = []
}
