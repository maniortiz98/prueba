#!/bin/bash
# Script para configurar secretos en Google Secret Manager

# Configuración
PROJECT_ID="${1:-your-project-id}"
REGION="us-central1"

if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "❌ Error: Proporciona tu PROJECT_ID como primer argumento"
    echo "   Uso: ./setup-secrets.sh tu-project-id"
    exit 1
fi

echo "🔧 Configurando secretos en Google Secret Manager para el proyecto: $PROJECT_ID"

# Configurar proyecto
gcloud config set project $PROJECT_ID

# Habilitar APIs necesarias
echo "📡 Habilitando APIs necesarias..."
gcloud services enable secretmanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Crear secretos en Secret Manager
echo "🔐 Creando secretos..."

# API URL
echo -n "https://miapi-en-produccion.com/api" | gcloud secrets create api-url --data-file=-
echo "✅ Secreto 'api-url' creado"

# GCP Key (reemplaza con tu valor real)
echo -n "valor-produccion-secreto" | gcloud secrets create gcp-key --data-file=-
echo "✅ Secreto 'gcp-key' creado"

# Version
echo -n "1.0.0" | gcloud secrets create app-version --data-file=-
echo "✅ Secreto 'app-version' creado"

# Configurar permisos para Cloud Build
echo "🔑 Configurando permisos..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud secrets add-iam-policy-binding api-url \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding gcp-key \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding app-version \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/secretmanager.secretAccessor"

echo "🎉 Configuración completada!"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Actualiza los valores de los secretos si es necesario:"
echo "      gcloud secrets versions add api-url --data-file=<archivo>"
echo "   2. Ejecuta el build:"
echo "      gcloud builds submit --config cloudbuild.yaml"
echo "   3. O despliega directamente:"
echo "      gcloud run deploy mani-app --source . --region $REGION"
