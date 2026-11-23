# Spec Delta

## ADDED Requirements

### Requirement: Filtrado de reportes por categoría y prioridad

El sistema DEBE (MUST) permitir al administrador municipal filtrar la lista general de reportes por categoría y prioridad, y DEBE mostrar únicamente los reportes que coinciden con esos criterios, ordenados de mayor a menor prioridad (Alta → Media → Baja).

#### Scenario: Filtrado de reportes por categoría y alta prioridad

- **GIVEN** el administrador municipal revisa la lista general de incidentes
- **WHEN** aplica un filtro por categoría específica y prioridad Alta
- **THEN** el sistema muestra únicamente los reportes que coinciden con esos criterios
- **AND** los ordena mostrando primero los más urgentes (Alta → Media → Baja)

### Requirement: Indicación cuando no hay reportes que coincidan con los filtros

El sistema DEBE (MUST) indicar que no hay resultados y DEBE mantener la opción de cambiar los criterios de búsqueda cuando los filtros aplicados por categoría, prioridad y estado no coinciden con ningún reporte.

#### Scenario: Filtrado sin resultados coincidentes

- **GIVEN** el administrador municipal revisa la lista de incidentes
- **WHEN** aplica filtros por categoría, prioridad y estado que no coinciden con ningún reporte
- **THEN** el sistema indica que no hay resultados
- **AND** mantiene la opción de cambiar los criterios de búsqueda

### Requirement: Consulta combinada de categoría, prioridad y estado

El sistema DEBE (MUST) combinar con AND los filtros por categoría, prioridad y estado que aplique simultáneamente el administrador municipal, y DEBE conservarlos para poder modificarlos.

#### Scenario: Consulta combinada de categoría, prioridad y estado

- **GIVEN** el administrador municipal revisa la lista general de incidentes
- **WHEN** aplica simultáneamente filtros por categoría, prioridad y estado
- **THEN** el sistema muestra solo los reportes que cumplen los tres criterios a la vez
- **AND** conserva los filtros aplicados para poder modificarlos

### Requirement: Visualización del departamento asignado y del estado en la lista

El sistema DEBE (MUST) mostrar en cada fila de la lista general el departamento asignado y el estado actual del reporte, manteniendo el orden de mayor a menor prioridad. «Activos» no es un estado del dominio: los reportes Completado y Descartado se muestran salvo que se filtre explícitamente por otro estado.

#### Scenario: Visualización del departamento asignado y del estado en la lista

- **GIVEN** el administrador municipal consulta la lista general de incidentes
- **WHEN** se muestran los reportes filtrados
- **THEN** cada reporte muestra su departamento asignado y su estado actual
- **AND** el sistema mantiene el orden de mayor a menor prioridad
