package com.example.chatbot.data.remote

import com.example.chatbot.data.remote.model.ChatRequestDto
import com.example.chatbot.data.remote.model.ChatResponseDto
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Url

interface ChatbotApiService {
    @POST
    suspend fun sendChatMessage(
        @Url url: String,
        @Body request: ChatRequestDto
    ): Response<ChatResponseDto>
}
