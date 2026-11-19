# Guía de Instalación, Configuración y Despliegue de PostgreSQL - Chatbot UNAB

## 1. Opciones de Despliegue

### Opción A: Despliegue Automático mediante Docker Compose (Recomendado)
El proyecto cuenta con un entorno contenerizado oficial (`docker-compose.yml`) que inicia el servidor **PostgreSQL 16 Alpine** en el puerto `5432` y el servidor **n8n** en el puerto `5678`.

```bash
docker compose up -d
```

### Opción B: Instalación Nativa en Windows
1. Descargar el instalador oficial de PostgreSQL desde [postgresql.org/download/windows](https://www.postgresql.org/download/windows/).
2. Instalar el servidor PostgreSQL, pgAdmin 4 y psql.
3. Definir la contraseña de administrador y conservar el puerto `5432`.

---

## 2. Orden de Ejecución de los 5 Scripts SQL

Para construir el esquema académico y la memoria de chat completa, ejecute los 5 scripts en el siguiente orden:

```bash
# 1. Creación de tablas académicas, restricciones, índices y triggers
Get-Content database/01_crear_tablas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab

# 2. Inserción de datos sintéticos de demostración
Get-Content database/02_datos_sinteticos.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab

# 3. Consultas académicas para el chatbot
Get-Content database/03_consultas_academicas.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab

# 4. Suite de pruebas de integridad
Get-Content database/04_pruebas_integridad.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab

# 5. Tablas de memoria persistente de conversaciones del chatbot
Get-Content database/05_memoria_chat.sql -Raw | docker exec -i chatbot_db psql -U chatbot_admin -d chatbot_unab
```

---

## 3. Verificación de las 12 Tablas Creadas

Para comprobar las tablas resultantes (10 académicas + 2 de memoria de chat):

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

**Resultado esperado**:
1. `conversaciones`
2. `estudiante_plan_estudio`
3. `estudiantes`
4. `historial_academico`
5. `materias`
6. `mensajes`
7. `periodos_academicos`
8. `plan_materias`
9. `planes_estudio`
10. `politicas_academicas`
11. `prerrequisitos`
12. `programas`

---

## 4. Adaptación y Despliegue en Supabase

El modelo relacional fue diseñado desde su origen para ser 100% compatible con **Supabase**:

1. Crear un proyecto nuevo en [supabase.com](https://supabase.com/).
2. En el **SQL Editor**, ejecutar sucesivamente `01_crear_tablas.sql`, `02_datos_sinteticos.sql` y `05_memoria_chat.sql`.
3. Supabase habilitará las API REST nativas para la comunicación con los workflows de **n8n**.
