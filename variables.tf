variable service_principal_credentials {
  type = object({
    client_id = string
    client_secret = string
    tenant_id = string
    subscription_id = string
  })
}

variable resource_group_name {
  type = string
}

variable tags {
  type = map(string)
  default = {}
}

variable k8s_cluster {
  type = object({
    cluster_name = string
    resource_group = string
  })
}

variable backup_storage_name {
  type = string
  default = "default"
}

## Optional
# Setting up this will create a storage account and a container
# If you already have a storage account and a container, and you want to use that, please setup storage_account_name and storage_account_container_name
variable storage {
  type = object({
    account_name = string
    account_kind = string
    account_tier = string
    account_replication_type = string
    min_tls_version = string
    access_tier = string
    assign_identity = bool
  })

  default = {
    account_name = "velero"
    account_kind = "BlobStorage"
    account_tier = "Standard"
    account_replication_type = "GRS"
    access_tier = "Hot"
    min_tls_version = "TLS1_2"
    assign_identity = true
  }

  description = "Will create a storage account and a container for backup your k8s cluster, if you already have a storage account and a container, please setup storage_account_name and container_name"
}

## Optionals
# This options are only if you already have a service principal
variable application_id {
  type = string
  default = ""
  description = "Optional, this will use your service principal attached to this application id, if this is null will create a service principal"
}

variable service_principal_password {
  type = string
  default = ""
  description = "Optional, this will use your service principal password, if this is null will create a random password. Required set application_id"
}

# This options are only if you already have a storage account and container
variable storage_account_name {
  type = string
  default = ""
  description = "Optional, will use your storage account, if this is null will create a storage account"
}

variable container_name {
  type = string
  default = ""
  description = "Optional, only required if you setup storage_account_name. This is your existed container at your storage account"
}
