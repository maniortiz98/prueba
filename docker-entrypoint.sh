#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Angular..."

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

    # Inyectar el script en el index.html
    if [ -f "/usr/share/nginx/html/index.html" ]; then
        # Buscar la etiqueta </head> e inyectar nuestro script antes
        sed -i 's|</head>|  <script src="env-config.js"></script>\n</head>|g' /usr/share/nginx/html/index.html
        echo "✅ Script de configuración inyectado en index.html"
    fi
else
    echo "ℹ️  Usando configuración por defecto (no se encontraron variables de entorno)"
fi

echo "🌐 Iniciando servidor Nginx..."

# Ejecutar el comando original
exec "$@"
