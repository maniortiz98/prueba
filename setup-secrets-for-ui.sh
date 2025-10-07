#!/bin/bash
# Script para configurar secretos específicos para tu configuración actual

PROJECT_ID="${1:-your-project-id}"

if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "❌ Error: Proporciona tu PROJECT_ID como primer argumento"
    echo "   Uso: ./setup-secrets-for-ui.sh tu-project-id"
    exit 1
fi

echo "🔐 Configurando secretos para Cloud Run UI..."
echo "   Proyecto: $PROJECT_ID"

# Configurar proyecto
gcloud config set project $PROJECT_ID

# Habilitar APIs
echo "📡 Habilitando APIs necesarias..."
gcloud services enable secretmanager.googleapis.com --quiet
gcloud services enable run.googleapis.com --quiet

# Crear secretos con los valores que tienes en la UI
echo "🔧 Creando secretos con tus valores..."

# API URL
echo -n "valor-produccion-gcp" | gcloud secrets create ng-app-api-url --data-file=- 2>/dev/null || \
echo -n "valor-produccion-gcp" | gcloud secrets versions add ng-app-api-url --data-file=-
echo "✅ Secreto 'ng-app-api-url' configurado con: valor-produccion-gcp"

# GCP Key
echo -n "super-secreto-123-gcp" | gcloud secrets create ng-app-gcp-key --data-file=- 2>/dev/null || \
echo -n "super-secreto-123-gcp" | gcloud secrets versions add ng-app-gcp-key --data-file=-
echo "✅ Secreto 'ng-app-gcp-key' configurado con: super-secreto-123-gcp"

# Version
echo -n "1.0.0" | gcloud secrets create ng-app-version --data-file=- 2>/dev/null || \
echo -n "1.0.0" | gcloud secrets versions add ng-app-version --data-file=-
echo "✅ Secreto 'ng-app-version' configurado con: 1.0.0"

# Configurar permisos para Cloud Run
echo "🔑 Configurando permisos para Cloud Run..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUD_RUN_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Permisos para cada secreto
for secret in ng-app-api-url ng-app-gcp-key ng-app-version; do
    gcloud secrets add-iam-policy-binding $secret \
        --member="serviceAccount:${CLOUD_RUN_SA}" \
        --role="roles/secretmanager.secretAccessor" \
        --quiet
    echo "✅ Permisos configurados para secreto: $secret"
done

echo ""
echo "🎉 ¡Configuración de secretos completada!"
echo ""
echo "📋 Ahora en la UI de Cloud Run puedes:"
echo "   1. Ir a 'Variables & Secrets' → 'Secrets'"
echo "   2. Hacer clic en 'ADD SECRET'"
echo "   3. Configurar así:"
echo ""
echo "      Secreto: ng-app-api-url    → Variable: NG_APP_API_URL"
echo "      Secreto: ng-app-gcp-key    → Variable: NG_APP_GCP_KEY"
echo "      Secreto: ng-app-version    → Variable: NG_APP_VERSION"
echo ""
echo "🔧 También necesitas en 'Environment Variables':"
echo "      PORT = 80"
echo ""
echo "🚀 Comando para despliegue automático:"
echo "   gcloud run deploy mani-app --source . --region us-central1 --port 80"
