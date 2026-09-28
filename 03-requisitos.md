# Clasificación de requisitos

Las actividades del TO-BE citadas en la última columna corresponden a la tabla "Actividades que cambian del AS-IS al TO-BE" de [02-rediseno-to-be.md](./02-rediseno-to-be.md).

## Requisitos de producto

| ID | Requisito | Tipo | Actividad TO-BE asociada |
|---|---|---|---|
| RP-01 | El sistema debe permitir al vecino crear un reporte adjuntando foto, ubicación georreferenciada, descripción y categoría (luminaria, microbasural, bache u otra). | Funcional | Reporta el problema en la app |
| RP-02 | El sistema debe registrar automáticamente cada reporte con un identificador único, fecha y hora, y estado inicial "Recibido". | Funcional | Registra el reporte automáticamente |
| RP-03 | El sistema debe permitir al vecino consultar el historial y el estado actual de los reportes que ha enviado. | Funcional | Notifica al vecino el descarte / el estado resuelto (trazabilidad) |
| RP-04 | El sistema debe asignar a cada reporte una prioridad (alta, media o baja) según su categoría y urgencia, sin intervención manual. | Funcional | Prioriza automáticamente según urgencia e impacto |
| RP-05 | El sistema debe asignar cada reporte al departamento municipal que corresponde según su categoría, y permitir al administrador reasignarlo. | Funcional | Asigna al departamento correspondiente |
| RP-06 | El sistema debe permitir al administrador municipal filtrar y ordenar los reportes por categoría, prioridad y estado. | Funcional | Revisa y confirma la asignación |
| RP-07 | El sistema debe permitir al administrador cambiar el estado de un reporte (en revisión, descartado, completado) y registrar una nota de resolución o el motivo del descarte. | Funcional | Actualiza estado: descartado / Actualiza estado en la app: resuelto |
| RP-08 | El sistema debe notificar al vecino cada vez que cambie el estado de uno de sus reportes. | Funcional | Notifica al vecino el descarte / el estado resuelto |
| RP-09 | Un vecino sin capacitación previa debe poder completar un reporte en un máximo de [3] pasos desde la pantalla principal. | No funcional (usabilidad) | Reporta el problema en la app |
| RP-10 | Solo el personal municipal autenticado y con rol de administrador debe poder ver el panel de gestión y modificar estados de reportes. | No funcional (seguridad) | Actualiza estado en la app |
| RP-11 | La notificación de un cambio de estado debe llegar al vecino en un máximo de [X] minutos desde que el administrador lo registra. | No funcional (rendimiento) | Notifica al vecino el descarte / el estado resuelto |

Los valores entre corchetes ([3] pasos, [X] minutos) son propuestas iniciales: ajústenlos según lo que levanten en la elicitación o lo que acuerden como equipo.

## Requisitos de proyecto

| ID | Requisito |
|---|---|
| RY-01 | Toda la documentación de la Entrega 1 debe estar en formato Markdown, en la rama `main` de un repositorio de la organización de GitHub del equipo. |
| RY-02 | Los diagramas BPMN deben elaborarse en Camunda Modeler o draw.io/bpmn.io, y entregarse como imagen PNG junto con su archivo fuente `.bpmn`. |
| RY-03 | La elicitación de requisitos debe realizarse con al menos dos técnicas distintas, dejando evidencia gráfica de cada una. |
| RY-04 | El equipo debe registrar su trabajo en un GitHub Project de la organización, con todos los integrantes como miembros. |

## Requisito derivado

**Requisito origen:** RP-03 (consultar historial de reportes propios) y RP-08 (notificar cambios de estado al vecino).

**Requisito derivado (RP-12):** El sistema debe permitir al vecino registrarse e iniciar sesión, guardando al menos un medio de contacto (correo o notificación en el dispositivo).

**Justificación:** Para mostrarle a cada vecino solo sus propios reportes y para poder enviarle notificaciones, el sistema necesita saber quién es y cómo contactarlo. Ninguno de los dos requisitos origen se puede cumplir sin esta identificación.

**Actividad TO-BE asociada:** Reporta el problema en la app / Notifica al vecino el descarte / el estado resuelto.
