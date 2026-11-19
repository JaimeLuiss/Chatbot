-- =============================================================================
-- PROYECTO: Chatbot Académico UNAB
-- SCRIPT 02: Inserción de Datos Sintéticos y Ficticios de Demostración (DML)
-- DESCRIPCIÓN: Poblamiento controlado de datos demostrativos para probar
--              consultas del chatbot, prerrequisitos, correquisitos y notas.
-- =============================================================================

BEGIN;

-- 1. PROGRAMAS (DEMO)
INSERT INTO programas (codigo_programa, nombre_programa, activo)
VALUES ('ING-SIST-DEMO', 'Ingeniería de Sistemas (Programa Demostración UNAB)', TRUE)
ON CONFLICT (codigo_programa) DO NOTHING;

-- 2. PLANES DE ESTUDIO (DEMO)
INSERT INTO planes_estudio (id_programa, version_plan, nombre_plan, activo)
SELECT p.id_programa, 'PENSUM-DEMO-2020', 'Pensum Transición Demostración 2020', FALSE
FROM programas p WHERE p.codigo_programa = 'ING-SIST-DEMO'
ON CONFLICT (id_programa, version_plan) DO NOTHING;

INSERT INTO planes_estudio (id_programa, version_plan, nombre_plan, activo)
SELECT p.id_programa, 'PENSUM-DEMO-2024', 'Pensum Vigente Demostración 2024', TRUE
FROM programas p WHERE p.codigo_programa = 'ING-SIST-DEMO'
ON CONFLICT (id_programa, version_plan) DO NOTHING;

-- 3. MATERIAS (DEMO)
INSERT INTO materias (codigo_materia, nombre_materia, creditos, descripcion) VALUES
('DEMO-MAT-101', 'Cálculo I (DEMO)', 3, 'Fundamentos de cálculo diferencial e integral'),
('DEMO-MAT-102', 'Cálculo II (DEMO)', 3, 'Integrales múltiples y series'),
('DEMO-PRG-101', 'Programación I (DEMO)', 3, 'Lógica de programación y algoritmos en Kotlin/Java'),
('DEMO-PRG-102', 'Programación II (DEMO)', 3, 'Estructuras de datos y POO'),
('DEMO-BD-201', 'Bases de Datos (DEMO)', 3, 'Modelado relacional, SQL y PostgreSQL'),
('DEMO-IA-301', 'Inteligencia Artificial (DEMO)', 3, 'Machine Learning y Prompt Engineering'),
('DEMO-FIS-101', 'Física I (DEMO)', 3, 'Mecánica clásica y vectores')
ON CONFLICT (codigo_materia) DO NOTHING;

-- 4. PLAN_MATERIAS (Asignación de materias al PENSUM-DEMO-2024)
INSERT INTO plan_materias (id_plan, id_materia, semestre_sugerido)
SELECT pe.id_plan, m.id_materia,
    CASE m.codigo_materia
        WHEN 'DEMO-MAT-101' THEN 1
        WHEN 'DEMO-PRG-101' THEN 1
        WHEN 'DEMO-MAT-102' THEN 2
        WHEN 'DEMO-PRG-102' THEN 2
        WHEN 'DEMO-FIS-101' THEN 2
        WHEN 'DEMO-BD-201' THEN 3
        WHEN 'DEMO-IA-301' THEN 4
    END
FROM planes_estudio pe
CROSS JOIN materias m
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT (id_plan, id_materia) DO NOTHING;

