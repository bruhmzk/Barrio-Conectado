# Design

## Context

La aplicación ya tiene HU-01, HU-02 y HU-03 implementadas: migraciones `001_esquema_inicial.sql` y `002_cambios_estado.sql`, `seed` con tres reportes (uno en «En revisión»), selector de usuario por cookie (`app/rutas/demo.py`), detalle del vecino con historial de `cambios_estado` y panel de administración con filtros. Ver `proposal.md` para la motivación. Las fuentes de verdad de este ciclo son la ficha `.cin324/historias/HU-04.md`, el modelo de dominio (`08-modelo-dominio.md`), EST-01, CU-04 y DSS-02. Stack: Python 3.12 + FastAPI + Jinja2 + `sqlite3` + pytest.

## Goals / Non-Goals

**Goals:**
- Aplicar la única transición de EST-01 de esta historia: `En revisión → Completado` con evento `completarReporte()` y guarda de nota no vacía.
- Persistir el `CambioEstado` con fecha, hora, estados anterior y nuevo, nota y administrador responsable, de modo que HU-02 ya pueda mostrarlo.
- Rechazar sin efectos secundarios los intentos con nota vacía o con un reporte que no esté en «En revisión».
- Simular la solicitud de aviso al Sistema de Notificaciones sin persistir `Notificación` y sin fallar el cierre cuando el servicio no esté disponible.
- Cubrir los cuatro escenarios Gherkin con pruebas automáticas y la variante de sin administrador seleccionado.

**Non-Goals:**
- Crear tablas, columnas o migraciones nuevas; `cambios_estado` ya existe en la migración 002.
- Crear una entidad o tabla `Notificación`, ejecutar EST-02 ni envíos reales (HU-05 / RP-08).
- Implementar descarte (HU-07), ajuste de prioridad (HU-06), reasignación (HU-08), autenticación real ni requisitos no funcionales.
- Modificar los documentos del curso ni reescribir migraciones o datos de ejemplo ya confirmados.

## Decisions

### Persistencia: transición única y atómica, sin migración

La ficha solo usa `Reporte`, `CambioEstado` y `Usuario`. Ya existen `reportes.usuario_id`, `cambios_estado` (con `nota`, `usuario_id` y `CHECK` que admite `Completado`) y `usuarios` en las migraciones 001 y 002; esta historia no las toca. La nota de resolución se guarda en `cambios_estado.nota`. La asociación `CambioEstado 1 – 1 Notificación` del modelo queda diferida a HU-05 (decisión D3).

Se agrega en `app/dominio/reporte.py` una única función de transición `completar_reporte(conn, numero_seguimiento, nota, usuario_id, notificador=None)` que:

| Paso | Definición | Origen |
|------|-----------|--------|
| 1 | Buscar el reporte por `numero_seguimiento`; si no existe, fallar con mensaje claro | DSS-02, paso 3 |
| 2 | Verificar `estado == "En revisión"`; si no, devolver rechazo sin escribir | EST-01, guarda de estado; variante D5 |
| 3 | Quitar espacios a `nota`; si queda vacía, devolver «La nota de resolución es obligatoria» sin escribir | EST-01, guarda `notaResolucion != vacía`; D5 |
| 4 | Dentro de `with conn:`, actualizar `reportes.estado = "Completado"` e insertar en `cambios_estado` con `fecha_hora`, `estado_anterior`, `estado_nuevo`, `nota` y `usuario_id` | Modelo de dominio y DSS-02, paso 7 |
| 5 | Después de confirmar la transacción, llamar al adaptador de notificaciones y devolver un `ResultadoCierre` con el mensaje visible | DSS-02, paso 8; D5 |

Alternativa descartada: actualizar `reportes.estado` directamente desde la ruta. Duplicaría las reglas de guarda, dejaría el `CambioEstado` sin registrar en rutas alternativas y rompería la trazabilidad de HU-02. También se descartó llamar al notificador dentro de la transacción: un fallo del servicio externo no debe deshacer un cierre ya válido, según la variante confirmada de «aviso pendiente».

### Adaptador del Sistema de Notificaciones

Se crea `app/integraciones/notificaciones.py` siguiendo el patrón de `app/integraciones/mapas.py`:

| Elemento | Definición |
|----------|------------|
| `Notificador` | `Protocol` con el mensaje de DSS-02 `solicitar_aviso(solicitud) -> ResultadoAviso` |
| `SolicitudAviso` | `numero_seguimiento`, `destinatario`, `estado_nuevo`, `nota` |
| `ResultadoAviso` | `aceptado: bool`, `mensaje: str` («aviso aceptado» o «aviso pendiente de envío») |
| `NotificacionesSimuladas` | Implementación por defecto: registra la solicitud en consola y devuelve éxito; acepta `disponible=False` y lee `CIN324_NOTIFICACIONES_DISPONIBLES=0` para simular caída |

La ruta obtiene la implementación simulada (sin capa de configuración adicional) y la pasa a `completar_reporte`. No se crea `integraciones_log`: la historia no pide persistir el aviso y un registro en consola basta para la simulación. Alternativa descartada: envío HTTP o correo real; está fuera de alcance y añadiría dependencias.

### Rutas y pantalla derivadas de CU-04 y DSS-02

