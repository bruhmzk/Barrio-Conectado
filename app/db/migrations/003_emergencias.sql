-- HU-09: soporte de reportes de emergencia.
-- SQLite no permite modificar restricciones CHECK existentes, así que las
-- tablas afectadas se reconstruyen copiando sus datos.

PRAGMA foreign_keys = OFF;

ALTER TABLE categorias ADD COLUMN es_emergencia INTEGER NOT NULL DEFAULT 0;

CREATE TABLE usuarios_nueva (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    medio_contacto TEXT,
    rol TEXT NOT NULL DEFAULT 'vecino'
        CHECK (rol IN ('vecino', 'administrador', 'gestor_emergencias'))
);

INSERT INTO usuarios_nueva (id, nombre, medio_contacto, rol)
SELECT id, nombre, medio_contacto, rol FROM usuarios;

DROP TABLE usuarios;
ALTER TABLE usuarios_nueva RENAME TO usuarios;

CREATE TABLE reportes_nueva (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero_seguimiento TEXT NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    fecha_hora_registro TEXT NOT NULL,
    estado TEXT NOT NULL DEFAULT 'Recibido'
        CHECK (estado IN (
            'Recibido', 'En revisión', 'Completado', 'Descartado',
            'En atención por Gestor', 'Derivado a Autoridad', 'Resuelto'
        )),
    prioridad TEXT NOT NULL
        CHECK (prioridad IN ('Máxima', 'Alta', 'Media', 'Baja')),
    es_emergencia INTEGER NOT NULL DEFAULT 0 CHECK (es_emergencia IN (0, 1)),
    aviso_pendiente INTEGER NOT NULL DEFAULT 0 CHECK (aviso_pendiente IN (0, 1)),
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    categoria_id INTEGER NOT NULL REFERENCES categorias(id)
);

INSERT INTO reportes_nueva (
    id, numero_seguimiento, descripcion, fecha_hora_registro, estado,
    prioridad, es_emergencia, aviso_pendiente, usuario_id, categoria_id
)
SELECT id, numero_seguimiento, descripcion, fecha_hora_registro, estado,
       prioridad, 0, 0, usuario_id, categoria_id
FROM reportes;

DROP TABLE reportes;
ALTER TABLE reportes_nueva RENAME TO reportes;

CREATE TABLE cambios_estado_nueva (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    fecha_hora TEXT NOT NULL,
    estado_anterior TEXT NOT NULL,
    estado_nuevo TEXT NOT NULL
        CHECK (estado_nuevo IN (
            'Recibido', 'En revisión', 'Completado', 'Descartado',
            'En atención por Gestor', 'Derivado a Autoridad', 'Resuelto'
        )),
    nota TEXT,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id)
);

INSERT INTO cambios_estado_nueva (
    id, reporte_id, fecha_hora, estado_anterior, estado_nuevo, nota, usuario_id
)
SELECT id, reporte_id, fecha_hora, estado_anterior, estado_nuevo, nota, usuario_id
FROM cambios_estado;

DROP TABLE cambios_estado;
ALTER TABLE cambios_estado_nueva RENAME TO cambios_estado;

CREATE INDEX idx_cambios_estado_reporte_fecha
    ON cambios_estado(reporte_id, fecha_hora);

PRAGMA foreign_keys = ON;
