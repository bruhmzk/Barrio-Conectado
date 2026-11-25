# Spec Delta — reportes

## MODIFIED Requirements

### Requirement: Clasificación automática al registrar

El sistema DEBE (MUST) asignar automáticamente a los reportes normales (no de emergencia) la prioridad según la `urgenciaBase` de su categoría y el departamento que corresponde a esa categoría, creando la asignación inicial sin intervención del administrador. Los reportes de emergencia se clasifican con prioridad «Máxima» y se asignan al Gestor de emergencias, según la capacidad `emergencias`.

#### Scenario: Prioridad y departamento asignados según la categoría

- **GIVEN** un vecino envía un reporte normal con una categoría registrada en el sistema
- **WHEN** el sistema registra el reporte
- **THEN** asigna la prioridad correspondiente a la `urgenciaBase` de la categoría
- **AND** asigna el departamento asociado a la categoría mediante una asignación inicial

#### Scenario: Un reporte de emergencia no usa la urgencia base de la categoría

- **GIVEN** un usuario envía un reporte de emergencia con una categoría marcada como emergencia
- **WHEN** el sistema registra el reporte
- **THEN** le asigna prioridad "Máxima" en lugar de la `urgenciaBase` de la categoría
- **AND** lo asigna al departamento «Gestor de emergencias»
