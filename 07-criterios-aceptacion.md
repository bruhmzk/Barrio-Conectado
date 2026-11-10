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

## HU-05 — Recibir notificaciones de cambio de estado

Historia: Como vecino, quiero recibir una notificación cuando cambie el estado de mi reporte, para enterarme del avance sin tener que revisar la aplicación.

**Actividad TO-BE asociada:** Notifica al vecino el descarte / el estado resuelto

```gherkin
Característica: Notificación de cambios de estado

  Escenario: Notificación al completar un reporte
    Dado que un vecino tiene un reporte en estado "En revisión"
    Cuando el administrador cambia el estado a "Completado" con nota de resolución
    Entonces el sistema envía una notificación push al dispositivo del vecino
    Y la notificación incluye el número de seguimiento y el nuevo estado "Completado"
    Y la notificación llega en un máximo de 5 minutos.

  Escenario: Notificación al descartar un reporte
    Dado que un vecino tiene un reporte en estado "En revisión"
    Cuando el administrador cambia el estado a "Descartado" con motivo de descarte
    Entonces el sistema envía una notificación push al dispositivo del vecino
    Y la notificación incluye el número de seguimiento, el nuevo estado "Descartado" y el motivo del descarte.

  Escenario: Notificación al iniciar revisión
    Dado que un vecino tiene un reporte en estado "Recibido"
    Cuando el administrador cambia el estado a "En revisión"
    Entonces el sistema envía una notificación push al dispositivo del vecino
    Y la notificación incluye el número de seguimiento y el nuevo estado "En revisión".

  Escenario: Fallo en el servicio de notificaciones con reintento
    Dado que el servicio de notificaciones está temporalmente no disponible
    Cuando ocurre un cambio de estado en un reporte
    Entonces el sistema programa un reintento de envío
    Y registra la notificación como "Pendiente de envío" hasta que el servicio recupere disponibilidad.
```

## HU-06 — Recibir reportes ya priorizados

Historia: Como administrador municipal, quiero que cada reporte llegue ya priorizado según su categoría y urgencia, para atender primero lo más crítico sin tener que evaluar cada reclamo a mano.

**Actividad TO-BE asociada:** Prioriza automáticamente según urgencia e impacto

```gherkin
Característica: Priorización automática de reportes

  Escenario: Prioridad Alta para luminaria
    Dado que un vecino registra un reporte de categoría "Luminaria"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema asigna prioridad "Alta" al reporte automáticamente.

  Escenario: Prioridad Media para microbasural
    Dado que un vecino registra un reporte de categoría "Microbasural"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema asigna prioridad "Media" al reporte automáticamente.

  Escenario: Prioridad Alta para bache
    Dado que un vecino registra un reporte de categoría "Bache"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema asigna prioridad "Alta" al reporte automáticamente.

  Escenario: Prioridad Media para categoría "Otra"
    Dado que un vecino registra un reporte de categoría "Otra"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema asigna prioridad "Media" al reporte automáticamente.

  Escenario: Escalamiento de prioridad por marca "Urgente"
    Dado que un vecino registra un reporte de categoría "Microbasural" y marca la casilla "Urgente"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema asigna prioridad "Alta" (sube de Media a Alta).

  Escenario: Tope de prioridad en "Alta"
    Dado que un vecino registra un reporte de categoría "Luminaria" y marca la casilla "Urgente"
    Cuando el reporte se guarda en el sistema
    Entonces el sistema mantiene prioridad "Alta" (no existe nivel superior).

  Escenario: Ajuste manual de prioridad por administrador
    Dado que un reporte tiene prioridad "Media" asignada automáticamente
    Cuando el administrador cambia la prioridad a "Alta"
    Entonces el sistema registra el cambio con fecha, hora y usuario que lo realizó
    Y la nueva prioridad prevalece sobre la automática.
```

## HU-07 — Descartar un reporte indicando el motivo

Historia: Como administrador municipal, quiero descartar un reporte indicando el motivo, para que el vecino entienda por qué no se ejecutará una reparación.

**Actividad TO-BE asociada:** Actualiza estado: descartado

```gherkin
Característica: Descarte de reportes con motivo

  Escenario: Descarte exitoso con motivo
    Dado que un reporte se encuentra en estado "En revisión"
    Cuando el administrador cambia el estado a "Descartado" e ingresa el motivo "No corresponde a competencia municipal"
    Entonces el sistema actualiza el estado a "Descartado"
    Y registra la fecha, hora, usuario y motivo del descarte
    Y envía notificación al vecino con el número de seguimiento, estado "Descartado" y el motivo.

  Escenario: Intento de descarte sin motivo
    Dado que un reporte se encuentra en estado "En revisión"
    Cuando el administrador intenta cambiar el estado a "Descartado" dejando el motivo en blanco
    Entonces el sistema impide la actualización del estado
    Y requiere que se ingrese obligatoriamente el motivo del descarte.

  Escenario: Descarte directo desde "Recibido"
    Dado que un reporte se encuentra en estado "Recibido" (sin pasar por "En revisión")
    Cuando el administrador cambia el estado a "Descartado" con motivo "Duplicado de reporte #12345"
    Entonces el sistema actualiza el estado a "Descartado"
    Y registra la fecha, hora, usuario y motivo
    Y envía notificación al vecino con el motivo.
```

## HU-08 — Asignar y reasignar reportes por departamento

Historia: Como administrador municipal, quiero que el sistema asigne cada reporte al departamento que corresponde según su categoría y poder reasignarlo si hace falta, para evitar derivaciones manuales entre oficinas.

**Actividad TO-BE asociada:** Asigna al departamento correspondiente / Revisa y confirma la asignación

```gherkin
Característica: Asignación y reasignación de reportes por departamento

  Escenario: Asignación automática por categoría Luminaria
    Dado que se registra un reporte de categoría "Luminaria"
    Cuando el reporte se guarda
    Entonces el sistema asigna automáticamente el departamento "Alumbrado Público".

  Escenario: Asignación automática por categoría Microbasural
    Dado que se registra un reporte de categoría "Microbasural"
    Cuando el reporte se guarda
    Entonces el sistema asigna automáticamente el departamento "Aseo y Ornato".

  Escenario: Asignación automática por categoría Bache
    Dado que se registra un reporte de categoría "Bache"
    Cuando el reporte se guarda
    Entonces el sistema asigna automáticamente el departamento "Obras Públicas".

  Escenario: Asignación "Otra" queda pendiente de derivación
    Dado que se registra un reporte de categoría "Otra"
    Cuando el reporte se guarda
    Entonces el sistema asigna departamento "Sin asignar" y requiere derivación manual del administrador.

  Escenario: Reasignación de reporte por administrador
    Dado que un reporte está asignado a "Alumbrado Público"
    Cuando el administrador cambia la asignación a "Obras Públicas"
    Entonces el sistema registra la reasignación con fecha, hora y usuario
    Y el reporte queda asignado al nuevo departamento.

  Escenario: Historial de asignaciones
    Dado que un reporte ha sido reasignado dos veces
    Cuando el administrador consulta el historial del reporte
    Entonces el sistema muestra ambas asignaciones con fecha, hora, usuario, departamento origen y destino.
```
