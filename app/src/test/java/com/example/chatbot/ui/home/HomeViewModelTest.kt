package com.example.chatbot.ui.home

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

/**
 * Prueba unitaria local para verificar la correcta inicialización y emisión del estado en [HomeViewModel].
 */
class HomeViewModelTest {

    @Test
    fun homeViewModel_initialState_emitsWelcomeAndStatusMessages() {
        val viewModel = HomeViewModel()
        val state = viewModel.uiState.value

        assertEquals("¡Bienvenido al Chatbot de Apoyo Académico UNAB!", state.welcomeMessage)
        assertEquals("Sistema en desarrollo inicial (MVVM + Clean Architecture activo)", state.statusMessage)
        assertFalse(state.isLoading)
    }
}
