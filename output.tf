output application_id {
  value = data.azuread_service_principal.service_principal.application_id
}

output service_principal_password {
  value = local.service_principal_password
}

output storage_account_name {
  value = data.azurerm_storage_account.storage_account.name
}

output storage_container_name {
  value = data.azurerm_storage_container.container.name
}
