# Tasks

## 1. Consulta de dominio y opciones de filtro

- [x] 1.1 Agregar `PRIORIDADES = ("Alta", "Media", "Baja")` y `listar_reportes_para_administracion(conn, categoria_id=None, prioridad=None, estado=None)` en `app/dominio/reporte.py`, con los joins por Categoría/Asignación/Departamento, los filtros opcionales combinados con AND y el orden por `CASE` de prioridad más `fecha_hora_registro DESC`; verificar con `pytest tests/test_consulta_administracion_hu03.py`.
- [x] 1.2 Crear `tests/test_consulta_administracion_hu03.py` con pruebas de: sin filtros devuelve los tres reportes en orden `BC-2026-000103`, `BC-2026-000102`, `BC-2026-000101`; el filtro Luminaria devuelve solo `BC-2026-000101` con departamento `Alumbrado`; la combinación Luminaria + Media + Recibido devuelve ese mismo folio y Luminaria + Alta + Completado devuelve cero filas sin duplicados; verificar con `pytest tests/test_consulta_administracion_hu03.py`.

## 2. Ruta, pantalla y control del administrador de demostración

- [x] 2.1 Crear `app/rutas/administracion.py` con `APIRouter(prefix="/administracion")` y `GET /administracion/reportes`, leyendo `categoria_id`, `prioridad` y `estado` como strings opcionales (`""` = sin filtro), usando `usuario_actual`, `listar_categorias`, `ESTADOS`, `PRIORIDADES` y la consulta nueva; verificar que `client.get("/administracion/reportes")` responde 200 con *Administrador Demo* elegido.
- [x] 2.2 Crear `app/templates/administracion_reportes.html` extendiendo `base.html`, con formulario `GET`, tres `<select>` con opción vacía, botón «Filtrar», enlace «Limpiar filtros», tabla con número de seguimiento, categoría, prioridad, estado, departamento y fecha, y el mensaje «No hay resultados. Cambia los criterios de búsqueda» sin ocultar el formulario; verificar en el HTML que los valores elegidos quedan seleccionados.
- [x] 2.3 Registrar el router en `app/main.py` y agregar el enlace «Panel de administración» en `app/templates/base.html`; verificar que el enlace aparece en `/` y en `/reportes/nuevo`.
- [x] 2.4 Crear `tests/test_panel_administracion_hu03.py` con las variantes: sin usuario seleccionado y con *Vecino Demo* se muestra «Selecciona un administrador de demostración para ver el panel»; con *Administrador Demo* y sin filtros se listan los tres reportes; verificar con `pytest tests/test_panel_administracion_hu03.py`.

## 3. Escenarios Gherkin de la ficha HU-03

- [x] 3.1 Crear `tests/test_hu03_gherkin.py` con la prueba «HU-03 · Filtrado de reportes por categoría y alta prioridad»: elegir administrador, pedir `categoria_id` de Microbasural y `prioridad=Alta`, y comprobar que solo aparece `BC-2026-000102`; verificar con `pytest tests/test_hu03_gherkin.py -k alta_prioridad`.
- [x] 3.2 Agregar «HU-03 · Filtrado sin resultados coincidentes»: pedir Luminaria + Alta + Completado, comprobar el mensaje «No hay resultados. Cambia los criterios de búsqueda» y que el formulario con los tres filtros sigue presente; verificar con `pytest tests/test_hu03_gherkin.py -k sin_resultados`.
- [x] 3.3 Agregar «HU-03 · Consulta combinada de categoría, prioridad y estado»: pedir Bache + Alta + Recibido, comprobar que solo aparece `BC-2026-000103` y que los tres valores siguen seleccionados en el HTML; verificar con `pytest tests/test_hu03_gherkin.py -k combinada`.
- [x] 3.4 Agregar «HU-03 · Visualización del departamento asignado y del estado en la lista»: sin filtros, comprobar que aparecen `Alumbrado`, `Aseo`, `Obras` y «En revisión», y que el orden de los folios en la respuesta es `BC-2026-000103`, `BC-2026-000102`, `BC-2026-000101`; verificar con `pytest tests/test_hu03_gherkin.py -k departamento`.

## 4. Verificación integral y documentación

- [x] 4.1 Ejecutar `pytest` completo y verificar que pasan las pruebas nuevas y las 40 existentes, sin regresiones en `/reportes/nuevo`, `/reportes` ni `/reportes/{numero_seguimiento}`; verificar con `pytest`.
- [x] 4.2 Actualizar `README.md`: marcar HU-03 como implementada (cambio `hu-03-filtrar-reportes`), documentar `GET /administracion/reportes`, los tres filtros combinables, el orden Alta → Media → Baja con desempate por fecha, el mensaje sin resultados, el uso de *Administrador Demo* y un recorrido manual para los cuatro escenarios Gherkin; conservar los comandos de instalar, crear la base, ejecutar y probar; verificar leyendo el README que todo lo anterior está presente.
