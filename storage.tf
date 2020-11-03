locals {
  storage_account_count    = var.storage_account_name == "" ? 1 : 0
  tags                      = flatten([ for tag_key, tag_value in var.tags : tag_value])
  storage_account_name      = var.storage_account_name != "" ? var.storage_account_name : format("%s%s", replace(var.storage.account_name, "/-|_/", ""), random_id.storage_id[0].hex)
  prefix = coalesce(var.storage_account_name, var.storage.account_name)
}

data azurerm_storage_account storage_account {
  name = var.storage_account_name != "" ? var.storage_account_name : azurerm_storage_account.storage_account[0].name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data azurerm_storage_container container {
  name = var.container_name != "" ? var.container_name : azurerm_storage_container.container[0].name
  storage_account_name = data.azurerm_storage_account.storage_account.name
}

resource "random_id" "storage_id" {
  count       = local.storage_account_count
  byte_length = 8
}

resource "azurerm_storage_account" "storage_account" {
  count               = local.storage_account_count
  name                = local.storage_account_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  account_kind = var.storage.account_kind
  account_tier = var.storage.account_tier
  account_replication_type = var.storage.account_replication_type
  access_tier = var.storage.access_tier

  identity {
    type = var.storage.assign_identity ? "SystemAssigned" : null
  }

  min_tls_version = "TLS1_2"
  allow_blob_public_access = false
  enable_https_traffic_only = true

  tags = merge({"name" = local.prefix}, var.tags)
}

resource azurerm_storage_container "container" {
  count                 = local.storage_account_count
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.storage_account[0].name
  container_access_type = "private"
}
