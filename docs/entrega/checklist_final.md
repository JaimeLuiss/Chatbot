# Lista de Comprobación de Entrega Final - Chatbot Académico UNAB

| Componente | Requisito | Estado | Verificación |
| :--- | :--- | :---: | :--- |
| **Android App** | Kotlin 2.2.10 + MVVM + Clean Architecture | ✅ OK | `assembleDebug` exitoso |
| **Android App** | UI XML + Material Design 3 (Colores UNAB) | ✅ OK | Pantallas de Selección, Dashboard y Chat |
| **Android App** | Cliente HTTP Retrofit + Gson + OkHttp | ✅ OK | Integración con `NetworkConfig.kt` |
| **Android App** | Observación de UI State mediante StateFlow & repeatOnLifecycle | ✅ OK | Pruebas unitarias de ViewModel |
| **Base de Datos**| PostgreSQL 16 Alpine con 12 tablas en 3FN | ✅ OK | Ejecutado en Docker `chatbot_db` |
| **Base de Datos**| Trigger de protección de periodos cerrados | ✅ OK | `trg_proteger_historial_cerrado` verificado |
| **Base de Datos**| Memoria persistente de conversaciones y mensajes | ✅ OK | Script `05_memoria_chat.sql` verificado |
| **Infraestructura**| Docker Compose (`docker-compose.yml`) | ✅ OK | Servicios `db` y `n8n` activos |
| **n8n Workflow**| Webhook `POST /webhook/chatbot-academico` | ✅ OK | `n8n/workflows/chatbot_academico.json` |
| **n8n Workflow**| Guardrails de seguridad y filtrado de prompts | ✅ OK | Probado y validado en workflow |
| **n8n Workflow**| Consultas SQL parametrizadas a PostgreSQL | ✅ OK | 15 consultas académicas verificadas |
| **Pruebas** | Pruebas unitarias en Android (`testDebugUnitTest`) | ✅ OK | 6 pasadas, 0 fallidas |
| **Seguridad** | `.env` en `.gitignore` y cero llaves de API expuestas | ✅ OK | Auditado y verificado |
| **Documentación**| `README.md`, Guía Instalación, Guion Demostración | ✅ OK | Creados en `docs/` |
| **Git / GitHub**| Commits modulares y push a `origin/main` como `JaimeLuiss` | ✅ OK | Repositorio al día |
