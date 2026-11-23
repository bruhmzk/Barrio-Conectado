# Design

## Context

La aplicación ya tiene HU-01 implementada: migración `001_esquema_inicial.sql`, `seed` con departamentos, categorías y dos usuarios de demostración, selector de usuario por cookie (`app/rutas/demo.py`), registro de reportes y adaptador simulado de mapas. Ver `proposal.md` para la motivación. Las fuentes de verdad de este ciclo son la ficha `.cin324/historias/HU-02.md`, el modelo de dominio (`08-modelo-dominio.md`), EST-01, CU-02 y el flujo reconstruido (HU-02 no tiene DSS, según `12-trazabilidad.md`). Stack: Python 3.12 + FastAPI + Jinja2 + `sqlite3` + pytest.

## Goals / Non-Goals

**Goals:**
- Mostrar «Mis reportes» filtrados por el vecino elegido en el selector de demostración, con fecha, categoría y estado actual, y el mensaje de lista vacía.
- Mostrar el detalle de un reporte propio con su historial de `CambioEstado` ordenado por fecha.
- Persistir `CambioEstado` con una migración nueva y dejar datos de ejemplo que hagan verificables los escenarios.
- Cubrir cada escenario Gherkin con una prueba automática.

**Non-Goals:**
- Ejecutar transiciones de EST-01, registrar notas de resolución ni notificar al vecino (HU-04, HU-05).
- Filtros, ordenación o panel de administrador (HU-03) y el resto de historias.
- Autenticación real, requisitos no funcionales, reescritura de la migración 001 o cambio de documentos del curso.

## Decisions

### Persistencia de `CambioEstado` (del modelo de dominio)

Nueva migración `app/db/migrations/002_cambios_estado.sql`, sin tocar la migración 001:

| Columna | Definición | Origen |
|---------|-----------|--------|
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | identificación interna |
| `reporte_id` | `INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE` | composición Reporte 1 – 0..* CambioEstado |
| `fecha_hora` | `TEXT NOT NULL` | atributo `fechaHora` |
| `estado_anterior` | `TEXT NOT NULL` | atributo `estadoAnterior` |
| `estado_nuevo` | `TEXT NOT NULL CHECK (...)` con los cuatro estados | atributo `estadoNuevo` / EST-01 |
| `nota` | `TEXT` (opcional) | atributo `nota` |
| `usuario_id` | `INTEGER NOT NULL REFERENCES usuarios(id)` | asociación «realizado por» CambioEstado 0..* – 1 Usuario |

Índice por `(reporte_id, fecha_hora)` para leer el historial ordenado. Alternativa descartada: guardar el historial como texto en `reportes`: el modelo define `CambioEstado` como clase con multiplicidad `0..*`, así que necesita su propia tabla.

El estado **actual** sigue siendo `reportes.estado` (ya existe); la tabla nueva solo alimenta el historial. Nombres de estado: `Recibido`, `En revisión`, `Completado`, `Descartado` (`001_esquema_inicial.sql` y `app/dominio/reporte.py:ESTADOS`). EST-01 escribe `EnRevisión`; se muestra «En revisión» según la decisión D7 de la ficha, sin cambiar el diagrama.

### Sin transiciones

HU-02 solo ejecuta `SELECT`: no llama a ninguna función de cambio de estado ni crea `CambioEstado`. Las filas de ejemplo del historial se cargan desde el `seed`, no desde la navegación. Así se respeta que las transiciones pertenecen a HU-04/HU-07.

### Rutas derivadas de CU-02 y del flujo reconstruido

| Método y ruta | Propósito |
|---------------|-----------|
| `GET /reportes` | Lista de reportes del usuario de demostración seleccionado |
| `GET /reportes/{numero_seguimiento}` | Detalle del reporte propio y su historial de cambios |

