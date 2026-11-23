CREATE TABLE departamentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE
);

CREATE TABLE categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    urgencia_base TEXT NOT NULL CHECK (urgencia_base IN ('alta', 'media', 'baja')),
    departamento_id INTEGER NOT NULL REFERENCES departamentos(id)
);

CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    medio_contacto TEXT,
    rol TEXT NOT NULL DEFAULT 'vecino' CHECK (rol IN ('vecino', 'administrador'))
);

CREATE TABLE reportes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero_seguimiento TEXT NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    fecha_hora_registro TEXT NOT NULL,
    estado TEXT NOT NULL DEFAULT 'Recibido'
        CHECK (estado IN ('Recibido', 'En revisión', 'Completado', 'Descartado')),
    prioridad TEXT NOT NULL CHECK (prioridad IN ('Alta', 'Media', 'Baja')),
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    categoria_id INTEGER NOT NULL REFERENCES categorias(id)
);

CREATE TABLE ubicaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL UNIQUE REFERENCES reportes(id) ON DELETE CASCADE,
    latitud REAL NOT NULL,
    longitud REAL NOT NULL,
    referencia TEXT
);

CREATE TABLE fotografias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    archivo_imagen TEXT NOT NULL
);

CREATE TABLE asignaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    departamento_id INTEGER NOT NULL REFERENCES departamentos(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    fecha_hora TEXT NOT NULL
);
