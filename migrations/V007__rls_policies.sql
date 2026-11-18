-- V007__rls_policies.sql
-- Row Level Security (RLS) Policies - OPCIONAL
-- Habilitar solo si se usa PostgreSQL como API directa (ej. PostgREST, Supabase)
-- Ejecutar: psql -d barrio_conectado -f V007__rls_policies.sql
-- Requiere: V001-V006
-- ADVERTENCIA: Requiere roles de BD alineados con roles de app (vecino_role, admin_role, moderador_role)

-- ============================================================
-- CREAR ROLES DE BASE DE DATOS
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'vecino_role') THEN
        CREATE ROLE vecino_role NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_role') THEN
        CREATE ROLE admin_role NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'moderador_role') THEN
        CREATE ROLE moderador_role NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'api_role') THEN
        CREATE ROLE api_role NOLOGIN;
    END IF;
END $$;

-- ============================================================
-- HABILITAR RLS EN TABLAS
-- ============================================================

ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE reportes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE departamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE categoria_departamento ENABLE ROW LEVEL SECURITY;
ALTER TABLE fotografias ENABLE ROW LEVEL SECURITY;
ALTER TABLE cambios_estado ENABLE ROW LEVEL SECURITY;
ALTER TABLE asignaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria_login ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FUNCIÓN AUXILIAR: Obtener usuario actual de la sesión
-- ============================================================

CREATE OR REPLACE FUNCTION current_app_user_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
    SELECT NULLIF(current_setting('app.current_user_id', true), '')::UUID;
$$;

CREATE OR REPLACE FUNCTION current_app_user_rol()
RETURNS usuario_rol_enum LANGUAGE sql STABLE AS $$
    SELECT NULLIF(current_setting('app.current_user_rol', true), '')::usuario_rol_enum;
$$;

-- ============================================================
-- POLÍTICAS: usuarios
-- ============================================================

-- Vecino ve solo su propio registro
CREATE POLICY usuarios_vecino_select ON usuarios
FOR SELECT TO vecino_role
USING (id = current_app_user_id());

-- Admin ve todos
CREATE POLICY usuarios_admin_all ON usuarios
FOR ALL TO admin_role
USING (true);

-- Moderador ve vecinos de su zona (requiere campo zona_id en usuarios - futuro)
-- CREATE POLICY usuarios_moderador_select ON usuarios
-- FOR SELECT TO moderador_role
-- USING (rol = 'vecino' AND zona_id = (SELECT zona_id FROM usuarios WHERE id = current_app_user_id()));

-- Api role para login/registro
CREATE POLICY usuarios_api_insert ON usuarios
FOR INSERT TO api_role
WITH CHECK (true);

CREATE POLICY usuarios_api_select_login ON usuarios
FOR SELECT TO api_role
USING (true); -- Para login por email

-- ============================================================
-- POLÍTICAS: reportes
-- ============================================================

-- Vecino: solo sus reportes
CREATE POLICY reportes_vecino_select ON reportes
FOR SELECT TO vecino_role
USING (usuario_id = current_app_user_id());

-- Vecino: insertar sus reportes
CREATE POLICY reportes_vecino_insert ON reportes
FOR INSERT TO vecino_role
WITH CHECK (usuario_id = current_app_user_id());

-- Vecino: NO puede actualizar/borrar (solo admin/moderador)

-- Admin: acceso total
CREATE POLICY reportes_admin_all ON reportes
FOR ALL TO admin_role
USING (true);

-- Moderador: ve reportes de su zona (futuro: join con ubicacion)
-- CREATE POLICY reportes_moderador_select ON reportes
-- FOR SELECT TO moderador_role
-- USING (ST_Contains((SELECT zona_geom FROM moderador_zonas WHERE usuario_id = current_app_user_id()), ubicacion::geometry));

-- ============================================================
-- POLÍTICAS: categorias, departamentos (catálogos de lectura)
-- ============================================================

