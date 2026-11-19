-- =============================================================================
-- PROYECTO: Chatbot Académico UNAB
-- SCRIPT 03: Consultas Académicas SQL para Integración con el Chatbot (n8n / Backend)
-- DESCRIPCIÓN: 15 Consultas SQL parametrizadas para alimentar las respuestas
--              de la IA a las inquietudes del estudiante.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CONSULTA 1: Información general del estudiante
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    e.id_estudiante,
    e.codigo_estudiante,
    e.nombre_completo,
    e.correo_institucional,
    p.nombre_programa,
    pe.version_plan,
    pe.nombre_plan,
    e.fecha_ingreso,
    e.estado_estudiante
FROM estudiantes e
JOIN programas p ON e.id_programa = p.id_programa
JOIN estudiante_plan_estudio epe ON epe.id_estudiante = e.id_estudiante AND epe.estado_asignacion = 'ACTIVO'
JOIN planes_estudio pe ON epe.id_plan = pe.id_plan
WHERE e.codigo_estudiante = 'U00010001';

-- -----------------------------------------------------------------------------
-- CONSULTA 2: Materias aprobadas
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    m.codigo_materia,
    m.nombre_materia,
    m.creditos,
    h.nota_final,
    h.semestre_cursado,
    pa.codigo_periodo
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
JOIN periodos_academicos pa ON h.id_periodo = pa.id_periodo
WHERE e.codigo_estudiante = 'U00010001'
  AND h.estado_materia = 'APROBADA'
ORDER BY h.semestre_cursado ASC, m.nombre_materia ASC;

-- -----------------------------------------------------------------------------
-- CONSULTA 3: Materias reprobadas
-- Parámetro: :codigo_estudiante = 'U00010002'
-- -----------------------------------------------------------------------------
SELECT
    m.codigo_materia,
    m.nombre_materia,
    h.numero_intento,
    h.nota_final,
    pa.codigo_periodo
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
JOIN periodos_academicos pa ON h.id_periodo = pa.id_periodo
WHERE e.codigo_estudiante = 'U00010002'
  AND h.estado_materia = 'REPROBADA'
ORDER BY m.nombre_materia ASC, h.numero_intento ASC;

-- -----------------------------------------------------------------------------
-- CONSULTA 4: Materias pendientes (frente al plan activo)
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
WITH plan_activo AS (
    SELECT epe.id_plan, epe.id_estudiante
    FROM estudiante_plan_estudio epe
    JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010001' AND epe.estado_asignacion = 'ACTIVO'
    LIMIT 1
),
materias_aprobadas AS (
    SELECT DISTINCT id_materia
    FROM historial_academico h
    JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010001' AND h.estado_materia = 'APROBADA'
)
SELECT
    pm.semestre_sugerido,
    m.codigo_materia,
    m.nombre_materia,
    m.creditos
FROM plan_materias pm
JOIN plan_activo pa ON pm.id_plan = pa.id_plan
JOIN materias m ON pm.id_materia = m.id_materia
WHERE pm.id_materia NOT IN (SELECT id_materia FROM materias_aprobadas)
ORDER BY pm.semestre_sugerido ASC, m.nombre_materia ASC;

-- -----------------------------------------------------------------------------
-- CONSULTA 5: Materias actualmente en curso
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    m.codigo_materia,
    m.nombre_materia,
    m.creditos,
    h.semestre_cursado,
    pa.codigo_periodo
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
JOIN periodos_academicos pa ON h.id_periodo = pa.id_periodo
WHERE e.codigo_estudiante = 'U00010001'
  AND h.estado_materia = 'EN_CURSO';

-- -----------------------------------------------------------------------------
-- CONSULTA 6: Historial completo de calificaciones
-- Parámetro: :codigo_estudiante = 'U00010002'
-- -----------------------------------------------------------------------------
SELECT
    pa.codigo_periodo,
    m.codigo_materia,
    m.nombre_materia,
    h.numero_intento,
    h.nota_final,
    h.estado_materia
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
JOIN periodos_academicos pa ON h.id_periodo = pa.id_periodo
WHERE e.codigo_estudiante = 'U00010002'
ORDER BY pa.fecha_inicio ASC, m.nombre_materia ASC;

