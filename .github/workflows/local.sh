#!/bin/bash

set -eo pipefail

usage() {
    echo "Usage: $0 -e ENV_PATH"
    exit 1
}


while [[ $# -gt 0 ]]; do
    case "$1" in
        -e)
            ENV_PATH="$2"
            shift 2
        ;;
        *)
            usage
        ;;
    esac
done

# Vérifier si les arguments obligatoires sont définis
if [ -z "$ENV_PATH" ]; then
    echo "Error: Missing required arguments."
    usage
fi
# export env variables
export $(grep -v '^#' $ENV_PATH | xargs)
# import deployment functions
source ./deployment.sh

# need az cli
# source .venv/bin/activate
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
DB_HOST=$(./keyvault.sh host $POSTGRES_KEYVAULT)
DB_USERNAME=$(./keyvault.sh username $POSTGRES_KEYVAULT)
DB_PASSWORD=$(./keyvault.sh password $POSTGRES_KEYVAULT)

source ./context.sh -g $KUBERNETES_RESOURCE_GROUP -n $KUBERNETES_CLUSTER_NAME

APP_NAME="labelstudio"
helm_release="${APP_NAME}-release"
namespace="${APP_NAME}-namespace"
tls_secret_name="ingress-tls-labelstudio"
postgres_secret_name="postgres-dev-labelstudio"

# creates the namespace and the tls secret
source ./secrets.sh \
    --namespace $namespace \
    --tls-secret-name $tls_secret_name \
    --tls-crt $TLS_CRT \
    --tls-key $TLS_KEY \
    --postgres-secret $postgres_secret_name \
    --postgres-password $PGPASSWORD

echo "Namespace: $namespace"
echo "Helm release: $helm_release"
deploy_labelstudio \
    $namespace \
    $helm_release \
    $DOMAIN_NAME \
    $tls_secret_name \
    $DB_HOST \
    $DB_USERNAME \
    $DB_PASSWORD \
    $ARM_TENANT_ID \
    $postgres_secret_name \
    $PGPASSWORD \
    $ENV