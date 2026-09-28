# Proceso de negocio — AS-IS

## Macro-proceso y proceso específico

[Macro-proceso] → [Proceso específico que se modela]

## Objetivo de negocio del proceso

[Descripción]

## Participantes y sus objetivos

| Participante | Objetivo en el proceso |
|---|---|
| Vecino | Que el problema reportado se solucione en un plazo razonable |
| Junta de vecinos / dirigente | Canalizar y representar los reclamos de su sector ante el municipio |
| Municipio — Oficina de Partes | Registrar formalmente la solicitud del vecino |
| Departamento Técnico Municipal (obras, aseo, alumbrado, etc.) | Evaluar, priorizar y ejecutar la reparación con los recursos disponibles |

## Diagrama AS-IS

![Proceso AS-IS](./Diagramas/Diagrama BPMN AS-IS.drawio.png)
Archivo fuente: [`./diagramas/as-is.bpmn`](./diagramas/as-is.bpmn)

El diagrama distingue tareas manuales (anotar en cuaderno, llenar formulario en papel, ejecutar en terreno) de una tarea de usuario (registrar la solicitud en una planilla o sistema interno), reflejando que hoy casi todo el proceso es manual y sin apoyo tecnológico.

## Problemas identificados

- No existe un canal único ni estandarizado de reporte: el vecino puede llamar, escribir por WhatsApp, publicar en redes sociales o ir presencialmente, lo que dispersa la información.
- No hay trazabilidad ni número de seguimiento para el vecino una vez que reporta.
- La priorización de reclamos depende del criterio subjetivo de quien revisa en el departamento técnico, sin datos objetivos de urgencia o impacto.
- No existe notificación de cambio de estado: el vecino no sabe si su reclamo fue recibido, descartado o resuelto.
- Reclamos duplicados de distintos vecinos sobre el mismo problema no se detectan ni se consolidan.
- [Agregar aquí cualquier problema adicional que surja de la elicitación real con un dirigente vecinal o funcionario municipal]
