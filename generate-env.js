const fs = require('fs');
const path = require('path');

// Leer el archivo .env
const envPath = path.join(__dirname, '.env');
let envContent = '';

if (fs.existsSync(envPath)) {
  envContent = fs.readFileSync(envPath, 'utf8');
}

// Parsear las variables
const envVars = {};
const lines = envContent.split('\n');

lines.forEach(line => {
  const [key, ...valueParts] = line.split('=');
  if (key && valueParts.length > 0) {
    const value = valueParts.join('=').trim();
    envVars[key.trim()] = value;
  }
});

// Generar el archivo env.config.ts
const configContent = `// Configuración de variables de entorno desde .env
// Este archivo se genera automáticamente desde generate-env.js

export const env = {
  API_URL: '${envVars.NG_APP_API_URL || 'http://localhost:3000/api'}',
  GCP_KEY: '${envVars.NG_APP_GCP_KEY || 'default-key'}',
  VERSION: '${envVars.NG_APP_VERSION || '1.0.0'}'
};
`;

// Escribir el archivo
const configPath = path.join(__dirname, 'src/app/env.config.ts');
fs.writeFileSync(configPath, configContent);

console.log('✅ Variables de entorno cargadas desde .env:');
console.log('   NG_APP_API_URL:', envVars.NG_APP_API_URL);
console.log('   NG_APP_GCP_KEY:', envVars.NG_APP_GCP_KEY);
console.log('   NG_APP_VERSION:', envVars.NG_APP_VERSION);
