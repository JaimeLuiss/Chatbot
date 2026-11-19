package com.example.chatbot.domain.repository

import com.example.chatbot.domain.model.Student

interface StudentRepository {
    suspend fun getStudents(): List<Student>
    suspend fun getStudentByCode(code: String): Student?
}
