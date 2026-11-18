-- V002__tablas_principales.sql
-- Tablas principales, índices y constraints
-- Ejecutar: psql -d barrio_conectado -f V002__tablas_principales.sql
-- Requiere: V001__enums.sql, extensiones uuid-ossp, postgis, pgcrypto

-- Extensiones requeridas
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TABLA: usuarios
-- ============================================================
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(30),
    rol usuario_rol_enum NOT NULL DEFAULT 'vecino',
    password_hash TEXT,
    proveedor_oauth VARCHAR(50),
    proveedor_sub VARCHAR(255),
    avatar_url TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    ultimo_login TIMESTAMPTZ,
    CONSTRAINT chk_usuarios_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_proveedor ON usuarios(proveedor_oauth, proveedor_sub);
CREATE INDEX idx_usuarios_activo ON usuarios(activo) WHERE activo;
CREATE INDEX idx_usuarios_creado_en ON usuarios(creado_en DESC);

COMMENT ON TABLE usuarios IS 'Usuarios del sistema: vecinos, administradores y moderadores';
COMMENT ON COLUMN usuarios.proveedor_oauth IS 'Proveedor OAuth: google, microsoft, claveunica, local';
COMMENT ON COLUMN usuarios.proveedor_sub IS 'Subject/ID del proveedor OAuth';
COMMENT ON COLUMN usuarios.password_hash IS 'Hash Argon2id; NULL si solo autenticación OAuth';

-- ============================================================
-- TABLA: categorias
-- ============================================================
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    prioridad_base prioridad_enum NOT NULL DEFAULT 'Media',
    icono VARCHAR(50),
    color_hex VARCHAR(7) CHECK (color_hex ~* '^#[0-9A-Fa-f]{6}$'),
    activo BOOLEAN NOT NULL DEFAULT true,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_categorias_activo ON categorias(activo) WHERE activo;

COMMENT ON TABLE categorias IS 'Catálogo de categorías de problemas (luminaria, microbasural, bache, etc.)';
COMMENT ON COLUMN categorias.prioridad_base IS 'Prioridad por defecto para reportes de esta categoría';
COMMENT ON COLUMN categorias.icono IS 'Nombre de icono Material Design / Lucide';
COMMENT ON COLUMN categorias.color_hex IS 'Color hex #RRGGBB para UI';

-- ============================================================
-- TABLA: departamentos
-- ============================================================
CREATE TABLE departamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(120) NOT NULL UNIQUE,
    descripcion TEXT,
    email_contacto VARCHAR(255),
    telefono VARCHAR(30),
    activo BOOLEAN NOT NULL DEFAULT true,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_departamentos_activo ON departamentos(activo) WHERE activo;

COMMENT ON TABLE departamentos IS 'Departamentos municipales responsables de atender categorías';

-- ============================================================
-- TABLA: categoria_departamento (N:M con principal)
-- ============================================================
CREATE TABLE categoria_departamento (
    categoria_id UUID NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    departamento_id UUID NOT NULL REFERENCES departamentos(id) ON DELETE RESTRICT,
    es_principal BOOLEAN NOT NULL DEFAULT true,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (categoria_id, departamento_id)
);

CREATE INDEX idx_cat_dept_principal ON categoria_departamento(categoria_id) WHERE es_principal;

COMMENT ON TABLE categoria_departamento IS 'Relación categoría-departamento; es_principal=true indica responsable por defecto';

-- ============================================================
-- TABLA: reportes (CORE)
-- ============================================================
CREATE TABLE reportes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_seguimiento VARCHAR(30) NOT NULL UNIQUE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    categoria_id UUID NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    departamento_id UUID NOT NULL REFERENCES departamentos(id) ON DELETE RESTRICT,
    descripcion TEXT NOT NULL,
    estado reporte_estado_enum NOT NULL DEFAULT 'Ingresado',
    prioridad prioridad_enum NOT NULL DEFAULT 'Media',
    ubicacion GEOGRAPHY(POINT, 4326) NOT NULL,
    referencia_ubicacion VARCHAR(300),
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    completado_en TIMESTAMPTZ,
    descartado_en TIMESTAMPTZ
);

