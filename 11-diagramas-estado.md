# Diagramas de estado

## EST-01 — Ciclo de vida de reportes

- Clase del dominio: [Reporte](./08-modelo-dominio.md)
- Diagramas de secuencia relacionados: [DSS-01](./10-diagramas-secuencia.md)

![EST-01](./diagramas/est-01.png)

Archivo fuente: [`./diagramas/est-01.puml`](./diagramas/est-01.puml)

### Tabla de transiciones

| Estado origen | Evento | Guarda | Acción | Estado destino |
|---|---|---|---|---|
| [*] | registrarReporte() | coordenadasValidas == true | crearRegistroYAsignarDepartamento() | Recibido |
| Recibido | tomarConocimiento() | — | registrarCambioEstado() | EnRevisión |
| EnRevisión | completarReporte() | notaResolucion != vacía | registrarNotaYGenerarNotificacion() | Completado |
| EnRevisión | descartarReporte() | motivoDescarte != vacío | registrarMotivoYGenerarNotificacion() | Descartado |
| Completado | [*] | — | — | [*] |
| Descartado | [*] | — | — | [*] |

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
