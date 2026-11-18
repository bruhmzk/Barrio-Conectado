-- V004__vistas.sql
-- Vistas útiles para consultas frecuentes
-- Ejecutar: psql -d barrio_conectado -f V004__vistas.sql
-- Requiere: V001, V002, V003

-- ============================================================
-- VISTA: Reporte completo para listados (vecino y admin)
-- ============================================================
CREATE OR REPLACE VIEW v_reportes_completo AS
SELECT
    r.id,
    r.numero_seguimiento,
    r.usuario_id,
    u.nombre AS vecino_nombre,
    u.email AS vecino_email,
    r.categoria_id,
    c.nombre AS categoria_nombre,
    c.prioridad_base AS categoria_prioridad_base,
    c.icono AS categoria_icono,
    c.color_hex AS categoria_color,
    r.departamento_id,
    d.nombre AS departamento_nombre,
    r.descripcion,
    r.estado,
    r.prioridad,
    ST_X(r.ubicacion::geometry) AS longitud,
    ST_Y(r.ubicacion::geometry) AS latitud,
    r.referencia_ubicacion,
    r.creado_en,
    r.actualizado_en,
    r.completado_en,
    r.descartado_en,
    -- Último cambio de estado
    ce.timestamp AS ultima_actualizacion_estado,
    ce.nota AS ultima_nota,
    ce.usuario_id AS ultimo_usuario_cambio,
    ue.nombre AS ultimo_usuario_nombre,
    -- Conteo fotos
    COUNT(f.id) AS total_fotos,
    -- Asignación actual (la más reciente)
    a.usuario_id AS admin_asignado_id,
    a.confirmada AS asignacion_confirmada,
    a.confirmada_en,
    aa.nombre AS admin_asignado_nombre
FROM reportes r
JOIN usuarios u ON u.id = r.usuario_id
JOIN categorias c ON c.id = r.categoria_id
JOIN departamentos d ON d.id = r.departamento_id
LEFT JOIN LATERAL (
    SELECT * FROM cambios_estado
    WHERE reporte_id = r.id
    ORDER BY timestamp DESC LIMIT 1
) ce ON true
LEFT JOIN usuarios ue ON ue.id = ce.usuario_id
LEFT JOIN fotografias f ON f.reporte_id = r.id
LEFT JOIN LATERAL (
    SELECT * FROM asignaciones
    WHERE reporte_id = r.id
    ORDER BY creado_en DESC LIMIT 1
) a ON true
LEFT JOIN usuarios aa ON aa.id = a.usuario_id
GROUP BY r.id, u.nombre, u.email, c.nombre, c.prioridad_base, c.icono, c.color_hex,
         d.nombre, ce.timestamp, ce.nota, ce.usuario_id, ue.nombre,
         a.usuario_id, a.confirmada, a.confirmada_en, aa.nombre;

COMMENT ON VIEW v_reportes_completo IS 'Vista completa de reportes con joins para listados vecino/admin';

-- ============================================================
-- VISTA: Estadísticas para dashboard admin
-- ============================================================
CREATE OR REPLACE VIEW v_estadisticas_dashboard AS
SELECT
    COUNT(*) FILTER (WHERE estado = 'Ingresado') AS ingresados,
    COUNT(*) FILTER (WHERE estado = 'EnRevisión') AS en_revision,
    COUNT(*) FILTER (WHERE estado = 'Completado') AS completados,
    COUNT(*) FILTER (WHERE estado = 'Descartado') AS descartados,
    COUNT(*) FILTER (WHERE prioridad = 'Alta') AS prioridad_alta,
    COUNT(*) FILTER (WHERE prioridad = 'Media') AS prioridad_media,
    COUNT(*) FILTER (WHERE prioridad = 'Baja') AS prioridad_baja,
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '24 hours') AS ultimas_24h,
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '7 days') AS ultimos_7d,
    COUNT(*) FILTER (WHERE creado_en >= now() - INTERVAL '30 days') AS ultimos_30d,
    AVG(EXTRACT(EPOCH FROM (completado_en - creado_en))/3600)
        FILTER (WHERE estado = 'Completado' AND completado_en IS NOT NULL) AS horas_promedio_resolucion
FROM reportes;

