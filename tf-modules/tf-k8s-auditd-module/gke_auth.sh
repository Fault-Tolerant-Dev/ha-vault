#!/usr/bin/env bash
gcloud auth activate-service-account \
	--key-file=tf_project.key.json \
	--project="vault-poc-254520"

gcloud container clusters get-credentials \
    cluster-west \
	--region=us-west2
