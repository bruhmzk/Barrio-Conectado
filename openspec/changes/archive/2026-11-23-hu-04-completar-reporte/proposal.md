# Proposal

## Why

En el AS-IS la reparación se ejecutaba sin registrar el cierre, por lo que no quedaba constancia de la nota de resolución ni el vecino podía ver cómo terminó su reporte. Con HU-01, HU-02 y HU-03 ya se pueden registrar, consultar y filtrar reportes, pero el administrador municipal todavía no puede completar un incidente dejando trazabilidad; HU-04 implementa la actividad del TO-BE **«Actualiza estado en la app: resuelto»** (RP-07, CU-04), con apoyo de la Plataforma BarrioConectado.

## What Changes

- Se agrega una pantalla de **cierre de reporte** para el usuario *Administrador Demo* del selector de demostración, accesible desde el panel de administración de HU-03, con el número de seguimiento, la descripción, el estado actual y un campo para la **nota de resolución**.
- El administrador puede completar únicamente reportes en **«En revisión»**: se ejecuta la transición EST-01 `completarReporte()` hacia **«Completado»** con la guarda `notaResolucion != vacía` (después de quitar espacios).
- Al completar, se actualiza `reportes.estado` y se crea un `CambioEstado` con `fecha_hora`, `estado_anterior`, `estado_nuevo`, `nota` y `usuario_id` del administrador. No se crean tablas ni migraciones: `cambios_estado` ya existe desde la migración `002_cambios_estado.sql`.
- Si la nota está vacía, el sistema rechaza el cambio, muestra «La nota de resolución es obligatoria» y no registra cambio de estado ni aviso. Si el reporte está en otro estado, rechaza la operación sin modificar datos.
- Se simula la solicitud de aviso al **Sistema de Notificaciones** mediante un adaptador, con respuesta «aviso aceptado» o «aviso pendiente» si el servicio no está disponible; el cierre se confirma igual. **No se persiste `Notificación`**: HU-05 queda pendiente.
- El vecino autor ve el nuevo estado y la nota en el detalle de HU-02, que ya muestra el historial de cambios; no se crea una pantalla nueva para el vecino.
- Se agregan cuatro pruebas automáticas, una por cada escenario Gherkin de la ficha confirmada de HU-04, más la variante confirmada de sin administrador seleccionado.

**Fuera de alcance:** el descarte con motivo (HU-07); la generación, envío y estados reales de `Notificación` (HU-05 / RP-08 / EST-02); el ajuste manual de prioridad (HU-06); la reasignación de departamento (HU-08); la autenticación real (RP-10 / RP-12) y los requisitos no funcionales RP-09 y RP-11. Tampoco se modifican los documentos del curso: las correcciones de vocabulario del Gherkin original («en proceso», «notifica…») quedan registradas solo en la ficha `.cin324/historias/HU-04.md`.

## Capabilities

### New Capabilities

- Ninguna.

### Modified Capabilities

- `reportes`: se agregan requisitos para completar un reporte desde «En revisión» con nota obligatoria, registrar el `CambioEstado`, rechazar estados inválidos y simular la solicitud de aviso al vecino; no se modifican los requisitos de registro (HU-01), consulta del vecino (HU-02) ni filtrado (HU-03).

## Impact

- **Historia:** HU-04 — Completar reporte con nota de resolución (ficha confirmada en `.cin324/historias/HU-04.md`).
- **Actividad del TO-BE:** Actualiza estado en la app: resuelto; tarea de usuario del administrador con apoyo de tarea de servicio de la Plataforma BarrioConectado.
- **Caso de uso:** CU-04 — Completar reporte con nota de resolución (actor principal: Administrador municipal; actor externo: Sistema de Notificaciones, relacionado por `include` con CU-05 y simulado en este ciclo).
- **Requisito que cubre:** RP-07. RP-08 es contexto y se difiere a HU-05.
- **Diagramas:** EST-01 (transición `En revisión → Completado`) y DSS-02 (cierre y solicitud de aviso, con las ramas `alt` de nota inválida, estado inválido y servicio no disponible).
- **Código afectado:** nueva lógica de dominio en `app/dominio/reporte.py` (o módulo de cambios de estado), un nuevo adaptador en `app/integraciones/`, una nueva ruta en `app/rutas/administracion.py`, una plantilla de cierre, un enlace desde el panel de HU-03 y nuevas pruebas pytest. Se reutilizan la base SQLite, las migraciones 001 y 002, el `seed` y el selector de usuario de demostración.
- **Dependencias:** las ya instaladas (FastAPI, Uvicorn, Jinja2, pytest, httpx); no se agregan bibliotecas ni infraestructura. La integración externa se simula, sin servicios reales.
