# Casos de uso

## Actores

| Actor | Tipo (humano / sistema externo) | Descripción |
|---|---|---|
| Vecino | Humano | Usuario registrado que reporta problemas en la via publica y realiza seguimiento.|
| Administrador municipal | Humano | Funcionario que filtra, prioriza, asigna y actualiza el estado de los reportes.|
| Sistema de Geolocalizacion | Sistema externo | Servicio de mapas que provee y valida coordenadas geograficas para las ubicaciones.|
| Sistema de Notificaciones | Sistema externo | Plataforma encargada de despachar los avisos al vecino cuando hay cambios de estado.|

## Diagrama de casos de uso

![Casos de uso](./diagramas/casos-de-uso.png)

Archivo fuente: [`./diagramas/casos-de-uso.puml`](./diagramas/casos-de-uso.puml)

## Casos de uso y su origen

| ID | Caso de uso (objetivo del actor) | Actor principal | Historia de origen |
|---|---|---|---|
| CU-01 | Registrar un reporte de incidente | Vecino | [HU-01](./04-historias-usuario.md#hu-01) |
| CU-02 | Consultar historial de reportes | Vecino | [HU-02](./04-historias-usuario.md#hu-02) |
| CU-03 | Filtrar reportes para asignacion | Administrador municipal | [HU-03](./04-historias-usuario.md#hu-03) |
| CU-04 | Completar reporte con nota de resolucion | Administrador municipal | [HU-04](./04-historias-usuario.md#hu-04) |

