# Spec Delta — emergencias

## Purpose

Permite a cualquier usuario reportar una emergencia de estado crítico con una interfaz simplificada, registrarla con prioridad máxima, derivarla de inmediato al Gestor de emergencias y que ese gestor la reciba en una bandeja para tomar conocimiento.

## ADDED Requirements

### Requirement: Acceso directo al apartado de emergencias

El sistema DEBE (MUST) mostrar un apartado **Emergencia** visible en el menú principal y en la pantalla de inicio, y al pulsarlo DEBE mostrar directamente el formulario simplificado de reporte de emergencia, sin pasos intermedios ni campos adicionales obligatorios.

#### Scenario: Acceso directo a reporte de emergencia desde menú principal

- **GIVEN** un usuario autenticado se encuentra en la pantalla principal
- **WHEN** pulsa el botón de emergencia visible en el menú principal
- **THEN** el sistema muestra el formulario simplificado de reporte de emergencia
- **AND** el formulario requiere la menor cantidad de toques posible para su envío: un toque para abrirlo y un toque para enviarlo

### Requirement: Registro simplificado de un reporte de emergencia

El sistema DEBE (MUST) registrar el reporte de emergencia con estado «Recibido», prioridad «Máxima», `esEmergencia = true`, un número de seguimiento único y la fecha y hora del registro, exigiendo únicamente el tipo de emergencia y la ubicación (la descripción es opcional). Además DEBE (MUST) derivarlo automáticamente al departamento «Gestor de emergencias» mediante una asignación inicial y notificar al gestor para atención inmediata.

#### Scenario: Registro exitoso de un reporte de emergencia con interfaz simplificada

- **GIVEN** un usuario autenticado se encuentra en la plataforma
- **AND** accede al apartado de emergencias visible desde el menú principal
- **WHEN** envía el reporte de emergencia con los datos mínimos requeridos (ubicación y tipo)
- **THEN** el sistema registra el reporte con estado "Recibido" y prioridad "Máxima"
- **AND** asigna un número de seguimiento único
- **AND** deriva automáticamente el reporte al Gestor de emergencias
- **AND** notifica al Gestor de emergencias para atención inmediata

### Requirement: Rechazo del registro de emergencia con datos mínimos incompletos

El sistema DEBE (MUST) rechazar el registro cuando falte el tipo de emergencia o la ubicación, y DEBE solicitar que se completen la ubicación y el tipo antes de continuar, sin crear el reporte ni la asignación.

#### Scenario: Registro de emergencia con datos mínimos incompletos

- **GIVEN** un usuario autenticado abrió el formulario simplificado de emergencia
- **WHEN** intenta enviar el reporte sin indicar el tipo de emergencia o la ubicación
- **THEN** el sistema rechaza el registro
- **AND** solicita completar la ubicación y el tipo antes de continuar

### Requirement: Validación de la ubicación del reporte de emergencia

El sistema DEBE (MUST) validar la ubicación del reporte de emergencia con el Sistema de Geolocalización antes de registrarlo y DEBE (MUST) rechazar el registro cuando el servicio informe que la ubicación no es válida, solicitando una nueva ubicación en el mismo formulario simplificado.

#### Scenario: Registro de emergencia con ubicación no válida

- **GIVEN** un usuario autenticado completó el tipo y la ubicación de una emergencia
- **WHEN** envía el reporte y el Sistema de Geolocalización informa que la ubicación no es válida
- **THEN** el sistema no registra el reporte
- **AND** solicita una ubicación válida en el formulario simplificado

### Requirement: Derivación al Gestor cuando la notificación no está disponible

El sistema DEBE (MUST) registrar y derivar el reporte de emergencia al Gestor de emergencias aun cuando el Sistema de Notificaciones no esté disponible, y DEBE (MUST) dejar el aviso pendiente de envío, visible en la bandeja del gestor, sin impedir el registro.

#### Scenario: Derivación al Gestor cuando la notificación no está disponible

- **GIVEN** un usuario autenticado envía una emergencia con datos completos y ubicación válida
- **AND** el Sistema de Notificaciones no está disponible
- **WHEN** el sistema registra el reporte
- **THEN** el reporte queda derivado al Gestor de emergencias con prioridad "Máxima"
- **AND** el aviso al Gestor queda pendiente de envío y visible en su bandeja

### Requirement: Bandeja y detalle de emergencias del Gestor

El sistema DEBE (MUST) mostrar al gestor de emergencias seleccionado una bandeja con los reportes de emergencia derivados, indicando número de seguimiento, tipo, fecha, estado, prioridad y si el aviso quedó pendiente. Al abrir uno DEBE (MUST) mostrar su detalle con ubicación, referencia, descripción cuando la haya e historial de cambios de estado.

#### Scenario: Bandeja con las emergencias derivadas

- **GIVEN** un gestor de emergencias está seleccionado en el selector de usuario de demostración
- **AND** existen reportes de emergencia derivados al departamento «Gestor de emergencias»
- **WHEN** abre la bandeja de emergencias
- **THEN** el sistema muestra únicamente los reportes de emergencia derivados a ese departamento
- **AND** indica número de seguimiento, tipo, fecha, estado y prioridad de cada uno

#### Scenario: Detalle de una emergencia derivada

- **GIVEN** un gestor de emergencias está seleccionado en el selector de usuario de demostración
- **WHEN** abre el detalle de una emergencia de su bandeja
- **THEN** el sistema muestra su ubicación con referencia, la descripción cuando exista y el historial de cambios de estado

### Requirement: Toma de conocimiento de una emergencia

El sistema DEBE (MUST) permitir al gestor de emergencias cambiar el estado de un reporte de «Recibido» a «En atención por Gestor» registrando un `CambioEstado` con fecha, hora, estado anterior, estado nuevo y el gestor responsable. DEBE (MUST) rechazar la operación cuando el reporte no esté en estado «Recibido», conservando su estado sin registrar el cambio.

#### Scenario: Toma de conocimiento exitosa

- **GIVEN** un reporte de emergencia se encuentra en estado "Recibido" con prioridad "Máxima"
- **WHEN** el gestor de emergencias pulsa "Tomar conocimiento"
- **THEN** el sistema cambia el estado del reporte a "En atención por Gestor"
- **AND** registra el cambio de estado con fecha, hora y el gestor responsable

#### Scenario: Toma de conocimiento rechazada por estado inválido

- **GIVEN** un reporte de emergencia no se encuentra en estado "Recibido"
- **WHEN** el gestor de emergencias intenta tomar conocimiento
- **THEN** el sistema rechaza la operación
- **AND** no registra cambio de estado ni modifica el reporte
