package com.example.chatbot.domain.model

data class ChatResponse(
    val success: Boolean,
    val conversationId: Long?,
    val studentCode: String,
    val responseText: String,
    val intent: String,
    val source: String,
    val timestamp: String
)
