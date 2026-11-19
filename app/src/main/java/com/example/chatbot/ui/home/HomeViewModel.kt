package com.example.chatbot.ui.home

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * ViewModel encargado de gestionar el estado de la pantalla principal de la aplicación.
 * Mantiene la separación de responsabilidades expidiendo un [StateFlow] inmutable.
 */
class HomeViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(
        HomeUiState(
            welcomeMessage = "¡Bienvenido al Chatbot de Apoyo Académico UNAB!",
            statusMessage = "Sistema en desarrollo inicial (MVVM + Clean Architecture activo)",
            isLoading = false
        )
    )
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()
}
