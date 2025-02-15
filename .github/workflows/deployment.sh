
#!/bin/bash


# Usage examples:
# deploy_labelstudio "app-name" "labelstudio-namespace" "labelstudio-release" "example.com" "tls-secret" "mapbox-api-key" "db-host" "db-username" "db-password"

# Function to deploy labelstudio
deploy_labelstudio() {
    HELM_RELEASE="$1"
    DOMAIN_NAME="$2"
    TLS_SECRET_NAME="$3"
    DB_HOST="$4"
    DB_USERNAME="$5"
    DB_PASSWORD="$6"
    ARM_TENANT_ID="$7"
    POSTGRES_SECRET_NAME="$8"
    PGPASSWORD="$9"
    LABEL_STUDIO_USERNAME="${10}"
    LABEL_STUDIO_PASSWORD="${11}"
    
    echo "Helm release: $HELM_RELEASE"
    echo "Domain name: $DOMAIN_NAME"
    echo "TLS Secret: $TLS_SECRET_NAME"
    echo "POSTGRES_SECRET_NAME: $POSTGRES_SECRET_NAME"

    # Helm dependency update
    helm dependency update "../../helm/labelstudio"
    
    # Deploy labelstudio with override
    helm upgrade \
    -n labelstudio-namespace \
    "$HELM_RELEASE" \
    --install \
    "../../helm/labelstudio" \
    -f "../../helm/labelstudio/values.yaml" \
    -f "../../helm/labelstudio/values.override.yaml" \
    --set "global.pgConfig.host=$DB_HOST" \
    --set "global.pgConfig.userName=$DB_USERNAME" \
    --set "global.pgConfig.password.secretName=$POSTGRES_SECRET_NAME" \
    --set "global.pgConfig.password.secretKey=pgpassword" \
    --set "app.ingress.host=$DOMAIN_NAME" \
    --set "app.ingress.tls[0].hosts[0]=$DOMAIN_NAME" \
    --set "app.ingress.tls[0].secretName=ingress-tls-labelstudio" \
    --set "global.extraEnvironmentVars.LABEL_STUDIO_USERNAME=$LABEL_STUDIO_USERNAME" \
    --set "global.extraEnvironmentVars.LABEL_STUDIO_PASSWORD=$LABEL_STUDIO_PASSWORD" \
    --debug
    
}