-- 5. PRERREQUISITOS Y CORREQUISITOS (DEMO)
-- Cálculo II requiere Cálculo I (PRERREQUISITO)
INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
SELECT pe.id_plan, m_destino.id_materia, m_req.id_materia, 'PRERREQUISITO'
FROM planes_estudio pe
JOIN materias m_destino ON m_destino.codigo_materia = 'DEMO-MAT-102'
JOIN materias m_req ON m_req.codigo_materia = 'DEMO-MAT-101'
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- Programación II requiere Programación I (PRERREQUISITO)
INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
SELECT pe.id_plan, m_destino.id_materia, m_req.id_materia, 'PRERREQUISITO'
FROM planes_estudio pe
JOIN materias m_destino ON m_destino.codigo_materia = 'DEMO-PRG-102'
JOIN materias m_req ON m_req.codigo_materia = 'DEMO-PRG-101'
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- Bases de Datos requiere Programación II (PRERREQUISITO)
INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
SELECT pe.id_plan, m_destino.id_materia, m_req.id_materia, 'PRERREQUISITO'
FROM planes_estudio pe
JOIN materias m_destino ON m_destino.codigo_materia = 'DEMO-BD-201'
JOIN materias m_req ON m_req.codigo_materia = 'DEMO-PRG-102'
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- Inteligencia Artificial requiere Bases de Datos (PRERREQUISITO)
INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
SELECT pe.id_plan, m_destino.id_materia, m_req.id_materia, 'PRERREQUISITO'
FROM planes_estudio pe
JOIN materias m_destino ON m_destino.codigo_materia = 'DEMO-IA-301'
JOIN materias m_req ON m_req.codigo_materia = 'DEMO-BD-201'
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- Física I exige Cálculo I de forma conjunta (CORREQUISITO)
INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
SELECT pe.id_plan, m_destino.id_materia, m_req.id_materia, 'CORREQUISITO'
FROM planes_estudio pe
JOIN materias m_destino ON m_destino.codigo_materia = 'DEMO-FIS-101'
JOIN materias m_req ON m_req.codigo_materia = 'DEMO-MAT-101'
WHERE pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- 6. POLÍTICAS ACADÉMICAS (DEMO)
INSERT INTO politicas_academicas (nombre_politica, nota_minima_aprobatoria, nota_minima_permitida, nota_maxima_permitida, fecha_inicio_vigencia)
VALUES ('Reglamento Académico Demostración UNAB', 3.00, 0.00, 5.00, '2024-01-01')
ON CONFLICT DO NOTHING;

-- 7. PERIODOS ACADÉMICOS (DEMO)
INSERT INTO periodos_academicos (codigo_periodo, anio, periodo, fecha_inicio, fecha_fin, cerrado) VALUES
('2024-1', 2024, '1', '2024-02-01', '2024-06-15', TRUE),
('2024-2', 2024, '2', '2024-08-01', '2024-11-30', TRUE),
('2025-1', 2025, '1', '2025-02-01', '2025-06-15', TRUE),
('2025-2', 2025, '2', '2025-08-01', '2025-11-30', TRUE),
('2026-1', 2026, '1', '2026-02-01', '2026-06-15', FALSE)
ON CONFLICT (codigo_periodo) DO NOTHING;

-- 8. ESTUDIANTES (DEMO)
INSERT INTO estudiantes (codigo_estudiante, nombre_completo, correo_institucional, id_programa, fecha_ingreso, estado_estudiante)
SELECT 'U00010001', 'Carlos Gómez (Estudiante DEMO Aprobado)', 'cgomez_demo@unab.edu.co', p.id_programa, '2024-02-01', 'ACTIVO'
FROM programas p WHERE p.codigo_programa = 'ING-SIST-DEMO'
ON CONFLICT (codigo_estudiante) DO NOTHING;

INSERT INTO estudiantes (codigo_estudiante, nombre_completo, correo_institucional, id_programa, fecha_ingreso, estado_estudiante)
SELECT 'U00010002', 'María Rodríguez (Estudiante DEMO Repetidora)', 'mrodriguez_demo@unab.edu.co', p.id_programa, '2024-02-01', 'ACTIVO'
FROM programas p WHERE p.codigo_programa = 'ING-SIST-DEMO'
ON CONFLICT (codigo_estudiante) DO NOTHING;

