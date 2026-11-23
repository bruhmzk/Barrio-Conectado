# Design

## Context

La aplicación ya tiene HU-01 y HU-02 implementadas: migraciones `001_esquema_inicial.sql` y `002_cambios_estado.sql`, `seed` con departamentos, categorías, tres usuarios y tres reportes de ejemplo, selector de usuario por cookie (`app/rutas/demo.py`), registro de reportes, consulta del vecino y adaptador simulado de mapas. Ver `proposal.md` para la motivación. Las fuentes de verdad de este ciclo son la ficha `.cin324/historias/HU-03.md`, el modelo de dominio (`08-modelo-dominio.md`), EST-01, CU-03 y el flujo reconstruido (HU-03 no tiene DSS, según `12-trazabilidad.md`). Stack: Python 3.12 + FastAPI + Jinja2 + `sqlite3` + pytest.

## Goals / Non-Goals

**Goals:**
- Mostrar el panel de administración con la lista general de reportes y sus columnas de negocio: número de seguimiento, categoría, prioridad, estado, departamento asignado y fecha de registro.
- Aplicar filtros combinables con AND por categoría, prioridad y estado, con mensaje y controles persistentes cuando no haya coincidencias.
- Ordenar por prioridad Alta → Media → Baja y, en empate, por fecha de registro más reciente, sin modificar datos.
- Cubrir cada escenario Gherkin con una prueba automática y las variantes confirmadas (sin administrador seleccionado, sin filtros).

**Non-Goals:**
- Crear tablas, migraciones o columnas nuevas: todas las entidades de la ficha ya están persistidas.
- Confirmar, asignar o reasignar personal (HU-08), cambiar estados o registrar notas (HU-04, HU-07), notificar (HU-05) o ajustar prioridades (HU-06).
- Autenticación real, requisitos no funcionales, integraciones externas, cambios en los documentos del curso ni reescritura de las migraciones 001/002.

## Decisions

### Persistencia: consulta de solo lectura, sin migración nueva

La ficha solo lee `Reporte`, `Categoría`, `Departamento`, `Asignación` y `Usuario`. Ya existen `reportes`, `categorias`, `departamentos`, `asignaciones` y `usuarios` en la migración 001, y `cambios_estado` en la 002; esta historia no las toca. El mensaje «No hay resultados. Cambia los criterios de búsqueda» es un estado de la interfaz, no un dato persistido.

Alternativa descartada: agregar un indicador `activo` a `reportes` o una tabla de vista. El Gherkin usa «reportes activos» pero EST-01 no define ese estado y la decisión D4 lo interpreta como «que coinciden con los filtros aplicados»; agregarlo sería inventar un requisito y obligaría a cambiar HU-01, HU-02, HU-04 y el `seed`.

### Consulta de dominio y orden

Nueva función `listar_reportes_para_administracion(conn, categoria_id=None, prioridad=None, estado=None)` en `app/dominio/reporte.py`:

| Parte | Definición | Origen |
|-------|-----------|--------|
| Columnas | `r.numero_seguimiento`, `r.descripcion`, `r.fecha_hora_registro`, `r.estado`, `r.prioridad`, `c.nombre AS categoria`, `d.nombre AS departamento` | Atributos de `Reporte` y `Categoría`; `Departamento.nombre` vía `Asignación` |
| Joins | `JOIN categorias c ON c.id = r.categoria_id`; `LEFT JOIN asignaciones a ON a.id = (SELECT MIN(id) FROM asignaciones WHERE reporte_id = r.id)`; `LEFT JOIN departamentos d ON d.id = a.departamento_id` | Multiplicidades `Reporte 0..* – 1 Categoría`, `Reporte 1 – 1..* Asignación`, `Asignación 0..* – 1 Departamento` |
| Filtros | `WHERE r.categoria_id = ?`, `r.prioridad = ?`, `r.estado = ?` solo cuando el parámetro llega con valor | CA1 / RP-06; combinados con AND (D5) |
| Orden | `ORDER BY CASE r.prioridad WHEN 'Alta' THEN 1 WHEN 'Media' THEN 2 WHEN 'Baja' THEN 3 ELSE 4 END, r.fecha_hora_registro DESC` | CA2, D5 y desempate confirmado |

Los valores se pasan como parámetros `?`; la lista de condiciones se arma con `AND` a partir de una lista de fragmentos fijos. Alternativas descartadas: interpolar valores en la cadena SQL (riesgo y menor claridad) y ordenar por `r.prioridad` como texto (daría Alta, Baja, Media). El `LEFT JOIN` por `MIN(a.id)` evita filas duplicadas si aparecieran reasignaciones; hoy solo existe la asignación inicial creada por HU-01, y cuando HU-08 se implemente se acordará cuál se considera «vigente».

Se exponen las listas de opciones que ya existen: `listar_categorias(conn)` (`app/dominio/categoria.py`), `ESTADOS` (`app/dominio/reporte.py`, con `Recibido`, `En revisión`, `Completado`, `Descartado`) y una nueva constante `PRIORIDADES = ("Alta", "Media", "Baja")` en el mismo módulo. La opción vacía de cada `<select>` significa «sin filtro».

