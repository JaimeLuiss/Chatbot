package com.example.chatbot.domain.repository

import com.example.chatbot.domain.model.ChatResponse

interface ChatRepository {
    suspend fun sendMessage(
        studentCode: String,
        message: String,
        conversationId: Long?
    ): Result<ChatResponse>
}
