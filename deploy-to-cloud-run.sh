#!/bin/bash
# Script para desplegar directamente a Cloud Run

PROJECT_ID="${1:-your-project-id}"
REGION="${2:-us-central1}"
SERVICE_NAME="mani-app"

if [ "$PROJECT_ID" = "your-project-id" ]; then
    echo "❌ Error: Proporciona tu PROJECT_ID como primer argumento"
    echo "   Uso: ./deploy-to-cloud-run.sh tu-project-id [region]"
    exit 1
fi

echo "🚀 Desplegando a Cloud Run..."
echo "   Proyecto: $PROJECT_ID"
echo "   Región: $REGION"
echo "   Servicio: $SERVICE_NAME"

# Configurar proyecto
gcloud config set project $PROJECT_ID

# Usar los valores que tienes configurados en la UI de Cloud Run
echo "� Usando variables de entorno configuradas..."
API_URL="valor-produccion-gcp"
GCP_KEY="super-secreto-123-gcp"
VERSION="1.0.0"

echo "✅ Variables configuradas:"
echo "   API_URL: $API_URL"
echo "   GCP_KEY: [HIDDEN]"
echo "   VERSION: $VERSION"

# Desplegar a Cloud Run con configuración de puerto automática
echo "🌐 Desplegando servicio..."
gcloud run deploy $SERVICE_NAME \
  --source . \
  --region $REGION \
  --allow-unauthenticated \
  --port 80 \
  --set-env-vars "NG_APP_API_URL=$API_URL,NG_APP_GCP_KEY=$GCP_KEY,NG_APP_VERSION=$VERSION" \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --timeout 300

if [ $? -eq 0 ]; then
    echo "🎉 Despliegue exitoso!"

    # Obtener URL del servicio
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')
    echo "🔗 URL del servicio: $SERVICE_URL"
    echo "🔗 Health check: $SERVICE_URL/health"

    echo ""
    echo "📋 Comandos útiles:"
    echo "   Ver logs: gcloud run services logs tail $SERVICE_NAME --region $REGION"
    echo "   Ver detalles: gcloud run services describe $SERVICE_NAME --region $REGION"
    echo "   Eliminar: gcloud run services delete $SERVICE_NAME --region $REGION"
else
    echo "❌ Error en el despliegue"
    exit 1
fi
