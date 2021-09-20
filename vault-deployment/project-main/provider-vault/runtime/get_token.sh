#!/usr/bin/env bash
export VAULT_ADDR="https://vault.evilmachine.net:8200"
vault login -tls-skip-verify -method=gcp \
role="admin" \
service_account="vault-admin-account@vault-main-258419.iam.gserviceaccount.com" \
project="vault-main-258419" \
jwt_exp="10m" \
credentials=@vault_admin.key.json
