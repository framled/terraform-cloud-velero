provider azurerm {
  version = "=2.31.1"
  client_id = var.service_principal_credentials.client_id
  client_secret = var.service_principal_credentials.client_secret
  tenant_id = var.service_principal_credentials.tenant_id
  subscription_id = var.service_principal_credentials.subscription_id
  features {}
}

provider "azuread" {
  version = "=1.0.0"
  client_id = var.service_principal_credentials.client_id
  client_secret = var.service_principal_credentials.client_secret
  tenant_id = var.service_principal_credentials.tenant_id
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "aks" {
  name = var.k8s_cluster.cluster_name
  resource_group_name = var.k8s_cluster.resource_group
}

data "azurerm_subscription" "primary" {}
