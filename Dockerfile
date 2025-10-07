# Multi-stage build para Angular con GCP
FROM node:20-alpine AS build
WORKDIR /app

# Instalar Google Cloud SDK para acceder a Secret Manager
RUN apk add --no-cache \
    curl \
    python3 \
    py3-pip \
    && curl -sSL https://sdk.cloud.google.com | bash

# Añadir gcloud al PATH
ENV PATH="/root/google-cloud-sdk/bin:${PATH}"

# Copiar archivos de configuración
COPY package.json ./
COPY load-secrets.sh ./
COPY generate-env.js ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Hacer el script ejecutable
RUN chmod +x load-secrets.sh

# Cargar secretos y generar configuración (solo si está en GCP)
RUN if [ -n "$GOOGLE_CLOUD_PROJECT" ]; then \
        ./load-secrets.sh && node generate-env.js; \
    else \
        echo "Usando configuración local" && node generate-env.js; \
    fi

# Build de la aplicación
RUN npm run build --configuration=production

# Etapa de producción con Nginx (versión más segura)
FROM nginx:1.25-alpine

# Crear usuario no-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copiar archivos de la aplicación
COPY --from=build /app/dist/mani/browser /usr/share/nginx/html

# Copiar configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Cambiar permisos
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE 8080

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"]
