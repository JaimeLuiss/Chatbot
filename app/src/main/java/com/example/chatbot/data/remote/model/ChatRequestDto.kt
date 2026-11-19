package com.example.chatbot.data.remote.model

import com.google.gson.annotations.SerializedName

data class ChatRequestDto(
    @SerializedName("student_code") val studentCode: String,
    @SerializedName("message") val message: String,
    @SerializedName("conversation_id") val conversationId: Long? = null,
    @SerializedName("student_id") val studentId: String? = null
)
