package com.example.chatbot

import android.os.Bundle
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.example.chatbot.ui.home.HomeViewModel
import kotlinx.coroutines.launch

/**
 * Actividad principal de la aplicación.
 * Observa el [HomeViewModel] utilizando StateFlow de forma inmutable y respetando el ciclo de vida.
 */
class MainActivity : AppCompatActivity() {

    private val viewModel: HomeViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val tvWelcome = findViewById<TextView>(R.id.tvWelcome)
        val tvStatus = findViewById<TextView>(R.id.tvStatus)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    tvWelcome.text = state.welcomeMessage
                    tvStatus.text = state.statusMessage
                }
            }
        }
    }
}
