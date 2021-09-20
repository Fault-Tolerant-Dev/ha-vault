resource "kubernetes_namespace" "namespace_auditd" {
  metadata {
    name = "auditd-namespace"
  }
}

resource "kubernetes_role" "role_auditd" {
  metadata {
    name      = "auditd-role"
    namespace = "auditd-namespace"
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["cos-auditd-setup-psp", "cos-auditd-logging-psp"]
  }

  depends_on = ["kubernetes_namespace.namespace_auditd"]
}

resource "kubernetes_role_binding" "role_binding_auditd" {
  metadata {
    name      = "auditd-role-binding"
    namespace = "auditd-namespace"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "auditd-account"
    namespace = "auditd-namespace"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "auditd-role"
  }

  depends_on = ["kubernetes_namespace.namespace_auditd"]
}

resource "kubernetes_service_account" "service_account_auditd" {
  metadata {
    name      = "auditd-account"
    namespace = "auditd-namespace"
  }

  depends_on = ["kubernetes_namespace.namespace_auditd"]
}

data "template_file" "template_google_fluentd" {
  template = file("${path.module}/google_fluentd.conf")
}

resource "kubernetes_config_map" "config_map_auditd" {
  metadata {
    name      = "fluentd-gcp-config-cos-auditd"
    namespace = "auditd-namespace"
  }

  data = {
    "google-fluentd.conf" = data.template_file.template_google_fluentd.template
  }

  depends_on = [
    "kubernetes_namespace.namespace_auditd",
  ]
}

resource "kubernetes_daemonset" "daemonset_auditd" {
  metadata {
    name      = "cos-auditd-logging"
    namespace = "auditd-namespace"
  }

  depends_on = ["kubernetes_namespace.namespace_auditd"]

  spec {
    selector {
      match_labels = {
        name = "cos-auditd-logging"
      }
    }

    template {
      metadata {
        labels = {
          name = "cos-auditd-logging"
        }
      }

      spec {
        service_account_name = "auditd-account"

        volume {
          name = "host"

          host_path {
            path = "/"
          }
        }

        volume {
          name = "varlog"

          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "libsystemddir"

          host_path {
            path = "/usr/lib64"
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name         = "fluentd-gcp-config-cos-auditd"
            default_mode = "0644"
          }
        }

        init_container {
          name    = "cos-auditd-setup"
          image   = "ubuntu"
          command = ["chroot", "/host", "systemctl", "start", "cloud-audit-setup"]

          resources {
            requests {
              cpu    = "10m"
              memory = "10Mi"
            }
          }

          volume_mount {
            name       = "host"
            mount_path = "/host"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name  = "fluentd-gcp-cos-auditd"
          image = "gcr.io/stackdriver-agents/stackdriver-logging-agent:0.6-1.6.0-1"

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          resources {
            limits {
              memory = "500Mi"
              cpu    = "1"
            }

            requests {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
            read_only  = true
          }

          volume_mount {
            name       = "libsystemddir"
            read_only  = true
            mount_path = "/host/lib"
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/google-fluentd/google-fluentd.conf"
            sub_path   = "google-fluentd.conf"
          }

          liveness_probe {
            exec {
              command = ["/bin/sh", "-c", "LIVENESS_THRESHOLD_SECONDS=$${LIVENESS_THRESHOLD_SECONDS:-300}; STUCK_THRESHOLD_SECONDS=$${LIVENESS_THRESHOLD_SECONDS:-900}; if [ ! -e /var/log/fluentd-buffers ]; then\n  exit 1;\nfi; touch -d \"$${STUCK_THRESHOLD_SECONDS} seconds ago\" /tmp/marker-stuck; if [[ -z \"$(find /var/log/fluentd-buffers -type f -newer /tmp/marker-stuck -print -quit)\" ]]; then\n  rm -rf /var/log/fluentd-buffers;\n  exit 1;\nfi; touch -d \"$${LIVENESS_THRESHOLD_SECONDS} seconds ago\" /tmp/marker-liveness; if [[ -z \"$(find /var/log/fluentd-buffers -type f -newer /tmp/marker-liveness -print -quit)\" ]]; then\n  exit 1;\nfi;\n"]
            }

            initial_delay_seconds = 600
            timeout_seconds       = 1
            period_seconds        = 60
            success_threshold     = 1
            failure_threshold     = 3
          }

          termination_message_path = "/dev/termination-log"
          image_pull_policy        = "IfNotPresent"
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dns_policy                       = "Default"

        node_selector = {
          "cloud.google.com/gke-os-distribution" = "cos"
        }

        host_network = true
        host_pid     = true

        toleration {
          key    = "node.alpha.kubernetes.io/ismaster"
          effect = "NoSchedule"
        }

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
      }
    }
  }
}
