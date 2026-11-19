package com.example.chatbot.data.repository

import com.example.chatbot.domain.model.Student
import com.example.chatbot.domain.repository.StudentRepository

class StudentRepositoryImpl : StudentRepository {

    private val demoStudents = listOf(
        Student(
            code = "U00010001",
            name = "Carlos Gómez",
            program = "Ingeniería de Sistemas (UNAB)",
            planVersion = "PENSUM-DEMO-2024",
            status = "ACTIVO",
            profileType = "Estudiante Regular (Aprobado - Promedio 4.22)"
        ),
        Student(
            code = "U00010002",
            name = "María Rodríguez",
            program = "Ingeniería de Sistemas (UNAB)",
            planVersion = "PENSUM-DEMO-2024",
            status = "ACTIVO",
            profileType = "Estudiante con Asignaturas Repetidas y Reprobadas"
        ),
        Student(
            code = "U00010003",
            name = "Juan Pérez",
            program = "Ingeniería de Sistemas (UNAB)",
            planVersion = "PENSUM-DEMO-2024",
            status = "ACTIVO",
            profileType = "Estudiante de Nuevo Ingreso 2026-1"
        )
    )

    override suspend fun getStudents(): List<Student> = demoStudents

    override suspend fun getStudentByCode(code: String): Student? {
        return demoStudents.find { it.code == code }
    }
}
