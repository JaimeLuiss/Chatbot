package com.example.chatbot.data.repository

import com.example.chatbot.core.network.NetworkConfig
import com.example.chatbot.data.remote.ChatbotApiService
import com.example.chatbot.data.remote.RetrofitClient
import com.example.chatbot.data.remote.model.ChatRequestDto
import com.example.chatbot.domain.model.ChatResponse
import com.example.chatbot.domain.repository.ChatRepository

class ChatRepositoryImpl(
    private val apiService: ChatbotApiService = RetrofitClient.apiService
) : ChatRepository {

    override suspend fun sendMessage(
        studentCode: String,
        message: String,
        conversationId: Long?
    ): Result<ChatResponse> {
        return try {
            val request = ChatRequestDto(
                studentCode = studentCode,
                studentId = studentCode,
                message = message,
                conversationId = conversationId
            )
            val response = apiService.sendChatMessage(NetworkConfig.N8N_WEBHOOK_URL, request)

            if (response.isSuccessful) {
                val body = response.body()
                if (body != null) {
                    Result.success(body.toDomain())
                } else {
                    Result.failure(Exception("El servidor n8n devolvió una respuesta vacía."))
                }
            } else {
                val errorText = response.errorBody()?.string() ?: "Error HTTP ${response.code()}"
                Result.failure(Exception("Error de comunicación ($errorText)"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.localizedMessage ?: "No se pudo conectar con el Webhook de n8n Cloud."}"))
        }
    }
}
