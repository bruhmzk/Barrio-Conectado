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
