resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserver-${var.project}-${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.password
  tags = {
    environment = var.environment
    project     = var.project
    created_by  = "Terraform"
  }
}

resource "azurerm_mssql_database" "ppc_entity_db" {
  name                = "entitydb-${var.project}-${var.environment}"
  server_id           = azurerm_mssql_server.sql_server.id
  sku_name            = "Basic"
  tags = {
    environment = var.environment
    project     = var.project
    created_by  = "Terraform"
  }
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-private-endpoint-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnetdb.id
  private_service_connection {
    name                           = "sql-private-endpoint-connection-${var.project}-${var.environment}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names               = ["sqlServer"]
    is_manual_connection            = false
  }
  tags = {
    environment = var.environment
    project     = var.project
    created_by  = "Terraform"
  }
}   

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "private.dbserver.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = var.environment
    project     = var.project
    created_by  = "Terraform"
  }
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = "sqlserver-record-${var.project}-${var.environment}"
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 300
  records = [
    azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
    name = "vnetlink-${var.project}-${var.environment}"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
    virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_sql_firewall_rule" "firewall_rule" {
  name                = "firewall-rule-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mssql_server.sql_server.name
  start_ip_address    = "181.115.59.188"
  end_ip_address      = "181.115.59.188"
}