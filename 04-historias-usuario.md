# Historias de usuario

Las actividades del TO-BE citadas corresponden a la tabla "Actividades que cambian del AS-IS al TO-BE" de [02-rediseno-to-be.md](./02-rediseno-to-be.md).

## HU-01 — Registrar un reporte

Como vecino, quiero registrar un reporte adjuntando una foto, mi ubicación y una descripción, para informar a las autoridades de un problema de mi barrio de forma rápida y bien documentada.

**Actividad TO-BE asociada:** Reporta el problema en la app / Registra el reporte automáticamente

**Criterios de aceptación:**

- CA1: El formulario exige foto, ubicación (GPS o punto en el mapa), categoría y descripción antes de permitir el envío.
- CA2: Si falta algún campo obligatorio, el sistema no envía el reporte e indica cuál falta.
- CA3: Al enviar, el sistema muestra una confirmación con un número de seguimiento.
- CA4: El reporte queda guardado con estado inicial "Recibido", fecha y hora.

## HU-02 — Consultar mis reportes

Como vecino, quiero consultar el historial y el estado de mis reportes enviados, para saber en qué etapa está cada uno sin tener que llamar ni ir al municipio.

**Actividad TO-BE asociada:** Notifica al vecino el descarte / el estado resuelto (trazabilidad)

**Criterios de aceptación:**

- CA1: El vecino ve una lista de sus reportes con fecha, categoría y estado actual.
- CA2: Al abrir un reporte, ve el historial de cambios de estado con su fecha.
- CA3: El vecino solo puede ver los reportes que él mismo envió.

## HU-03 — Filtrar reportes para asignar personal

Como administrador municipal, quiero filtrar los reportes por categoría y prioridad, para asignar personal a la reparación empezando por los casos más críticos.

**Actividad TO-BE asociada:** Revisa y confirma la asignación

**Criterios de aceptación:**

- CA1: El administrador puede filtrar por categoría, prioridad y estado, y combinar los filtros.
- CA2: La lista se puede ordenar de mayor a menor prioridad.
- CA3: Cada reporte de la lista muestra su departamento asignado y su estado.

## HU-04 — Completar un reporte con nota de resolución

Como administrador municipal, quiero cambiar el estado de un reporte a "Completado" y añadir una nota de resolución, para dejar constancia del trabajo realizado y que el vecino pueda verlo.

**Actividad TO-BE asociada:** Actualiza estado en la app: resuelto

**Criterios de aceptación:**

- CA1: Para marcar un reporte como "Completado", la nota de resolución es obligatoria.
- CA2: El cambio queda registrado con fecha, hora y el usuario que lo hizo.
- CA3: El nuevo estado y la nota son visibles para el vecino que envió el reporte.

## HU-05 — Recibir notificaciones de cambio de estado

Como vecino, quiero recibir una notificación cuando cambie el estado de mi reporte, para enterarme del avance sin tener que revisar la aplicación.

**Actividad TO-BE asociada:** Notifica al vecino el descarte / el estado resuelto

**Criterios de aceptación:**

- CA1: El sistema envía una notificación cada vez que el estado del reporte cambia.
- CA2: La notificación incluye el número de seguimiento y el nuevo estado.
- CA3: Si el reporte fue descartado, la notificación incluye el motivo.

## HU-06 — Recibir reportes ya priorizados

Como administrador municipal, quiero que cada reporte llegue ya priorizado según su categoría y urgencia, para atender primero lo más crítico sin tener que evaluar cada reclamo a mano.

**Actividad TO-BE asociada:** Prioriza automáticamente según urgencia e impacto

**Criterios de aceptación:**

- CA1: Al registrarse un reporte, el sistema le asigna una prioridad (alta, media o baja) sin intervención del administrador.
- CA2: Los criterios de priorización están definidos y documentados. [definirlos con el equipo o con la elicitación]
- CA3: El administrador puede ajustar la prioridad manualmente y el cambio queda registrado.

## HU-07 — Descartar un reporte indicando el motivo

Como administrador municipal, quiero descartar un reporte indicando el motivo, para que el vecino entienda por qué no se ejecutará una reparación.

**Actividad TO-BE asociada:** Actualiza estado: descartado

**Criterios de aceptación:**

- CA1: Para descartar un reporte, el motivo es obligatorio.
- CA2: El reporte pasa a estado "Descartado" y queda registrado con fecha y usuario.
- CA3: El vecino recibe una notificación con el motivo del descarte.

## HU-08 — Asignar y reasignar reportes por departamento

Como administrador municipal, quiero que el sistema asigne cada reporte al departamento que corresponde según su categoría y poder reasignarlo si hace falta, para evitar derivaciones manuales entre oficinas.

**Actividad TO-BE asociada:** Asigna al departamento correspondiente / Revisa y confirma la asignación

**Criterios de aceptación:**

- CA1: Al registrarse un reporte, el sistema lo asigna al departamento que corresponde a su categoría.
- CA2: El administrador puede cambiar el departamento asignado.
- CA3: Cada reasignación queda registrada con fecha y usuario.