INSERT INTO estudiantes (codigo_estudiante, nombre_completo, correo_institucional, id_programa, fecha_ingreso, estado_estudiante)
SELECT 'U00010003', 'Juan Pérez (Estudiante DEMO Nuevo 2026)', 'jperez_demo@unab.edu.co', p.id_programa, '2026-02-01', 'ACTIVO'
FROM programas p WHERE p.codigo_programa = 'ING-SIST-DEMO'
ON CONFLICT (codigo_estudiante) DO NOTHING;

-- 9. ASIGNACIÓN DE PLANES DE ESTUDIO (DEMO)
INSERT INTO estudiante_plan_estudio (id_estudiante, id_plan, fecha_asignacion, estado_asignacion)
SELECT e.id_estudiante, pe.id_plan, '2024-02-01', 'ACTIVO'
FROM estudiantes e
CROSS JOIN planes_estudio pe
WHERE e.codigo_estudiante IN ('U00010001', 'U00010002') AND pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

INSERT INTO estudiante_plan_estudio (id_estudiante, id_plan, fecha_asignacion, estado_asignacion)
SELECT e.id_estudiante, pe.id_plan, '2026-02-01', 'ACTIVO'
FROM estudiantes e
CROSS JOIN planes_estudio pe
WHERE e.codigo_estudiante = 'U00010003' AND pe.version_plan = 'PENSUM-DEMO-2024'
ON CONFLICT DO NOTHING;

-- 10. HISTORIAL ACADÉMICO (DEMO)

-- ESTUDIANTE 1: Carlos Gómez (Avance normal)
-- Periodo 2024-1:
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 1, 1, 4.50, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-MAT-101' AND p.codigo_periodo = '2024-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 1, 1, 4.20, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-PRG-101' AND p.codigo_periodo = '2024-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2024-2:
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 2, 1, 3.80, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-MAT-102' AND p.codigo_periodo = '2024-2'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 2, 1, 4.00, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-PRG-102' AND p.codigo_periodo = '2024-2'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2025-1:
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 3, 1, 4.60, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-BD-201' AND p.codigo_periodo = '2025-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2026-1 (Materia actualmente EN_CURSO):
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 4, 1, NULL, 'EN_CURSO'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010001' AND m.codigo_materia = 'DEMO-IA-301' AND p.codigo_periodo = '2026-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;


-- ESTUDIANTE 2: María Rodríguez (Materias reprobadas y repetidas)
-- Periodo 2024-1: Reprobó Cálculo I
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 1, 1, 2.20, 'REPROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010002' AND m.codigo_materia = 'DEMO-MAT-101' AND p.codigo_periodo = '2024-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2024-2: Repitió Cálculo I (Intento 2 - Aprobó)
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 2, 2, 3.20, 'APROBADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010002' AND m.codigo_materia = 'DEMO-MAT-101' AND p.codigo_periodo = '2024-2'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2025-1: Cursó Programación I (Canceló)
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 3, 1, NULL, 'CANCELADA'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010002' AND m.codigo_materia = 'DEMO-PRG-101' AND p.codigo_periodo = '2025-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

-- Periodo 2026-1: Cursando Cálculo II (Intento 1 EN_CURSO)
INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, id_politica, id_estudiante_plan, semestre_cursado, numero_intento, nota_final, estado_materia)
SELECT e.id_estudiante, m.id_materia, p.id_periodo, pol.id_politica, ep.id_estudiante_plan, 4, 1, NULL, 'EN_CURSO'
FROM estudiantes e, materias m, periodos_academicos p, politicas_academicas pol, estudiante_plan_estudio ep
WHERE e.codigo_estudiante = 'U00010002' AND m.codigo_materia = 'DEMO-MAT-102' AND p.codigo_periodo = '2026-1'
  AND pol.nombre_politica = 'Reglamento Académico Demostración UNAB' AND ep.id_estudiante = e.id_estudiante AND ep.estado_asignacion = 'ACTIVO'
ON CONFLICT DO NOTHING;

COMMIT;
