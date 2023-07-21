
provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "vm-login" {
  name                = var.ssh-key-name
  resource_group_name = var.ssh-rg-name
}

resource "azurerm_linux_virtual_machine" "bgapp-db-vm" {
  name                = "bgapp-db-vm"
  resource_group_name = var.rg-name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "radoslv"
  disable_password_authentication = true
  network_interface_ids = [
    var.nic-db,
  ]
  
  admin_ssh_key {
    username   = "radoslv"
    public_key = data.azurerm_ssh_public_key.vm-login.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

    provisioner "file" {
    source      = "./provisioning/provision-db.sh"
    destination = "/tmp/provision-db.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = "radoslv"
      private_key = file("/mnt/c/Users/RadoslavStoimenov/keys/bgapp-ssh.pem")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-db.sh",
      "/tmp/provision-db.sh",
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = "radoslv"
      private_key = file("/mnt/c/Users/RadoslavStoimenov/keys/bgapp-ssh.pem")
    }
  }
}
