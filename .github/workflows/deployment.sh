
#!/bin/bash


# Usage examples:
# deploy_labelstudio "app-name" "labelstudio-namespace" "labelstudio-release" "example.com" "tls-secret" "mapbox-api-key" "db-host" "db-username" "db-password"

# Function to deploy labelstudio
deploy_labelstudio() {
    NAMESPACE="$1"
    HELM_RELEASE="$2"
    DOMAIN_NAME="$3"
    TLS_SECRET_NAME="$4"
    DB_HOST="$5"
    DB_USERNAME="$6"
    DB_PASSWORD="$7"
    ARM_TENANT_ID="$8"
    POSTGRES_SECRET_NAME="$9"
    PGPASSWORD="$10"
    ENV="$11"
    PLCHLDR="$12"
    
    echo "Namespace: $NAMESPACE"
    echo "Helm release: $HELM_RELEASE"
    echo "Domain name: $DOMAIN_NAME"
    echo "TLS Secret: $TLS_SECRET_NAME"
    echo "POSTGRES_SECRET_NAME: $POSTGRES_SECRET_NAME"
    echo "ENV: $ENV"

    # Helm dependency update
    # helm dependency update "../../helm/labelstudio"
    
    # Deploy labelstudio with override
    helm upgrade \
    -n "$NAMESPACE" \
    "$HELM_RELEASE" \
    --install \
    "../../helm/labelstudio" \
    -f "../../helm/labelstudio/values.yaml" \
    -f "../../helm/labelstudio/values.override.yaml" \
    -f "../../helm/labelstudio/values.override.$ENV.yaml" \
    --set "global.pgConfig.host=$DB_HOST" \
    --set "global.pgConfig.userName=$DB_USERNAME" \
    --set "global.pgConfig.password.secretName=$POSTGRES_SECRET_NAME" \
    --set "global.pgConfig.password.secretKey=pgpassword" \
    --set "app.ingress.host=$DOMAIN_NAME" \
    --debug
    
}
