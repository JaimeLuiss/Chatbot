# Guía de Despliegue de Infraestructura Local (Docker, PostgreSQL y n8n)

## 1. Descripción General
Esta guía describe el procedimiento para desplegar localmente la infraestructura completa de backend y base de datos para el proyecto **Chatbot Académico UNAB** utilizando **Docker Compose**.

La arquitectura local consta de dos contenedores:
- **`chatbot_db`**: Servidor de base de datos PostgreSQL 16 (Alpine) en el puerto `5432` con volumen persistente `postgres_data`.
- **`chatbot_n8n`**: Servidor de automatización y orquestación n8n en el puerto `5678` con volumen persistente `n8n_data`.

---

## 2. Requisitos Previos
1. **Docker Desktop** instalado y en ejecución (motor Linux / WSL2).
2. Archivo `.env` en la raíz del proyecto configurado a partir de `.env.example`.

---

## 3. Inicio del Stack de Infraestructura

Desde la raíz del proyecto (`C:\Users\jaime\AndroidStudioProjects\Chatbot`), ejecute:

```bash
# Iniciar servicios en segundo plano
docker compose up -d
```

### Verificación del Estado de Contenedores:
```bash
docker ps
```

**Salida esperada**:
- `chatbot_db`: Estado `Up (healthy)`, puerto `0.0.0.0:5432->5432/tcp`.
- `chatbot_n8n`: Estado `Up`, puerto `0.0.0.0:5678->5678/tcp`.

---

## 4. Ejecución e Inicialización de la Base de Datos

Ejecute en secuencia los 5 scripts SQL sobre el contenedor PostgreSQL `chatbot_db`:

### En Windows PowerShell:
```powershell
Get-Content database/01_crear_tablas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
Get-Content database/02_datos_sinteticos.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
Get-Content database/03_consultas_academicas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
Get-Content database/04_pruebas_integridad.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
Get-Content database/05_memoria_chat.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
```

---

## 5. Acceso a n8n y Configuración Inicial

1. Abrir el navegador web e ingresar a `http://localhost:5678`.
2. Al iniciar por primera vez, completar el registro básico de usuario administrador local.
3. El panel de control permitirá crear flujos de trabajo (Workflows) con nodos HTTP Webhook e integraciones a PostgreSQL en `chatbot_db:5432` o `localhost:5432`.

---

## 6. Comprobación y Verificación de Tablas

Para verificar la creación de las 12 tablas (10 académicas + 2 de memoria de chat):

```powershell
docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab -c "\dt"
```

---

## 7. Detención y Reinicio de Infraestructura

- **Detener servicios manteniendo volúmenes persistentes**:
  ```bash
  docker compose stop
  ```
- **Volver a iniciar servicios**:
  ```bash
  docker compose start
  ```
- **NO ejecute `docker compose down -v`** para evitar la pérdida no deseada de los datos de prueba y la configuración de n8n.
