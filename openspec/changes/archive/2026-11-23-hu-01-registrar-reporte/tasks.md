# Tasks

## 1. Estructura y dependencias

- [x] 1.1 Crear la estructura `app/` (main, db, dominio, servicios, integraciones, rutas, templates) y `requirements.txt`; verificar que `pip install -r requirements.txt` termina sin errores en el entorno virtual.
- [x] 1.2 Crear `app/main.py` con FastAPI, Jinja2 y el montaje de rutas; verificar que `uvicorn app.main:app` arranca y que `GET /` responde 200.

## 2. Base de datos y datos de ejemplo

- [x] 2.1 Escribir la migración `001_esquema_inicial.sql` con `departamentos`, `categorias`, `usuarios`, `reportes`, `ubicaciones`, `fotografias` y `asignaciones`; verificar que `python -m app.db.seed` crea `data/app.db` y registra la migración en `schema_migrations`.
- [x] 2.2 Implementar `app/db/seed.py` idempotente con departamentos (Alumbrado, Aseo, Obras), categorías (Luminaria/media, Microbasural/alta, Bache/alta) y usuarios de demostración (un vecino y un administrador); verificar que ejecutarlo dos veces no duplica filas.
- [x] 2.3 Implementar la conexión a SQLite por solicitud y el helper de transacción; verificar con una prueba que la migración se aplica y que la conexión se cierra.

## 3. Integración simulada de mapas

- [x] 3.1 Implementar `ValidadorUbicacion` y `MapasSimulados` en `app/integraciones/mapas.py`; verificar con pruebas unitarias que acepta coordenadas en rango y rechaza las fuera de rango devolviendo una referencia.

## 4. Lógica de registro

- [x] 4.1 Implementar la generación del número de seguimiento `BC-AAAA-XXXXXX` con verificación de unicidad y reintento; verificar con una prueba de formato y de no repetición.
- [x] 4.2 Implementar `registrar_reporte` en `app/servicios/registrar_reporte.py` con validación de los cuatro campos obligatorios, transacción (reporte + ubicación + fotografía + asignación) y clasificación automática; verificar con pruebas unitarias de campos faltantes, prioridad y departamento.
- [x] 4.3 Crear las rutas `GET /reportes/nuevo` y `POST /reportes`; verificar con `TestClient` los escenarios «Registro exitoso de un reporte con todos los datos» e «Intento de registro con datos incompletos».
- [x] 4.4 Manejar la validación de ubicación con el adaptador simulado; verificar con `TestClient` los escenarios «Ubicación válida» y «Ubicación no válida».

## 5. Pantallas

- [x] 5.1 Crear `base.html` e `inicio.html` con el selector de usuario de demostración y el enlace al registro; verificar `GET /` y `POST /demo/usuario` con `TestClient`.
- [x] 5.2 Crear `nuevo_reporte.html` con los campos categoría, descripción, fotografía y ubicación, y los mensajes de error; verificar que el formulario se renderiza y que los errores se muestran.
- [x] 5.3 Crear `confirmacion.html` que muestra el número de seguimiento; verificar `GET /reportes/{numero_seguimiento}/confirmacion` con un reporte registrado.

## 6. Pruebas de aceptación y documentación

- [x] 6.1 Completar la suite de `pytest` con una prueba por escenario de la especificación (registro exitoso, datos incompletos, ubicación válida, ubicación no válida y clasificación automática) usando una base temporal por prueba; verificar que `pytest` pasa en verde.
- [x] 6.2 Actualizar `README.md` con cómo instalar, ejecutar, cargar datos de ejemplo y probar; verificar que los comandos documentados funcionan tal como están escritos.

## Workflow follow-up

- Revisar las especificaciones con el estudiante y obtener la confirmación antes de implementar.
- Archivar el cambio después de que el estudiante valide el sistema.
