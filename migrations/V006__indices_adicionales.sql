-- V006__indices_adicionales.sql
-- Índices adicionales de performance y consultas específicas
-- Ejecutar: psql -d barrio_conectado -f V006__indices_adicionales.sql
-- Requiere: V001-V005

-- ============================================================
-- ÍNDICES PARA CONSULTAS GEOESPACIALES AVANZADAS
-- ============================================================

-- Índice para clustering DBSCAN (eps en metros)
-- Usado en v_reportes_mapa y consultas de proximidad
CREATE INDEX idx_reportes_ubicacion_cluster ON reportes USING GIST (ubicacion)
    WITH (fillfactor = 90)
WHERE estado IN ('Ingresado', 'EnRevisión');

-- Índice parcial para reportes recientes (últimos 90 días) - heatmap
CREATE INDEX idx_reportes_recientes_geo ON reportes USING GIST (ubicacion)
WHERE creado_en >= now() - INTERVAL '90 days' AND estado IN ('Ingresado', 'EnRevisión');

-- ============================================================
-- ÍNDICES COMPUESTOS PARA FILTROS ADMIN COMUNES
-- ============================================================

-- Filtro: estado + prioridad + categoría (más selectivo primero)
CREATE INDEX idx_reportes_est_prio_cat ON reportes(estado, prioridad, categoria_id)
WHERE estado IN ('Ingresado', 'EnRevisión');

-- Filtro: departamento + estado + prioridad (para panel por departamento)
CREATE INDEX idx_reportes_depto_est_prio ON reportes(departamento_id, estado, prioridad, creado_en DESC)
WHERE estado IN ('Ingresado', 'EnRevisión');

-- Filtro: vecino + estado (para "mis reportes")
CREATE INDEX idx_reportes_usuario_estado ON reportes(usuario_id, estado, creado_en DESC);

-- ============================================================
-- ÍNDICES PARA NOTIFICACIONES (WORKER PERFORMANCE)
-- ============================================================

-- Cola de envío: estado + próximo_reintento + tipo (prioridad Push)
CREATE INDEX idx_notif_cola_envio ON notificaciones(estado, proximo_reintento, tipo)
WHERE estado = 'Pendiente'
ORDER BY
    CASE tipo WHEN 'Push' THEN 1 WHEN 'SMS' THEN 2 ELSE 3 END,
    proximo_reintento NULLS FIRST;

-- Notificaciones por reporte (para mostrar en detalle)
CREATE INDEX idx_notif_reporte_tipo ON notificaciones(reporte_id, tipo, creado_en DESC);

-- ============================================================
-- ÍNDICES PARA AUDITORÍA Y SEGURIDAD
-- ============================================================

-- Login fallidos por IP (detección fuerza bruta)
CREATE INDEX idx_audit_login_fallidos_ip ON auditoria_login(ip, creado_en DESC)
WHERE NOT exitoso;

-- Login por usuario (historial)
CREATE INDEX idx_audit_login_usuario ON auditoria_login(usuario_id, creado_en DESC);

-- Refresh tokens por expiración (limpieza)
CREATE INDEX idx_refresh_tokens_limpieza ON refresh_tokens(expira_en, revocado)
WHERE revocado = false;

-- ============================================================
-- ÍNDICES PARA ASIGNACIONES
-- ============================================================

-- Asignaciones por admin sin confirmar
CREATE INDEX idx_asig_admin_sin_confirmar ON asignaciones(usuario_id, confirmada, creado_en)
WHERE confirmada = false;

-- Reasignaciones (historial completo por reporte)
CREATE INDEX idx_asig_reporte_historial ON asignaciones(reporte_id, creado_en DESC);

-- ============================================================
-- ÍNDICES PARA FOTOGRAFÍAS
-- ============================================================

-- Fotos por reporte ordenadas
CREATE INDEX idx_fotos_reporte_orden ON fotografias(reporte_id, orden);

-- ============================================================
-- ESTADÍSTICAS DE TABLAS (para planner)
-- ============================================================

-- Actualizar estadísticas tras crear índices
ANALYZE reportes;
ANALYZE notificaciones;
ANALYZE usuarios;
ANALYZE categorias;
ANALYZE departamentos;
ANALYZE asignaciones;
ANALYZE cambios_estado;
ANALYZE fotografias;
ANALYZE refresh_tokens;
ANALYZE auditoria_login;

-- ============================================================
-- COMENTARIOS DE MANTENIMIENTO
-- ============================================================

-- REINDEX CONCURRENTLY mensual (ventana baja):
-- REINDEX CONCURRENTLY INDEX idx_reportes_ubicacion_gist;
-- REINDEX CONCURRENTLY INDEX idx_reportes_ubicacion_cluster;
-- REINDEX CONCURRENTLY INDEX idx_notif_cola_envio;

-- pg_stat_clear_snapshot() diario via cron para stats frescas