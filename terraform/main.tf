terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # lokalny kubeconfig
}

resource "kubernetes_namespace" "mirror" {
  metadata {
    name = "mirror"
  }
}

resource "kubernetes_deployment" "mirror" {
  metadata {
    name      = "mirror"
    namespace = kubernetes_namespace.mirror.metadata[0].name
    labels = { app = "mirror" }
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "mirror" } }

    template {
      metadata { labels = { app = "mirror" } }

      spec {
        container {
          name  = "mirror"
          image = "mirror:latest"
          port { container_port = 8080 }
        }
      }
    }
  }
}

resource "kubernetes_service" "mirror" {
  metadata {
    name      = "mirror"
    namespace = kubernetes_namespace.mirror.metadata[0].name
  }

  spec {
    selector = { app = "mirror" }
    type     = "NodePort"
    port {
      port        = 80
      target_port = 8080
      node_port   = 30080
    }
  }
}
