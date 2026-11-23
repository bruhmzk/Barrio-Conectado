# Proposal

## Why

El proceso AS-IS dispersa los reportes de los vecinos en llamadas, WhatsApp, redes sociales y visitas presenciales, y el municipio los registra a mano en cuadernos o planillas, sin número de seguimiento ni trazabilidad. HU-01 establece el canal único digital y el registro automático de cada reporte, que es la base de todo el proceso TO-BE.

## What Changes

- Se agrega un formulario web para que el vecino registre un reporte con **categoría, descripción, fotografía y ubicación** (GPS o punto en el mapa).
- El sistema valida los cuatro campos obligatorios y rechaza el envío indicando cuáles faltan.
- El sistema valida la ubicación con el **Servicio de mapas y geolocalización** (simulado) y rechaza las coordenadas inválidas.
- Al registrar, el sistema crea el reporte en estado **Recibido**, con número de seguimiento único y fecha y hora.
- El sistema asigna automáticamente la **prioridad** según la `urgenciaBase` de la categoría y el **departamento** que corresponde a la categoría, creando la `Asignación` inicial.
- El sistema muestra una pantalla de confirmación con el número de seguimiento.
- Se agrega un selector de rol/usuario de demostración para identificar al vecino autor (no hay autenticación real).
- Se cargan datos de ejemplo de categorías, departamentos y usuarios.
- Se agregan pruebas automáticas: una por cada escenario Gherkin de HU-01.

**Fuera de alcance:** HU-02 (consultar historial), HU-03 (filtrar), HU-04 (completar con nota), HU-05 (notificaciones), HU-06 (ajuste manual de prioridad), HU-07 (descarte), HU-08 (reasignación), autenticación real (RP-12) y los requisitos no funcionales RP-09, RP-10 y RP-11.

## Capabilities

### New Capabilities
- `reportes`: comportamiento del sistema para registrar y gestionar el ciclo de vida de los reportes ciudadanos; esta historia cubre el registro inicial.

### Modified Capabilities
- Ninguna.

## Impact

- **Historia:** HU-01 — Registrar un reporte.
- **Actividad del TO-BE:** Reporta el problema en la app / Registra el reporte automáticamente.
- **Caso de uso:** CU-01 — Registrar reporte de un problema.
- **Código nuevo:** aplicación Python + FastAPI + Jinja2; tablas `Usuario`, `Categoria`, `Departamento`, `Reporte`, `Ubicacion`, `Fotografia`, `Asignacion`; servicio simulado de mapas; ruta y plantilla de registro; datos de ejemplo; pruebas pytest.
- **Dependencias:** FastAPI, Uvicorn, Jinja2, python-multipart, pytest, httpx.
