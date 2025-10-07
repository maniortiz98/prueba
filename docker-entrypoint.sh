#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Angular..."

# Configurar puerto desde variable de entorno (Cloud Run usa PORT)
export PORT=${PORT:-8080}
echo "🔧 Configurando puerto: $PORT"

# Generar configuración de Nginx con el puerto correcto
envsubst '${PORT}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf
echo "✅ Configuración de Nginx generada para puerto $PORT"

# Verificar si hay variables de entorno definidas
if [ -n "$NG_APP_API_URL" ] || [ -n "$NG_APP_GCP_KEY" ] || [ -n "$NG_APP_VERSION" ]; then
    echo "🔧 Inyectando variables de entorno en la aplicación..."

    # Crear script de configuración que se inyectará en el HTML
    cat > /usr/share/nginx/html/env-config.js << EOF
window.ENV = {
  API_URL: '${NG_APP_API_URL:-https://localhost:3000/api}',
  GCP_KEY: '${NG_APP_GCP_KEY:-default-key}',
  VERSION: '${NG_APP_VERSION:-1.0.0}'
};
EOF

    echo "✅ Variables de entorno configuradas:"
    echo "   API_URL: ${NG_APP_API_URL:-https://localhost:3000/api}"
    echo "   GCP_KEY: [HIDDEN]"
    echo "   VERSION: ${NG_APP_VERSION:-1.0.0}"

    # Inyectar el script en el index.html si no está ya inyectado
    if [ -f "/usr/share/nginx/html/index.html" ] && ! grep -q "env-config.js" /usr/share/nginx/html/index.html; then
        # Buscar la etiqueta </head> e inyectar nuestro script antes
        sed -i 's|</head>|  <script src="env-config.js"></script>\n</head>|g' /usr/share/nginx/html/index.html
        echo "✅ Script de configuración inyectado en index.html"
    fi
else
    echo "ℹ️  Usando configuración por defecto (no se encontraron variables de entorno)"
fi

echo "🌐 Iniciando servidor Nginx en puerto $PORT..."

# Ejecutar el comando original
exec "$@"
