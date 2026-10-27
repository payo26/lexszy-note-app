terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "790aa1f8-6209-43c8-8546-2cbff23d845f"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraformstate-rg"
    storage_account_name = "notesapptfstate261024"
    container_name       = "tfstate"
    key                  = "notes-app.terraform.tfstate"

    use_azuread_auth = true
    use_cli          = true
  }
}


# Generate unique suffix for ACI DNS name
resource "random_id" "dns_suffix" {
  byte_length = 4
}

# Generate unique suffix for Azure Container Registry
resource "random_id" "acr_suffix" {
  byte_length = 4
}


# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "notes-app-rg"
  location = "East US"
}

#create container instance
resource "azurerm_container_group" "notes_app" {
  name                = "notes-app-container-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  # Notes App container
  container {
    name   = "notes-app-container"
    image  = "${azurerm_container_registry.acr.login_server}/notes-app:v1"
    cpu    = 0.5
    memory = 1.5
    commands = ["/bin/sh", "-c", "sleep 20 && node server.js"]

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      DB_HOST = "127.0.0.1"
      DB_PORT = "5432"
      DB_USER = var.db_user
      DB_NAME = var.db_name
    }

    secure_environment_variables = {
      DB_PASSWORD = var.db_password
    }
  }

  # PostgreSQL container
  container {
    name   = "postgres"
    image  = "${azurerm_container_registry.acr.login_server}/postgres:16-alpine"
    cpu    = 0.5
    memory = 1.0

    ports {
      port     = 5432
      protocol = "TCP"
    }

    environment_variables = {
      POSTGRES_DB   = var.db_name
      POSTGRES_USER = var.db_user
    }

    secure_environment_variables = {
      POSTGRES_PASSWORD = var.db_password
    }

    volume {
      name       = "postgres-data"
      mount_path = "/var/lib/postgresql/data"
      empty_dir  = true
    }
  }
}

#create container registry
resource "azurerm_container_registry" "acr" {
  name                = "notesappacr${random_id.acr_suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

#output the public IP address of the container instance
output "container_instance_ip" {
  value = azurerm_container_group.notes_app.ip_address
}