CREATE POLICY catalogos_read_all ON categorias
FOR SELECT TO vecino_role, admin_role, moderador_role, api_role
USING (activo = true);

CREATE POLICY catalogos_read_all_dept ON departamentos
FOR SELECT TO vecino_role, admin_role, moderador_role, api_role
USING (activo = true);

CREATE POLICY catalogos_read_all_cd ON categoria_departamento
FOR SELECT TO vecino_role, admin_role, moderador_role, api_role
USING (true);

-- Admin escribe catálogos
CREATE POLICY catalogos_admin_write ON categorias
FOR ALL TO admin_role
USING (true);

CREATE POLICY catalogos_admin_write_dept ON departamentos
FOR ALL TO admin_role
USING (true);

CREATE POLICY catalogos_admin_write_cd ON categoria_departamento
FOR ALL TO admin_role
USING (true);

-- ============================================================
-- POLÍTICAS: fotografias
-- ============================================================

-- Vecino ve fotos de sus reportes
CREATE POLICY fotos_vecino_select ON fotografias
FOR SELECT TO vecino_role
USING (reporte_id IN (SELECT id FROM reportes WHERE usuario_id = current_app_user_id()));

-- Vecino inserta fotos en sus reportes
CREATE POLICY fotos_vecino_insert ON fotografias
FOR INSERT TO vecino_role
WITH CHECK (reporte_id IN (SELECT id FROM reportes WHERE usuario_id = current_app_user_id()));

-- Admin ve todas
CREATE POLICY fotos_admin_all ON fotografias
FOR ALL TO admin_role
USING (true);

-- ============================================================
-- POLÍTICAS: cambios_estado (auditoría)
-- ============================================================

-- Vecino ve historial de sus reportes
CREATE POLICY ce_vecino_select ON cambios_estado
FOR SELECT TO vecino_role
USING (reporte_id IN (SELECT id FROM reportes WHERE usuario_id = current_app_user_id()));

-- Admin ve todo
CREATE POLICY ce_admin_all ON cambios_estado
FOR ALL TO admin_role
USING (true);

-- Sistema (api_role) inserta via triggers
CREATE POLICY ce_api_insert ON cambios_estado
FOR INSERT TO api_role
WITH CHECK (true);

-- ============================================================
-- POLÍTICAS: asignaciones
-- ============================================================

-- Admin ve y gestiona todas
CREATE POLICY asig_admin_all ON asignaciones
FOR ALL TO admin_role
USING (true);

-- Admin asignado ve sus asignaciones
CREATE POLICY asig_admin_asignado_select ON asignaciones
FOR SELECT TO admin_role
USING (usuario_id = current_app_user_id());

-- Admin asignado puede confirmar
CREATE POLICY asig_admin_confirmar ON asignaciones
FOR UPDATE TO admin_role
USING (usuario_id = current_app_user_id())
WITH CHECK (usuario_id = current_app_user_id());

-- Vecino ve asignación de sus reportes (solo depto, no admin)
CREATE POLICY asig_vecino_select ON asignaciones
FOR SELECT TO vecino_role
USING (reporte_id IN (SELECT id FROM reportes WHERE usuario_id = current_app_user_id()));

-- ============================================================
-- POLÍTICAS: notificaciones
-- ============================================================

-- Vecino ve sus notificaciones
CREATE POLICY notif_vecino_select ON notificaciones
FOR SELECT TO vecino_role
USING (destinatario_id = current_app_user_id());

-- Admin ve todas
CREATE POLICY notif_admin_all ON notificaciones
FOR ALL TO admin_role
USING (true);

-- Worker (api_role) procesa cola
CREATE POLICY notif_worker_select ON notificaciones
FOR SELECT TO api_role
USING (estado = 'Pendiente');

CREATE POLICY notif_worker_update ON notificaciones
FOR UPDATE TO api_role
USING (estado = 'Pendiente')
WITH CHECK (true);

