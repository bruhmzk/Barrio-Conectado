# Criterios de aceptación (Gherkin)

## HU-01 — Registrar un reporte

Historia: Como vecino, quiero registrar un reporte adjuntando una foto, mi ubicación y una descripción, para informar a las autoridades de un problema de mi barrio de forma rápida y bien documentada.

```gherkin
Característica: Registro de reportes de incidentes

  Escenario: Registro exitoso de un reporte con todos los datos
    Dado que un vecino autenticado se encuentra en la plataforma 
    Y dispone de una fotografia, ubicacion valida y descripcion del problema
    Cuando envia el reporte del incidente
    Entonces el sistema registra el reporte con estado "Ingresado"
    Y asigna un numero de folio unico para el seguimiento del vecino

  Escenario: Intento de registro con datos incompletos
    Dado que un vecuno esta redactando un reporte de incidente
    Cuando intenta enviar el reporte sin adjuntar una descripcion o ubicacion valida
    Entonces el sistema rechaza el registro 
    Y solicita que se completen los datos obligatorios antes de continuar
```

## HU-02 — Consultar mis reportes

Historia: Como vecino, quiero consultar el historial y el estado de mis reportes enviados, para saber en qué etapa está cada uno sin tener que llamar ni ir al municipio.

```gherkin
Característica: Consulta de historial de reportes

  Escenario: Visualización exitosa del historial de reportes activos
    Dado que un vecino ha registrado uno o más reportes previamente
    Cuando solicita consultar el historial de sus solicitudes
    Entonces el sistema despliega la lista de todos sus incidentes reportados
    Y muestra el estado actualizado de cada uno de ellos.

Escenario: Escenario: Consulta de historial por un vecino sin reportes previos
    Dado que un vecino nunca ha registrado un reporte de incidente
    Cuando solicita consultar el historial de sus solicitudes
    Entonces el sistema muestra una lista vacía
    Y le notifica que no existen reportes asociados a su cuenta.
```

## HU-03 — Filtrar reportes para asignar personal

Historia: Como administrador municipal, quiero filtrar los reportes por categoría y prioridad, para asignar personal a la reparación empezando por los casos más críticos.

```gherkin
Característica: Filtrado y priorizacion de reportes 

  Escenario: Filtrado de reportes por alta priorizacion 
    Dado que el administrador municipal revisa la lista general de incidentes
    Cuando aplica un filtro por categoria especifica y prioridad alta
    Entonces el sistema muestra unicamente los reportes que coinciden con esos criterios
    Y los ordena mostrando primero los mas urgentes.

  Escenario: Filtrado sin resultados coincidentes 
    Dado que el administrador municipal revisa la lista de incidentes
    Cuando aplica un filtro para una categoria que no tiene reportes activos
    Entonces el sistema indica que no hay resultados
    Y mantiene la opcion de cambiar los criterios de busqueda
```

## HU-04 — Completar un reporte con nota de resolución

Historia: Como administrador municipal, quiero cambiar el estado de un reporte a "Completado" y añadir una nota de resolución, para dejar constancia del trabajo realizado y que el vecino pueda verlo.

```gherkin
Característica: Resolución de reportes de incidentes

  Escenario: Escenario: Cierre exitoso de un reporte con justificación
    Dado que un reporte se encuentra en estado de revisión o en proceso
    Cuando el administrador municipal cambia el estado a "Completado" y adjunta una nota de resolución
    Entonces el sistema actualiza definitivamente el estado del reporte
    Y notifica al vecino creador que su incidente ha sido resuelto junto con la nota adjunta.

  Escenario: Escenario: Intento de cierre de reporte sin nota de resolución
    Dado que un reporte se encuentra en proceso de atención
    Cuando el administrador municipal intenta cambiar el estado a "Completado" dejando la nota de resolución en blanco
    Entonces el sistema impide la actualización del estado
    Y requiere que se ingrese obligatoriamente la constancia del trabajo realizado.
```

## HU-09 — Registrar reporte de emergencia

Historia: Como usuario, quiero enviar un nuevo tipo de reporte, para reportar emergencias de estado crítico.

```gherkin
Característica: Registro de reportes de emergencia

  Escenario: Registro exitoso de un reporte de emergencia con interfaz simplificada
    Dado que un usuario autenticado se encuentra en la plataforma
    Y accede al apartado de emergencias visible desde el menú principal
    Cuando envía el reporte de emergencia con los datos mínimos requeridos (ubicación y tipo)
    Entonces el sistema registra el reporte con estado "Recibido" y prioridad "Máxima"
    Y asigna un número de seguimiento único
    Y deriva automáticamente el reporte al Gestor de emergencias
    Y notifica al Gestor de emergencias para atención inmediata

  Escenario: Acceso directo a reporte de emergencia desde menú principal
    Dado que un usuario autenticado se encuentra en la pantalla principal
    Cuando pulsa el botón de emergencia visible en el menú principal
    Entonces el sistema muestra el formulario simplificado de reporte de emergencia
    Y el formulario requiere la menor cantidad de toques posible para su envío

  Escenario: Registro de emergencia con datos mínimos incompletos
    Dado que un usuario autenticado abrió el formulario simplificado de emergencia
    Cuando intenta enviar el reporte sin indicar el tipo de emergencia o la ubicación
    Entonces el sistema rechaza el registro
    Y solicita completar la ubicación y el tipo antes de continuar

  Escenario: Registro de emergencia con ubicación no válida
    Dado que un usuario autenticado completó el tipo y la ubicación de una emergencia
    Cuando envía el reporte y el Sistema de Geolocalización informa que la ubicación no es válida
    Entonces el sistema no registra el reporte
    Y solicita una ubicación válida en el formulario simplificado

  Escenario: Derivación al Gestor cuando la notificación no está disponible
    Dado que un usuario autenticado envía una emergencia con datos completos y ubicación válida
    Y el Sistema de Notificaciones no está disponible
    Cuando el sistema registra el reporte
    Entonces el reporte queda derivado al Gestor de emergencias con prioridad "Máxima"
    Y el aviso al Gestor queda pendiente de envío y visible en su bandeja
```
