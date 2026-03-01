resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { "environment" = "cp2" }
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_resource_group.rg, azurerm_virtual_network.vn]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags       = { "environment" = "cp2" }
  depends_on = [azurerm_resource_group.rg, azurerm_subnet.subnet, azurerm_public_ip.public_ip]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = { "environment" = "cp2" }
  depends_on          = [azurerm_resource_group.rg]
}