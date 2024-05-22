#!/bin/bash

set -eo pipefail
# Default values if not provided as arguments
namespace="labelstudio-namespace"
tls_secret_name=""
crt_path="./tls.crt"
key_path="./tls.key"
TLS_CRT=""
TLS_KEY=""
postrges_secret_name=""
PGPASSWORD=""

# Function to display usage instructions
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -n, --namespace            Kubernetes Namespace"
    echo "  -tls, --tls-secret-name    TLS Secret Name"
    echo "  --tls-crt                  Base64-encoded TLS Certificate"
    echo "  --tls-key                  Base64-encoded TLS Key"
    echo "  -pst, --postgres-secret    Postgres Secret Name"
    echo "  -pgp, --postgres-password  Postgres Password"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--namespace)
            namespace="$2"
            shift 2
            ;;
        -tls|--tls-secret-name)
            tls_secret_name="$2"
            shift 2
            ;;
        --tls-crt)
            TLS_CRT="$2"
            shift 2
            ;;
        --tls-key)
            TLS_KEY="$2"
            shift 2
            ;;
        -pst|--postgres-secret)
            postrges_secret_name="$2"
            shift 2
            ;;
        -pgp|--postgres-password)
            PGPASSWORD="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$namespace" ] || [ -z "$tls_secret_name" ] || [ -z "$TLS_CRT" ] || [ -z "$TLS_KEY" ] || [ -z "$postrges_secret_name"] || [ -z "$PGPASSWORD"]; then
    echo "Error: Missing required arguments."
    usage
fi


# NAMESPACE
echo "Namespace: $namespace"
if kubectl get namespace "$namespace" >/dev/null 2>&1; then
    echo "Namespace $namespace already exists"
else
    echo "Creating namespace $namespace"
    kubectl create namespace "$namespace"
fi

# CERTIFICATE
echo $TLS_CRT | base64 -d >> $crt_path
echo $TLS_KEY | base64 -d >> $key_path
if kubectl get secret "$tls_secret_name" -n "$namespace" > /dev/null 2>&1; then
    echo "Secret $tls_secret_name already exists."
else
    # create secret if not exists
    kubectl create secret tls "$tls_secret_name" \
    --cert="$crt_path" \
    --key="$key_path" \
    --namespace "$namespace"
    echo "Secret $tls_secret_name created."
fi

# POSTGRES
if kubectl get secret "$postrges_secret_name" -n "$namespace" > /dev/null 2>&1; then
    echo "Secret $postrges_secret_name already exists."
else
    # create secret if not exists
    kubectl create secret generic "$postrges_secret_name" \
    --from-literal=pgpassword="$PGPASSWORD" \
    --namespace "$namespace"
    echo "Secret $postrges_secret_name created."
fi