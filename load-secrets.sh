#!/bin/sh
# Script para cargar secretos desde Google Secret Manager

# Verificar que gcloud esté instalado
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI no está instalado"
    exit 1
fi

# Variables de configuración
PROJECT_ID=${GOOGLE_CLOUD_PROJECT}
SECRET_API_URL_NAME="api-url"
SECRET_GCP_KEY_NAME="gcp-key"
SECRET_VERSION_NAME="app-version"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: GOOGLE_CLOUD_PROJECT no está configurado"
    exit 1
fi

echo "🔐 Cargando secretos desde Google Secret Manager..."

# Obtener secretos de Google Secret Manager
NG_APP_API_URL=$(gcloud secrets versions access latest --secret="$SECRET_API_URL_NAME" --project="$PROJECT_ID" 2>/dev/null || echo "http://localhost:3000/api")
NG_APP_GCP_KEY=$(gcloud secrets versions access latest --secret="$SECRET_GCP_KEY_NAME" --project="$PROJECT_ID" 2>/dev/null || echo "default-key")
NG_APP_VERSION=$(gcloud secrets versions access latest --secret="$SECRET_VERSION_NAME" --project="$PROJECT_ID" 2>/dev/null || echo "1.0.0")

# Exportar variables de entorno
export NG_APP_API_URL
export NG_APP_GCP_KEY
export NG_APP_VERSION

# Crear archivo .env temporal
cat > .env << EOF
NG_APP_API_URL=$NG_APP_API_URL
NG_APP_GCP_KEY=$NG_APP_GCP_KEY
NG_APP_VERSION=$NG_APP_VERSION
EOF

echo "✅ Secretos cargados exitosamente"
echo "   API_URL: $NG_APP_API_URL"
echo "   GCP_KEY: [HIDDEN]"
echo "   VERSION: $NG_APP_VERSION"
