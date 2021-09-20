/******************************************
  Vault Setup Configurations
 *****************************************/
module "vault_module" {
  source                 = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-vault-module.git"
  gcp_auth_account_key   = "${var.gcp_auth_account_key}"
  bound_projects         = "${var.vault_bound_projects}"
  bound_service_accounts = "${var.vault_bound_service_accounts}"
}
