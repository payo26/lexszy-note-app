
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Existing Azure resource group"
  type        = string
  default     = "notes-app-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "name_suffix" {
  description = "Unique lowercase suffix for Azure resources"
  type        = string
  default     = "payo261024"
}

variable "docker_image" {
  description = "Original Docker Hub image"
  type        = string
  default     = "prayo25/notes-app:v1"
}

variable "acr_image_name" {
  description = "Image repository in Azure Container Registry"
  type        = string
  default     = "notes-app"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "v1"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "notesdb"
}

variable "db_user" {
  description = "PostgreSQL database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "Notes App container port"
  type        = number
  default     = 3000
}

variable "deploy_containers" {
  description = "Enable ACI deployment after pushing the image to ACR"
  type        = bool
  default     = false
}

