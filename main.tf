provider "azurerm" {
  version = "= 2.81.0"
  features {}
}

variable "public_ssh_key" {
  type    = string
}
resource "azurerm_resource_group" "rg" {
  name     = "terraform-dokku-vm"
  location = "centralindia"
}

# Create public IP
resource "azurerm_public_ip" "dokku-public-ip" {
  name                = "dokkuPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>
resource "azurerm_virtual_network" "v-net" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html> 
resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.v-net.name
  address_prefixes     = ["10.0.2.0/24"]
}

## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "dokku-nic" {
  name                = "dokkuNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dokku-public-ip.id
  }
}
resource "azurerm_linux_virtual_machine" "dokku-vm" {
  location              = azurerm_resource_group.rg.location
  name                  = "dokkuVM"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.dokku-nic.id]
  size                  = "Standard_B1s"
  admin_username        = "azureuser"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.public_ssh_key
  }
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.dokku-vm.public_ip_address
}

# Store VM IP in text file, to be used by Ansible 
resource "local_file" "ip" {
  content = azurerm_linux_virtual_machine.dokku-vm.public_ip_address
  filename = "ip.txt"
}