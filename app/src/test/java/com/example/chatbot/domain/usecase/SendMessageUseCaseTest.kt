package com.example.chatbot.domain.usecase

import com.example.chatbot.domain.model.ChatResponse
import com.example.chatbot.domain.repository.ChatRepository
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SendMessageUseCaseTest {

    private class FakeChatRepository : ChatRepository {
        override suspend fun sendMessage(
            studentCode: String,
            message: String,
            conversationId: Long?
        ): Result<ChatResponse> {
            return Result.success(
                ChatResponse(
                    success = true,
                    conversationId = conversationId ?: 1L,
                    studentCode = studentCode,
                    responseText = "Respuesta simulada para: $message",
                    intent = "general_chat",
                    source = "fake",
                    timestamp = "2026-11-19T00:00:00Z"
                )
            )
        }
    }

    @Test
    fun sendMessageUseCase_invokesRepositoryAndReturnsSuccess() = runBlocking {
        val fakeRepo = FakeChatRepository()
        val useCase = SendMessageUseCase(fakeRepo)

        val result = useCase("U00010001", "¿Cuál es mi promedio?", null)
        assertTrue(result.isSuccess)
        val response = result.getOrNull()!!
        assertEquals("Respuesta simulada para: ¿Cuál es mi promedio?", response.responseText)
    }
}
