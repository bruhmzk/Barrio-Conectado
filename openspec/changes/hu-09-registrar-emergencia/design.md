# Design — HU-09 Registrar reporte de emergencia

## Context

Ver `proposal.md`. El sistema ya implementa el registro de reportes normales (HU-01), consulta (HU-02), filtrado (HU-03) y cierre con nota (HU-04) con FastAPI, Jinja2 y `sqlite3`. Los puntos de partida que condicionan este diseño son:

- `app/servicios/registrar_reporte.py` exige foto, categoría, descripción y ubicación, y asigna prioridad según `urgenciaBase`; el flujo de emergencia necesita una validación distinta.
- `app/dominio/reporte.py` define `ESTADOS = ("Recibido", "En revisión", "Completado", "Descartado")` y `PRIORIDADES = ("Alta", "Media", "Baja")`, y el esquema SQL tiene `CHECK` sobre esas listas.
- `app/rutas/demo.py` resuelve al usuario actual desde la cookie `usuario_demo`, con roles `vecino` y `administrador`.
- `app/integraciones/notificaciones.py` y `app/integraciones/mapas.py` son adaptadores simulados, controlables por variables de entorno.
- No existe tabla de notificaciones; HU-04 no persiste una `Notificación` cuando el servicio no está disponible.

## Goals / Non-Goals

**Goals:**

- Un flujo de emergencia independiente del formulario normal, con su propia validación, servicio, rutas y plantillas.
- Persistir `esEmergencia`, la prioridad `Máxima` y los estados de EST-03 sin romper los reportes normales.
- Que la derivación al Gestor sea observable: bandeja, detalle, aviso pendiente y cambio de estado.
- Mantener el selector de rol de demostración y los adaptadores simulados.

**Non-Goals:**

- CU-10 completo (derivar a autoridad, resolver, descartar) y los estados «Derivado a Autoridad», «Resuelto» y «Descartado» de emergencia.
- Notificaciones al vecino (HU-05) y persistencia de `Notificación` como entidad.
- Autenticación real, permisos por sesión y requisitos no funcionales.
- Reutilizar el formulario normal con un campo «es emergencia»: la interfaz simplificada es una pantalla propia.

## Decisions

### 1. Modelo de datos (derivado del modelo de dominio)

Nueva migración `app/db/migrations/003_emergencias.sql`. SQLite no permite alterar `CHECK`, así que las tablas afectadas se reconstruyen copiando sus datos:

| Cambio | Tabla | Detalle |
|---|---|---|
| Nuevo atributo de `Categoría` | `categorias` | `es_emergencia INTEGER NOT NULL DEFAULT 0` |
| Nuevo atributo de `Reporte` | `reportes` | `es_emergencia INTEGER NOT NULL DEFAULT 0`; `prioridad` admite `Máxima`; `estado` admite `En atención por Gestor`, `Derivado a Autoridad` y `Resuelto`; nueva columna `aviso_pendiente INTEGER NOT NULL DEFAULT 0` |
| Nuevos estados en trazabilidad | `cambios_estado` | `estado_nuevo` admite los estados de EST-03 |
| Nuevo rol | `usuarios` | `rol` admite `gestor_emergencias` |
| Nuevo departamento | `departamentos` | se inserta «Gestor de emergencias» desde el seed |

`aviso_pendiente` es la forma mínima de representar el aviso que no pudo enviarse (EST-02, estado `Fallida`): se muestra en la bandeja como «aviso pendiente de envío» sin crear una tabla nueva que el modelo de dominio no exige.

**Alternativa descartada:** una tabla `notificaciones`. El modelo la describe, pero el código de HU-04 decidió no persistirla cuando el servicio falla; introducirla ahora obligaría a rehacer HU-04 y a inventar el envío real.

### 2. Constantes del dominio

- `app/dominio/reporte.py`: agregar `"Máxima"` a `PRIORIDADES` y los estados de EST-03 a `ESTADOS`. El orden de prioridad del panel administrativo pasa a `Máxima → Alta → Media → Baja`.
- `app/dominio/emergencia.py` (nuevo): constantes `ESTADO_EMERGENCIA = "Recibido"`, `PRIORIDAD_MAXIMA = "Máxima"`, `ESTADO_EN_ATENCION = "En atención por Gestor"`, `DEPARTAMENTO_EMERGENCIAS = "Gestor de emergencias"` y consultas de bandeja, detalle y toma de conocimiento.
- El estado persistido es `Recibido` con `prioridad = Máxima`; «Recibido (Máxima prioridad)» es la etiqueta de EST-03, no un valor nuevo de la columna `estado`.

### 3. Registro de emergencia (DSS-03)

`app/servicios/registrar_emergencia.py` con `registrar_emergencia(conn, usuario_id, categoria_id, descripcion, latitud, longitud, validador=None, notificador=None)`:

1. Valida que existan tipo (categoría con `es_emergencia = 1`) y ubicación; la descripción es opcional.
2. Convierte y valida las coordenadas con `MapasSimulados`; si son inválidas, lanza `ErrorValidacion`.
3. Genera el número con `generar_numero_seguimiento`, fija `prioridad = Máxima`, `estado = Recibido`, `es_emergencia = 1` y guarda ubicación, asignación al departamento «Gestor de emergencias» y el `CambioEstado` inicial no se crea (el reporte nace en su estado inicial, igual que HU-01).
4. Solicita el aviso urgente con `NotificacionesSimuladas`; si falla, deja `aviso_pendiente = 1` y el registro continúa.

**Alternativa descartada:** generalizar `registrar_reporte` con un parámetro `es_emergencia`. Mezclaría dos reglas de validación distintas (foto/descripción obligatorias vs. mínimos) y haría más difícil probar cada escenario por separado.

