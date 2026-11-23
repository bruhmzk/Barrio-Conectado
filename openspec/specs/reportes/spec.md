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

### Requirement: Filtrado de reportes por categoría y prioridad

El sistema DEBE (MUST) permitir al administrador municipal filtrar la lista general de reportes por categoría y prioridad, y DEBE mostrar únicamente los reportes que coinciden con esos criterios, ordenados de mayor a menor prioridad (Alta → Media → Baja).

#### Scenario: Filtrado de reportes por categoría y alta prioridad

- **GIVEN** el administrador municipal revisa la lista general de incidentes
- **WHEN** aplica un filtro por categoría específica y prioridad Alta
- **THEN** el sistema muestra únicamente los reportes que coinciden con esos criterios
- **AND** los ordena mostrando primero los más urgentes (Alta → Media → Baja)

### Requirement: Indicación cuando no hay reportes que coincidan con los filtros

El sistema DEBE (MUST) indicar que no hay resultados y DEBE mantener la opción de cambiar los criterios de búsqueda cuando los filtros aplicados por categoría, prioridad y estado no coinciden con ningún reporte.

#### Scenario: Filtrado sin resultados coincidentes

- **GIVEN** el administrador municipal revisa la lista de incidentes
- **WHEN** aplica filtros por categoría, prioridad y estado que no coinciden con ningún reporte
- **THEN** el sistema indica que no hay resultados
- **AND** mantiene la opción de cambiar los criterios de búsqueda

### Requirement: Consulta combinada de categoría, prioridad y estado

El sistema DEBE (MUST) combinar con AND los filtros por categoría, prioridad y estado que aplique simultáneamente el administrador municipal, y DEBE conservarlos para poder modificarlos.

#### Scenario: Consulta combinada de categoría, prioridad y estado

- **GIVEN** el administrador municipal revisa la lista general de incidentes
- **WHEN** aplica simultáneamente filtros por categoría, prioridad y estado
- **THEN** el sistema muestra solo los reportes que cumplen los tres criterios a la vez
- **AND** conserva los filtros aplicados para poder modificarlos

### Requirement: Visualización del departamento asignado y del estado en la lista

El sistema DEBE (MUST) mostrar en cada fila de la lista general el departamento asignado y el estado actual del reporte, manteniendo el orden de mayor a menor prioridad. «Activos» no es un estado del dominio: los reportes Completado y Descartado se muestran salvo que se filtre explícitamente por otro estado.

#### Scenario: Visualización del departamento asignado y del estado en la lista

- **GIVEN** el administrador municipal consulta la lista general de incidentes
- **WHEN** se muestran los reportes filtrados
- **THEN** cada reporte muestra su departamento asignado y su estado actual
- **AND** el sistema mantiene el orden de mayor a menor prioridad

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
