# Etapa de build
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build --configuration=production

# Etapa final: Nginx
FROM nginx:alpine

# Copiar la build de Angular
COPY --from=build /app/dist/mani/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

# Generar env.js dinámicamente a partir de variables de entorno de Cloud Run
# y luego iniciar Nginx
# Generar env.js y reemplazar variables en nginx.conf
CMD sh -c "\
envsubst '\$PORT \$API_KEY \$API_URL' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
echo \"window['env'] = { production: true, apiUrl: '${API_URL}', API_KEY: '${API_KEY}' };\" > /usr/share/nginx/html/assets/env.js && \
nginx -g 'daemon off;'"