### 4. Rutas (derivadas de DSS-03 y CU-09/CU-10)

Nuevo `app/rutas/emergencias.py` con prefijo `/emergencias`:

| Método y ruta | Propósito | Actor |
|---|---|---|
| `GET /emergencias/nueva` | Formulario simplificado: tipo y ubicación | Cualquier usuario autenticado |
| `POST /emergencias` | Registrar y derivar; redirige a la confirmación | Cualquier usuario autenticado |
| `GET /emergencias/{numero_seguimiento}/confirmacion` | Confirmación con número de seguimiento | Autor del reporte |
| `GET /emergencias` | Bandeja de emergencias derivadas | Gestor de emergencias |
| `GET /emergencias/{numero_seguimiento}` | Detalle con ubicación, descripción e historial | Gestor de emergencias |
| `POST /emergencias/{numero_seguimiento}/tomar-conocimiento` | Cambiar a «En atención por Gestor» | Gestor de emergencias |

La ruta `/emergencias/nueva` se declara antes de `/emergencias/{numero_seguimiento}`. Las rutas del gestor exigen `rol = gestor_emergencias`; si no hay usuario o el rol no corresponde, muestran un aviso y no ejecutan la acción, igual que el panel de administración.

### 5. Interfaz

- `base.html`: enlace **Emergencia** en el menú principal y enlace **Bandeja de emergencias** visible para el rol gestor.
- `inicio.html`: botón destacado **Emergencia** que lleva directo a `/emergencias/nueva` (1 toque).
- `emergencia_nueva.html`: selector de tipo (solo categorías con `es_emergencia = 1`), latitud/longitud con valores de demostración precargados, descripción opcional y un único botón **Enviar emergencia** (2.º toque).
- `emergencia_confirmacion.html`: número de seguimiento, estado, prioridad y aviso de derivación.
- `emergencias_bandeja.html`: tabla con número, tipo, fecha, estado, prioridad y aviso pendiente.
- `emergencia_detalle.html`: ubicación con referencia, descripción, historial y botón **Tomar conocimiento** cuando el estado es `Recibido`.

### 6. Integraciones simuladas

| Sistema | Adaptador | Comportamiento |
|---|---|---|
| Sistema de Geolocalización | `MapasSimulados` (existente) | Valida el rango de coordenadas y devuelve una referencia; no se modifica |
| Sistema de Notificaciones | `NotificacionesSimuladas` (ampliado) | Nuevo método `solicitar_aviso_urgente` con número, tipo, ubicación y destinatario «Gestor de emergencias»; responde «aviso aceptado» o «servicio no disponible» según `CIN324_NOTIFICACIONES_DISPONIBLES` |

### 7. Datos de ejemplo (`app/db/seed.py`)

- Departamento «Gestor de emergencias».
- Categorías **Incendio**, **Emergencia médica** y **Accidente**, con `urgencia_base = 'alta'` y `es_emergencia = 1`, asignadas al departamento del gestor.
- Usuario **Gestor Emergencias Demo** con `rol = gestor_emergencias`.
- Un reporte de emergencia de ejemplo en estado `Recibido` con `aviso_pendiente = 0` y otro en `En atención por Gestor`, para que la bandeja tenga contenido desde el primer arranque.
- Las inserciones nuevas usan `INSERT OR IGNORE` o `WHERE NOT EXISTS` para que el seed siga siendo idempotente.

### 8. Pruebas (una por escenario Gherkin)

`tests/test_hu09_gherkin.py` con los cinco escenarios (dos de camino feliz y tres de error), `tests/test_emergencias_gestor_hu09.py` para bandeja, detalle y toma de conocimiento, y `tests/test_migracion_hu09.py` para comprobar que la migración conserva los reportes previos y que el seed es idempotente. Se usarán las fixtures existentes de `tests/conftest.py` y una base temporal por prueba.

## Risks / Trade-offs

- **Reconstrucción de tablas con `CHECK`** → la migración copia los datos y se prueba sobre una base con reportes de HU-01…HU-04; si algo falla, se restaura el archivo `data/app.db` y se vuelve a sembrar.
- **Prioridad «Máxima» altera el orden y los filtros del panel administrativo** → se actualizan `PRIORIDADES`, el `ORDER BY` y las pruebas de HU-03 para incluir el nuevo valor al inicio.
- **Convivencia de «Resuelto» (EST-03) y «Completado» (EST-01)** → es una decisión confirmada del estudiante; se documenta en la ficha y no se unifican los nombres.
- **Aviso pendiente como columna y no como entidad** → se pierde el historial de reintentos; se acepta porque el alcance no incluye reenvío ni la entidad `Notificación`.
- **El formulario usa coordenadas de demostración** → la ubicación no es un mapa real; se avisa en la pantalla y en el README, coherente con los sistemas simulados.
- **Cualquier usuario autenticado puede reportar emergencias** → es lo que dice el Gherkin («un usuario autenticado»); la restricción por rol aplica solo a la bandeja del gestor.

## Migration Plan

1. Aplicar `003_emergencias.sql` al arrancar (el mecanismo `schema_migrations` ya existe) o al ejecutar `python -m app.db.seed`.
2. Ejecutar el seed para crear el departamento, las categorías, el usuario gestor y los reportes de ejemplo.
3. Verificar con `pytest` que las pruebas de HU-01…HU-04 siguen pasando y que las nuevas de HU-09 pasan.
4. Reversión: restaurar el respaldo de `data/app.db` anterior a la migración, o borrar `data/app.db` y volver a ejecutar el seed para una base limpia.
