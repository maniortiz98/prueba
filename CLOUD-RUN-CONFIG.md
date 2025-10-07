# 📋 Configuración manual de Cloud Run - Guía paso a paso

## 🔧 1. CONFIGURACIÓN DEL PUERTO

En la sección **"Settings"** → **"Container"**:
- ✅ **Container port**: `80` (NO uses $PORT aquí, sino el número fijo)
- ✅ **Request timeout**: `300` segundos
- ✅ **Memory**: `512 MiB` (mínimo recomendado)
- ✅ **CPU**: `1` (suficiente para Angular)

## 🌐 2. VARIABLES DE ENTORNO

En **"Variables & Secrets"** → **"Environment variables"**:

### ✅ Variables requeridas:
```
Name: NG_APP_API_URL
Value: valor-produccion-gcp

Name: NG_APP_GCP_KEY  
Value: super-secreto-123-gcp

Name: NG_APP_VERSION
Value: 1.0.0
```

### ⚠️ IMPORTANTE - También necesitas:
```
Name: PORT
Value: 80
```

## 🔐 3. PARA USAR GOOGLE SECRET MANAGER (Opcional pero recomendado)

Si quieres usar secretos en lugar de variables de entorno:

### Paso 1: Crear secretos
```bash
# API URL
echo -n "valor-produccion-gcp" | gcloud secrets create ng-app-api-url --data-file=-

# GCP Key  
echo -n "super-secreto-123-gcp" | gcloud secrets create ng-app-gcp-key --data-file=-

# Version
echo -n "1.0.0" | gcloud secrets create ng-app-version --data-file=-
```

### Paso 2: En Cloud Run UI
En **"Variables & Secrets"** → **"Secrets"**:
- ✅ Agregar secreto: `ng-app-api-url` → Variable: `NG_APP_API_URL`
- ✅ Agregar secreto: `ng-app-gcp-key` → Variable: `NG_APP_GCP_KEY`  
- ✅ Agregar secreto: `ng-app-version` → Variable: `NG_APP_VERSION`

## 🚀 4. CONFIGURACIÓN COMPLETA RECOMENDADA

### Pestaña "General":
- ✅ **Service name**: `mani-app`
- ✅ **Region**: `us-central1` (o tu región preferida)
- ✅ **Authentication**: `Allow unauthenticated invocations`

### Pestaña "Container":
- ✅ **Container image URL**: `gcr.io/TU-PROJECT-ID/mani-app:latest`
- ✅ **Container port**: `80`
- ✅ **Request timeout**: `300`
- ✅ **Memory**: `512 MiB`
- ✅ **CPU**: `1`

### Pestaña "Variables & Secrets":
```
Environment Variables:
- PORT = 80
- NG_APP_API_URL = valor-produccion-gcp
- NG_APP_GCP_KEY = super-secreto-123-gcp  
- NG_APP_VERSION = 1.0.0
```

### Pestaña "Connections":
- ✅ **Ingress**: `All`
- ✅ **CPU allocation**: `CPU is only allocated during request processing`

### Pestaña "Security":
- ✅ **Service account**: Usar la por defecto o crear una específica
- ✅ **Execution environment**: `Second generation`

## 🧪 5. VERIFICACIÓN

Después del despliegue:

### Health Check:
```bash
curl https://TU-SERVICE-URL/health
# Debe responder: healthy
```

### Variables de entorno:
- Ve a la consola del navegador en tu app
- Deberías ver en console.log:
  ```
  API URL: valor-produccion-gcp
  GCP Key: super-secreto-123-gcp
  Version: 1.0.0
  ```

## ❌ 6. PROBLEMAS COMUNES

### "Container failed to start":
- ✅ Verifica que Container port sea `80`
- ✅ Verifica que la variable `PORT=80` esté configurada
- ✅ Revisa los logs: `gcloud run services logs tail mani-app`

### "Variables no aparecen":
- ✅ Verifica que los nombres sean exactos: `NG_APP_API_URL` (no `ng_app_api_url`)
- ✅ Despliega una nueva revisión después de cambiar variables
- ✅ Verifica en el network del navegador que `env-config.js` se cargue

### "Secretos no aparecen en UI":
- ✅ Primero crea los secretos con `gcloud secrets create`
- ✅ Asigna permisos: `gcloud secrets add-iam-policy-binding`
- ✅ Refresca la página del Cloud Run

## 💡 7. COMANDO RÁPIDO PARA DESPLEGAR

```bash
gcloud run deploy mani-app \
  --image gcr.io/TU-PROJECT-ID/mani-app:latest \
  --region us-central1 \
  --allow-unauthenticated \
  --port 80 \
  --set-env-vars "PORT=80,NG_APP_API_URL=valor-produccion-gcp,NG_APP_GCP_KEY=super-secreto-123-gcp,NG_APP_VERSION=1.0.0" \
  --memory 512Mi \
  --cpu 1
```
