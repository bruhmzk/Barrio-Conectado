# Tasks — HU-09 Registrar reporte de emergencia

## 1. Migración y datos de ejemplo

- [x] 1.1 Crear `app/db/migrations/003_emergencias.sql` con `es_emergencia` en `categorias` y `reportes`, `aviso_pendiente` en `reportes`, prioridad `Máxima`, los estados de EST-03 y el rol `gestor_emergencias`. Verificar ejecutando `python -m app.db.seed` sobre una copia de `data/app.db` con reportes de HU-01…HU-04 y comprobando que no se pierde ningún reporte, ubicación, asignación ni cambio de estado.
- [x] 1.2 Extender `PRIORIDADES` y `ESTADOS` en `app/dominio/reporte.py` y el orden de prioridad del panel (`Máxima → Alta → Media → Baja`). Verificar que `pytest tests/test_hu03_gherkin.py tests/test_panel_administracion_hu03.py` sigue pasando.
- [x] 1.3 Ampliar `app/db/seed.py` con el departamento «Gestor de emergencias», las categorías Incendio, Emergencia médica y Accidente, el usuario `Gestor Emergencias Demo` y dos reportes de emergencia de ejemplo (uno `Recibido`, uno `En atención por Gestor`). Verificar que ejecutar el seed dos veces no duplica filas.

## 2. Dominio y registro de emergencia

- [x] 2.1 Crear `app/dominio/emergencia.py` con las constantes de estado, prioridad y departamento, y las consultas de bandeja, detalle y toma de conocimiento. Verificar con pruebas unitarias sobre una base temporal que la bandeja solo lista `es_emergencia = 1` asignados al Gestor.
- [x] 2.2 Crear `app/servicios/registrar_emergencia.py` que valide tipo y ubicación (descripción opcional), consulte `MapasSimulados`, registre el reporte con `prioridad = Máxima`, `estado = Recibido`, `es_emergencia = 1`, número de seguimiento y asignación al Gestor, y deje `aviso_pendiente = 1` si la notificación falla. Verificar que las pruebas de validación rechazan datos mínimos incompletos y ubicación inválida sin crear filas.
- [x] 2.3 Ampliar `app/integraciones/notificaciones.py` con `solicitar_aviso_urgente` (número, tipo, ubicación, destinatario «Gestor de emergencias») y verificar con `CIN324_NOTIFICACIONES_DISPONIBLES=0` que responde «servicio no disponible» sin lanzar excepción.
- [x] 2.4 Crear `app/rutas/emergencias.py` con `GET /emergencias/nueva`, `POST /emergencias` y `GET /emergencias/{numero_seguimiento}/confirmacion`, y registrarlo en `app/main.py`. Verificar con `TestClient` que el registro redirige a la confirmación con el número de seguimiento.
- [x] 2.5 Escribir `tests/test_hu09_gherkin.py` con los escenarios «Registro exitoso…», «Registro de emergencia con datos mínimos incompletos», «Registro de emergencia con ubicación no válida» y «Derivación al Gestor cuando la notificación no está disponible»; verificar que los cuatro pasan con `pytest tests/test_hu09_gherkin.py`.

## 3. Pantallas del vecino

- [x] 3.1 Agregar el enlace **Emergencia** al menú de `app/templates/base.html` y el botón destacado en `app/templates/inicio.html`, apuntando a `/emergencias/nueva`. Verificar con `TestClient` el escenario «Acceso directo a reporte de emergencia desde menú principal» (el botón existe y lleva al formulario en un solo paso).
- [x] 3.2 Crear `app/templates/emergencia_nueva.html` con selector de tipo (solo categorías de emergencia), coordenadas de demostración precargadas, descripción opcional y un único botón «Enviar emergencia», mostrando los errores de validación. Verificar con `TestClient` que un envío con dos clics registra el reporte y que un envío sin tipo o ubicación vuelve al formulario con el mensaje correspondiente.
- [x] 3.3 Crear `app/templates/emergencia_confirmacion.html` que muestre número de seguimiento, estado «Recibido», prioridad «Máxima», derivación al Gestor y, si corresponde, «aviso pendiente de envío». Verificar con `TestClient` que la página contiene el número generado.

## 4. Bandeja y detalle del Gestor de emergencias

- [x] 4.1 Agregar a `app/rutas/emergencias.py` las rutas `GET /emergencias` y `GET /emergencias/{numero_seguimiento}` protegidas para el rol `gestor_emergencias`, con aviso cuando no hay gestor seleccionado. Verificar con `TestClient` que un vecino o administrador no accede a la bandeja y que el gestor sí.
- [x] 4.2 Crear `app/templates/emergencias_bandeja.html` y `app/templates/emergencia_detalle.html` con número, tipo, fecha, estado, prioridad, aviso pendiente, ubicación, referencia, descripción cuando exista e historial de cambios. Verificar con `TestClient` que la bandeja lista solo emergencias derivadas y que el detalle muestra la ubicación.
- [x] 4.3 Implementar `POST /emergencias/{numero_seguimiento}/tomar-conocimiento` para pasar de «Recibido» a «En atención por Gestor» registrando `CambioEstado` con el gestor responsable, rechazando cualquier otro estado. Verificar con `tests/test_emergencias_gestor_hu09.py` los dos casos: toma exitosa y rechazo por estado inválido.
- [x] 4.4 Escribir `tests/test_emergencias_gestor_hu09.py` con bandeja, detalle, toma exitosa, rechazo por estado inválido y control de rol; verificar que pasa completo.

## 5. Integración y documentación

- [x] 5.1 Ejecutar la suite completa (`pytest`) y verificar que las 70 pruebas anteriores y las nuevas de HU-09 pasan sin regresiones, incluida `tests/test_migracion_hu09.py` si se agrega la comprobación de la migración.
- [x] 5.2 Actualizar `README.md` con la instalación, el seed, el arranque, el recorrido manual de los cinco escenarios, el rol de gestor en el selector y el comando de pruebas; verificar que los comandos documentados funcionan tal como están escritos.

## Workflow follow-up

- Archivar el cambio con `openspec-archive-change` después de que el estudiante valide el sistema.
- Actualizar `.cin324/proyecto.md` (HU-09 hecha, cambio archivado, comandos y observaciones).
- Sugerir el commit `HU-09: registrar reporte de emergencia (cambio hu-09-registrar-emergencia)`.
