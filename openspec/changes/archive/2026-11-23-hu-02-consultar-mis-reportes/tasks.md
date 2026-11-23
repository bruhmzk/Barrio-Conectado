# Tasks

## 1. Persistencia de `CambioEstado`

- [x] 1.1 Crear `app/db/migrations/002_cambios_estado.sql` con la tabla `cambios_estado` (`id`, `reporte_id` con `ON DELETE CASCADE`, `fecha_hora`, `estado_anterior`, `estado_nuevo` con CHECK de los cuatro estados, `nota` opcional, `usuario_id` FK) y el índice por `(reporte_id, fecha_hora)`; verificar que se aplica al arrancar comprobando las columnas en una base temporal.
- [x] 1.2 Agregar `tests/test_migracion_hu02.py` que compruebe que la migración 002 se registra en `schema_migrations`, que la tabla tiene esas columnas y que un `estado_nuevo` inventado es rechazado por el CHECK; verificar con `pytest tests/test_migracion_hu02.py`.

## 2. Datos de ejemplo para la consulta

- [x] 2.1 Ampliar `USUARIOS` en `app/db/seed.py` con `("Vecino Demo 2", "vecino2@demo.cl", "vecino")` sin quitar los usuarios de HU-01; verificar que `python -m app.db.seed` ejecutado dos veces no duplica filas en `usuarios`.
- [x] 2.2 Cargar los tres reportes de ejemplo (`BC-2026-000101`, `BC-2026-000102`, `BC-2026-000103`) con su `Ubicacion`, `Fotografia` y `Asignacion` inicial según la categoría; verificar con una consulta que los tres números existen y que cada uno tiene ubicación, foto y asignación.
- [x] 2.3 Cargar el `CambioEstado` de ejemplo de `BC-2026-000102` (`Recibido → En revisión`, fecha `2026-11-20 10:15`, nota vacía, registrado por *Administrador Demo*); verificar que la tabla `cambios_estado` tenga exactamente esa fila para ese reporte.
- [x] 2.4 Agregar `tests/test_seed_hu02.py` con una prueba de idempotencia que llame dos veces a `sembrar(conn)` sobre la base temporal y compruebe los conteos de usuarios, reportes y cambios de estado; verificar con `pytest tests/test_seed_hu02.py`.

## 3. Lista de reportes propios

- [x] 3.1 Agregar `listar_reportes_de_usuario(conn, usuario_id)` en `app/dominio/reporte.py`, devolviendo número de seguimiento, fecha, categoría y estado, ordenados por fecha descendente; verificar con una prueba de dominio que solo devuelve los reportes del autor indicado.
- [x] 3.2 Agregar `GET /reportes` en `app/rutas/reportes.py` y la plantilla `app/templates/mis_reportes.html` (que extienda `base.html`), con la lista, el mensaje «No existen reportes asociados a tu cuenta» para la lista vacía y el mensaje «Selecciona un vecino de demostración para consultar tus reportes» cuando no haya usuario elegido; verificar con `client.get("/reportes")` que *Vecino Demo* ve 2 reportes y no ve el de *Vecino Demo 2*.
- [x] 3.3 Agregar el enlace «Mis reportes» en `app/templates/base.html` y verificar que aparece en `/` y en `/reportes/nuevo`.

## 4. Detalle e historial de cambios

- [x] 4.1 Agregar `obtener_reporte_para_usuario(conn, numero_seguimiento, usuario_id)` y `listar_cambios_estado(conn, reporte_id)` en `app/dominio/reporte.py`, filtrando el primero por autor y ordenando el historial por `fecha_hora`; verificar con una prueba que un número de seguimiento ajeno devuelva `None`.
- [x] 4.2 Agregar `GET /reportes/{numero_seguimiento}` en `app/rutas/reportes.py` (declarada después de `/reportes/nuevo`) y la plantilla `app/templates/detalle_reporte.html`, mostrando estado actual e historial con fecha, estados y nota, o el texto «Sin cambios de estado registrados»; verificar 200 con el reporte `BC-2026-000102` y 404 con un reporte de otro vecino.
- [x] 4.3 Verificar con `client.get("/reportes/nuevo")` que la ruta literal sigue mostrando el formulario de HU-01 y no es capturada por la ruta dinámica.

## 5. Escenarios Gherkin, verificación integral y documentación

- [x] 5.1 Crear `tests/test_hu02_gherkin.py` con una prueba por escenario de la ficha confirmada — «Visualización exitosa del historial de reportes propios», «Consulta de historial por un vecino sin reportes previos» (creando un vecino sin reportes dentro de la prueba) y «Consulta del historial de cambios de estado de un reporte» — más las variantes de reporte ajeno, reporte sin cambios y sin usuario seleccionado; verificar con `pytest tests/test_hu02_gherkin.py`.
- [x] 5.2 Ejecutar `pytest` completo y verificar que pasan las pruebas nuevas y las 18 de HU-01, sin regresiones en rutas ni en el `seed`.
- [x] 5.3 Actualizar `README.md`: marcar HU-02 como implementada (cambio `hu-02-consultar-mis-reportes`), documentar el usuario *Vecino Demo 2* y los tres reportes de ejemplo, añadir un recorrido manual para los tres escenarios Gherkin y conservar los comandos de instalar, crear la base, ejecutar y probar; verificar leyendo el README que el recorrido, los comandos y el estado de HU-02 estén presentes.
