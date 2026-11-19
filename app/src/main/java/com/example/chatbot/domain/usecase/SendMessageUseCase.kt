package com.example.chatbot.domain.usecase

import com.example.chatbot.domain.model.ChatResponse
import com.example.chatbot.domain.repository.ChatRepository

class SendMessageUseCase(private val repository: ChatRepository) {
    suspend operator fun invoke(
        studentCode: String,
        message: String,
        conversationId: Long?
    ): Result<ChatResponse> {
        return repository.sendMessage(studentCode, message, conversationId)
    }
}
