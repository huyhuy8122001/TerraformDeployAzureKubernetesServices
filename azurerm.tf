#Kubernetes Cluster

resource "azurerm_resource_group" "k8s-resources" {
  name     = "k8s-resources"
  location = "Southeast Asia"
}

resource "azurerm_kubernetes_cluster" "k8s_demo_1" {
  name                = "k8s_demo_1"
  location            = azurerm_resource_group.k8s-resources.location
  resource_group_name = azurerm_resource_group.k8s-resources.name
  dns_prefix          = "k8s-demo-1"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }
}

resource "time_sleep" "wait_for_kubernetes" {

  depends_on = [
    azurerm_kubernetes_cluster.k8s_demo_1
  ]

  create_duration = "30s"
}

data "azurerm_lb" "traefik_lb" {

  depends_on = [
    helm_release.traefik
  ]

  name                = "kubernetes"
  resource_group_name = "mc_k8s-resources_k8s_demo_1_southeastasia"
}

data "azurerm_public_ip" "traefik_lb_ip" {
  
  depends_on = [
    helm_release.traefik
  ]
  
  name                = "kubernetes-${data.azurerm_lb.traefik_lb.frontend_ip_configuration.1.name}"
  resource_group_name = "mc_${azurerm_resource_group.k8s-resources.name}_${azurerm_kubernetes_cluster.k8s_demo_1.name}_${azurerm_resource_group.k8s-resources.location}"
}

output "public_ip_address" {
  value = data.azurerm_public_ip.traefik_lb_ip.ip_address
}