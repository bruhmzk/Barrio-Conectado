# Diagramas de secuencia de sistema

## DSS-01 — Registro de reporte con validación de ubicación

- Caso de uso: [CU-01](./09-casos-de-uso.md)
- Historia: [HU-01](./04-historias-usuario.md#hu-01)
- Sistemas externos que participan: Sistema de Geolocalización

![DSS-01](./diagramas/dss-01.png)

Archivo fuente: [`./diagramas/dss-01.puml`](./diagramas/dss-01.puml)

Variantes representadas: 
-Bloque `alt`: Representa el escenario principal (camino feliz) donde el Sistema de Geolocalización confirma que las coordenadas son válidas, permitiendo al sistema registrar el reporte y devolver el número de seguimiento al vecino. También representa el escenario alternativo (de error), donde las coordenadas son inválidas y el sistema rechaza el registro.

## DSS-02 — Cierre de reporte y envío de notificación
- Caso de uso: [CU-04](./09-casos-de-uso.md)
- Historia: [HU-04](./04-historias-usuario.md#hu-04)
- Sistemas externos que participan: Sistema de Notificaciones

![DSS-02](./diagramas/dss-02.png)

Archivo fuente: [`./diagramas/dss-02.puml`](./diagramas/dss-02.puml)

Variantes representadas: 
-Bloque `alt`: Verifica si el administrador ingresó la nota de resolución. Si la nota no está vacía, el sistema cambia el estado, invoca al Sistema de Notificaciones para avisar al vecino y confirma el éxito al administrador. Si la nota está vacía (escenario de error), el sistema rechaza el cambio de estado y solicita el ingreso de la nota.

## DSS-03 — Descarte de reporte con notificación
- Caso de uso: [CU-07](./09-casos-de-uso.md)
- Historia: [HU-07](./04-historias-usuario.md#hu-07)
- Sistemas externos que participan: Sistema de Notificaciones

![DSS-03](./diagramas/dss-03.png)

Archivo fuente: [`./diagramas/dss-03.puml`](./diagramas/dss-03.puml)

Variantes representadas:
- Bloque `alt` principal: Verifica si el administrador ingresó el motivo de descarte. Si el motivo no está vacío, el sistema cambia el estado a "Descartado", invoca al Sistema de Notificaciones y confirma. Si el motivo está vacío, rechaza el cambio.
- Bloque `alt` anidado (servicio de notificaciones): Maneja la disponibilidad del servicio de notificaciones (igual que DSS-02).

## DSS-04 — Inicio de revisión y notificación al vecino
- Caso de uso: [CU-03](./09-casos-de-uso.md) / [CU-05](./09-casos-de-uso.md)
- Historia: [HU-05](./04-historias-usuario.md#hu-05)
- Sistemas externos que participan: Sistema de Notificaciones

![DSS-04](./diagramas/dss-04.png)

Archivo fuente: [`./diagramas/dss-04.puml`](./diagramas/dss-04.puml)

Variantes representadas:
- El administrador toma conocimiento de un reporte en estado "Recibido" y lo pasa a "En revisión".
- El sistema registra el cambio de estado e invoca al Sistema de Notificaciones.
- Bloque `alt` para manejo de disponibilidad del servicio de notificaciones.

## DSS-05 — Ajuste manual de prioridad y reasignación de departamento
- Caso de uso: [CU-06](./09-casos-de-uso.md), [CU-08](./09-casos-de-uso.md)
- Historias: [HU-06](./04-historias-usuario.md#hu-06), [HU-08](./04-historias-usuario.md#hu-08)
- Sistemas externos que participan: (ninguno, operación interna)

![DSS-05](./diagramas/dss-05.png)

Archivo fuente: [`./diagramas/dss-05.puml`](./diagramas/dss-05.puml)

Variantes representadas:
- Secuencia para ajustar prioridad: el administrador modifica la prioridad y el sistema registra el cambio con auditoría.
- Secuencia para reasignar departamento: el administrador cambia el departamento y el sistema registra la reasignación con origen/destino/usuario/fecha.

## DSS-06 — Autenticación (Registro e Inicio de sesión)
- Caso de uso: [CU-09](./09-casos-de-uso.md)
- Requisito: [RP-12](./03-requisitos.md)
- Sistemas externos que participan: (ninguno, operación interna)

![DSS-06](./diagramas/dss-06.png)

Archivo fuente: [`./diagramas/dss-06.puml`](./diagramas/dss-06.puml)

Variantes representadas:
- Bloque `alt` para Registro vs Inicio de sesión.
- En Registro: valida unicidad de medio de contacto y fortaleza de contraseña; hashea contraseña (Argon2/Bcrypt); crea usuario con rol "vecino"; genera token JWT.
- En Inicio de sesión: verifica hash; si correcto genera token JWT; si incorrecto cuenta intentos y bloquea temporalmente tras N fallos.
