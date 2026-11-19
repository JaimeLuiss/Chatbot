package com.example.chatbot.core.network

/**
 * Configuración centralizada de red para la conexión con el Webhook HTTPS de n8n Cloud.
 */
object NetworkConfig {

    /**
     * URL del Webhook HTTPS de producción en n8n Cloud.
     */
    const val N8N_WEBHOOK_URL = "https://cienciadatos.app.n8n.cloud/webhook/chatbot-academico"

    /**
     * URL base predeterminada para la inicialización del cliente Retrofit.
     */
    const val DEFAULT_BASE_URL = "https://cienciadatos.app.n8n.cloud/"
}
