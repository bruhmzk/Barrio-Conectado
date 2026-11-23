# Design

## Context

Proyecto nuevo (no hay código de aplicación todavía). Ver `proposal.md` para la motivación. Las fuentes de verdad son `.cin324/historias/HU-01.md`, el modelo de dominio (`diagramas/modelo-dominio.puml`), EST-01 (`diagramas/est-01.puml`) y DSS-01 (`diagramas/dss-01.puml`). El stack es Python 3.12 + FastAPI + Jinja2 + `sqlite3` + pytest.

## Goals / Non-Goals

**Goals:**
- Registrar un reporte desde una página web con los cuatro datos obligatorios y confirmarlo con número de seguimiento.
- Persistir el reporte, su ubicación, su fotografía (referencia) y la asignación inicial en SQLite.
- Validar la ubicación mediante un adaptador simulado del Servicio de mapas.

**Non-Goals:**
- Consultar, filtrar o cambiar el estado de reportes (HU-02…HU-04).
- Notificaciones (HU-05), ajuste manual de prioridad (HU-06), descarte (HU-07) y reasignación (HU-08).
- Autenticación real (selector de usuario de demostración) y requisitos no funcionales.

## Decisions

### Tablas derivadas del modelo de dominio

| Tabla | Columnas | Origen en el modelo |
|-------|----------|---------------------|
| `departamentos` | `id`, `nombre` (único) | `Departamento` |
| `categorias` | `id`, `nombre` (único), `urgencia_base` (`alta`/`media`/`baja`), `departamento_id` FK | `Categoria` (`nombre`, `urgenciaBase`) y asociación Categoría 1..* – 1 Departamento |
| `usuarios` | `id`, `nombre`, `medio_contacto`, `rol` (`vecino`/`administrador`) | `Usuario`; `rol` es apoyo del selector de demostración |
| `reportes` | `id`, `numero_seguimiento` (único), `descripcion`, `fecha_hora_registro`, `estado`, `prioridad`, `usuario_id` FK, `categoria_id` FK | `Reporte`; Usuario 1 – 0..* Reporte; Reporte 0..* – 1 Categoría |
| `ubicaciones` | `id`, `reporte_id` (único) FK, `latitud`, `longitud`, `referencia` | `Ubicacion` (composición Reporte 1 – 1 Ubicación) |
| `fotografias` | `id`, `reporte_id` FK, `archivo_imagen` | `Fotografia` (composición Reporte 1 – 1..* Fotografía) |
| `asignaciones` | `id`, `reporte_id` FK, `departamento_id` FK, `usuario_id` FK nulo, `fecha_hora` | `Asignacion`; la asignación inicial no tiene usuario |

Se usa `sqlite3` de la biblioteca estándar (sin ORM) para mantenerlo simple y explícito. Alternativa considerada: SQLAlchemy; se descarta para no añadir una dependencia que el equipo no pidió.

### Transición de estado (EST-01)

Al registrar se ejecuta la transición `[*] → Recibido` con evento «Registrar reporte», guarda «datos completos y ubicación válida» y acción «asignar número de seguimiento, prioridad y departamento». No se crea `CambioEstado` porque el reporte recién recibido no tiene cambios. `estado` se guarda como texto `Recibido`.

### Clasificación automática

- `prioridad` = `Alta` si `urgencia_base = alta`, `Media` si `media`, `Baja` si `baja`.
- `departamento` = `categorias.departamento_id` de la categoría elegida; se inserta una fila en `asignaciones` con `usuario_id = NULL`.
- Datos de ejemplo: Luminaria (`media` → Alumbrado), Microbasural (`alta` → Aseo), Bache (`alta` → Obras).

### Rutas derivadas de DSS-01

| Método y ruta | Propósito |
|---------------|-----------|
| `GET /` | Página de inicio con el selector de usuario de demostración y acceso al registro |
| `POST /demo/usuario` | Guarda en cookie el usuario de demostración elegido |
| `GET /reportes/nuevo` | Muestra el formulario de registro |
| `POST /reportes` | Valida datos, valida ubicación y registra el reporte |
| `GET /reportes/{numero_seguimiento}/confirmacion` | Muestra la confirmación con el número de seguimiento |

### Integración externa simulada

`app/integraciones/mapas.py` define la interfaz `ValidadorUbicacion` y una implementación `MapasSimulados`. `validar(latitud, longitud)` devuelve un resultado con `valida: bool` y `referencia: str`; es válida si `-90 ≤ latitud ≤ 90` y `-180 ≤ longitud ≤ 180`, y la referencia resume las coordenadas. No hay llamada de red.

### Fotografía

El formulario usa un campo de archivo; se valida que se haya seleccionado uno y se guarda **solo el nombre del archivo** en `fotografias.archivo_imagen` (no se almacena el binario). Es la simulación acordada en la ficha.

### Número de seguimiento

Formato `BC-<año>-<6 dígitos>` (por ejemplo `BC-2026-000123`), generado con un contador aleatorio y verificado contra la base; si colisiona, se reintenta. Alternativa considerada: UUID; se descarta porque el número debe ser legible para el vecino.

### Estructura y ejecución

```
app/
  main.py
  db/conexion.py, db/migrations/001_*.sql, db/seed.py
  dominio/reporte.py, categoria.py, usuario.py
  servicios/registrar_reporte.py
  integraciones/mapas.py
  rutas/reportes.py, rutas/demo.py
  templates/base.html, inicio.html, nuevo_reporte.html, confirmacion.html
tests/
requirements.txt
README.md
```

## Risks / Trade-offs

- **Alias de Python de Microsoft Store en Windows** → documentar el uso de `.venv` y, si hace falta, la ruta completa de `python.exe`.
- **`sqlite3` y concurrencia** → abrir una conexión por solicitud y usar transacciones para el registro (reporte + ubicación + fotografía + asignación).
- **Fotografía simulada** → no se conserva la imagen real; suficiente para el alcance del curso y para las pruebas.
- **Colisión del número de seguimiento** → verificación de unicidad con reintento.
- **Datos de ejemplo discutibles** (urgencia y departamento por categoría) → están registrados como supuesto en la ficha y se pueden ajustar en `seed.py`.
