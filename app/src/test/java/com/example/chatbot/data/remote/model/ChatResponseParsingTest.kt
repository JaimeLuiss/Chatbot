package com.example.chatbot.data.remote.model

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ChatResponseParsingTest {

    @Test
    fun chatResponseDto_toDomain_parsesResponseFieldCorrectly() {
        val dto = ChatResponseDto(
            success = true,
            conversationId = 101L,
            studentCode = "U00010001",
            response = "Tienes 5 materias aprobadas.",
            output = null,
            message = null,
            intent = "approved_subjects",
            source = "postgresql",
            timestamp = "2026-11-19T00:00:00Z"
        )
        val domain = dto.toDomain()

        assertTrue(domain.success)
        assertEquals(101L, domain.conversationId)
        assertEquals("U00010001", domain.studentCode)
        assertEquals("Tienes 5 materias aprobadas.", domain.responseText)
        assertEquals("approved_subjects", domain.intent)
    }

    @Test
    fun chatResponseDto_toDomain_fallsBackToOutputOrMessage() {
        val dtoOutput = ChatResponseDto(
            output = "Respuesta desde output LLM."
        )
        assertEquals("Respuesta desde output LLM.", dtoOutput.toDomain().responseText)

        val dtoMessage = ChatResponseDto(
            message = "Respuesta desde message field."
        )
        assertEquals("Respuesta desde message field.", dtoMessage.toDomain().responseText)
    }
}
