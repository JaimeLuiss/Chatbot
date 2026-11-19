package com.example.chatbot.core.network

/**
 * Configuración centralizada de red para la conexión con el Webhook HTTPS de n8n Cloud.
 */
object NetworkConfig {

    /**
     * URL del Webhook HTTPS de n8n Cloud.
     * Reemplazar por la URL oficial en producción (ej: "https://tu-instancia-n8n.cloud/webhook/chatbot-academico").
     * Para entorno de emulador local se referencia "http://10.0.2.2:5678/webhook/chatbot-academico".
     */
    const val N8N_WEBHOOK_URL = "http://10.0.2.2:5678/webhook/chatbot-academico"

    /**
     * URL base de respaldo para la inicialización de Retrofit.
     */
    const val DEFAULT_BASE_URL = "http://10.0.2.2:5678/"
}
