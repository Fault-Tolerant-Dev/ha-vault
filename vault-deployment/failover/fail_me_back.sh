#!/usr/bin/env bash
echo "Gcloud Authing"
rm -rf ~bcerniglia/.config/
gcloud auth activate-service-account \
	   --key-file=failover_control_account.key.json \
	   --project="vault-main-258419"

echo "Getting Cluster Creds"
rm -rf ~bcerniglia/.kube/
gcloud container clusters get-credentials \
    cluster-primary \
	--region=us-west2
sleep 1
gcloud container clusters get-credentials \
    cluster-secondary \
	--region=us-east4
sleep 1


# For clean failover uncomment next three lines
echo "Scale secondary to 0"
kubectl --namespace=vault-namespace scale statefulsets vault-stateful --replicas 0 --cluster gke_vault-main-258419_us-east4_cluster-secondary
sleep 30

# Prevents secondary cluster from unexpectedly coming back up
echo "Preventing Nonsense"
gsutil iam ch serviceAccount:vault-node-account-secondary@vault-main-258419.iam.gserviceaccount.com:objectViewer \
       -d serviceAccount:vault-node-account-secondary@vault-main-258419.iam.gserviceaccount.com:objectAdmin \
       gs://vault-locks-56142
sleep 1

# Gives primary cluster the ability to create a lock
gsutil iam ch serviceAccount:vault-node-account-primary@vault-main-258419.iam.gserviceaccount.com:objectAdmin \
       -d serviceAccount:vault-node-account-primary@vault-main-258419.iam.gserviceaccount.com:objectViewer \
       gs://vault-locks-56142
sleep 1


echo "Scale primary to 3"
kubectl --namespace=vault-namespace scale statefulsets vault-stateful --replicas 3 --cluster gke_vault-main-258419_us-west2_cluster-primary
sleep 1

# Update CNAME to point at secondary
echo "update dns records"
gcloud dns record-sets import \
       primary_active_records.yaml --delete-all-existing \
       --zone=vault-zone




