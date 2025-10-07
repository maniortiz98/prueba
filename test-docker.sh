#!/bin/bash
# Script para probar el contenedor localmente

echo "🔨 Construyendo imagen Docker..."
docker build -t mani-app .

echo "🧪 Probando contenedor localmente..."
echo "   - Puerto: 8080"
echo "   - Variables de entorno de prueba configuradas"

# Ejecutar contenedor con variables de entorno de prueba
docker run --rm -p 8080:8080 \
  -e PORT=8080 \
  -e NG_APP_API_URL="https://test-api.com/api" \
  -e NG_APP_GCP_KEY="test-key-123" \
  -e NG_APP_VERSION="1.0.0" \
  mani-app

echo "✅ Contenedor ejecutándose en http://localhost:8080"
echo "💡 Presiona Ctrl+C para detener"
