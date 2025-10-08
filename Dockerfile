FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ARG API_URL
ARG GCP_KEY

ENV NG_APP_API_URL=$API_URL
ENV NG_APP_GCP_KEY=$GCP_KEY

RUN npm run build --configuration=production

FROM nginx:alpine

COPY --from=build /app/dist/mani /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
