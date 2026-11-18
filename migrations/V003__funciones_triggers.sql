-- V003__funciones_triggers.sql
-- Funciones de negocio, triggers y validaciones
-- Ejecutar: psql -d barrio_conectado -f V003__funciones_triggers.sql
-- Requiere: V001, V002

-- ============================================================
-- FUNCIÓN: Generar número de seguimiento único (REP-YYYY-NNNNNN)
-- ============================================================
CREATE OR REPLACE FUNCTION generar_numero_seguimiento()
RETURNS VARCHAR(30) LANGUAGE plpgsql AS $$
DECLARE
    seq_num INTEGER;
    year_part VARCHAR(4) := TO_CHAR(now(), 'YYYY');
    result VARCHAR(30);
BEGIN
    LOOP
        SELECT COALESCE(MAX(CAST(SUBSTRING(numero_seguimiento FROM 'REP-\d{4}-(\d{6})') AS INTEGER)), 0) + 1
        INTO seq_num
        FROM reportes
        WHERE numero_seguimiento LIKE 'REP-' || year_part || '-%';

        result := 'REP-' || year_part || '-' || LPAD(seq_num::TEXT, 6, '0');

        IF NOT EXISTS (SELECT 1 FROM reportes WHERE numero_seguimiento = result) THEN
            RETURN result;
        END IF;
    END LOOP;
END $$;

COMMENT ON FUNCTION generar_numero_seguimiento IS 'Genera número de seguimiento único formato REP-YYYY-NNNNNN';

-- ============================================================
-- TRIGGER: Asignar valores por defecto al INSERT en reportes
-- ============================================================
CREATE OR REPLACE FUNCTION trg_reportes_before_insert()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_prioridad prioridad_enum;
    v_departamento_id UUID;
BEGIN
    -- Número de seguimiento
    NEW.numero_seguimiento := generar_numero_seguimiento();

    -- Prioridad base desde categoría
    SELECT prioridad_base INTO v_prioridad FROM categorias WHERE id = NEW.categoria_id;
    NEW.prioridad := v_prioridad;

    -- Departamento principal desde categoria_departamento
    SELECT departamento_id INTO v_departamento_id
    FROM categoria_departamento
    WHERE categoria_id = NEW.categoria_id AND es_principal = true
    LIMIT 1;
    NEW.departamento_id := v_departamento_id;

    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_bi
BEFORE INSERT ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_reportes_before_insert();

-- ============================================================
-- TRIGGER: Registrar cambio de estado automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION trg_reportes_estado_change()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        INSERT INTO cambios_estado (reporte_id, estado_anterior, estado_nuevo, usuario_id, nota)
        VALUES (NEW.id, OLD.estado, NEW.estado,
                COALESCE(NULLIF(current_setting('app.current_user_id', true), '')::UUID, NEW.usuario_id),
                NULL);

        -- Timestamps de cierre
        IF NEW.estado = 'Completado' THEN
            NEW.completado_en := now();
        ELSIF NEW.estado = 'Descartado' THEN
            NEW.descartado_en := now();
        END IF;
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_estado
BEFORE UPDATE OF estado ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_reportes_estado_change();

