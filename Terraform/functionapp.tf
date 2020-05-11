# Configure the Azure provider
 terraform {
  required_version = ">= 0.11" 
  backend "azurerm" {
  storage_account_name = "terraformteststrg"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
	access_key  ="oZKXNq2KHAQZYwk6vv0EgeF4+7qM3C5VUrFo/md2B5iIHeTQCF5u+C1wmC2Yub/pBKk2bAJ1z4UY+F1ORS7PZQ=="
	}
}
provider "azurerm" { 
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "example" {
  name     = "azure-functions-test-rg"
  location = "westus2"
}

resource "azurerm_storage_account" "example" {
  name                     = "functionsapptestdelete"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                      = "test-azure-functions-delete"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
    app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "dotnet"
        FUNCTIONS_EXTENSION_VERSION = "~2"
        WEBSITE_NODE_DEFAULT_VERSION = "8.11.3"
        AzureWebJobsSecretStorageType = "Files"
        }
}

resource "azurerm_function_app_slot" "example" {
  name                      = "staging"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  function_app_name         = azurerm_function_app.example.name
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
    app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "dotnet"
        FUNCTIONS_EXTENSION_VERSION = "~2"
        WEBSITE_NODE_DEFAULT_VERSION = "8.11.4"
        AzureWebJobsSecretStorageType = "Files"
        }
}
