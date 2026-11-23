# Spec Delta

## ADDED Requirements

### Requirement: Consulta de los reportes propios

El sistema DEBE (MUST) mostrar al vecino seleccionado únicamente los reportes que él mismo envió, con fecha, categoría y estado actual, y DEBE indicar con una lista vacía y un mensaje cuando no tenga reportes asociados a su cuenta.

#### Scenario: Visualización exitosa del historial de reportes propios

- **GIVEN** un vecino ha registrado uno o más reportes previamente
- **WHEN** solicita consultar el historial de sus reportes
- **THEN** el sistema despliega la lista de todos sus reportes
- **AND** muestra el estado actual de cada uno de ellos

#### Scenario: Consulta de historial por un vecino sin reportes previos

- **GIVEN** un vecino nunca ha registrado un reporte
- **WHEN** solicita consultar el historial de sus reportes
- **THEN** el sistema muestra una lista vacía
- **AND** le notifica que no existen reportes asociados a su cuenta

#### Scenario: Un vecino no ve los reportes de otro vecino

- **GIVEN** otro vecino tiene reportes registrados en el sistema
- **WHEN** el vecino seleccionado solicita consultar sus propios reportes
- **THEN** el sistema no muestra los reportes del otro vecino
- **AND** no permite abrirlos desde la lista del vecino

### Requirement: Historial de cambios de estado del reporte

El sistema DEBE (MUST) mostrar, al abrir un reporte propio por su número de seguimiento, el estado actual y el historial de cambios de estado registrados, ordenados por fecha, con estado anterior, estado nuevo y nota cuando la haya, sin modificar el estado del reporte.

#### Scenario: Consulta del historial de cambios de estado de un reporte

- **GIVEN** un vecino tiene un reporte con cambios de estado registrados
- **WHEN** abre el detalle de ese reporte
- **THEN** el sistema muestra el historial de cambios con su fecha
- **AND** muestra el estado anterior, el estado nuevo y la nota cuando la haya

#### Scenario: Reporte sin cambios de estado registrados

- **GIVEN** un vecino tiene un reporte recién registrado en estado "Recibido"
- **WHEN** abre el detalle de ese reporte
- **THEN** el sistema muestra el estado actual "Recibido"
- **AND** muestra el historial de cambios vacío

### Requirement: Identificación del vecino al consultar

El sistema DEBE (MUST) usar el vecino elegido en el selector de usuario de demostración para filtrar la consulta y DEBE pedir que se seleccione uno antes de mostrar reportes cuando no haya ninguno elegido.

#### Scenario: Vecino seleccionado

- **GIVEN** un vecino está usando el selector de usuario de demostración
- **WHEN** solicita consultar el historial de sus reportes
- **THEN** el sistema filtra los reportes por ese vecino como autor

#### Scenario: Sin vecino seleccionado

- **GIVEN** ningún usuario de demostración está seleccionado
- **WHEN** se solicita consultar el historial de reportes
- **THEN** el sistema pide seleccionar un vecino antes de continuar
