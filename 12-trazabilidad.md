# Trazabilidad

## Matriz de trazabilidad

| Requisito (Entrega 1) | Historia | Caso de uso | Secuencia | Estado | Clases del dominio |
|---|---|---|---|---|---|
| RP-01 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte, Categoría, Ubicación, Fotografía |
| RP-02 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte, Fotografía |
| RP-03 | HU-02 | [CU-02] | [---] | [EST-01] | Usuario, Reporte, CambioEstado |
| RP-04 | HU-06 | [CU-06] | [DSS-05] | [EST-01] | Reporte, Categoría |
| RP-05 | HU-08 | [CU-08] | [DSS-05] | [EST-01] | Reporte, Asignación, Departamento, Usuario, Categoría |
| RP-06 | HU-03 | [CU-03] | [---] | [---] | Usuario, Reporte, Categoría, Departamento |
| RP-07 | HU-04, HU-07 | [CU-04, CU-07] | [DSS-02, DSS-03] | [EST-01] | Usuario, Reporte, CambioEstado |
| RP-08 | HU-05, HU-07 | [CU-05] | [DSS-02, DSS-03, DSS-04] | [EST-02] | CambioEstado, Notificación, Usuario |
| RP-09 | HU-01 | [CU-01] | [DSS-01] | [EST-01] | Usuario, Reporte |
| RP-10 | HU-03, HU-04, HU-06, HU-07, HU-08 | [CU-03, CU-04, CU-06, CU-07, CU-08] | [DSS-02, DSS-03, DSS-05] | [EST-01] | Usuario, Reporte, Categoría, Departamento |
| RP-11 | HU-05 | [CU-05] | [DSS-02, DSS-03, DSS-04] | [EST-02] | Notificación, Usuario |
| RP-12 | --- | [CU-09] | [DSS-06] | [---] | Usuario, Sesion |

## Trazabilidad inversa (Clases → Requisitos)

| Clase del dominio | Requisitos relacionados | Historias | Casos de uso |
|---|---|---|---|
| Usuario | RP-01, RP-02, RP-03, RP-07, RP-08, RP-10, RP-12 | HU-01, HU-02, HU-04, HU-05, HU-07 | CU-01, CU-02, CU-04, CU-05, CU-07, CU-09 |
| Reporte | RP-01, RP-02, RP-03, RP-04, RP-05, RP-06, RP-07, RP-09 | HU-01, HU-02, HU-03, HU-04, HU-06, HU-07, HU-08 | CU-01, CU-02, CU-03, CU-04, CU-06, CU-07, CU-08 |
| Categoría | RP-01, RP-04, RP-05, RP-06, RP-10 | HU-01, HU-03, HU-06, HU-08 | CU-01, CU-03, CU-06, CU-08 |
| Departamento | RP-05, RP-06, RP-10 | HU-03, HU-08 | CU-03, CU-08 |
| Ubicación | RP-01 | HU-01 | CU-01 |
| Fotografía | RP-01, RP-02 | HU-01 | CU-01 |
| CambioEstado | RP-03, RP-07, RP-08 | HU-02, HU-04, HU-05, HU-07 | CU-02, CU-04, CU-05, CU-07 |
| Asignación | RP-05, RP-10 | HU-08 | CU-08 |
| Notificación | RP-08, RP-11 | HU-05, HU-07 | CU-05 |
| Sesion | RP-12 | --- | CU-09 |

## Observaciones

- **Cobertura completa**: Todas las 8 historias de usuario (HU-01 a HU-08) ahora tienen al menos un Caso de Uso asociado y, donde corresponde, Diagrama de Secuencia de Sistema (DSS). Las historias de consulta (HU-02, HU-03) no requieren DSS por ser operaciones internas sin integración externa compleja.
- **RP-12 (Autenticación)**: Ahora está trazado a CU-09 (Iniciar sesión/Registrarse), DSS-06 y las clases `Usuario` y `Sesion`. Es un requisito funcional derivado (no no-funcional), necesario para RP-03 y RP-08.
- **RP-10 (Seguridad/roles)**: Se extiende a CU-06, CU-07, CU-08 ya que el rol de administrador es requerido para ajustar prioridad, descartar y reasignar.
- **EST-01 extendido**: Incluye transiciones de reapertura (`EnRevisión → Recibido`, `Completado → EnRevisión`) y descarte directo desde `Recibido`, cubriendo HU-07 y flujos de excepción operativa.
- **EST-02**: Cubre el ciclo completo de notificaciones con reintentos y fallo definitivo, vinculado a RP-11 (≤ 5 min) y RP-08.
