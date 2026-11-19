package com.example.chatbot.ui.chat

import android.os.Bundle
import android.view.View
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.chatbot.R
import com.example.chatbot.domain.model.Sender
import com.example.chatbot.ui.student.StudentSelectionActivity
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.button.MaterialButton
import com.google.android.material.chip.Chip
import com.google.android.material.progressindicator.LinearProgressIndicator
import kotlinx.coroutines.launch

class ChatActivity : AppCompatActivity() {

    companion object {
        const val EXTRA_INITIAL_QUESTION = "extra_initial_question"
    }

    private val viewModel: ChatViewModel by viewModels()
    private lateinit var adapter: MessageAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chat)

        val studentCode = intent.getStringExtra(StudentSelectionActivity.EXTRA_STUDENT_CODE) ?: "U00010001"
        val initialQuestion = intent.getStringExtra(EXTRA_INITIAL_QUESTION)

        viewModel.initStudent(studentCode)

        setupToolbar()
        setupRecyclerView()
        setupViews()
        observeUiState()

        initialQuestion?.let {
            viewModel.sendMessage(it)
        }
    }

    private fun setupToolbar() {
        val toolbar = findViewById<MaterialToolbar>(R.id.toolbar)
        toolbar.setNavigationOnClickListener { finish() }
    }

    private fun setupRecyclerView() {
        adapter = MessageAdapter()
        val rvMessages = findViewById<RecyclerView>(R.id.rvMessages)
        rvMessages.layoutManager = LinearLayoutManager(this).apply { stackFromEnd = true }
        rvMessages.adapter = adapter
    }

    private fun setupViews() {
        val etInput = findViewById<EditText>(R.id.etMessageInput)
        val btnSend = findViewById<MaterialButton>(R.id.btnSend)
        val btnRetry = findViewById<MaterialButton>(R.id.btnRetry)

        btnSend.setOnClickListener {
            val text = etInput.text.toString()
            if (text.isNotBlank()) {
                viewModel.sendMessage(text)
                etInput.setText("")
            }
        }

        btnRetry.setOnClickListener {
            val lastUserMessage = viewModel.uiState.value.messages.lastOrNull { it.sender == Sender.USER }
            lastUserMessage?.let {
                viewModel.clearError()
                viewModel.sendMessage(it.text)
            }
        }

        findViewById<Chip>(R.id.chipApproved).setOnClickListener {
            viewModel.sendMessage("¿Qué materias he aprobado?")
        }

        findViewById<Chip>(R.id.chipFailed).setOnClickListener {
            viewModel.sendMessage("¿Qué materias he reprobado?")
        }

        findViewById<Chip>(R.id.chipPending).setOnClickListener {
            viewModel.sendMessage("¿Qué materias tengo pendientes?")
        }

        findViewById<Chip>(R.id.chipGPA).setOnClickListener {
            viewModel.sendMessage("¿Cuál es mi promedio acumulado?")
        }
    }

    private fun observeUiState() {
        val tvActiveStudent = findViewById<TextView>(R.id.tvActiveStudentInfo)
        val loadingIndicator = findViewById<LinearProgressIndicator>(R.id.loadingIndicator)
        val layoutError = findViewById<LinearLayout>(R.id.layoutError)
        val tvErrorMessage = findViewById<TextView>(R.id.tvErrorMessage)
        val btnSend = findViewById<MaterialButton>(R.id.btnSend)
        val rvMessages = findViewById<RecyclerView>(R.id.rvMessages)

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { state ->
                    tvActiveStudent.text = "Estudiante activo: ${state.studentCode}"
                    adapter.submitList(state.messages)
                    if (state.messages.isNotEmpty()) {
                        rvMessages.smoothScrollToPosition(state.messages.size - 1)
                    }

                    loadingIndicator.visibility = if (state.isLoading) View.VISIBLE else View.GONE
                    btnSend.isEnabled = !state.isLoading

                    if (state.errorMessage != null) {
                        layoutError.visibility = View.VISIBLE
                        tvErrorMessage.text = state.errorMessage
                    } else {
                        layoutError.visibility = View.GONE
                    }
                }
            }
        }
    }
}
