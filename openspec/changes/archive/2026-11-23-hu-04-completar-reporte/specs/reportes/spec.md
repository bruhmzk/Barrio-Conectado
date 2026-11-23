# Spec Delta

## ADDED Requirements

### Requirement: Cierre de un reporte con nota de resolución obligatoria

El sistema DEBE (MUST) permitir al administrador municipal completar un reporte en estado «En revisión» adjuntando una nota de resolución no vacía, actualizando el estado a «Completado», registrando el `CambioEstado` con fecha, hora, estados anterior y nuevo, nota y administrador responsable, y haciendo visibles el estado y la nota al vecino autor al consultar su reporte.

#### Scenario: Cierre exitoso de un reporte con justificación

- **GIVEN** un reporte se encuentra en estado "En revisión"
- **WHEN** el administrador municipal cambia el estado a "Completado" y adjunta una nota de resolución
- **THEN** el sistema actualiza definitivamente el estado del reporte
- **AND** registra la nota de resolución con fecha, hora y el administrador que realizó el cambio
- **AND** el vecino creador puede ver el nuevo estado y la nota al consultar su reporte

### Requirement: Rechazo de cierre de reporte sin nota de resolución

El sistema DEBE (MUST) impedir la actualización del estado cuando la nota de resolución esté vacía después de quitar espacios, y DEBE exigir la constancia del trabajo realizado sin registrar `CambioEstado` ni solicitar aviso.

#### Scenario: Intento de cierre de reporte sin nota de resolución

- **GIVEN** un reporte se encuentra en estado "En revisión"
- **WHEN** el administrador municipal intenta cambiar el estado a "Completado" dejando la nota de resolución en blanco
- **THEN** el sistema impide la actualización del estado
- **AND** requiere que se ingrese obligatoriamente la constancia del trabajo realizado

### Requirement: Rechazo de cierre de un reporte que no está En revisión

El sistema DEBE (MUST) rechazar la operación de completar cuando el reporte no esté en «En revisión», y DEBE conservar su estado sin registrar cambio de estado ni nota.

#### Scenario: Intento de cierre de un reporte que no está En revisión

- **GIVEN** un reporte se encuentra en estado "Recibido", "Descartado" o "Completado"
- **WHEN** el administrador municipal intenta completarlo
- **THEN** el sistema rechaza la operación
- **AND** no registra cambio de estado ni nota

### Requirement: Cierre con servicio de notificaciones no disponible

El sistema DEBE (MUST) completar el reporte y registrar la nota aun cuando el Sistema de Notificaciones no esté disponible, y DEBE informar que el aviso quedó pendiente sin persistir una `Notificación`.

#### Scenario: Cierre con servicio de notificaciones no disponible

- **GIVEN** un reporte se encuentra en estado "En revisión"
- **AND** el Sistema de Notificaciones no está disponible
- **WHEN** el administrador municipal cambia el estado a "Completado" y adjunta una nota de resolución
- **THEN** el sistema actualiza el estado a "Completado" y registra la nota
- **AND** confirma el cierre al administrador informando que el aviso quedó pendiente de envío