-- -----------------------------------------------------------------------------
-- CONSULTA 7: Número de intentos por materia
-- Parámetro: :codigo_estudiante = 'U00010002'
-- -----------------------------------------------------------------------------
SELECT
    m.codigo_materia,
    m.nombre_materia,
    COUNT(*) AS total_intentos,
    MAX(h.nota_final) AS nota_maxima_obtenida
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
WHERE e.codigo_estudiante = 'U00010002'
GROUP BY m.id_materia, m.codigo_materia, m.nombre_materia
ORDER BY total_intentos DESC;

-- -----------------------------------------------------------------------------
-- CONSULTA 8: Créditos aprobados
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    e.codigo_estudiante,
    e.nombre_completo,
    COALESCE(SUM(m.creditos), 0) AS total_creditos_aprobados
FROM estudiantes e
LEFT JOIN historial_academico h ON e.id_estudiante = h.id_estudiante AND h.estado_materia = 'APROBADA'
LEFT JOIN materias m ON h.id_materia = m.id_materia
WHERE e.codigo_estudiante = 'U00010001'
GROUP BY e.id_estudiante, e.codigo_estudiante, e.nombre_completo;

-- -----------------------------------------------------------------------------
-- CONSULTA 9: Créditos pendientes
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
WITH plan_activo AS (
    SELECT epe.id_plan, epe.id_estudiante
    FROM estudiante_plan_estudio epe
    JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010001' AND epe.estado_asignacion = 'ACTIVO'
    LIMIT 1
),
materias_aprobadas AS (
    SELECT DISTINCT id_materia
    FROM historial_academico h
    JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010001' AND h.estado_materia = 'APROBADA'
)
SELECT
    COALESCE(SUM(m.creditos), 0) AS total_creditos_pendientes
FROM plan_materias pm
JOIN plan_activo pa ON pm.id_plan = pa.id_plan
JOIN materias m ON pm.id_materia = m.id_materia
WHERE pm.id_materia NOT IN (SELECT id_materia FROM materias_aprobadas);

-- -----------------------------------------------------------------------------
-- CONSULTA 10: Porcentaje de avance del plan de estudios
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
WITH plan_activo AS (
    SELECT epe.id_plan, epe.id_estudiante
    FROM estudiante_plan_estudio epe
    JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010001' AND epe.estado_asignacion = 'ACTIVO'
    LIMIT 1
),
creditos_totales AS (
    SELECT SUM(m.creditos) AS total_plan
    FROM plan_materias pm
    JOIN plan_activo pa ON pm.id_plan = pa.id_plan
    JOIN materias m ON pm.id_materia = m.id_materia
),
creditos_aprobados AS (
    SELECT SUM(m.creditos) AS total_aprobado
    FROM historial_academico h
    JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
    JOIN materias m ON h.id_materia = m.id_materia
    WHERE e.codigo_estudiante = 'U00010001' AND h.estado_materia = 'APROBADA'
)
SELECT
    ca.total_aprobado,
    ct.total_plan,
    ROUND((ca.total_aprobado::NUMERIC / NULLIF(ct.total_plan, 0)) * 100, 2) AS porcentaje_avance
FROM creditos_aprobados ca, creditos_totales ct;

-- -----------------------------------------------------------------------------
-- CONSULTA 11: Promedio académico acumulado (GPA)
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    e.codigo_estudiante,
    e.nombre_completo,
    ROUND(SUM(h.nota_final * m.creditos) / NULLIF(SUM(m.creditos), 0), 2) AS promedio_acumulado
FROM estudiantes e
JOIN historial_academico h ON e.id_estudiante = h.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
WHERE e.codigo_estudiante = 'U00010001'
  AND h.nota_final IS NOT NULL
GROUP BY e.id_estudiante, e.codigo_estudiante, e.nombre_completo;

