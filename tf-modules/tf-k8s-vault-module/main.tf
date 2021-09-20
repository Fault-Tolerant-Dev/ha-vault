resource "kubernetes_namespace" "namespace_vault" {
  metadata {
    annotations {
      name = "vault-namespace"
    }

    labels {
      mylabel = "vault-namespace"
    }

    name = "vault-namespace"
  }
}

resource "kubernetes_role" "role_vault" {
  metadata {
    name      = "vault-role"
    namespace = "vault-namespace"
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["vault-psp"]
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

resource "kubernetes_role_binding" "role_binding_vault" {
  metadata {
    name      = "vault-role-binding"
    namespace = "vault-namespace"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "vault-account"
    namespace = "vault-namespace"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "vault-role"
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

resource "kubernetes_service_account" "service_account_vault" {
  metadata {
    name      = "vault-account"
    namespace = "vault-namespace"
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

data "template_file" "template_vault_config" {
  template = file("${path.module}/vault_config.hcl")

  vars {
    vault_lb_ip              = var.vault_config_lb_ip
    vault_cluster_ip         = var.vault_config_cluster_ip
    vault_storage_bucket     = var.vault_config_storage_bucket_name
    vault_locks_bucket       = var.vault_config_locks_bucket_name
    vault_gcpckms_project_id = var.vault_config_gcpkms_project_id
    vault_gcpckms_region     = var.vault_config_gcpkms_project_region
    vault_gcpckms_keyring    = var.vault_config_gcpkms_keyring
    vault_gcpckms_key        = var.vault_config_gcpkms_key
    enable_vault_ui          = var.vault_config_enable_ui
    vault_log_level          = var.vault_config_log_level
  }
}

resource "kubernetes_config_map" "config_map_vault" {
  metadata {
    name      = "vault-config"
    namespace = "vault-namespace"
  }

  data = {
    "vault_config.hcl" = data.template_file.template_vault_config.rendered
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

data "local_file" "locale_file_vault_secrets_tls_crt" {
  filename = var.vault_secrets_tls_crt
}

data "local_file" "locale_file_vault_secrets_tls_key" {
  filename = var.vault_secrets_tls_key
}

resource "kubernetes_secret" "secret_vault_tls" {
  metadata {
    name      = "vault-tls"
    namespace = "vault-namespace"
  }

  data {
    "vault.crt" = data.local_file.locale_file_vault_secrets_tls_crt.content
    "vault.key" = data.local_file.locale_file_vault_secrets_tls_key.content
  }

  type       = "kubernetes.io/generic"
  depends_on = ["kubernetes_namespace.namespace_vault"]
}

data "local_file" "locale_file_vault_secrets_seal_key" {
  filename = var.vault_secrets_seal_key
}

resource "kubernetes_secret" "secret_vault_seal" {
  metadata {
    name      = "vault-seal"
    namespace = "vault-namespace"
  }

  data {
    "vault_seal.key.json" = data.local_file.locale_file_vault_secrets_seal_key.content
  }

  type       = "kubernetes.io/generic"
  depends_on = ["kubernetes_namespace.namespace_vault"]
}

resource "kubernetes_stateful_set" "stateful_set_vault" {
  metadata {
    name      = "vault-stateful"
    namespace = "vault-namespace"

    labels {
      app = "vault"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels {
        app = "vault"
      }
    }

    template {
      metadata {
        labels {
          app = "vault"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name         = "vault-config"
            default_mode = "0400"
          }
        }

        volume {
          name = "tls"

          secret {
            secret_name  = "vault-tls"
            default_mode = "0400"
          }
        }

        volume {
          name = "seal"

          secret {
            secret_name  = "vault-seal"
            default_mode = "0400"
          }
        }

        container {
          name              = "vault"
          image             = var.vault_image
          image_pull_policy = "Always"

          args = ["server", "-config=/vault/config"]

          port {
            name           = "http"
            container_port = 8200
          }

          port {
            name           = "internal"
            container_port = 8201
          }

          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/vault/config"
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/vault/tls"
          }

          volume_mount {
            name       = "seal"
            read_only  = true
            mount_path = "/vault/seal"
          }

          readiness_probe {
            exec {
              command = ["/bin/sh", "-ec", "vault status -tls-skip-verify"]
            }

            initial_delay_seconds = 15
            timeout_seconds       = 5
            period_seconds        = 3
            success_threshold     = 1
            failure_threshold     = 2
          }

          security_context {
            run_as_user                = 1001
            run_as_group               = 1001
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = "vault-account"

        security_context {
          fs_group = 1001
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = {
                  "app.kubernetes.io/name" = "vault"
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }

    service_name          = "vault"
    pod_management_policy = "Parallel"

    update_strategy {
      type = "OnDelete"
    }
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

resource "kubernetes_service" "service_vault_cluster" {
  metadata {
    name      = "vault-service-cluster"
    namespace = "vault-namespace"
  }

  spec {
    port {
      name        = "vault-8201"
      port        = "8201"
      target_port = "8201"
      protocol    = "TCP"
    }

    selector = {
      app = "vault"
    }

    type       = "ClusterIP"
    cluster_ip = var.cluster_ip
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}

resource "kubernetes_service" "service_vault_lb" {
  metadata {
    name      = "vault-service-loadbalance"
    namespace = "vault-namespace"
  }

  spec {
    port {
      name        = "vault-8200"
      port        = "8200"
      target_port = "8200"
      protocol    = "TCP"
    }

    selector = {
      app = "vault"
    }

    type             = "LoadBalancer"
    load_balancer_ip = var.loadbalancer_ip
  }

  depends_on = ["kubernetes_namespace.namespace_vault"]
}
