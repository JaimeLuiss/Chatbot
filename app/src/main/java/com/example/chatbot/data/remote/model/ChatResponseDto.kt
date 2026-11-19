package com.example.chatbot.data.remote.model

import com.example.chatbot.domain.model.ChatResponse
import com.google.gson.annotations.SerializedName

data class ChatResponseDto(
    @SerializedName("success") val success: Boolean? = true,
    @SerializedName("conversation_id") val conversationId: Long? = null,
    @SerializedName("student_code") val studentCode: String? = null,
    @SerializedName("response") val response: String? = null,
    @SerializedName("output") val output: String? = null,
    @SerializedName("message") val message: String? = null,
    @SerializedName("intent") val intent: String? = null,
    @SerializedName("source") val source: String? = null,
    @SerializedName("timestamp") val timestamp: String? = null
) {
    fun toDomain(): ChatResponse {
        val text = response ?: output ?: message ?: "Respuesta del chatbot procesada."
        return ChatResponse(
            success = success ?: true,
            conversationId = conversationId,
            studentCode = studentCode ?: "",
            responseText = text,
            intent = intent ?: "general_chat",
            source = source ?: "n8n_cloud",
            timestamp = timestamp ?: ""
        )
    }
}
