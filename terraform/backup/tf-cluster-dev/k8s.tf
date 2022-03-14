data "azurerm_kubernetes_cluster" "hyukjun_cluster" {
  name                = "hyukjun-cluster"
  resource_group_name = azurerm_resource_group.terraform_rg.name
}
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.password
  client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.hyukjun_cluster.kube_config.0.cluster_ca_certificate)}"
#   load_config_file       = false
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "wordpress-mysql"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "wordpress",
        tier = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app  = "wordpress",
          tier = "mysql"
        }
      }

      spec {
        container {
          image = "mysql:5.6"
          name  = "mysql"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "password"
          }

          port {
            container_port = 3306
            name           = "mysql"
          }

        }
      }
    }
  }
}


resource "kubernetes_service" "service_mysql" {
  metadata {
    name = "wordpress-mysql"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector = {
      app  = "wordpress",
      tier = "mysql"
    }
    port {
      port = 3306
    }
  }
}

resource "kubernetes_deployment" "wp" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "wordpress",
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "wordpress",
          tier = "frontend"
        }
      }

      spec {
        container {
          image = "wordpress:5.5.3-apache"
          name  = "wordpress"

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "wordpress-mysql"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "password"
          }
          port {
            container_port = 80
            name           = "wordpress"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service_wp" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app  = "wordpress",
      tier = "frontend"
    }
    port {
      port = 80
    }
  }
}
