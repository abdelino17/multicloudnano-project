data "azurerm_resource_group" "udacity" {
  name = "Regroup_5rb_XIAx1WZACRgV30r"
}

resource "azurerm_container_group" "udacity" {
  name                = "udacity-continst"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-abdel-azure"
  os_type             = "Linux"

  container {
    name   = "azure-container-app"
    image  = "docker.io/tscotto5/azure_app:1.0"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "AWS_S3_BUCKET"       = "udacity-abdel-aws-s3-bucket",
      "AWS_DYNAMO_INSTANCE" = "udacity-abdel-aws-dynamodb"
    }
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
  tags = {
    environment = "udacity"
  }
}

####### Your Additions Will Start Here ######
resource "azurerm_storage_account" "udacity" {
  name                     = "udacityabdelsa"
  resource_group_name      = data.azurerm_resource_group.udacity.name
  location                 = data.azurerm_resource_group.udacity.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "udacity" {
  name                         = "udacity-abdel-azure-sql"
  resource_group_name          = data.azurerm_resource_group.udacity.name
  location                     = data.azurerm_resource_group.udacity.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "Il@veAz@re2023"
}

resource "azurerm_mssql_database" "udacity" {
  name           = "udacity"
  server_id      = azurerm_mssql_server.udacity.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 150
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    name        = "udacity-mssql-db"
    environment = "production"
  }
}

resource "azurerm_service_plan" "udacity" {
  name                = "udacity-sp"
  resource_group_name = data.azurerm_resource_group.udacity.name
  location            = data.azurerm_resource_group.udacity.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "udacity" {
  name                = "udacity-abdel-azure-dotnet-app"
  resource_group_name = data.azurerm_resource_group.udacity.name
  location            = azurerm_service_plan.udacity.location
  service_plan_id     = azurerm_service_plan.udacity.id

  site_config {}

  tags = {
    name        = "udacity-windows-webapp"
    environment = "production"
  }
}