-- Índices para consultas frecuentes
CREATE INDEX idx_reportes_usuario ON reportes(usuario_id);
CREATE INDEX idx_reportes_estado ON reportes(estado);
CREATE INDEX idx_reportes_prioridad ON reportes(prioridad);
CREATE INDEX idx_reportes_categoria ON reportes(categoria_id);
CREATE INDEX idx_reportes_departamento ON reportes(departamento_id);
CREATE INDEX idx_reportes_creado_en ON reportes(creado_en DESC);
-- Compuesto para filtros admin
CREATE INDEX idx_reportes_filtros_admin ON reportes(estado, prioridad, categoria_id, departamento_id);
-- Geoespacial GiST para proximidad
CREATE INDEX idx_reportes_ubicacion_gist ON reportes USING GIST (ubicacion);
-- Parciales para reportes activos
CREATE INDEX idx_reportes_activos ON reportes(creado_en DESC) WHERE estado IN ('Ingresado', 'EnRevisión');
CREATE INDEX idx_reportes_pendientes_depto ON reportes(departamento_id, prioridad, creado_en) WHERE estado IN ('Ingresado', 'EnRevisión');

COMMENT ON TABLE reportes IS 'Entidad central: reporte de problema en vía pública';
COMMENT ON COLUMN reportes.numero_seguimiento IS 'Formato REP-YYYY-NNNNNN (ej. REP-2025-001234)';
COMMENT ON COLUMN reportes.ubicacion IS 'PostGIS GEOGRAPHY(POINT,4326) - WGS84, metros reales';
COMMENT ON COLUMN reportes.referencia_ubicacion IS 'Descripción textual: "Esquina Av. Principal c/ Calle 5"';

-- Trigger para actualizado_en
CREATE OR REPLACE FUNCTION trigger_actualizado_en()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.actualizado_en = now();
    RETURN NEW;
END $$;

CREATE TRIGGER trg_reportes_actualizado_en
BEFORE UPDATE ON reportes
FOR EACH ROW EXECUTE FUNCTION trigger_actualizado_en();

CREATE TRIGGER trg_usuarios_actualizado_en
BEFORE UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION trigger_actualizado_en();

-- ============================================================
-- TABLA: fotografias
-- ============================================================
CREATE TABLE fotografias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporte_id UUID NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    tipo_mime VARCHAR(50) NOT NULL CHECK (tipo_mime IN ('image/jpeg', 'image/png', 'image/webp', 'image/heic')),
    tamano_bytes INTEGER NOT NULL CHECK (tamano_bytes > 0 AND tamano_bytes <= 10485760),
    ancho INTEGER,
    alto INTEGER,
    hash_sha256 CHAR(64) NOT NULL,
    orden SMALLINT NOT NULL DEFAULT 1,
    subida_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_fotografias_reporte ON fotografias(reporte_id, orden);
CREATE UNIQUE INDEX idx_fotografias_hash ON fotografias(hash_sha256);

COMMENT ON TABLE fotografias IS 'Evidencias fotográficas de reportes; URL firmada S3/GCS';
COMMENT ON COLUMN fotografias.hash_sha256 IS 'SHA-256 del archivo para deduplicación global';

-- ============================================================
-- TABLA: cambios_estado (AUDITORÍA INMUTABLE)
-- ============================================================
CREATE TABLE cambios_estado (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporte_id UUID NOT NULL REFERENCES reportes(id) ON DELETE RESTRICT,
    estado_anterior reporte_estado_enum,
    estado_nuevo reporte_estado_enum NOT NULL,
    nota TEXT,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_origen INET,
    user_agent TEXT
);

CREATE INDEX idx_cambios_estado_reporte ON cambios_estado(reporte_id, timestamp DESC);
CREATE INDEX idx_cambios_estado_usuario ON cambios_estado(usuario_id, timestamp DESC);

