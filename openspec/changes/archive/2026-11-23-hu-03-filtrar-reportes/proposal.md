# Proposal

## Why

En el AS-IS el departamento técnico revisaba los reclamos acumulados con criterio propio y sin una asignación formal, por lo que los casos más críticos no podían identificarse de forma objetiva. Con HU-01 y HU-02 ya se pueden registrar y consultar reportes, pero el administrador municipal todavía no tiene una vista que le permita revisar la lista general, filtrarla y ordenarla para decidir por dónde empezar. HU-03 implementa la parte de **revisión** de la actividad del TO-BE «Revisa y confirma la asignación» (RP-06, CU-03), apoyada en la prioridad y el departamento que HU-01 ya asigna automáticamente.

## What Changes

- Se agrega una pantalla de **panel de administración** para el usuario *Administrador Demo* del selector de demostración, con la lista general de reportes: número de seguimiento, categoría, prioridad, estado, departamento asignado y fecha de registro.
- Se agregan filtros por **categoría**, **prioridad** (Alta / Media / Baja) y **estado** (Recibido / En revisión / Completado / Descartado), combinables entre sí con **AND**; sin filtros se muestran todos los reportes.
- La lista se ordena de **mayor a menor prioridad** (Alta → Media → Baja); en empate, por fecha de registro más reciente. El orden se aplica después de filtrar.
- Si no hay coincidencias, se muestra «No hay resultados. Cambia los criterios de búsqueda» y los filtros siguen visibles y modificables.
- Se muestra el departamento asignado leyendo la `Asignación` existente de cada reporte; no se crean ni modifican asignaciones.
- Se usa una consulta de solo lectura en SQLite (`SELECT` con `WHERE` dinámico y `ORDER BY`). No se agregan tablas ni migraciones: las entidades que intervienen ya existen desde HU-01 y HU-02.
- Se agregan cuatro pruebas automáticas, una por cada escenario Gherkin de la ficha confirmada de HU-03, más las variantes de sin administrador seleccionado y sin filtros.

**Fuera de alcance:** la confirmación, asignación y reasignación de personal (HU-08); el cambio de estado con nota de resolución (HU-04); el descarte con motivo (HU-07); las notificaciones automáticas (HU-05 / RP-08); el ajuste manual de prioridad (HU-06); la autenticación real (RP-12) y los requisitos no funcionales RP-09, RP-10 y RP-11. HU-03 no dispara transiciones de EST-01, no registra `CambioEstado`, no genera `Notificación` y no participa de sistemas externos: CU-03 no tiene actores externos y el flujo es local a SQLite.

## Capabilities

### New Capabilities

- Ninguna.

### Modified Capabilities

- `reportes`: se agregan requisitos para filtrar por categoría, prioridad y estado, ordenar por prioridad y mostrar el departamento asignado en la lista general del administrador; no se modifican los requisitos de registro (HU-01) ni de consulta del vecino (HU-02).

## Impact

- **Historia:** HU-03 — Filtrar reportes para asignar personal (ficha confirmada en `.cin324/historias/HU-03.md`).
- **Actividad del TO-BE:** Revisa y confirma la asignación — solo la cara de revisión; tarea de usuario del administrador con apoyo de la Plataforma BarrioConectado.
- **Caso de uso:** CU-03 — Filtrar reportes para asignación (actor principal: Administrador municipal; sin actores externos ni `include`/`extend`). El flujo no tiene DSS: está reconstruido desde el Gherkin y los CA, según `12-trazabilidad.md`.
- **Requisito que cubre:** RP-06. RP-04 y RP-05 son contexto; RP-10 se lee pero no se implementa.
- **Código afectado:** nuevas funciones de consulta en `app/dominio/reporte.py`, una nueva ruta en `app/rutas/reportes.py`, una nueva plantilla en `app/templates/`, un enlace en `app/templates/base.html` y nuevas pruebas pytest. Se reutilizan la base SQLite, el selector de usuario de demostración, las migraciones 001 y 002 y los tres reportes de ejemplo del `seed`.
- **Dependencias:** las ya instaladas (FastAPI, Uvicorn, Jinja2, pytest, httpx); no se agregan bibliotecas ni infraestructura, y no hay integraciones externas que simular.
