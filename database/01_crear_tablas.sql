-- =============================================================================
-- PROYECTO: Chatbot Académico UNAB
-- SCRIPT 01: Creación de Esquema de Base de Datos Relacional (PostgreSQL)
-- DESCRIPCIÓN: Crea las 10 tablas normalizadas (3FN), restricciones, índices
--              y mecanismos de protección de periodos académicos cerrados.
-- =============================================================================

BEGIN;

-- 1. TABLA: programas
CREATE TABLE IF NOT EXISTS programas (
    id_programa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_programa VARCHAR(20) NOT NULL UNIQUE,
    nombre_programa VARCHAR(150) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 2. TABLA: estudiantes
CREATE TABLE IF NOT EXISTS estudiantes (
    id_estudiante BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_estudiante VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(200) NOT NULL,
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    id_programa BIGINT NOT NULL REFERENCES programas(id_programa) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_ingreso DATE NOT NULL,
    estado_estudiante VARCHAR(30) NOT NULL DEFAULT 'ACTIVO'
        CHECK (estado_estudiante IN ('ACTIVO', 'INACTIVO', 'GRADUADO', 'SUSPENDIDO'))
);

-- 3. TABLA: planes_estudio
CREATE TABLE IF NOT EXISTS planes_estudio (
    id_plan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa BIGINT NOT NULL REFERENCES programas(id_programa) ON DELETE RESTRICT ON UPDATE CASCADE,
    version_plan VARCHAR(20) NOT NULL,
    nombre_plan VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_programa_version_plan UNIQUE (id_programa, version_plan)
);

-- 4. TABLA: estudiante_plan_estudio (NUEVA - Asignación y cambio de pensum)
CREATE TABLE IF NOT EXISTS estudiante_plan_estudio (
    id_estudiante_plan BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante BIGINT NOT NULL REFERENCES estudiantes(id_estudiante) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_plan BIGINT NOT NULL REFERENCES planes_estudio(id_plan) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE NULL,
    estado_asignacion VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
        CHECK (estado_asignacion IN ('ACTIVO', 'INACTIVO')),
    CONSTRAINT chk_fecha_fin_plan CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_asignacion)
);

-- 5. TABLA: materias
CREATE TABLE IF NOT EXISTS materias (
    id_materia BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_materia VARCHAR(20) NOT NULL UNIQUE,
    nombre_materia VARCHAR(150) NOT NULL,
    creditos INTEGER NOT NULL CHECK (creditos > 0),
    descripcion TEXT NULL
);

-- 6. TABLA: plan_materias (Tabla puente N:M)
CREATE TABLE IF NOT EXISTS plan_materias (
    id_plan BIGINT NOT NULL REFERENCES planes_estudio(id_plan) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_materia BIGINT NOT NULL REFERENCES materias(id_materia) ON DELETE RESTRICT ON UPDATE CASCADE,
    semestre_sugerido INTEGER NOT NULL CHECK (semestre_sugerido >= 1 AND semestre_sugerido <= 12),
    PRIMARY KEY (id_plan, id_materia)
);

-- 7. TABLA: prerrequisitos (N:M recursivo con clasificación)
CREATE TABLE IF NOT EXISTS prerrequisitos (
    id_plan BIGINT NOT NULL REFERENCES planes_estudio(id_plan) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_materia BIGINT NOT NULL REFERENCES materias(id_materia) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_materia_requisito BIGINT NOT NULL REFERENCES materias(id_materia) ON DELETE RESTRICT ON UPDATE CASCADE,
    tipo_requisito VARCHAR(20) NOT NULL DEFAULT 'PRERREQUISITO'
        CHECK (tipo_requisito IN ('PRERREQUISITO', 'CORREQUISITO')),
    PRIMARY KEY (id_plan, id_materia, id_materia_requisito),
    CONSTRAINT chk_materia_no_autorequisito CHECK (id_materia <> id_materia_requisito)
);

-- 8. TABLA: politicas_academicas
CREATE TABLE IF NOT EXISTS politicas_academicas (
    id_politica BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa BIGINT NULL REFERENCES programas(id_programa) ON DELETE RESTRICT ON UPDATE CASCADE,
    nombre_politica VARCHAR(100) NOT NULL,
    nota_minima_aprobatoria NUMERIC(3,2) NOT NULL DEFAULT 3.00,
    nota_minima_permitida NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    nota_maxima_permitida NUMERIC(3,2) NOT NULL DEFAULT 5.00,
    fecha_inicio_vigencia DATE NOT NULL,
    fecha_fin_vigencia DATE NULL,
    CONSTRAINT chk_rango_notas CHECK (
        nota_minima_permitida >= 0.00 AND
        nota_maxima_permitida <= 5.00 AND
        nota_minima_aprobatoria >= nota_minima_permitida AND
        nota_minima_aprobatoria <= nota_maxima_permitida
    ),
    CONSTRAINT chk_vigencia_politica CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia)
);

