package com.example.chatbot.ui.chat

import com.example.chatbot.domain.model.ChatResponse
import com.example.chatbot.domain.repository.ChatRepository
import com.example.chatbot.domain.usecase.SendMessageUseCase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class ChatViewModelTest {

    private class MockRepository : ChatRepository {
        override suspend fun sendMessage(
            studentCode: String,
            message: String,
            conversationId: Long?
        ): Result<ChatResponse> {
            return Result.success(
                ChatResponse(
                    success = true,
                    conversationId = 1L,
                    studentCode = studentCode,
                    responseText = "Respuesta mock",
                    intent = "test",
                    source = "test",
                    timestamp = ""
                )
            )
        }
    }

    @Test
    fun chatViewModel_initStudent_setsStudentCodeAndInitialMessage() {
        val viewModel = ChatViewModel(SendMessageUseCase(MockRepository()))
        viewModel.initStudent("U00010002")

        val state = viewModel.uiState.value
        assertEquals("U00010002", state.studentCode)
        assertEquals(1, state.messages.size)
        assertNotNull(state.messages.first().text)
    }
}
