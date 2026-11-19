# Guía de Instalación y Configuración Completa - Chatbot UNAB

## 1. Requisitos del Sistema

- **Sistema Operativo**: Windows 10/11, macOS o Linux.
- **Android Studio**: Versión Ladybug (2024.2.1) o posterior con SDK 37 (o API 26+).
- **Docker Desktop**: En ejecución (motor WSL2 en Windows o Docker Engine en Linux).
- **Git**: Versión 2.30 o superior.

---

## 2. Despliegue de la Infraestructura Backend (PostgreSQL 16 + n8n)

1. **Abrir Terminal en la Raíz del Proyecto**:
   ```powershell
   cd C:\Users\jaime\AndroidStudioProjects\Chatbot
   ```

2. **Iniciar Contenedores mediante Docker Compose**:
   ```bash
   docker compose up -d
   ```

3. **Verificar que los Contenedores estén Activos**:
   ```bash
   docker ps
   ```
   *Debe mostrar `chatbot_db` (puerto 5432) y `chatbot_n8n` (puerto 5678)*.

4. **Poblar la Base de Datos con los Scripts SQL**:
   ```powershell
   Get-Content database/01_crear_tablas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
   Get-Content database/02_datos_sinteticos.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
   Get-Content database/03_consultas_academicas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
   Get-Content database/04_pruebas_integridad.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
   Get-Content database/05_memoria_chat.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
   ```

---

## 3. Configuración de n8n Cloud y DeepSeek LLM

1. **Importar el Workflow**:
   En n8n Cloud o en el servidor n8n local (`http://localhost:5678`), importar el archivo `n8n/workflows/chatbot_academico.json`.
2. **Configurar Credencial de DeepSeek**:
   En el nodo de DeepSeek / HTTP Request de n8n, agregar la clave API de DeepSeek como una credencial de tipo **Header Auth** (`Authorization: Bearer YOUR_DEEPSEEK_API_KEY`).
3. **Activar el Workflow**:
   Activar el interruptor **Active** en la esquina superior derecha del workflow de n8n.
4. **Copiar la URL del Webhook HTTPS**:
   Copiar la URL de producción generada por el nodo Webhook (ej. `https://tu-instancia.n8n.cloud/webhook/chatbot-academico`).

---

## 4. Configuración y Compilación de la App Android

1. **Abrir el Proyecto en Android Studio**:
   Abrir la carpeta `C:\Users\jaime\AndroidStudioProjects\Chatbot`.
2. **Configurar la URL del Webhook**:
   Editar `app/src/main/java/com/example/chatbot/core/network/NetworkConfig.kt` y reemplazar el valor de `N8N_WEBHOOK_URL` por tu URL HTTPS real:
   ```kotlin
   object NetworkConfig {
       const val N8N_WEBHOOK_URL = "https://tu-instancia.n8n.cloud/webhook/chatbot-academico"
   }
   ```
3. **Sincronizar Gradle**:
   Hacer clic en **File > Sync Project with Gradle Files**.
4. **Ejecutar Pruebas Unitarias**:
   ```bash
   ./gradlew testDebugUnitTest
   ```
5. **Compilar y Ejecutar**:
   Seleccionar un emulador o dispositivo físico y presionar **Run 'app'** (Shift + F10).

---

## 5. Solución de Problemas Frecuentes

- **Error de Conexión HTTP desde el Emulador Android**:
  Asegurarse de usar `http://10.0.2.2:5678/webhook/chatbot-academico` para servidores locales o HTTPS para servidores en la nube.
- **Error 404 en el Webhook de n8n**:
  Verificar que el workflow esté marcado como **Active** en n8n.
- **Error de Metadatos AAR en Gradle**:
  Asegurarse de que `compileSdk = 37` esté configurado en `app/build.gradle.kts`.