-- 9. TABLA: periodos_academicos
CREATE TABLE IF NOT EXISTS periodos_academicos (
    id_periodo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_periodo VARCHAR(20) NOT NULL UNIQUE,
    anio INTEGER NOT NULL CHECK (anio >= 2000 AND anio <= 2100),
    periodo VARCHAR(10) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    cerrado BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_fechas_periodo CHECK (fecha_fin >= fecha_inicio)
);

-- 10. TABLA: historial_academico
CREATE TABLE IF NOT EXISTS historial_academico (
    id_historial BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante BIGINT NOT NULL REFERENCES estudiantes(id_estudiante) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_materia BIGINT NOT NULL REFERENCES materias(id_materia) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_periodo BIGINT NOT NULL REFERENCES periodos_academicos(id_periodo) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_politica BIGINT NULL REFERENCES politicas_academicas(id_politica) ON DELETE RESTRICT ON UPDATE CASCADE,
    id_estudiante_plan BIGINT NULL REFERENCES estudiante_plan_estudio(id_estudiante_plan) ON DELETE RESTRICT ON UPDATE CASCADE,
    semestre_cursado INTEGER NOT NULL CHECK (semestre_cursado >= 1 AND semestre_cursado <= 14),
    numero_intento INTEGER NOT NULL DEFAULT 1 CHECK (numero_intento >= 1),
    nota_final NUMERIC(3,2) NULL,
    estado_materia VARCHAR(20) NOT NULL DEFAULT 'EN_CURSO'
        CHECK (estado_materia IN ('APROBADA', 'REPROBADA', 'EN_CURSO', 'CANCELADA')),
    CONSTRAINT uq_estudiante_materia_periodo_intento UNIQUE (id_estudiante, id_materia, id_periodo, numero_intento),
    CONSTRAINT chk_nota_valida CHECK (
        nota_final IS NULL OR (nota_final >= 0.00 AND nota_final <= 5.00)
    ),
    CONSTRAINT chk_nota_estado_coherencia CHECK (
        (estado_materia = 'EN_CURSO' AND nota_final IS NULL) OR
        (estado_materia = 'CANCELADA') OR
        (estado_materia IN ('APROBADA', 'REPROBADA') AND nota_final IS NOT NULL)
    )
);

-- =============================================================================
-- ÍNDICES DE RENDIMIENTO PARA CONSULTAS DEL CHATBOT
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_historial_estudiante ON historial_academico(id_estudiante);
CREATE INDEX IF NOT EXISTS idx_historial_materia ON historial_academico(id_materia);
CREATE INDEX IF NOT EXISTS idx_historial_periodo ON historial_academico(id_periodo);
CREATE INDEX IF NOT EXISTS idx_estudiante_plan_estudiante ON estudiante_plan_estudio(id_estudiante, estado_asignacion);
CREATE INDEX IF NOT EXISTS idx_plan_materias_plan ON plan_materias(id_plan, semestre_sugerido);
CREATE INDEX IF NOT EXISTS idx_prerrequisitos_materia ON prerrequisitos(id_plan, id_materia);

-- =============================================================================
-- FUNCIÓN Y TRIGGER PARA PROTECCIÓN DE PERIODOS CERRADOS
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_proteger_periodo_cerrado()
RETURNS TRIGGER AS $$
DECLARE
    v_cerrado BOOLEAN;
BEGIN
    SELECT cerrado INTO v_cerrado
    FROM periodos_academicos
    WHERE id_periodo = OLD.id_periodo;

    IF v_cerrado = TRUE THEN
        RAISE EXCEPTION 'Operación denegada: El periodo académico (ID: %) se encuentra CERRADO y su historial es inmutable.', OLD.id_periodo;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_proteger_historial_cerrado ON historial_academico;
CREATE TRIGGER trg_proteger_historial_cerrado
BEFORE UPDATE OR DELETE ON historial_academico
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_periodo_cerrado();

COMMIT;
