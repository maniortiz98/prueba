#!/bin/bash
# Script de prueba para verificar configuración en Cloud Run

echo "🧪 Verificando configuración de variables de entorno..."

# Simular ambiente de GCP
export NG_APP_API_URL="valor-produccion-gcp"
export NG_APP_GCP_KEY="super-secreto-123-gcp"
export NG_APP_VERSION="1.0.0"
export PORT="80"

echo "🔧 Variables de entorno configuradas:"
echo "   NG_APP_API_URL: $NG_APP_API_URL"
echo "   NG_APP_GCP_KEY: $NG_APP_GCP_KEY"
echo "   NG_APP_VERSION: $NG_APP_VERSION"
echo "   PORT: $PORT"

echo ""
echo "📝 Generando configuración..."
node generate-env.js

echo ""
echo "📋 Contenido de env.config.ts:"
cat src/app/env.config.ts

echo ""
echo "✅ Verificación completada!"
echo ""
echo "🚀 Para desplegar en GCP con estas variables:"
echo "   gcloud run deploy mani-app \\"
echo "     --source . \\"
echo "     --region us-central1 \\"
echo "     --allow-unauthenticated \\"
echo "     --port 80 \\"
echo "     --set-env-vars \"NG_APP_API_URL=$NG_APP_API_URL,NG_APP_GCP_KEY=$NG_APP_GCP_KEY,NG_APP_VERSION=$NG_APP_VERSION\""
