-- V001__enums.sql
-- Tipos enumerados para Barrio Conectado
-- Ejecutar: psql -d barrio_conectado -f V001__enums.sql

-- Rol de usuario
CREATE TYPE usuario_rol_enum AS ENUM ('vecino', 'admin', 'moderador');

-- Prioridad (Alta, Media, Baja)
CREATE TYPE prioridad_enum AS ENUM ('Alta', 'Media', 'Baja');

-- Estado del reporte (máquina de estados EST-01)
CREATE TYPE reporte_estado_enum AS ENUM ('Ingresado', 'EnRevisión', 'Completado', 'Descartado');

-- Tipo de notificación
CREATE TYPE notificacion_tipo_enum AS ENUM ('Push', 'Email', 'SMS');

-- Estado de notificación (máquina de estados EST-02)
CREATE TYPE notificacion_estado_enum AS ENUM ('Pendiente', 'Enviada', 'Fallida');

-- Comentarios para documentación
COMMENT ON TYPE usuario_rol_enum IS 'Roles del sistema: vecino (ciudadano), admin (funcionario municipal), moderador (dirigente vecinal)';
COMMENT ON TYPE prioridad_enum IS 'Niveles de prioridad para reportes y categorías';
COMMENT ON TYPE reporte_estado_enum IS 'Estados del ciclo de vida del reporte (ver EST-01)';
COMMENT ON TYPE notificacion_tipo_enum IS 'Canales de notificación soportados';
COMMENT ON TYPE notificacion_estado_enum IS 'Estados del ciclo de vida de notificación (ver EST-02)';