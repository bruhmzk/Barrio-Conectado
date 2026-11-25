# Propuesta — HU-09 Registrar reporte de emergencia

## Why

Los reportes de problemas de la vía pública no cubren las situaciones de estado crítico: hoy no existe una forma rápida de alertar al municipio cuando hay una emergencia, y el flujo normal (foto, descripción, categoría) exige demasiados pasos para el poco tiempo disponible. La Evaluación 2 incorporó la **HU-09**, el requisito **RP-13**, el actor **Gestor de emergencias** y la bifurcación de emergencia en el TO-BE, de modo que el sistema debe permitir reportar una emergencia con una interfaz simplificada, prioridad máxima y derivación inmediata.

## What Changes

- Nuevo apartado **Emergencia** visible en el menú principal y en la pantalla de inicio, con un formulario simplificado que solo pide **tipo de emergencia** y **ubicación** (la descripción es opcional).
- Registro automático del reporte de emergencia con `esEmergencia = true`, prioridad **Máxima**, estado **Recibido**, número de seguimiento único y asignación automática al departamento **Gestor de emergencias**.
- Validación de la ubicación con el Servicio de mapas y geolocalización simulado; rechazo con mensaje cuando faltan datos mínimos o la ubicación no es válida.
- Aviso urgente simulado al Gestor de emergencias; si el servicio no está disponible, el reporte igual queda registrado y derivado, y el aviso queda pendiente.
- Pantalla mínima del Gestor de emergencias (CU-10): **bandeja de emergencias**, **detalle** del reporte y acción **Tomar conocimiento**, que lleva el reporte de **Recibido (Máxima prioridad)** a **En atención por Gestor** registrando el `CambioEstado`.
- Nuevos datos de ejemplo: departamento «Gestor de emergencias», categorías **Incendio**, **Emergencia médica** y **Accidente** (`esEmergencia = true`) y un usuario con rol de gestor de emergencias; también reportes de emergencia de ejemplo para la bandeja.
- Ajuste del modelo de datos: `esEmergencia` en `reportes` y `categorias`, prioridad `Máxima` y estados de EST-03 en la base de datos, y rol `gestor_emergencias`.

**Fuera de alcance:** CU-10 completo (derivar a autoridad, resolver con nota, descartar con motivo y los estados «Derivado a Autoridad», «Resuelto» y «Descartado» de EST-03), notificaciones al vecino por cambio de estado (HU-05), filtrado/priorización manual (HU-03, HU-06), reasignación de departamentos (HU-08), autenticación real (se mantiene el selector de rol de demostración) y los requisitos no funcionales de `06-atributos-calidad.md`.

## Capabilities

### New Capabilities

- `emergencias`: registro de reportes de emergencia con interfaz simplificada, prioridad Máxima, derivación automática y bandeja mínima del Gestor de emergencias.

### Modified Capabilities

- `reportes`: la clasificación automática al registrar se limita a los reportes normales; los reportes de emergencia se clasifican con prioridad Máxima y se asignan al Gestor de emergencias según la capacidad `emergencias`.

## Impact

- **Código afectado:** `app/main.py` (nuevo router), `app/rutas/emergencias.py` (nuevo), `app/servicios/registrar_emergencia.py` (nuevo), `app/dominio/emergencia.py` (nuevo), `app/integraciones/notificaciones.py` (aviso urgente al gestor), `app/db/seed.py`, plantillas `base.html`, `inicio.html` y nuevas plantillas de emergencia.
- **Base de datos:** nueva migración `003_emergencias.sql` (columnas `esEmergencia`, prioridades y estados de emergencia, rol `gestor_emergencias` y su tabla de avisos pendientes si aplica).
- **APIs/rutas nuevas:** `GET /emergencias/nueva`, `POST /emergencias`, `GET /emergencias/{numero_seguimiento}/confirmacion`, `GET /emergencias` (bandeja del gestor), `GET /emergencias/{numero_seguimiento}` (detalle), `POST /emergencias/{numero_seguimiento}/tomar-conocimiento`.
- **Pruebas:** una prueba automática por cada uno de los cinco escenarios Gherkin de HU-09, más pruebas de la bandeja y del cambio de estado.
- **Sistemas externos simulados:** Servicio de mapas y geolocalización (ya existe) y Sistema de Notificaciones (se reutiliza el adaptador con un mensaje de aviso urgente al gestor).
