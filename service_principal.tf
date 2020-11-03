locals {
  application_count = var.application_id == "" ? 1 : 0
  service_principal_password = var.service_principal_password != "" ? var.service_principal_password : lookup(azuread_service_principal_password.password[0], "value", "")
}

data "azuread_service_principal" "service_principal" {
  application_id            = var.application_id != "" ? var.application_id : azuread_service_principal.service_principal[0].application_id
}

resource "azuread_application" "app" {
  count                      = local.application_count
  name                       = "velero"
}

resource "azuread_service_principal" "service_principal" {
  count                        = local.application_count
  application_id               = azuread_application.app[0].application_id
  app_role_assignment_required = false

  tags = local.tags
}

resource "random_password" "sp_password" {
  count            = local.application_count
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azuread_service_principal_password" "password" {
  count                = local.application_count
  service_principal_id = azuread_service_principal.service_principal[0].id
  description          = "My managed password"
  value                = random_password.sp_password[0].result
  end_date_relative    = "17520h"
}

resource "azurerm_role_assignment" "auth" {
  count                = local.application_count
  principal_id         = data.azuread_service_principal.service_principal.id
  role_definition_name = "Contributor"
  scope                = data.azurerm_storage_account.storage_account.id
}
