package com.example.chatbot.ui.home

/**
 * Estado inmutable de la interfaz de usuario para la pantalla principal (Home).
 *
 * @property welcomeMessage Mensaje principal de bienvenida a los estudiantes de la UNAB.
 * @property statusMessage Indicador de estado actual del desarrollo de la aplicación.
 * @property isLoading Indicador de si se están procesando o cargando datos.
 */
data class HomeUiState(
    val welcomeMessage: String = "",
    val statusMessage: String = "",
    val isLoading: Boolean = false
)
