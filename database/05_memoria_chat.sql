-- =============================================================================
-- PROYECTO: Chatbot Académico UNAB
-- SCRIPT 05: Memoria Persistente de Conversaciones e Historial de Chat
-- DESCRIPCIÓN: Crea las tablas de almacenamiento de conversaciones y mensajes
--              para mantener la memoria contextual entre sesiones del estudiante.
-- =============================================================================

BEGIN;

-- 1. TABLA: conversaciones
CREATE TABLE IF NOT EXISTS conversaciones (
    id_conversacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante BIGINT NOT NULL REFERENCES estudiantes(id_estudiante) ON DELETE RESTRICT ON UPDATE CASCADE,
    titulo_conversacion VARCHAR(200) NOT NULL DEFAULT 'Consulta Académica',
    fecha_inicio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_mensaje TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_conversacion VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
        CHECK (estado_conversacion IN ('ACTIVA', 'ARCHIVADA', 'CERRADA'))
);

-- 2. TABLA: mensajes
CREATE TABLE IF NOT EXISTS mensajes (
    id_mensaje BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_conversacion BIGINT NOT NULL REFERENCES conversaciones(id_conversacion) ON DELETE CASCADE ON UPDATE CASCADE,
    remitente VARCHAR(20) NOT NULL CHECK (remitente IN ('ESTUDIANTE', 'ASISTENTE', 'SISTEMA')),
    contenido_texto TEXT NOT NULL,
    tokens_usados INTEGER NULL CHECK (tokens_usados >= 0),
    fecha_envio TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ÍNDICES DE RENDIMIENTO PARA MEMORIA DE CHAT
CREATE INDEX IF NOT EXISTS idx_conversaciones_estudiante ON conversaciones(id_estudiante, fecha_ultimo_mensaje DESC);
CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion ON mensajes(id_conversacion, fecha_envio ASC);

-- -----------------------------------------------------------------------------
-- INSERCIÓN DE DATOS SINTÉTICOS DE PRUEBA DE CONVERSACIONES
-- -----------------------------------------------------------------------------
INSERT INTO conversaciones (id_estudiante, titulo_conversacion, estado_conversacion)
SELECT id_estudiante, 'Consulta de Materias Pendientes y Prerrequisitos', 'ACTIVA'
FROM estudiantes WHERE codigo_estudiante = 'U00010001'
ON CONFLICT DO NOTHING;

INSERT INTO mensajes (id_conversacion, remitente, contenido_texto, tokens_usados)
SELECT c.id_conversacion, 'ESTUDIANTE', '¿Qué materias tengo pendientes de cursar en mi pensum?', 12
FROM conversaciones c
JOIN estudiantes e ON c.id_estudiante = e.id_estudiante
WHERE e.codigo_estudiante = 'U00010001'
LIMIT 1;

INSERT INTO mensajes (id_conversacion, remitente, contenido_texto, tokens_usados)
SELECT c.id_conversacion, 'ASISTENTE', '¡Hola Carlos! En tu plan PENSUM-DEMO-2024 tienes pendiente cursar Inteligencia Artificial (DEMO) en el cuarto semestre. ¿Deseas verificar sus prerrequisitos?', 45
FROM conversaciones c
JOIN estudiantes e ON c.id_estudiante = e.id_estudiante
WHERE e.codigo_estudiante = 'U00010001'
LIMIT 1;

COMMIT;
