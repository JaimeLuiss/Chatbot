package com.example.chatbot.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.chatbot.data.repository.ChatRepositoryImpl
import com.example.chatbot.domain.model.ChatMessage
import com.example.chatbot.domain.model.Sender
import com.example.chatbot.domain.usecase.SendMessageUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class ChatViewModel(
    private val sendMessageUseCase: SendMessageUseCase = SendMessageUseCase(ChatRepositoryImpl())
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    fun initStudent(studentCode: String) {
        _uiState.update { currentState ->
            currentState.copy(
                studentCode = studentCode,
                messages = listOf(
                    ChatMessage(
                        sender = Sender.ASSISTANT,
                        text = "¡Hola! Soy el Asistente Académico de Ingeniería de Sistemas UNAB. ¿En qué puedo ayudarte hoy?"
                    )
                )
            )
        }
    }

    fun sendMessage(text: String) {
        val trimmed = text.trim()
        if (trimmed.isEmpty() || _uiState.value.isLoading) return

        val userMsg = ChatMessage(sender = Sender.USER, text = trimmed)
        val currentMessages = _uiState.value.messages.toMutableList().apply { add(userMsg) }

        _uiState.update { it.copy(messages = currentMessages, isLoading = true, errorMessage = null) }

        viewModelScope.launch {
            val result = sendMessageUseCase(
                studentCode = _uiState.value.studentCode,
                message = trimmed,
                conversationId = _uiState.value.conversationId
            )

            result.fold(
                onSuccess = { response ->
                    val assistantMsg = ChatMessage(sender = Sender.ASSISTANT, text = response.responseText)
                    val updatedMessages = _uiState.value.messages.toMutableList().apply { add(assistantMsg) }
                    _uiState.update {
                        it.copy(
                            messages = updatedMessages,
                            isLoading = false,
                            conversationId = response.conversationId ?: it.conversationId,
                            errorMessage = null
                        )
                    }
                },
                onFailure = { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            errorMessage = error.localizedMessage ?: "No se pudo conectar con el asistente."
                        )
                    }
                }
            )
        }
    }

    fun clearError() {
        _uiState.update { it.copy(errorMessage = null) }
    }
}
