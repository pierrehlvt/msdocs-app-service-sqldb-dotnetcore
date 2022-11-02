provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-lab"
    storage_account_name = "samfonfs2022"
    container_name       = "tfstate"
    key                  = "nfs-pierrehlvt.tfstate"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "nfs-pierrehlvt"
  location = var.location
}
#Database
resource "azurerm_mssql_server" "example" {
  name                         = "sql-${var.resources_suffix}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password
}
resource "azurerm_mssql_database" "example" {
  name           = "mydb"
  server_id      = azurerm_mssql_server.example.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  sku_name       = "Basic"
}
#WebApp
resource "azurerm_service_plan" "example" {
  name                = "asp-${var.resources_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S1"
  os_type             = "Windows"
}
resource "azurerm_windows_web_app" "example" {
  name                = "web-${var.resources_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id
  site_config {
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
  }
  app_settings = {
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    }
  connection_string {
    name = "MyDbConnection"
    type = "SQLAzure"
    value = "Server=tcp:${azurerm_mssql_server.example.name}.database.windows.net,1433;Initial Catalog=mydb;Persist Security Info=False;User ID=${azurerm_mssql_server.example.administrator_login};Password=${azurerm_mssql_server.example.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
#Monitoring
resource "azurerm_application_insights" "example" {
  name                = "ai-${var.resources_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}
    
  
  

  
  
  
    
      
      