COMMENT ON TABLE cambios_estado IS 'Audit trail inmutable de cada transición de estado (ver EST-01)';
COMMENT ON COLUMN cambios_estado.nota IS 'Obligatorio para Completado (resolución) y Descartado (motivo)';

-- ============================================================
-- TABLA: asignaciones
-- ============================================================
CREATE TABLE asignaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporte_id UUID NOT NULL REFERENCES reportes(id) ON DELETE RESTRICT,
    departamento_id UUID NOT NULL REFERENCES departamentos(id) ON DELETE RESTRICT,
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    asignado_por UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    confirmada BOOLEAN NOT NULL DEFAULT false,
    confirmada_en TIMESTAMPTZ,
    notas TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_asignaciones_reporte ON asignaciones(reporte_id, creado_en DESC);
CREATE INDEX idx_asignaciones_usuario ON asignaciones(usuario_id, confirmada) WHERE NOT confirmada;

COMMENT ON TABLE asignaciones IS 'Trazabilidad de asignaciones y reasignaciones a departamentos/admins';

-- ============================================================
-- TABLA: notificaciones
-- ============================================================
CREATE TABLE notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporte_id UUID NOT NULL REFERENCES reportes(id) ON DELETE RESTRICT,
    destinatario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    tipo notificacion_tipo_enum NOT NULL,
    plantilla VARCHAR(100) NOT NULL,
    asunto VARCHAR(200) NOT NULL,
    cuerpo TEXT NOT NULL,
    estado notificacion_estado_enum NOT NULL DEFAULT 'Pendiente',
    proveedor_id VARCHAR(100),
    reintentos SMALLINT NOT NULL DEFAULT 0,
    max_reintentos SMALLINT NOT NULL DEFAULT 3,
    proximo_reintento TIMESTAMPTZ,
    enviado_en TIMESTAMPTZ,
    error_mensaje TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notificaciones_estado_reintento ON notificaciones(estado, proximo_reintento) WHERE estado = 'Pendiente';
CREATE INDEX idx_notificaciones_destinatario ON notificaciones(destinatario_id, creado_en DESC);
CREATE INDEX idx_notificaciones_reporte ON notificaciones(reporte_id);

COMMENT ON TABLE notificaciones IS 'Cola de notificaciones multi-canal con reintentos (ver EST-02)';
COMMENT ON COLUMN notificaciones.plantilla IS 'Clave: reporte_creado, estado_cambiado, completado, descartado';
COMMENT ON COLUMN notificaciones.proximo_reintento IS 'Cuándo reintentar (backoff exponencial: 1m, 5m, 15m)';

-- ============================================================
-- TABLA: refresh_tokens (JWT refresh rotation)
-- ============================================================
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    token_hash CHAR(64) NOT NULL,
    expira_en TIMESTAMPTZ NOT NULL,
    revocado BOOLEAN NOT NULL DEFAULT false,
    revocado_en TIMESTAMPTZ,
    ip_origen INET,
    user_agent TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_refresh_tokens_usuario ON refresh_tokens(usuario_id, revocado) WHERE NOT revocado;
CREATE INDEX idx_refresh_tokens_expira ON refresh_tokens(expira_en) WHERE NOT revocado;

COMMENT ON TABLE refresh_tokens IS 'Refresh tokens JWT con rotación y revocación; token_hash = SHA-256(token)';

-- ============================================================
-- TABLA: auditoria_login
-- ============================================================
CREATE TABLE auditoria_login (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    ip INET NOT NULL,
    user_agent TEXT,
    exitoso BOOLEAN NOT NULL,
    metodo VARCHAR(20) NOT NULL CHECK (metodo IN ('password', 'oauth', 'refresh')),
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_auditoria_login_usuario ON auditoria_login(usuario_id, creado_en DESC);
CREATE INDEX idx_auditoria_login_ip ON auditoria_login(ip, creado_en DESC);

COMMENT ON TABLE auditoria_login IS 'Auditoría de intentos de login para seguridad y detección de ataques';