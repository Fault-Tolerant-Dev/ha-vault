#!/usr/bin/env bash
rm -rf ~bcerniglia/.kube/

gcloud auth activate-service-account \
	--key-file=gke_admin.key.json \
	--project="vault-main-258419"

gcloud container clusters get-credentials \
    cluster-primary \
	--region=us-west2
