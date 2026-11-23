CREATE TABLE cambios_estado (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    fecha_hora TEXT NOT NULL,
    estado_anterior TEXT NOT NULL,
    estado_nuevo TEXT NOT NULL CHECK (estado_nuevo IN ('Recibido', 'En revisión', 'Completado', 'Descartado')),
    nota TEXT,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id)
);

CREATE INDEX idx_cambios_estado_reporte_fecha ON cambios_estado(reporte_id, fecha_hora);