-- ============================================================
-- POLÍTICAS: refresh_tokens
-- ============================================================

-- Usuario ve sus tokens
CREATE POLICY rt_user_select ON refresh_tokens
FOR SELECT TO vecino_role, admin_role, moderador_role
USING (usuario_id = current_app_user_id());

-- Usuario revoca sus tokens
CREATE POLICY rt_user_revoke ON refresh_tokens
FOR UPDATE TO vecino_role, admin_role, moderador_role
USING (usuario_id = current_app_user_id())
WITH CHECK (usuario_id = current_app_user_id());

-- Api/Worker limpia expirados
CREATE POLICY rt_api_cleanup ON refresh_tokens
FOR DELETE TO api_role
USING (expira_en < now() - INTERVAL '7 days');

-- ============================================================
-- POLÍTICAS: auditoria_login
-- ============================================================

-- Admin ve todo
CREATE POLICY audit_admin_all ON auditoria_login
FOR SELECT TO admin_role
USING (true);

-- Usuario ve sus intentos
CREATE POLICY audit_user_select ON auditoria_login
FOR SELECT TO vecino_role, admin_role, moderador_role
USING (usuario_id = current_app_user_id());

-- Api inserta
CREATE POLICY audit_api_insert ON auditoria_login
FOR INSERT TO api_role
WITH CHECK (true);

-- ============================================================
-- GRANTS PARA ROLES
-- ============================================================

GRANT USAGE ON SCHEMA public TO vecino_role, admin_role, moderador_role, api_role;

GRANT SELECT, INSERT ON usuarios TO vecino_role, api_role;
GRANT ALL ON usuarios TO admin_role;

GRANT SELECT ON categorias, departamentos, categoria_departamento TO vecino_role, admin_role, moderador_role, api_role;
GRANT ALL ON categorias, departamentos, categoria_departamento TO admin_role;

GRANT SELECT, INSERT ON reportes TO vecino_role;
GRANT ALL ON reportes TO admin_role;

GRANT SELECT, INSERT ON fotografias TO vecino_role;
GRANT ALL ON fotografias TO admin_role;

GRANT SELECT ON cambios_estado TO vecino_role;
GRANT ALL ON cambios_estado TO admin_role;
GRANT INSERT ON cambios_estado TO api_role;

GRANT SELECT ON asignaciones TO vecino_role;
GRANT ALL ON asignaciones TO admin_role;

GRANT SELECT ON notificaciones TO vecino_role;
GRANT ALL ON notificaciones TO admin_role;
GRANT SELECT, UPDATE ON notificaciones TO api_role;

GRANT SELECT, UPDATE ON refresh_tokens TO vecino_role, admin_role, moderador_role;
GRANT DELETE ON refresh_tokens TO api_role;

GRANT SELECT ON auditoria_login TO vecino_role, admin_role, moderador_role;
GRANT INSERT ON auditoria_login TO api_role;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vecino_role, admin_role, moderador_role, api_role;

-- ============================================================
-- NOTAS DE USO
-- ============================================================

/*
USO EN APLICACIÓN (Node.js/Python):

// Al iniciar request autenticado:
await db.query(`SET LOCAL app.current_user_id = $1`, [user.id]);
await db.query(`SET LOCAL app.current_user_rol = $1`, [user.rol]);

// Para login (api_role):
await db.query(`SET ROLE api_role`);

// Para operaciones admin:
await db.query(`SET ROLE admin_role`);

// Para operaciones vecino:
await db.query(`SET ROLE vecino_role`);

IMPORTANTE:
- RLS añade overhead ~1-5% por query
- Requiere connection pooling con SET ROLE por request
- No compatible directo con Prisma/TypeORM sin raw queries
- Recomendado solo para PostgREST/Supabase/Hasura direct-to-db
- En arquitectura tradicional (API Gateway + Servicios), la authZ está en capa app
*/