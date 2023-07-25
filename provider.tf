terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.10.0"
    }
  }
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_key" {
  type = string
}


provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s_demo_1.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}