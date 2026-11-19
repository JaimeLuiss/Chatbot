package com.example.chatbot.ui.student

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.chatbot.R
import com.example.chatbot.ui.dashboard.DashboardActivity
import com.google.android.material.card.MaterialCardView

class StudentSelectionActivity : AppCompatActivity() {

    companion object {
        const val EXTRA_STUDENT_CODE = "extra_student_code"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_student_selection)

        findViewById<MaterialCardView>(R.id.cardStudent1).setOnClickListener {
            openDashboard("U00010001")
        }

        findViewById<MaterialCardView>(R.id.cardStudent2).setOnClickListener {
            openDashboard("U00010002")
        }

        findViewById<MaterialCardView>(R.id.cardStudent3).setOnClickListener {
            openDashboard("U00010003")
        }
    }

    private fun openDashboard(studentCode: String) {
        val intent = Intent(this, DashboardActivity::class.java).apply {
            putExtra(EXTRA_STUDENT_CODE, studentCode)
        }
        startActivity(intent)
    }
}
