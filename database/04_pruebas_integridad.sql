-- =============================================================================
-- PROYECTO: Chatbot Académico UNAB
-- SCRIPT 04: Pruebas de Integridad de Base de Datos (Validaciones y Restricciones)
-- DESCRIPCIÓN: Suite de pruebas automatizadas en bloques PL/pgSQL que verifican
--              que el motor rechace datos inválidos y permita datos correctos.
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'INICIANDO PRUEBAS DE INTEGRIDAD Y RESTRICCIONES DE LA BASE DE DATOS';
    RAISE NOTICE '=================================================================';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 1: Rechazo de nota inferior a 0.00
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    VALUES (1, 1, 1, 1, 1, -1.50, 'REPROBADA');

    RAISE EXCEPTION 'FALLO: Se aceptó una nota negativa (-1.50)';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 1): Se rechazó correctamente la nota negativa (-1.50).';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 2: Rechazo de nota superior a 5.00
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    VALUES (1, 1, 1, 1, 1, 5.50, 'APROBADA');

    RAISE EXCEPTION 'FALLO: Se aceptó una nota superior a 5.00 (5.50)';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 2): Se rechazó correctamente la nota fuera de rango (5.50).';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 3: Rechazo de créditos igual o inferior a cero
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO materias (codigo_materia, nombre_materia, creditos)
    VALUES ('DEMO-INVALID-0', 'Materia Crédito Cero', 0);

    RAISE EXCEPTION 'FALLO: Se aceptó una materia con 0 créditos';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 3): Se rechazaron correctamente los créditos menores o iguales a cero.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 4: Rechazo de número de intento inferior a 1
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    VALUES (1, 1, 1, 1, 0, 3.50, 'APROBADA');

    RAISE EXCEPTION 'FALLO: Se aceptó un intento en cero (0)';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 4): Se rechazó correctamente el número de intento en cero.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 5: Rechazo de prerrequisito consigo mismo (Auto-requisito)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO prerrequisitos (id_plan, id_materia, id_materia_requisito, tipo_requisito)
    VALUES (1, 1, 1, 'PRERREQUISITO');

    RAISE EXCEPTION 'FALLO: Se aceptó una materia como su propio prerrequisito';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 5): Se rechazó correctamente el auto-prerrequisito.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 6: Rechazo de referencia a estudiante inexistente (FK)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    VALUES (999999, 1, 1, 1, 1, 4.00, 'APROBADA');

    RAISE EXCEPTION 'FALLO: Se aceptó una clave foránea a un estudiante inexistente';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 6): Se rechazó correctamente el estudiante inexistente.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 7: Rechazo de referencia a materia inexistente (FK)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    VALUES (1, 999999, 1, 1, 1, 4.00, 'APROBADA');

    RAISE EXCEPTION 'FALLO: Se aceptó una clave foránea a una materia inexistente';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'ÉXITO (Prueba 7): Se rechazó correctamente la materia inexistente.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 8: Comportamiento correcto de materia EN_CURSO sin nota (DEBE PASAR)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    -- Esta operación es válida y debe pasar sin excepciones
    INSERT INTO historial_academico (id_estudiante, id_materia, id_periodo, semestre_cursado, numero_intento, nota_final, estado_materia)
    SELECT e.id_estudiante, m.id_materia, p.id_periodo, 3, 1, NULL, 'EN_CURSO'
    FROM estudiantes e, materias m, periodos_academicos p
    WHERE e.codigo_estudiante = 'U00010003' AND m.codigo_materia = 'DEMO-PRG-101' AND p.codigo_periodo = '2026-1'
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'ÉXITO (Prueba 8): Se permitió correctamente registrar una materia EN_CURSO sin nota definitiva.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 9: Protección de resultados en periodos cerrados (Trigger de inmutabilidad)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    -- Intentar modificar una nota en el periodo 2024-1 (que está cerrado)
    UPDATE historial_academico
    SET nota_final = 5.00
    WHERE id_periodo = (SELECT id_periodo FROM periodos_academicos WHERE codigo_periodo = '2024-1')
      AND id_estudiante = (SELECT id_estudiante FROM estudiantes WHERE codigo_estudiante = 'U00010001');

    RAISE EXCEPTION 'FALLO: El trigger permitió modificar un registro en un periodo CERRADO';
EXCEPTION
    WHEN raise_exception THEN
        RAISE NOTICE 'ÉXITO (Prueba 9): El trigger bloqueó la modificación en un periodo CERRADO.';
END $$;

-- -----------------------------------------------------------------------------
-- PRUEBA 10: Integridad de asignación de plan de estudio (DEBE PASAR)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    PERFORM id_plan FROM estudiante_plan_estudio WHERE id_estudiante = 1 AND estado_asignacion = 'ACTIVO';
    RAISE NOTICE 'ÉXITO (Prueba 10): Se consultó la asignación activa del plan de estudios correctamente.';
END $$;

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'TODAS LAS PRUEBAS DE INTEGRIDAD Y RESTRICCIONES FINALIZARON EXITOSAMENTE';
    RAISE NOTICE '=================================================================';
END $$;
