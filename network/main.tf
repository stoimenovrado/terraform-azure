
provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet-bgapp" {
  name                = "vnet-bgapp"
  resource_group_name = var.rg-name
  location            = var.location
  address_space       = ["10.69.69.0/24"]
}

#Web network settings below

resource "azurerm_subnet" "bgapp-web" {
  name                 = "bgapp-web"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.vnet-bgapp.name
  address_prefixes     = ["10.69.69.0/26"]
}

resource "azurerm_public_ip" "bgapp-web" {
  name                = "pip-bgapp-web"
  resource_group_name = var.rg-name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "bgapp-web" {
  name                = "bgapp-web-nic"
  resource_group_name = var.rg-name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bgapp-web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bgapp-web.id
  }
}

resource "azurerm_network_interface_security_group_association" "bgapp-web" {
  network_interface_id      = azurerm_network_interface.bgapp-web.id
  network_security_group_id = azurerm_network_security_group.bgapp-web.id
}

resource "azurerm_network_security_group" "bgapp-web" {
  name                = "bgapp-web-sg"
  resource_group_name = var.rg-name
  location            = var.location

  security_rule {
    name                       = "bgapp-web-80"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "bgapp-web-443"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "bgapp-web-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "bgapp-web-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#DB Network settings below

resource "azurerm_public_ip" "bgapp-db" {
  name                = "pip-bgapp-db"
  resource_group_name = var.rg-name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_subnet" "bgapp-db" {
  name                 = "bgapp-db"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.vnet-bgapp.name
  address_prefixes     = ["10.69.69.64/26"]
}

resource "azurerm_network_interface" "bgapp-db" {
  name                = "bgapp-db-nic"
  resource_group_name = var.rg-name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bgapp-db.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bgapp-db.id
  }
}

resource "azurerm_network_interface_security_group_association" "bgapp-db" {
  network_interface_id      = azurerm_network_interface.bgapp-db.id
  network_security_group_id = azurerm_network_security_group.bgapp-db.id
}

resource "azurerm_network_security_group" "bgapp-db" {
  name                = "bgapp-db-sg"
  resource_group_name = var.rg-name
  location            = var.location

  security_rule {
    name                       = "bgapp-db-3306"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.69.69.0/26" #For the web machines subnet -or- "VirtualNetwork" for access from all machines in the subnet
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "bgapp-db-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "bgapp-db-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Private DNS zone

resource "azurerm_private_dns_zone" "bgapp" {
  name                        = "bgapp.test"
  resource_group_name         = var.rg-name
}

resource "azurerm_private_dns_zone_virtual_network_link" "bgapp" {
  name                  = "bgapp-link"
  resource_group_name   = var.rg-name
  private_dns_zone_name = azurerm_private_dns_zone.bgapp.name
  virtual_network_id    = azurerm_virtual_network.vnet-bgapp.id
}

resource "azurerm_private_dns_a_record" "bgapp-db" {
  name                  = "db"
  zone_name             = azurerm_private_dns_zone.bgapp.name
  resource_group_name   = var.rg-name
  ttl                   = 300
  records               = [var.db-prip]
}

resource "azurerm_private_dns_a_record" "bgapp-web" {
  name                  = "web"
  zone_name             = azurerm_private_dns_zone.bgapp.name
  resource_group_name   = var.rg-name
  ttl                   = 300
  records               = [var.web-prip]
}
