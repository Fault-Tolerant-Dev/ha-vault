#!/usr/bin/env bash
openssl genrsa -out vault.key 2048

openssl req \
   -new -key vault.key \
   -out vault.csr \
   -config openssl.cnf

 openssl req \
    -new \
    -newkey rsa:2048 \
    -days 120 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=NewYork/L=The Cloud/O=Vault CA" \
    -keyout ca.key \
    -out ca.crt



openssl x509 \
    -req \
    -days 120 \
    -in vault.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -extensions v3_req \
    -extfile openssl.cnf \
    -out vault.crt

cat vault.crt ca.crt > vault-combined.crt