| Método y ruta | Propósito |
|---------------|-----------|
| `GET /administracion/reportes/{numero_seguimiento}/completar` | Formulario de cierre con número de seguimiento, descripción, estado actual y campo `nota` |
| `POST /administracion/reportes/{numero_seguimiento}/completar` | Valida, persiste el cierre, solicita el aviso simulado y muestra la confirmación o el error |

Se agregan las rutas al `APIRouter(prefix="/administracion")` existente en `app/rutas/administracion.py`, sin tocar el router de HU-01/HU-02. Se usa `obtener_reporte_por_numero` (sin filtro por vecino) porque el actor es el administrador municipal; el detalle del vecino sigue usando `obtener_reporte_para_usuario`. Alternativa descartada: reutilizar `/reportes/{numero_seguimiento}`; mezclaría el rol de vecino consultante con el de administrador que modifica y obligaría a condicionar la misma ruta por rol.

La plantilla `app/templates/completar_reporte.html` extiende `base.html` y muestra:
- El formulario `POST` con `<textarea name="nota">` y botón «Completar reporte».
- El mensaje «La nota de resolución es obligatoria» cuando falle la guarda (estado 400), conservando el texto escrito.
- El mensaje de rechazo por estado distinto a «En revisión» (estado 400), sin formulario activo.
- La confirmación con el nuevo estado «Completado» y «aviso aceptado» o «aviso pendiente de envío» (estado 200).

En `app/templates/administracion_reportes.html` se agrega la columna «Acción» con un enlace «Completar» solo cuando `reporte.estado == "En revisión"`. Ocultar el enlace no sustituye a la validación: la ruta y la función de dominio rechazan igual un `POST` directo sobre otro estado.

### Control del actor de demostración

Se reutiliza `usuario_actual`. Si no hay usuario seleccionado, o si `usuario["rol"] != "administrador"`, la ruta muestra «Selecciona un administrador de demostración para completar el reporte» junto al selector de la cabecera (estado 200), sin consultar ni escribir en la base. Es la sustitución acordada de RP-10. No se agrega middleware ni dependencia nueva.

### Visibilidad para el vecino

No se crea pantalla nueva: `app/templates/detalle_reporte.html` ya muestra `estado actual` y la tabla de `cambios` con `fecha_hora`, `estado_anterior`, `estado_nuevo` y `nota`. Al insertar el `CambioEstado`, el detalle de HU-02 lo mostrará sin cambios de código. Alternativa descartada: duplicar la nota en `reportes`; el modelo de dominio la ubica en `CambioEstado` y duplicarla rompería la trazabilidad.

### Datos de ejemplo

No se modifica `app/db/seed.py`: `BC-2026-000102` ya está en «En revisión» y es el candidato natural para la prueba manual; `BC-2026-000101` y `BC-2026-000103` permiten probar el rechazo por estado. Las pruebas crean su base temporal con las fixtures existentes y no dependen de `data/app.db`.

### Pruebas

- `tests/test_completar_reporte_hu04.py`: pruebas de dominio para la guarda de nota (incluida nota con espacios), el rechazo por estado, la escritura atómica de `reportes` + `cambios_estado` y el comportamiento del adaptador simulado disponible/no disponible.
- `tests/test_hu04_gherkin.py`: una prueba por cada escenario de la ficha, con nombres `HU-04 · <nombre del escenario>`; la primera comprueba además que el vecino autor ve el estado y la nota en `/reportes/BC-2026-000102`.
- `tests/test_panel_completar_hu04.py`: variantes de sin administrador seleccionado, vecino seleccionado y enlace «Completar» visible solo para «En revisión».
- Se reutilizan `db_temporal`, `conexion`, `client`, `datos` y `elegir_usuario` de `tests/conftest.py`. La caída del servicio se fuerza con `NotificacionesSimuladas(disponible=False)` o con la variable de entorno, sin red ni correo.

## Risks / Trade-offs

- **Doble cierre concurrente** → se relee el estado dentro de la transacción; el segundo intento recibe el rechazo por estado distinto a «En revisión».
- **Fallo del notificador** → se llama después del `commit` y se captura; el cierre queda registrado y se informa «aviso pendiente de envío», según D5.
- **No persistir `Notificación`** → la multiplicidad `CambioEstado 1 – 1 Notificación` sigue sin cumplirse en la base; supuesto confirmado en D3 y diferido a HU-05.
- **`POST` directo con estado inválido** → la validación vive en la función de dominio, no solo en el enlace de la plantilla.
- **Vocabulario del Gherkin original** → «en proceso» y «notifica al vecino» se corrigen solo en la ficha y en los specs del cambio, sin editar `07-criterios-aceptacion.md` (D4/D6).
- **Selector de rol sin autenticación real** → decisión del curso; RP-10 se lee pero no se implementa.

## Migration Plan

1. No hay migraciones nuevas: `app/main.py` sigue aplicando las existentes en el `lifespan`.
2. `python -m app.db.seed` sigue siendo idempotente y no necesita cambios; el reporte `BC-2026-000102` ya permite probar el cierre.
3. Rollback en desarrollo: borrar `data/app.db` y volver a ejecutar el `seed`. El cambio no altera el esquema; los cierres creados se eliminan con la base.
