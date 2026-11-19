package com.example.chatbot.ui.dashboard

import android.content.Intent
import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.chatbot.R
import com.example.chatbot.data.repository.StudentRepositoryImpl
import com.example.chatbot.ui.chat.ChatActivity
import com.example.chatbot.ui.student.StudentSelectionActivity
import com.google.android.material.button.MaterialButton
import kotlinx.coroutines.runBlocking

class DashboardActivity : AppCompatActivity() {

    private var studentCode: String = "U00010001"
    private val studentRepo = StudentRepositoryImpl()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)

        studentCode = intent.getStringExtra(StudentSelectionActivity.EXTRA_STUDENT_CODE) ?: "U00010001"

        val tvName = findViewById<TextView>(R.id.tvStudentName)
        val tvCode = findViewById<TextView>(R.id.tvStudentCode)
        val tvProgram = findViewById<TextView>(R.id.tvStudentProgram)
        val tvProfile = findViewById<TextView>(R.id.tvStudentProfile)

        val student = runBlocking { studentRepo.getStudentByCode(studentCode) }
        student?.let {
            tvName.text = it.name
            tvCode.text = "Código: ${it.code}"
            tvProgram.text = it.program
            tvProfile.text = "${it.profileType} (${it.planVersion})"
        }

        findViewById<MaterialButton>(R.id.btnOpenChat).setOnClickListener {
            openChat(null)
        }

        findViewById<MaterialButton>(R.id.btnQueryApproved).setOnClickListener {
            openChat("¿Qué materias he aprobado?")
        }

        findViewById<MaterialButton>(R.id.btnQueryFailed).setOnClickListener {
            openChat("¿Qué materias he reprobada?")
        }

        findViewById<MaterialButton>(R.id.btnQueryPending).setOnClickListener {
            openChat("¿Qué materias tengo pendientes?")
        }

        findViewById<MaterialButton>(R.id.btnQueryGPA).setOnClickListener {
            openChat("¿Cuál es mi promedio acumulado?")
        }

        findViewById<MaterialButton>(R.id.btnChangeStudent).setOnClickListener {
            finish()
        }
    }

    private fun openChat(initialQuestion: String?) {
        val intent = Intent(this, ChatActivity::class.java).apply {
            putExtra(StudentSelectionActivity.EXTRA_STUDENT_CODE, studentCode)
            initialQuestion?.let { putExtra(ChatActivity.EXTRA_INITIAL_QUESTION, it) }
        }
        startActivity(intent)
    }
}
