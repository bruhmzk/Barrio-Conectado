# reportes Specification

## Purpose

Permite a los vecinos registrar reportes de problemas en la vía pública y al municipio recibirlos clasificados, priorizados y con trazabilidad desde el primer momento.

## Requirements

### Requirement: Registro de un reporte con datos obligatorios

El sistema DEBE (MUST) exigir fotografía, ubicación, categoría y descripción para registrar un reporte, y DEBE rechazar el envío indicando los datos obligatorios que falten.

#### Scenario: Registro exitoso de un reporte con todos los datos

- **GIVEN** un vecino autenticado se encuentra en la plataforma y dispone de una fotografía, ubicación válida, categoría y descripción del problema
- **WHEN** envía el reporte del incidente
- **THEN** el sistema registra el reporte con estado "Recibido"
- **AND** asigna un número de seguimiento único para el seguimiento del vecino

#### Scenario: Intento de registro con datos incompletos

- **GIVEN** un vecino está redactando un reporte de incidente
- **WHEN** intenta enviar el reporte sin adjuntar una fotografía, descripción, categoría o ubicación válida
- **THEN** el sistema rechaza el registro
- **AND** solicita que se completen los datos obligatorios antes de continuar

### Requirement: Validación de la ubicación del reporte

El sistema DEBE (MUST) validar la ubicación del reporte con el Servicio de mapas y geolocalización antes de registrarlo, y DEBE rechazar las coordenadas no válidas solicitando una nueva ubicación.

#### Scenario: Ubicación válida

- **GIVEN** un vecino envió un reporte con todos los datos obligatorios
- **WHEN** el Servicio de mapas y geolocalización informa que la ubicación es válida
- **THEN** el sistema continúa con el registro del reporte
- **AND** conserva la referencia de la ubicación informada por el servicio

#### Scenario: Ubicación no válida

- **GIVEN** un vecino envió un reporte con todos los datos obligatorios
- **WHEN** el Servicio de mapas y geolocalización informa que la ubicación no es válida
- **THEN** el sistema rechaza el registro
- **AND** solicita al vecino una nueva ubicación

### Requirement: Trazabilidad del reporte registrado

El sistema DEBE (MUST) registrar la fecha y hora del reporte, asignarle un número de seguimiento único y mostrar al vecino una confirmación con ese número.

#### Scenario: Confirmación con número de seguimiento

- **GIVEN** un reporte con datos completos y ubicación válida
- **WHEN** el sistema lo registra
- **THEN** guarda la fecha y hora del registro
- **AND** muestra al vecino el número de seguimiento asignado

### Requirement: Clasificación automática al registrar

El sistema DEBE (MUST) asignar automáticamente al reporte la prioridad según la `urgenciaBase` de su categoría y el departamento que corresponde a esa categoría, creando la asignación inicial sin intervención del administrador.

#### Scenario: Prioridad y departamento asignados según la categoría

- **GIVEN** un vecino envía un reporte con una categoría registrada en el sistema
- **WHEN** el sistema registra el reporte
- **THEN** asigna la prioridad correspondiente a la `urgenciaBase` de la categoría
- **AND** asigna el departamento asociado a la categoría mediante una asignación inicial
