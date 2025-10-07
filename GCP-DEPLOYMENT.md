# 🚀 Despliegue en Google Cloud Platform (GCP)

Esta guía te ayudará a desplegar tu aplicación Angular en GCP usando Google Secret Manager para manejar secretos de forma segura.

## 📋 Prerrequisitos

1. **Google Cloud CLI instalado**
   ```bash
   # Verificar instalación
   gcloud --version
   ```

2. **Proyecto de GCP configurado**
   ```bash
   gcloud config set project TU-PROJECT-ID
   gcloud auth login
   ```

## 🔐 Configuración de Secretos

### Paso 1: Configurar secretos automáticamente
```bash
# Hacer el script ejecutable
chmod +x setup-secrets.sh

# Ejecutar configuración (reemplaza 'tu-project-id')
./setup-secrets.sh tu-project-id
```

### Paso 2: Configuración manual (opcional)
```bash
# Crear secretos manualmente
echo -n "https://tu-api.com/api" | gcloud secrets create api-url --data-file=-
echo -n "tu-clave-secreta" | gcloud secrets create gcp-key --data-file=-
echo -n "1.0.0" | gcloud secrets create app-version --data-file=-
```

## 🏗️ Opciones de Despliegue

### Opción 1: Cloud Build (Recomendado)
```bash
# Desplegar usando Cloud Build
gcloud builds submit --config cloudbuild.yaml
```

### Opción 2: Cloud Run directo
```bash
# Desplegar directamente a Cloud Run
gcloud run deploy mani-app \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_CLOUD_PROJECT=TU-PROJECT-ID
```

### Opción 3: Build local + Deploy
```bash
# 1. Construir imagen localmente
docker build -t gcr.io/TU-PROJECT-ID/mani-app .

# 2. Subir imagen
docker push gcr.io/TU-PROJECT-ID/mani-app

# 3. Desplegar
gcloud run deploy mani-app \
  --image gcr.io/TU-PROJECT-ID/mani-app \
  --region us-central1 \
  --allow-unauthenticated
```

## 🔧 Gestión de Secretos

### Ver secretos existentes
```bash
gcloud secrets list
```

### Actualizar un secreto
```bash
echo -n "nuevo-valor" | gcloud secrets versions add gcp-key --data-file=-
```

### Ver valor de un secreto
```bash
gcloud secrets versions access latest --secret="api-url"
```

## 🐛 Troubleshooting

### Error de permisos
```bash
# Verificar permisos de Service Account
gcloud projects get-iam-policy TU-PROJECT-ID
```

### Error de APIs
```bash
# Habilitar APIs necesarias
gcloud services enable secretmanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
```

### Logs de Cloud Run
```bash
# Ver logs del servicio
gcloud run services logs read mani-app --region=us-central1
```

## 📊 Monitoreo

### Ver estado del servicio
```bash
gcloud run services list
```

### Ver detalles del servicio
```bash
gcloud run services describe mani-app --region=us-central1
```

## 🔄 Automatización CI/CD

Para automatizar el despliegue, puedes:

1. **Conectar GitHub con Cloud Build**
2. **Usar GitHub Actions** con el archivo `cloudbuild.yaml`
3. **Configurar triggers** en Cloud Build

## 💡 Mejores Prácticas

- ✅ Usar secretos para datos sensibles
- ✅ Implementar health checks
- ✅ Configurar monitoreo y alertas
- ✅ Usar diferentes proyectos para dev/staging/prod
- ✅ Implementar rollback automático
- ✅ Configurar CDN para assets estáticos

## 🔗 Enlaces Útiles

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
