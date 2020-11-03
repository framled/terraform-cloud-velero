provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.aks.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.aks.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider helm {
  version = "1.3.2"

  kubernetes {
    load_config_file       = false
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    username               = data.azurerm_kubernetes_cluster.aks.kube_config.0.username
    password               = data.azurerm_kubernetes_cluster.aks.kube_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

resource "kubernetes_secret" "velero" {
  type = "Opaque"

  metadata {
    name = "cloud"
    namespace = kubernetes_namespace.velero.metadata[0].name
  }

  data = {
    cloud = templatefile(
    "${path.module}/templates/cloud.secrets.tpl",
    {
      azure_subscription_id   = data.azurerm_subscription.primary.subscription_id,
      azure_tenant_id         = data.azurerm_subscription.primary.tenant_id,
      azure_resource_group    = data.azurerm_resource_group.resource_group.name,
      azure_client_id         = data.azuread_service_principal.service_principal.application_id
      azure_client_secret     = local.service_principal_password,
      azure_cloud_name        = "AzurePublicCloud"
    }
    )
  }
}

resource "helm_release" "velero" {
  repository = "https://vmware-tanzu.github.io/helm-charts"
  name = "velero"
  chart = "velero"
  namespace = kubernetes_namespace.velero.metadata[0].name

  wait = true
  atomic = true
  skip_crds = false

  set {
    name = "credentials.existingSecret"
    value = kubernetes_secret.velero.metadata[0].name
  }

  set {
    name = "configuration.provider"
    value = "azure"
  }

  set {
    name = "configuration.backupStorageLocation.name"
    value = var.backup_storage_name
  }

  set {
    name = "configuration.backupStorageLocation.bucket"
    value = data.azurerm_storage_container.container.name
  }

  set {
    name = "configuration.backupStorageLocation.config.resourceGroup"
    value = data.azurerm_resource_group.resource_group.name
  }

  set {
    name = "configuration.backupStorageLocation.config.subscriptionId"
    value = data.azurerm_subscription.primary.subscription_id
  }

  set {
    name = "configuration.backupStorageLocation.config.storageAccount"
    value = local.storage_account_name
  }

  set {
    name = "image.repository"
    value = "velero/velero"
  }

  set {
    name = "image.tag"
    value = "v1.5.1"
  }

  set {
    name = "image.pullPolicy"
    value = "IfNotPresent"
  }

  set {
    name = "initContainers[0].name"
    value = "velero-plugin-for-microsoft-azure"
  }

  set {
    name = "initContainers[0].imagePullPolicy"
    value = "IfNotPresent"
  }

  set {
    name = "initContainers[0].image"
    value = "velero/velero-plugin-for-microsoft-azure:v1.1.0"
  }

  set {
    name = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  set {
    name = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }
}