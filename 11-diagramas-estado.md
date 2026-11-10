# Diagramas de estado

## EST-01 — Ciclo de vida de reportes

- Clase del dominio: [Reporte](./08-modelo-dominio.md)
- Diagramas de secuencia relacionados: [DSS-01](./10-diagramas-secuencia.md), [DSS-03](./10-diagramas-secuencia.md), [DSS-04](./10-diagramas-secuencia.md), [DSS-05](./10-diagramas-secuencia.md)

![EST-01](./diagramas/est-01.png)

Archivo fuente: [`./diagramas/est-01.puml`](./diagramas/est-01.puml)

### Tabla de transiciones

| Estado origen | Evento | Guarda | Acción | Estado destino |
|---|---|---|---|---|
| [*] | registrarReporte() | coordenadasValidas == true | crearRegistroYAsignarDeptoYPrioridad() | Recibido |
| Recibido | tomarConocimiento() | — | registrarCambioEstado() | EnRevisión |
| Recibido | descartarReporte() | motivoDescarte != vacío | registrarMotivoYGenerarNotificacion() | Descartado |
| EnRevisión | completarReporte() | notaResolucion != vacía | registrarNotaYGenerarNotificacion() | Completado |
| EnRevisión | descartarReporte() | motivoDescarte != vacío | registrarMotivoYGenerarNotificacion() | Descartado |
| EnRevisión | reabrirReporte() | usuarioConRolAdmin | registrarCambioEstado(nota: "Reabierto por admin") | Recibido |
| Completado | reabrirReporte() | usuarioConRolAdmin && reclamoVecino | registrarCambioEstado(nota: "Reabierto por reclamo vecino") | EnRevisión |
| Completado | [*] | — | — | [*] |
| Descartado | [*] | — | — | [*] |

### Notas sobre el ciclo de vida extendido

1. **Descartar desde "Recibido"**: Un administrador puede descartar un reporte directamente sin pasar por "En revisión" (ej. duplicado evidente, fuera de competencia). Requiere motivo obligatorio y genera notificación al vecino (HU-07, CU-07, DSS-03).

2. **Reapertura desde "En revisión" → "Recibido"**: Si un administrador inicia revisión pero detecta que faltan datos o fue error, puede devolver a "Recibido" para que otro admin lo retome. Queda trazado en `CambioEstado`.

3. **Reapertura desde "Completado" → "En revisión"**: Si el vecino reclama que la solución no fue efectiva (dentro de un plazo configurable, ej. 7 días), un admin puede reabrir el caso. Pasa a "En revisión" directamente para dar prioridad al seguimiento. Queda trazado con nota del motivo.

4. **Prioridad y asignación**: Al entrar a "Recibido", el sistema asigna prioridad automática (regla RP-04/HU-06) y departamento por defecto (RP-05/HU-08). La prioridad manual del admin (CU-06) prevalece y se traza. La reasignación de departamento (CU-08) no cambia el estado, solo actualiza `Asignación`.

## EST-02 — Ciclo de vida de Notificacion

- Clase del dominio: [Notificacion](./08-modelo-dominio.md)
- Diagramas de secuencia relacionados: [DSS-02](./10-diagramas-secuencia.md)

![EST-02](./diagramas/est-02.png)

Archivo fuente: [`./diagramas/est-02.puml`](./diagramas/est-02.puml)

### Tabla de transiciones

| Estado origen | Evento | Guarda | Acción | Estado destino |
|---|---|---|---|---|
| [*] | generarNotificacion() | — | encolarMensaje() | PendienteDeEnvío |
| PendienteDeEnvío | enviarNotificacion() | conexionExternaExitosa == true | registrarFechaHoraEnvio() | Enviada |
| PendienteDeEnvío | enviarNotificacion() | conexionExternaExitosa == false | reportarErrorEnvio() | Fallida |
| Enviada | [*] | — | — | [*] |
| Fallida | [*] | — | — | [*] |