COMMENT ON VIEW v_estadisticas_dashboard IS 'KPIs agregados para panel de administrador';

-- ============================================================
-- VISTA: Reportes geoespaciales para mapa (clustering)
-- ============================================================
CREATE OR REPLACE VIEW v_reportes_mapa AS
SELECT
    r.id,
    r.numero_seguimiento,
    r.categoria_id,
    c.nombre AS categoria_nombre,
    c.icono AS categoria_icono,
    c.color_hex AS categoria_color,
    r.estado,
    r.prioridad,
    ST_AsGeoJSON(r.ubicacion)::json AS geojson,
    r.referencia_ubicacion,
    r.creado_en
FROM reportes r
JOIN categorias c ON c.id = r.categoria_id
WHERE r.estado IN ('Ingresado', 'EnRevisión');

COMMENT ON VIEW v_reportes_mapa IS 'Reportes activos como GeoJSON para visualización en mapa';

-- ============================================================
-- VISTA: Historial de estados de un reporte (para detalle)
-- ============================================================
CREATE OR REPLACE VIEW v_historial_reporte AS
SELECT
    ce.id,
    ce.reporte_id,
    ce.estado_anterior,
    ce.estado_nuevo,
    ce.nota,
    ce.usuario_id,
    u.nombre AS usuario_nombre,
    u.rol AS usuario_rol,
    ce.timestamp,
    ce.ip_origen
FROM cambios_estado ce
JOIN usuarios u ON u.id = ce.usuario_id
ORDER BY ce.reporte_id, ce.timestamp;

COMMENT ON VIEW v_historial_reporte IS 'Historial completo de cambios de estado con info del usuario';

-- ============================================================
-- VISTA: Notificaciones pendientes de envío (para worker)
-- ============================================================
CREATE OR REPLACE VIEW v_notificaciones_pendientes AS
SELECT
    n.id,
    n.reporte_id,
    n.destinatario_id,
    u.email,
    u.nombre AS destinatario_nombre,
    n.tipo,
    n.plantilla,
    n.asunto,
    n.cuerpo,
    n.reintentos,
    n.max_reintentos,
    n.proximo_reintento,
    n.creado_en
FROM notificaciones n
JOIN usuarios u ON u.id = n.destinatario_id
WHERE n.estado = 'Pendiente'
  AND (n.proximo_reintento IS NULL OR n.proximo_reintento <= now())
ORDER BY n.creado_en;

COMMENT ON VIEW v_notificaciones_pendientes IS 'Cola de notificaciones listas para ser procesadas por worker';

-- ============================================================
-- VISTA: Asignaciones pendientes de confirmación
-- ============================================================
CREATE OR REPLACE VIEW v_asignaciones_pendientes AS
SELECT
    a.id,
    a.reporte_id,
    r.numero_seguimiento,
    r.categoria_id,
    c.nombre AS categoria_nombre,
    r.prioridad,
    r.estado,
    a.departamento_id,
    d.nombre AS departamento_nombre,
    a.usuario_id,
    u.nombre AS admin_nombre,
    u.email AS admin_email,
    a.creado_en
FROM asignaciones a
JOIN reportes r ON r.id = a.reporte_id
JOIN categorias c ON c.id = r.categoria_id
JOIN departamentos d ON d.id = a.departamento_id
LEFT JOIN usuarios u ON u.id = a.usuario_id
WHERE a.confirmada = false
ORDER BY a.creado_en;

COMMENT ON VIEW v_asignaciones_pendientes IS 'Asignaciones sin confirmar por el admin destinatario';

-- ============================================================
-- VISTA: Reporte con fotos (para detalle completo)
-- ============================================================
CREATE OR REPLACE VIEW v_reporte_con_fotos AS
SELECT
    r.*,
    json_agg(
        json_build_object(
            'id', f.id,
            'url', f.url,
            'tipo_mime', f.tipo_mime,
            'tamano_bytes', f.tamano_bytes,
            'ancho', f.ancho,
            'alto', f.alto,
            'orden', f.orden
        ) ORDER BY f.orden
    ) AS fotos
FROM reportes r
LEFT JOIN fotografias f ON f.reporte_id = r.id
GROUP BY r.id;

COMMENT ON VIEW v_reporte_con_fotos IS 'Reporte con array JSON de fotos ordenadas';