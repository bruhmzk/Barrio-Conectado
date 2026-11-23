# Proposal

## Why

En el proceso AS-IS el vecino no recibía retroalimentación y tenía que llamar o ir al municipio para saber en qué etapa estaba su reclamo. Con HU-01 ya se puede registrar un reporte y obtener un número de seguimiento, pero el vecino todavía no tiene ninguna pantalla donde consultarlo: HU-02 completar la cara de consulta de la trazabilidad del TO-BE (`Notifica al vecino el descarte / el estado resuelto`) y permite saber el estado sin contactar al municipio.

## What Changes

- Se agrega la pantalla **«Mis reportes»**, que lista únicamente los reportes cuyo autor es el vecino seleccionado en el selector de demostración, con fecha, categoría y estado actual.
- Si el vecino no tiene reportes, el sistema muestra la lista vacía y el mensaje «No existen reportes asociados a tu cuenta».
- Se agrega el detalle de un reporte, accesible por su número de seguimiento, con su estado actual y el historial de cambios de estado (`CambioEstado`) ordenado por fecha, incluyendo estado anterior, estado nuevo y nota cuando la haya.
- Se agrega soporte de persistencia para `CambioEstado` (entidad del modelo de dominio que aún no tiene tabla), sin crear ni modificar estados: HU-02 es solo lectura.
- Se extiende el `seed` con tres reportes de ejemplo (dos del *Vecino Demo* y uno de un segundo vecino) para poder verificar la lista, el historial fechado y el filtro por autor.
- Se agregan pruebas automáticas: una por cada uno de los tres escenarios Gherkin de la ficha confirmada de HU-02.

**Fuera de alcance:** cambio de estado o registro de nota (HU-04), notificaciones automáticas (HU-05 / RP-08), filtros y ordenación para el administrador (HU-03), descarte y reasignación (HU-07, HU-08), autenticación real (RP-12) y los requisitos no funcionales RP-09, RP-10 y RP-11. Esta historia no dispara transiciones de EST-01 ni participa de sistemas externos: CU-02 no tiene actores externos.

## Capabilities

### New Capabilities
- Ninguna.

### Modified Capabilities
- `reportes`: se agregan requisitos para consultar los reportes propios y su historial de cambios de estado; no se modifican los requisitos de registro de HU-01.

## Impact

- **Historia:** HU-02 — Consultar mis reportes (ficha confirmada en `.cin324/historias/HU-02.md`).
- **Actividad del TO-BE:** Notifica al vecino el descarte / el estado resuelto (trazabilidad) — cara de consulta; tarea de servicio de la Plataforma.
- **Caso de uso:** CU-02 — Consultar historial de reportes (actor principal: Vecino; sin actores externos ni `include`/`extend`).
- **Requisito que cubre:** RP-03.
- **Código afectado:** nuevas rutas y plantillas para la lista y el detalle, una migración nueva para `CambioEstado`, consultas en la capa de dominio, ampliación de `app/db/seed.py` y pruebas pytest. Se reutilizan la base SQLite, el selector de usuario de demostración y los datos de HU-01.
- **Dependencias:** las ya instaladas (FastAPI, Uvicorn, Jinja2, pytest, httpx); no se agregan bibliotecas ni infraestructura.
