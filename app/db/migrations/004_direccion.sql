PRAGMA foreign_keys = OFF;

CREATE TABLE ubicaciones_nueva (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL UNIQUE REFERENCES reportes(id) ON DELETE CASCADE,
    direccion TEXT NOT NULL,
    referencia TEXT,
    latitud REAL,
    longitud REAL
);

INSERT INTO ubicaciones_nueva (id, reporte_id, direccion, referencia, latitud, longitud)
SELECT id, reporte_id,
       COALESCE(NULLIF(TRIM(referencia), ''), 'Dirección no indicada'),
       referencia, latitud, longitud
FROM ubicaciones;

DROP TABLE ubicaciones;
ALTER TABLE ubicaciones_nueva RENAME TO ubicaciones;

PRAGMA foreign_keys = ON;
