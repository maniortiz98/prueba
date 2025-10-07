# Multi-stage build para Angular - Version simplificada
FROM node:20-alpine AS build
WORKDIR /app

# Copiar archivos de configuración
COPY package.json ./
COPY generate-env.js ./

# Instalar dependencias de Node.js
RUN npm install

# Copiar código fuente
COPY . .

# Generar configuración desde .env (para build local)
# En producción, las variables se inyectarán via Cloud Build
RUN node generate-env.js

# Build de la aplicación
RUN npm run build --configuration=production

# Etapa de producción con Nginx
FROM nginx:1.26-alpine

# Crear usuario no-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Instalar herramientas necesarias
RUN apk add --no-cache bash gettext

# Copiar archivos de la aplicación
COPY --from=build /app/dist/mani/browser /usr/share/nginx/html

# Copiar template de configuración de Nginx
COPY nginx.conf.template /etc/nginx/conf.d/nginx.conf.template

# Script para inyectar variables de entorno en runtime
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Cambiar permisos
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown appuser:appgroup /var/run/nginx.pid

# Cambiar a usuario no-root
USER appuser

# Cloud Run usa PORT dinámicamente
EXPOSE $PORT

# Usar entrypoint personalizado
ENTRYPOINT ["/docker-entrypoint.sh"]

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"]
