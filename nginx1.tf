resource "kubernetes_namespace" "nginx1" {

  depends_on = [
    time_sleep.wait_for_kubernetes
  ]

  metadata {
    name = "nginx1"
  }
}

resource "kubernetes_deployment" "nginx1" {

  depends_on = [
    kubernetes_namespace.nginx1
  ]

  metadata {
    name      = "nginx1"
    namespace = "nginx1"
    labels = {
      app = "nginx1"
    }
  }

  spec {
    replicas = 10

    selector {
      match_labels = {
        app = "nginx1"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx1"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx1" {

  depends_on = [
    kubernetes_namespace.nginx1
  ]

  metadata {
    name      = "nginx1"
    namespace = "nginx1"
  }
  spec {
    selector = {
      app = "nginx1"
    }
    port {
      port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubectl_manifest" "nginx1-certificate" {

  depends_on = [kubernetes_namespace.nginx1, time_sleep.wait_for_clusterissuer]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx1
  namespace: nginx1
spec:
  secretName: nginx1
  issuerRef:
    name: cloudflare-prod
    kind: ClusterIssuer
  dnsNames:
  - 'nginx1.hq-devlab.cloud'   
    YAML
}

resource "kubernetes_ingress_v1" "nginx1" {

  depends_on = [kubernetes_namespace.nginx1]

  metadata {
    name      = "nginx1"
    namespace = "nginx1"
  }

  spec {
    rule {

      host = "nginx1.hq-devlab.cloud"

      http {

        path {
          path = "/"

          backend {
            service {
              name = "nginx1"
              port {
                number = 80
              }
            }
          }

        }
      }
    }

    tls {
      secret_name = "nginx1"
      hosts       = ["nginx1.hq-devlab.cloud"]
    }
  }
}

resource "cloudflare_record" "clcreative-main-cluster" {
  zone_id = "e5b019b364ca1cf3b59580b19da946aa"
  name    = "nginx1.hq-devlab.cloud"
  value   = data.azurerm_public_ip.traefik_lb_ip.ip_address
  type    = "A"
  proxied = false
}