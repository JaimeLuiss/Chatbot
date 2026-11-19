package com.example.chatbot.core.network

/**
 * Configuración centralizada de red para la conexión con el Webhook HTTPS de n8n Cloud.
 */
object NetworkConfig {

    /**
     * URL del Webhook HTTPS de n8n Cloud en Producción.
     * 
     * INSTRUCCIONES MANUALES:
     * Para conectar la APK con tu n8n Cloud en producción, reemplaza el valor de esta constante
     * por la URL HTTPS real generada por tu nodo Webhook en n8n Cloud:
     * Ejemplo: "https://tu-instancia.n8n.cloud/webhook/chatbot-academico"
     */
    const val N8N_WEBHOOK_URL = "REEMPLAZAR_POR_URL_REAL_DEL_WEBHOOK_HTTPS_N8N"

    /**
     * URL base predeterminada para la inicialización de Retrofit en entorno HTTPS.
     */
    const val DEFAULT_BASE_URL = "https://n8n.cloud/"
}