Ambas usan `usuario_actual` de `app/rutas/demo.py` (cookie `usuario_demo`). Alternativa descartada: recibir `usuario_id` en la querystring, porque permitiría consultar reportes ajenos y rompería CA3. La ruta literal `/reportes/nuevo` debe seguir declarada **antes** que `/reportes/{numero_seguimiento}` para que «nuevo» no se interprete como número de seguimiento; la ruta existente `/reportes/{numero_seguimiento}/confirmacion` no entra en conflicto por tener un segmento adicional.

### Acceso restringido y variantes

- Lista: `WHERE r.usuario_id = :usuario_actual`.
- Detalle: se filtra también por `usuario_id`; si el reporte existe pero es de otro vecino, se responde **404** (no 403, para no revelar su existencia).
- Sin usuario de demostración seleccionado: se muestra el mensaje «Selecciona un vecino de demostración para consultar tus reportes» junto al selector en la cabecera (estado 200), igual que HU-01 pide elegir usuario antes de registrar.
- Reporte sin cambios: la plantilla muestra el estado actual y un texto «Sin cambios de estado registrados» en lugar de una tabla vacía.

### Datos de ejemplo en `seed.py`

Se mantiene el `seed` idempotente y se amplía:

- Usuario nuevo: **Vecino Demo 2** (`vecino2@demo.cl`, rol `vecino`).
- Tres reportes con números fijos y legibles: `BC-2026-000101` (*Vecino Demo*, Luminaria, **Recibido**), `BC-2026-000102` (*Vecino Demo*, Microbasural, **En revisión**) y `BC-2026-000103` (*Vecino Demo 2*, Bache, **Recibido**).
- Cada reporte de ejemplo lleva su `Ubicacion`, su `Fotografia` (nombre de archivo simulado) y su `Asignacion` inicial según la categoría, para respetar las multiplicidades del modelo.
- Un `CambioEstado` de ejemplo en `BC-2026-000102`: `Recibido → En revisión`, fecha `2026-11-20 10:15`, nota vacía, registrado por *Administrador Demo*.
- Inserciones con claves naturales (`numero_seguimiento`, texto del cambio) y `INSERT OR IGNORE` para no duplicar al repetir el comando.

### Pruebas

`tests/test_hu02_gherkin.py`, una prueba por escenario Gherkin de la ficha, más las variantes confirmadas (reporte ajeno, sin cambios, sin usuario seleccionado). Se reutilizan las fixtures `db_temporal`, `client`, `datos` y `elegir_usuario` de `tests/conftest.py`. La base de prueba es temporal (`CIN324_DB`), con las migraciones y el `seed` aplicados por la fixture.

### Integraciones externas

Ninguna: CU-02 no tiene actores externos y el flujo es local a SQLite. No se crea ningún adaptador nuevo; el simulador de mapas de HU-01 queda intacto.

## Risks / Trade-offs

- **Orden de rutas FastAPI** (`/reportes/nuevo` vs `/reportes/{numero_seguimiento}`) → declarar la ruta literal primero y añadir una prueba de regresión que visite `/reportes/nuevo`.
- **Historial visible solo si hay datos de ejemplo** → el `seed` carga el cambio fechado; sin él, CA2 no se podría probar. Está registrado como supuesto confirmado en la ficha.
- **Diferencia de nombres de estado (`EnRevisión` vs `En revisión`)** → decisión D7; el valor de la base manda en la interfaz, para no romper lo generado en HU-01.
- **Datos de ejemplo con año fijo (2026)** → son solo demostrativos; el formato de número de seguimiento coincide con HU-01.
- **Sin DSS para HU-02** → el flujo de 6 pasos es una reconstrucción confirmada; cualquier cambio de orden debe pasar primero por los artefactos del curso.

## Migration Plan

1. `app/main.py` ya aplica migraciones en el `lifespan`: basta con añadir `002_cambios_estado.sql` al directorio de migraciones.
2. `python -m app.db.seed` aplica las migraciones y carga los reportes y el cambio de ejemplo sin duplicar los existentes.
3. Rollback en desarrollo: borrar `data/app.db` y volver a ejecutar el `seed` (no hay datos reales en este proyecto de curso).
