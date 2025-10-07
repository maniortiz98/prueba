const fs = require('fs');
const path = require('path');

// Leer el archivo .env local (si existe)
const envPath = path.join(__dirname, '.env');
let envContent = '';

if (fs.existsSync(envPath)) {
  envContent = fs.readFileSync(envPath, 'utf8');
}

// Parsear las variables del archivo .env
const envVars = {};
const lines = envContent.split('\n');

lines.forEach(line => {
  const [key, ...valueParts] = line.split('=');
  if (key && valueParts.length > 0) {
    const value = valueParts.join('=').trim();
    envVars[key.trim()] = value;
  }
});

// Función para obtener variable con prioridad:
// 1. Variables de entorno del sistema (GCP)
// 2. Archivo .env local
// 3. Valor por defecto
function getEnvValue(key, defaultValue) {
  return process.env[key] || envVars[key] || defaultValue;
}

// Generar el archivo env.config.ts con valores dinámicos
const configContent = `// Configuración de variables de entorno desde .env y GCP
// Este archivo se genera automáticamente desde generate-env.js

export const env = {
  API_URL: '${getEnvValue('NG_APP_API_URL', 'http://localhost:3000/api')}',
  GCP_KEY: '${getEnvValue('NG_APP_GCP_KEY', 'default-key')}',
  VERSION: '${getEnvValue('NG_APP_VERSION', '1.0.0')}'
};
`;

// Escribir el archivo
const configPath = path.join(__dirname, 'src/app/env.config.ts');
fs.writeFileSync(configPath, configContent);

console.log('✅ Variables de entorno cargadas:');
console.log('   Fuente: ' + (process.env.NG_APP_API_URL ? 'GCP Environment Variables' : '.env local'));
console.log('   NG_APP_API_URL:', getEnvValue('NG_APP_API_URL', 'http://localhost:3000/api'));
console.log('   NG_APP_GCP_KEY:', getEnvValue('NG_APP_GCP_KEY', 'default-key'));
console.log('   NG_APP_VERSION:', getEnvValue('NG_APP_VERSION', '1.0.0'));