-- -----------------------------------------------------------------------------
-- CONSULTA 12: Prerrequisitos pendientes para una asignatura específica
-- Parámetro: :codigo_estudiante = 'U00010002', :codigo_materia = 'DEMO-BD-201'
-- -----------------------------------------------------------------------------
WITH plan_activo AS (
    SELECT epe.id_plan
    FROM estudiante_plan_estudio epe
    JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010002' AND epe.estado_asignacion = 'ACTIVO'
    LIMIT 1
),
materias_aprobadas AS (
    SELECT DISTINCT id_materia
    FROM historial_academico h
    JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010002' AND h.estado_materia = 'APROBADA'
)
SELECT
    m_req.codigo_materia AS requisito_codigo,
    m_req.nombre_materia AS requisito_nombre,
    pr.tipo_requisito
FROM prerrequisitos pr
JOIN plan_activo pa ON pr.id_plan = pa.id_plan
JOIN materias m_destino ON pr.id_materia = m_destino.id_materia
JOIN materias m_req ON pr.id_materia_requisito = m_req.id_materia
WHERE m_destino.codigo_materia = 'DEMO-BD-201'
  AND pr.id_materia_requisito NOT IN (SELECT id_materia FROM materias_aprobadas);

-- -----------------------------------------------------------------------------
-- CONSULTA 13: Materias disponibles para proyectar matricula
-- Parámetro: :codigo_estudiante = 'U00010002'
-- -----------------------------------------------------------------------------
WITH plan_activo AS (
    SELECT epe.id_plan
    FROM estudiante_plan_estudio epe
    JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010002' AND epe.estado_asignacion = 'ACTIVO'
    LIMIT 1
),
materias_aprobadas AS (
    SELECT DISTINCT id_materia
    FROM historial_academico h
    JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
    WHERE e.codigo_estudiante = 'U00010002' AND h.estado_materia = 'APROBADA'
),
materias_pendientes AS (
    SELECT pm.id_materia, pm.semestre_sugerido
    FROM plan_materias pm
    JOIN plan_activo pa ON pm.id_plan = pa.id_plan
    WHERE pm.id_materia NOT IN (SELECT id_materia FROM materias_aprobadas)
)
SELECT m.codigo_materia, m.nombre_materia, mp.semestre_sugerido, m.creditos
FROM materias_pendientes mp
JOIN materias m ON mp.id_materia = m.id_materia
WHERE NOT EXISTS (
    SELECT 1
    FROM prerrequisitos pr
    JOIN plan_activo pa ON pr.id_plan = pa.id_plan
    WHERE pr.id_materia = mp.id_materia
      AND pr.tipo_requisito = 'PRERREQUISITO'
      AND pr.id_materia_requisito NOT IN (SELECT id_materia FROM materias_aprobadas)
);

-- -----------------------------------------------------------------------------
-- CONSULTA 14: Plan de estudios asignado al estudiante
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    e.codigo_estudiante,
    e.nombre_completo,
    pe.version_plan,
    pe.nombre_plan,
    epe.fecha_asignacion,
    epe.estado_asignacion
FROM estudiante_plan_estudio epe
JOIN estudiantes e ON epe.id_estudiante = e.id_estudiante
JOIN planes_estudio pe ON epe.id_plan = pe.id_plan
WHERE e.codigo_estudiante = 'U00010001'
ORDER BY epe.fecha_asignacion DESC;

-- -----------------------------------------------------------------------------
-- CONSULTA 15: Evolución académica por periodo lectivo
-- Parámetro: :codigo_estudiante = 'U00010001'
-- -----------------------------------------------------------------------------
SELECT
    pa.codigo_periodo,
    COUNT(h.id_materia) AS materias_cursadas,
    SUM(m.creditos) FILTER (WHERE h.estado_materia = 'APROBADA') AS creditos_aprobados_periodo,
    ROUND(SUM(h.nota_final * m.creditos) / NULLIF(SUM(m.creditos), 0), 2) AS promedio_periodo
FROM historial_academico h
JOIN estudiantes e ON h.id_estudiante = e.id_estudiante
JOIN materias m ON h.id_materia = m.id_materia
JOIN periodos_academicos pa ON h.id_periodo = pa.id_periodo
WHERE e.codigo_estudiante = 'U00010001'
  AND h.nota_final IS NOT NULL
GROUP BY pa.id_periodo, pa.codigo_periodo, pa.fecha_inicio
ORDER BY pa.fecha_inicio ASC;
