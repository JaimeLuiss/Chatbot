package com.example.chatbot.ui.chat

import com.example.chatbot.domain.model.ChatMessage

data class ChatUiState(
    val studentCode: String = "U00010001",
    val conversationId: Long? = null,
    val messages: List<ChatMessage> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)
