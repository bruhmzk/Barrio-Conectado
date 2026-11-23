# Tasks

## 1. Adaptador del Sistema de Notificaciones simulado

- [x] 1.1 Crear `app/integraciones/notificaciones.py` con `Notificador`, `SolicitudAviso`, `ResultadoAviso` y `NotificacionesSimuladas(disponible=True)`, mensaje `solicitar_aviso`, registro en consola, respuesta «aviso aceptado» o «aviso pendiente de envío» y activación de caída con `CIN324_NOTIFICACIONES_DISPONIBLES=0`; verificar con `pytest tests/test_notificaciones_hu04.py`.
- [x] 1.2 Crear `tests/test_notificaciones_hu04.py` con tres pruebas: solicitud aceptada, servicio no disponible y ausencia de tabla `notificaciones` en la migración aplicada; verificar con `pytest tests/test_notificaciones_hu04.py`.

## 2. Transición de estado y persistencia del CambioEstado

- [x] 2.1 Agregar en `app/dominio/reporte.py` el resultado `ResultadoCierre` y la función `completar_reporte(conn, numero_seguimiento, nota, usuario_id, notificador=None)` con relectura del estado, guarda de nota no vacía tras quitar espacios, actualización de `reportes.estado`, inserción atómica en `cambios_estado` y llamada al notificador después del `commit`; verificar con `pytest tests/test_completar_reporte_hu04.py`.
- [x] 2.2 Crear `tests/test_completar_reporte_hu04.py` con pruebas de: cierre exitoso escribe `Completado` y un `CambioEstado` con nota y `usuario_id`; nota en blanco o con espacios no escribe; estado `Recibido` o `Completado` no escribe; `BC-2026-000102` sigue en «En revisión» tras el `seed`; verificar con `pytest tests/test_completar_reporte_hu04.py`.

## 3. Rutas, pantalla de cierre y control del administrador de demostración

- [x] 3.1 Agregar en `app/rutas/administracion.py` las rutas `GET` y `POST /administracion/reportes/{numero_seguimiento}/completar`, usando `usuario_actual`, `obtener_reporte_por_numero`, `completar_reporte` y `NotificacionesSimuladas`, con mensajes de error 400 y confirmación con el resultado del aviso; verificar que `client.get("/administracion/reportes/BC-2026-000102/completar")` responde 200 con *Administrador Demo* elegido.
- [x] 3.2 Crear `app/templates/completar_reporte.html` extendiendo `base.html`, con el número de seguimiento, descripción, estado actual, `<textarea name="nota">`, botón «Completar reporte», mensajes «La nota de resolución es obligatoria», rechazo por estado y confirmación con «aviso aceptado»/«aviso pendiente de envío»; verificar los textos en el HTML devuelto por `client`.
- [x] 3.3 Agregar en `app/templates/administracion_reportes.html` la columna «Acción» con el enlace «Completar» solo para reportes en «En revisión», y en `app/rutas/administracion.py` el mensaje «Selecciona un administrador de demostración para completar el reporte» cuando falte el rol; verificar que el enlace aparece para `BC-2026-000102` y no para `BC-2026-000101`.
- [x] 3.4 Crear `tests/test_panel_completar_hu04.py` con las variantes: sin usuario y con *Vecino Demo* se muestra el mensaje de administrador sin escribir en la base; con *Administrador Demo* se abre el formulario; un `POST` directo sobre `BC-2026-000101` es rechazado; verificar con `pytest tests/test_panel_completar_hu04.py`.

## 4. Escenarios Gherkin de la ficha HU-04

- [x] 4.1 Crear `tests/test_hu04_gherkin.py` con la prueba «HU-04 · Cierre exitoso de un reporte con justificación»: completar `BC-2026-000102` con nota, comprobar «Completado», el `CambioEstado` y que el vecino autor ve el estado y la nota en `/reportes/BC-2026-000102`; verificar con `pytest tests/test_hu04_gherkin.py -k cierre_exitoso`.
- [x] 4.2 Agregar «HU-04 · Intento de cierre de reporte sin nota de resolución»: enviar nota vacía, comprobar «La nota de resolución es obligatoria», que el estado sigue «En revisión» y que no hay `CambioEstado` nuevo; verificar con `pytest tests/test_hu04_gherkin.py -k sin_nota`.
- [x] 4.3 Agregar «HU-04 · Intento de cierre de un reporte que no está En revisión»: intentar completar `BC-2026-000101`, comprobar el rechazo y que no cambian el estado ni el historial; verificar con `pytest tests/test_hu04_gherkin.py -k estado_invalido`.
- [x] 4.4 Agregar «HU-04 · Cierre con servicio de notificaciones no disponible»: forzar `NotificacionesSimuladas(disponible=False)`, comprobar que el cierre se registra y que aparece «aviso pendiente de envío» sin tabla `notificaciones`; verificar con `pytest tests/test_hu04_gherkin.py -k servicio_no_disponible`.

## 5. Verificación integral y documentación

- [x] 5.1 Ejecutar `pytest` completo y verificar que pasan las pruebas nuevas y las 51 existentes, sin regresiones en `/reportes/nuevo`, `/reportes`, `/reportes/{numero_seguimiento}` ni `/administracion/reportes`; verificar con `& ".venv\Scripts\python.exe" -m pytest -q`.
- [x] 5.2 Actualizar `README.md`: marcar HU-04 como implementada (cambio `hu-04-completar-reporte`), documentar las rutas de cierre, la nota obligatoria, el rechazo por estado, la simulación del Sistema de Notificaciones sin tabla `Notificación`, la visibilidad para el vecino y un recorrido manual para los cuatro escenarios Gherkin con *Administrador Demo* y `BC-2026-000102`; conservar los comandos de instalar, crear la base, ejecutar y probar; verificar leyendo el README que todo lo anterior está presente.

## Workflow follow-up

- Archivar el cambio después de que el estudiante valide el sistema.
- Verificar el cambio archivado y actualizar `.cin324/proyecto.md` con la historia hecha y el nombre del cambio.
