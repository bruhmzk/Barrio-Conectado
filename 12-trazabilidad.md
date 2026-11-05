# Trazabilidad

## Matriz de trazabilidad

| Requisito (Entrega 1) | Historia | Caso de uso | Secuencia | Estado | Clases del dominio |
|---|---|---|---|---|---|
| RP-01 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte, Categoría, Ubicación, Fotografía |
| RP-02 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte, Fotografía |
| RP-03 | HU-02 | [CU-02] | [---] | [EST-01] | Usuario, Reporte, CambioEstado |
| RP-04 | HU-06 | [---] | [---] | [---] | Reporte |
| RP-05 | HU-08 | [---] | [---] | [---] | Reporte, Asignación, Departamento, Usuario |
| RP-06 | HU-03 | [CU-03] | [---] | [---] | Usuario, Reporte, Categoría, Departamento |
| RP-07 | HU-04, HU-07 | [CU-04] | [DSS-02] | [EST-01] | Usuario, Reporte, CambioEstado |
| RP-08 | HU-05, HU-07 | [CU-04] | [DSS-02] | [EST-02] | CambioEstado, Notificación, Usuario |
| RP-09 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte |
| RP-10 | HU-03, HU-04 | [CU-03, CU-04] | [DSS-02] | [EST-01] | Usuario, Reporte, Categoría |
| RP-11 | HU-05 | [---] | [---] | [EST-02] | Notificación, Usuario |
| RP-12 | --- | --- | --- | --- | --- |

## Observaciones

- *Sobre las Historias sin Caso de Uso o Secuencia:* Las historias HU-05, HU-06, HU-07 y HU-08 están marcadas con --- en Casos de Uso y Secuencia porque la pauta de esta entrega pedía enfocarse en un subconjunto principal (se modelaron 4 Casos de Uso y 2 Diagramas de Secuencia). Sus comportamientos se asumen como parte de las funciones internas del sistema o integradas indirectamente en el CU-04.
- *Sobre RP-12:* El requisito RP-12 no tiene Historia de Usuario, Caso de Uso ni Clases del Dominio asociadas (todas marcadas con ---) porque corresponde a un Requisito No Funcional (por ejemplo, rendimiento, seguridad o restricción tecnológica) o de Proyecto, los cuales no se modelan como acciones de usuario en UML.
- *Sobre HU-02 y HU-03:* Ambas historias son principalmente de consulta y filtrado de datos dentro del mismo sistema. Como no requieren integración con un sistema externo complejo, se omitió su Diagrama de Secuencia de Sistema (DSS) dejando la celda con ---, enfocando los DSS en los flujos de creación de reportes y notificaciones.