-- ============================================================
-- FUNCIÓN: Validar transición de estado (EST-01)
-- ============================================================
CREATE OR REPLACE FUNCTION validar_transicion_estado(
    p_estado_actual reporte_estado_enum,
    p_estado_nuevo reporte_estado_enum,
    p_nota TEXT
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
BEGIN
    -- Transiciones permitidas según EST-01
    IF p_estado_actual = 'Ingresado' AND p_estado_nuevo IN ('EnRevisión', 'Descartado') THEN
        RETURN p_estado_nuevo = 'EnRevisión' OR (p_nota IS NOT NULL AND p_nota <> '');
    ELSIF p_estado_actual = 'EnRevisión' AND p_estado_nuevo IN ('Completado', 'Descartado') THEN
        RETURN p_nota IS NOT NULL AND p_nota <> '';
    END IF;
    RETURN FALSE;
END $$;

COMMENT ON FUNCTION validar_transicion_estado IS 'Valida transiciones EST-01: Ingresado->EnRevisión/Descartado; EnRevisión->Completado/Descartado (requiere nota)';

-- ============================================================
-- TRIGGER: Validar transición en UPDATE (nota via SET LOCAL)
-- ============================================================
CREATE OR REPLACE FUNCTION trg_validar_transicion()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_nota TEXT;
BEGIN
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        v_nota := current_setting('app.estado_nota', true);

        IF NOT validar_transicion_estado(OLD.estado, NEW.estado, v_nota) THEN
            RAISE EXCEPTION 'Transición inválida: % -> % (nota requerida: %)',
                OLD.estado, NEW.estado,
                CASE WHEN NEW.estado IN ('Completado', 'Descartado') THEN 'SÍ' ELSE 'NO' END;
        END IF;
    END IF
    RETURN NEW;
END $$;

CREATE TRIGGER trg_validar_transicion
BEFORE UPDATE OF estado ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_validar_transicion();

-- ============================================================
-- FUNCIÓN: Crear asignación inicial automática
-- ============================================================
CREATE OR REPLACE FUNCTION trg_reportes_asignacion_inicial()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO asignaciones (reporte_id, departamento_id, asignado_por, confirmada)
        VALUES (NEW.id, NEW.departamento_id, NEW.usuario_id, false);
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_asignacion_inicial
AFTER INSERT ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_reportes_asignacion_inicial();

-- ============================================================
-- FUNCIÓN: Crear notificación automática en cambio de estado
-- ============================================================
CREATE OR REPLACE FUNCTION trg_reportes_notificacion_estado()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_plantilla VARCHAR(100);
    v_asunto VARCHAR(200);
    v_cuerpo TEXT;
    v_vecino_id UUID;
BEGIN
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
        -- Obtener vecino dueño del reporte
        SELECT usuario_id INTO v_vecino_id FROM reportes WHERE id = NEW.id;

        -- Determinar plantilla y contenido según nuevo estado
        CASE NEW.estado
            WHEN 'EnRevisión' THEN
                v_plantilla := 'estado_cambiado';
                v_asunto := 'Tu reporte ' || NEW.numero_seguimiento || ' está en revisión';
                v_cuerpo := 'El municipio ha comenzado a revisar tu reporte #' || NEW.numero_seguimiento || '. Estado actual: En revisión.';
            WHEN 'Completado' THEN
                v_plantilla := 'completado';
                v_asunto := 'Tu reporte ' || NEW.numero_seguimiento || ' ha sido completado';
                v_cuerpo := 'Tu reporte #' || NEW.numero_seguimiento || ' fue resuelto. Nota: ' || COALESCE(current_setting('app.estado_nota', true), 'Sin detalles');
            WHEN 'Descartado' THEN
                v_plantilla := 'descartado';
                v_asunto := 'Tu reporte ' || NEW.numero_seguimiento || ' fue descartado';
                v_cuerpo := 'Tu reporte #' || NEW.numero_seguimiento || ' fue descartado. Motivo: ' || COALESCE(current_setting('app.estado_nota', true), 'Sin motivo especificado');
            ELSE
                RETURN NEW;
        END CASE;

        -- Insertar notificación Push (primaria)
        INSERT INTO notificaciones (reporte_id, destinatario_id, tipo, plantilla, asunto, cuerpo, estado, max_reintentos, proximo_reintento)
        VALUES (NEW.id, v_vecino_id, 'Push', v_plantilla, v_asunto, v_cuerpo, 'Pendiente', 3, now() + INTERVAL '1 minute');

        -- Insertar notificación Email (fallback)
        INSERT INTO notificaciones (reporte_id, destinatario_id, tipo, plantilla, asunto, cuerpo, estado, max_reintentos, proximo_reintento)
        VALUES (NEW.id, v_vecino_id, 'Email', v_plantilla, v_asunto, v_cuerpo, 'Pendiente', 3, now() + INTERVAL '5 minutes');
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_notificacion_estado
AFTER UPDATE OF estado ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_reportes_notificacion_estado();

-- ============================================================
-- FUNCIÓN: Notificación al crear reporte (confirmación)
-- ============================================================
CREATE OR REPLACE FUNCTION trg_reportes_notificacion_creacion()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO notificaciones (reporte_id, destinatario_id, tipo, plantilla, asunto, cuerpo, estado, max_reintentos, proximo_reintento)
        VALUES (NEW.id, NEW.usuario_id, 'Push', 'reporte_creado',
                'Reporte ' || NEW.numero_seguimiento || ' recibido',
                'Tu reporte #' || NEW.numero_seguimiento || ' ha sido registrado correctamente. Estado: Ingresado.',
                'Pendiente', 3, now() + INTERVAL '1 minute');

        INSERT INTO notificaciones (reporte_id, destinatario_id, tipo, plantilla, asunto, cuerpo, estado, max_reintentos, proximo_reintento)
        VALUES (NEW.id, NEW.usuario_id, 'Email', 'reporte_creado',
                'Reporte ' || NEW.numero_seguimiento || ' recibido',
                'Tu reporte #' || NEW.numero_seguimiento || ' ha sido registrado correctamente. Estado: Ingresado.',
                'Pendiente', 3, now() + INTERVAL '5 minutes');
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_notificacion_creacion
AFTER INSERT ON reportes
FOR EACH ROW EXECUTE FUNCTION trg_reportes_notificacion_creacion();

-- ============================================================
-- FUNCIÓN: Limpiar refresh tokens expirados (job periódico)
-- ============================================================
CREATE OR REPLACE FUNCTION limpiar_refresh_tokens_expirados()
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    DELETE FROM refresh_tokens
    WHERE expira_en < now() - INTERVAL '7 days'
       OR (revocado AND revocado_en < now() - INTERVAL '30 days');
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END $$;

-- ============================================================
-- FUNCIÓN: Procesar cola de notificaciones pendientes
-- ============================================================
CREATE OR REPLACE FUNCTION procesar_notificaciones_pendientes(p_limite INTEGER DEFAULT 100)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    v_notif RECORD;
    v_procesadas INTEGER := 0;
BEGIN
    FOR v_notif IN
        SELECT id, tipo, proveedor_id, reintentos, max_reintentos
        FROM notificaciones
        WHERE estado = 'Pendiente'
          AND (proximo_reintento IS NULL OR proximo_reintento <= now())
        ORDER BY creado_en
        LIMIT p_limite
    LOOP
        -- Aquí se llamaría al worker externo (via NOTIFY/LISTEN o tabla de outbox)
        -- Solo actualizamos el contador y próximo reintento
        UPDATE notificaciones
        SET reintentos = reintentos + 1,
            proximo_reintento = CASE
                WHEN reintentos + 1 >= max_reintentos THEN NULL
                ELSE now() + (INTERVAL '1 minute' * POWER(5, reintentos)) -- 1m, 5m, 25m...
            END,
            estado = CASE
                WHEN reintentos + 1 >= max_reintentos THEN 'Fallida'
                ELSE 'Pendiente'
            END
        WHERE id = v_notif.id;

        v_procesadas := v_procesadas + 1;
    END LOOP;
    RETURN v_procesadas;
END $$;

COMMENT ON FUNCTION procesar_notificaciones_pendientes IS 'Worker llama a esta función; envía realmente via FCM/Email/SMS y actualiza estado final';

-- ============================================================
-- FUNCIÓN: Estadísticas de reporte para dashboard
-- ============================================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_dashboard()
RETURNS TABLE (
    ingresados BIGINT,
    en_revision BIGINT,
    completados BIGINT,
    descartados BIGINT,
    prioridad_alta BIGINT,
    prioridad_media BIGINT,
    prioridad_baja BIGINT,
    ultimas_24h BIGINT,
    ultimos_7d BIGINT,
    ultimos_30d BIGINT,
    horas_promedio_resolucion NUMERIC
) LANGUAGE sql AS $$
SELECT
    COUNT(*) FILTER (WHERE estado = 'Ingresado'),
    COUNT(*) FILTER (WHERE estado = 'EnRevisión'),
    COUNT(*) FILTER (WHERE estado = 'Completado'),
    COUNT(*) FILTER (WHERE estado = 'Descartado'),
    COUNT(*) FILTER (WHERE prioridad = 'Alta'),
    COUNT(*) FILTER (WHERE prioridad = 'Media'),
    COUNT(*) FILTER (WHERE prioridad = 'Baja'),
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '24 hours'),
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '7 days'),
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '30 days'),
    AVG(EXTRACT(EPOCH FROM (completado_en - creado_en))/3600)
        FILTER (WHERE estado = 'Completado' AND completado_en IS NOT NULL)
FROM reportes;
$$;