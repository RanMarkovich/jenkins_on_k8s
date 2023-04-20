#!/bin/bash

jsonpath="{.data.jenkins-admin-password}"

secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)

cat > ./admin_creds.txt <<EOL
username = admin
password = $(echo $secret | base64 --decode)
EOL