### Ruta y pantalla derivadas de CU-03 y del flujo reconstruido

| Método y ruta | Propósito |
|---------------|-----------|
| `GET /administracion/reportes` | Panel del Administrador municipal: formulario `GET` con los tres filtros y la tabla de resultados |

Se crea `app/rutas/administracion.py` con `APIRouter(prefix="/administracion")` y se incluye en `app/main.py` junto a los routers existentes. Alternativa descartada: agregar `/reportes/administracion` al router actual; chocaría con la ruta dinámica `/reportes/{numero_seguimiento}` y obligaría a depender del orden de declaración. Con un prefijo propio no hay ambigüedad y no se toca el flujo de HU-01/HU-02.

La plantilla `app/templates/administracion_reportes.html` extiende `base.html`, reutiliza la tabla CSS `.tabla` y muestra:
- El formulario con `name="categoria_id"`, `name="prioridad"` y `name="estado"`, con `method="get"`, un botón «Filtrar» y un enlace «Limpiar filtros» hacia la misma ruta sin parámetros. Los valores elegidos se conservan con Jinja para que puedan modificarse.
- La tabla con las seis columnas de negocio; el estado se muestra tal como está almacenado (`En revisión`, no `EnRevisión`, decisión D4).
- El mensaje «No hay resultados. Cambia los criterios de búsqueda» cuando la consulta devuelve cero filas, sin ocultar el formulario.
- Si no hay filtros, se consulta y muestra todos los reportes (variante confirmada).

### Control del actor de demostración

Se reutiliza `usuario_actual` de `app/rutas/demo.py`. Si no hay usuario seleccionado, o si `usuario["rol"] != "administrador"`, se muestra «Selecciona un administrador de demostración para ver el panel» junto al selector de la cabecera (estado 200), sin consultar la base. Es la sustitución acordada de RP-10: no hay inicio de sesión real, pero el panel no se muestra a un vecino. No se agrega middleware ni dependencia nueva.

Se agrega el enlace «Panel de administración» en `app/templates/base.html`, visible para todos los roles; la propia ruta se encarga de pedir el administrador. Alternativa descartada: condicionar el enlace por rol en la plantilla; dejaría al vecino sin pista de por qué no puede entrar y duplicaría la regla en dos sitios.

### Datos de ejemplo

No se modifica `app/db/seed.py`: los tres reportes ya cubren los filtros (Luminaria/Media/Recibido/Alumbrado, Microbasural/Alta/En revisión/Aseo y Bache/Alta/Recibido/Obras), el orden por prioridad y el caso sin resultados, por ejemplo `Luminaria + Alta + Completado`. Las pruebas crean su propia base temporal con las fixtures existentes; no dependen de `data/app.db`.

### Pruebas

`tests/test_hu03_gherkin.py`, una prueba por cada uno de los cuatro escenarios de la ficha, más las variantes de sin administrador seleccionado, vecino seleccionado y sin filtros. Se reutilizan las fixtures `db_temporal`, `client`, `conexion`, `datos` y `elegir_usuario` de `tests/conftest.py`. Cada prueba envía `client.get("/administracion/reportes", params={...})` después de `elegir_usuario(rol="administrador")` y comprueba el contenido HTML; las pruebas de filtro combinado también comproban el orden de los números de seguimiento en la respuesta.

### Integraciones externas

Ninguna. CU-03 no tiene actores externos y el flujo de ocho pasos es local a SQLite. No se crea ningún adaptador nuevo; el simulador de mapas de HU-01 queda intacto.

## Risks / Trade-offs

- **Colisión de rutas `/reportes/{numero_seguimiento}`** → se usa el prefijo `/administracion`; se añade una prueba que visita `/reportes/nuevo` y `/reportes/BC-2026-000102` para comprobar que HU-01/HU-02 siguen funcionando.
- **Orden textual de prioridades** → se usa `CASE` explícito; una prueba verifica que `Alta` aparece antes que `Media` y `Baja` aunque el orden de inserción sea distinto.
- **Duplicación por `1..* Asignación`** → subconsulta `MIN(a.id)`; supuesto registrado en la ficha mientras HU-08 no se implemente.
- **Vocabulario «activos» del Gherkin original** → decisión D4; la interfaz no ofrece un filtro «Activos» y no oculta estados terminales por defecto.
- **Sin DSS para HU-03** → el flujo es una reconstrucción confirmada; cualquier cambio de orden debe pasar primero por los artefactos del curso.
- **Selector de rol sin autenticación real** → decisión del curso; RP-10 se lee pero no se implementa.

## Migration Plan

1. No hay migraciones nuevas: `app/main.py` sigue aplicando las existentes en el `lifespan`.
2. `python -m app.db.seed` sigue siendo idempotente y no necesita cambios; los datos de ejemplo ya permiten probar la historia.
3. Rollback en desarrollo: borrar `data/app.db` y volver a ejecutar el `seed`; el cambio no altera esquema ni datos.

## Open Questions

Ninguna. Las dudas de alcance, estados, vocabulario y orden quedaron resueltas en las decisiones D1–D6 de la ficha confirmada.
