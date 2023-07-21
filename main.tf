terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.64.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bgapp-rg" {
  name     = var.rg-name
  location = var.location
}

module "network" {
  source       = "./network"
  rg-name      = azurerm_resource_group.bgapp-rg.name
  location     = azurerm_resource_group.bgapp-rg.location
  web-prip     = module.web.private_ip_address
  db-prip      = module.db.private_ip_address
}

module "web" {
  source       = "./web"
  rg-name      = azurerm_resource_group.bgapp-rg.name
  location     = azurerm_resource_group.bgapp-rg.location
  ssh-rg-name  = var.ssh-rg-name
  ssh-key-name = var.ssh-key-name
  nic-web      = module.network.azurerm_network_interface_bgapp_web
}

module "db" {
  source       = "./db"
  rg-name      = azurerm_resource_group.bgapp-rg.name
  location     = azurerm_resource_group.bgapp-rg.location
  ssh-rg-name  = var.ssh-rg-name
  ssh-key-name = var.ssh-key-name
  nic-db       = module.network.azurerm_network_interface_bgapp_db
}