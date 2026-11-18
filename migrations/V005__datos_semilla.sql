-- V005__datos_semilla.sql
-- Datos semilla: catálogos iniciales y usuario admin por defecto
-- Ejecutar: psql -d barrio_conectado -f V005__datos_semilla.sql
-- Requiere: V001, V002

-- ============================================================
-- CATEGORÍAS BASE
-- ============================================================
INSERT INTO categorias (nombre, descripcion, prioridad_base, icono, color_hex) VALUES
('Luminaria', 'Alumbrado público: postes, lámparas, cableado, fotocélulas', 'Alta', 'lightbulb', '#FFD600'),
('Microbasural', 'Acumulación de residuos domiciliarios/escombros en vía pública', 'Media', 'delete', '#EF6C00'),
('Bache', 'Deterioro de carpeta asfáltica, hoyos, hundimientos en calzada', 'Alta', 'road', '#C62828'),
('Señalética', 'Señales de tránsito dañadas, faltantes, vandalizadas u obsoletas', 'Media', 'sign', '#1565C0'),
('Vereda', 'Aceras rotas, desniveles, obstáculos peatonales, baldosas sueltas', 'Media', 'directions_walk', '#2E7D32'),
('Parques/Plazas', 'Juegos infantiles, bancas, áreas verdes, riego, pérgolas', 'Baja', 'park', '#388E3C'),
('Drenaje', 'Sumideros tapados, anegamientos, cunetas, cámaras de inspección', 'Alta', 'water', '#0277BD'),
('Otro', 'Problemas no clasificados en categorías anteriores', 'Baja', 'help', '#757575')
ON CONFLICT (nombre) DO NOTHING;

-- ============================================================
-- DEPARTAMENTOS BASE
-- ============================================================
INSERT INTO departamentos (nombre, descripcion, email_contacto, telefono) VALUES
('Alumbrado Público', 'Mantenimiento y reparación de luminarias, postes y redes eléctricas', 'alumbrado@municipio.cl', '+56 32 123456'),
('Aseo y Ornato', 'Limpieza de calles, recolección de residuos, microbasurales, barrido', 'aseo@municipio.cl', '+56 32 123457'),
('Obras Viales', 'Baches, pavimento, calzadas, veredas, badenes, ciclovías', 'obras@municipio.cl', '+56 32 123458'),
('Tránsito y Transporte', 'Señalética vertical/horizontal, semáforos, fiscalización, tachas', 'transito@municipio.cl', '+56 32 123459'),
('Parques y Jardines', 'Mantenimiento áreas verdes, plazas, juegos, riego, arbolado urbano', 'parques@municipio.cl', '+56 32 123460'),
('Drenaje y Alcantarillado', 'Red de aguas lluvia, sumideros, colectores, cámaras, bombeo', 'drenaje@municipio.cl', '+56 32 123461'),
('Obras Públicas General', 'Coordinación general, proyectos, inspección técnica, otros', 'obraspublicas@municipio.cl', '+56 32 123462')
ON CONFLICT (nombre) DO NOTHING;

-- ============================================================
-- RELACIÓN CATEGORÍA ↔ DEPARTAMENTO (PRINCIPAL)
-- ============================================================
INSERT INTO categoria_departamento (categoria_id, departamento_id, es_principal)
SELECT c.id, d.id, true
FROM categorias c, departamentos d
WHERE (c.nombre, d.nombre) IN (
    ('Luminaria', 'Alumbrado Público'),
    ('Microbasural', 'Aseo y Ornato'),
    ('Bache', 'Obras Viales'),
    ('Señalética', 'Tránsito y Transporte'),
    ('Vereda', 'Obras Viales'),
    ('Parques/Plazas', 'Parques y Jardines'),
    ('Drenaje', 'Drenaje y Alcantarillado'),
    ('Otro', 'Obras Públicas General')
)
ON CONFLICT (categoria_id, departamento_id) DO NOTHING;

-- Relaciones secundarias (ej. Vereda también puede ir a Aseo y Ornato por limpieza)
INSERT INTO categoria_departamento (categoria_id, departamento_id, es_principal)
SELECT c.id, d.id, false
FROM categorias c, departamentos d
WHERE (c.nombre, d.nombre) IN (
    ('Vereda', 'Aseo y Ornato'),
    ('Parques/Plazas', 'Aseo y Ornato'),
    ('Drenaje', 'Obras Viales')
)
ON CONFLICT (categoria_id, departamento_id) DO NOTHING;

-- ============================================================
-- USUARIO ADMIN POR DEFECTO
-- ============================================================
-- Password: "Admin123!" -> Argon2id hash (generar con: npx argon2-cli "Admin123!" o script Python)
-- Hash ejemplo (reemplazar con hash real generado):
-- $argon2id$v=19$m=65536,t=3,p=4$c29tZXNhbHQ$hash_generado
INSERT INTO usuarios (email, nombre, telefono, rol, password_hash, activo)
VALUES (
    'admin@municipio.cl',
    'Administrador Municipal',
    '+56 9 1234 5678',
    'admin',
    '$argon2id$v=19$m=65536,t=3,p=4$REPLACE_WITH_REAL_HASH',
    true
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- USUARIO MODERADOR EJEMPLO (para testing)
-- ============================================================
INSERT INTO usuarios (email, nombre, telefono, rol, password_hash, activo)
VALUES (
    'moderador@barrio.cl',
    'Juan Pérez - Moderador Barrio Norte',
    '+56 9 8765 4321',
    'moderador',
    '$argon2id$v=19$m=65536,t=3,p=4$REPLACE_WITH_REAL_HASH',
    true
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- VECINO EJEMPLO (para testing)
-- ============================================================
INSERT INTO usuarios (email, nombre, telefono, rol, password_hash, activo)
VALUES (
    'vecino@ejemplo.cl',
    'María González',
    '+56 9 1111 2222',
    'vecino',
    '$argon2id$v=19$m=65536,t=3,p=4$REPLACE_WITH_REAL_HASH',
    true
)
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- NOTA: Los hashes de contraseña DEBEN generarse en deploy/runtime
-- Script Python para generar:
-- import argon2
-- ph = argon2.PasswordHasher()
-- hash = ph.hash("tu_password_seguro")
-- print(hash)