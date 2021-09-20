resource "vault_audit" "stdout_audit" {
  type = "file"

  options = {
    file_path = "stdout"
  }
}

data "template_file" "template_admin_policy" {
  template = file("${path.module}/admin_policy.hcl")
}

resource "vault_policy" "admin_policy" {
  name = "admin-policy"

  policy = data.template_file.template_admin_policy.rendered
}

data "local_file" "locale_file_gcp_auth_backend_key" {
  filename = var.gcp_auth_account_key
}

resource "vault_gcp_auth_backend" "gcp_auth_backend" {
  credentials = data.local_file.locale_file_gcp_auth_backend_key.content
}

resource "vault_gcp_auth_backend_role" "gcp_auth_backend_role" {
  role                   = "admin"
  type                   = "iam"
  backend                = "gcp"
  max_jwt_exp            = "600"
  bound_projects         = var.bound_projects
  bound_service_accounts = var.bound_service_accounts
  token_ttl              = "600"
  token_policies         = ["admin-policy"]
  depends_on             = ["vault_gcp_auth_backend.gcp_auth_backend"]
}
