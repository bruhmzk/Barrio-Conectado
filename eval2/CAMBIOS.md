# CAMBIOS — Evaluación 2 (Cambio de requerimientos)

**Fecha:** 2026-11-24 (Martes 24/11, sesión de especificación sin IA)  
**Cambio:** HU-09 — Reporte de emergencias de estado crítico  
**Descripción:** Como usuario, quiero enviar un nuevo tipo de reporte para reportar emergencias de estado crítico, con interfaz simplificada (mínimos toques), acceso directo desde menú principal, prioridad máxima automática y derivación inmediata al Gestor de emergencias.

---

## Tabla de cambios por artefacto

| Artefacto | Qué cambió (antes → después) | Por qué el cambio lo exige | Responsable |
|-----------|------------------------------|----------------------------|-------------|
| **Historias de usuario** (`04-historias-usuario.md`) | Se agrega **HU-09** con CA1 (interfaz mínima) y CA2 (acceso menú principal). Antes: HU-01 a HU-08. Después: HU-01 a HU-09. | El cambio pide explícitamente "Como usuario, quiero enviar un nuevo tipo de reporte, para reportar emergencias de estado crítico" con dos criterios de aceptación específicos. | *Bruno Mora* |
| **Criterios de aceptación Gherkin** (`07-criterios-aceptacion.md`) | Se agregan **2 escenarios Gherkin** para HU-09: (1) Registro exitoso con datos mínimos, prioridad máxima, derivación a Gestor; (2) Acceso directo desde menú principal. Antes: solo HU-01 a HU-04. Después: HU-01 a HU-04 + HU-09. | Los criterios de aceptación en HU-09 requieren formalización en Gherkin para ser verificables y trazables a pruebas. | *Jesús Cortés* |
| **Modelo de dominio** (`08-modelo-dominio.md`, `diagramas/modelo-dominio.puml`) | Clase **Reporte**: agregado atributo `esEmergencia` (boolean). Clase **Categoría**: agregado atributo `esEmergencia` (boolean). Clase **Departamento**: descripción actualizada para incluir "Gestor de emergencias". Decisiones de modelado actualizadas. | El cambio requiere distinguir reportes de emergencia (estado crítico) para prioridad máxima y derivación automática. Dos opciones se evaluaron: atributo en Reporte o en Categoría; se eligió ambas para identificación rápida y categorización. | *Gabriel del Castillo* |
| **Casos de uso** (`09-casos-de-uso.md`, `diagramas/casos-de-uso.puml`) | Nuevo actor **Gestor de emergencias** (tipo humano). Nuevos CU: **CU-09** "Registrar reporte de emergencia" (actor Vecino) y **CU-10** "Gestionar reporte de emergencia" (actor Gestor). Tabla y diagrama actualizados. | El cambio exige: (1) nuevo actor que analiza y coordina con autoridades; (2) caso de uso para vecino que reporta emergencia; (3) caso de uso para gestor que gestiona la emergencia. | *Bruno Mora* |
| **Diagrama AS-IS** (`01-proceso-as-is.md`, `diagramas/as-is.puml`, `diagramas/as-is.drawio.png`) | En fila **Vecino**: bifurcación "¿Es emergencia?" → sí: deriva a nueva fila **Gestor de emergencias** (analiza y coordina respuesta); no: ciclo normal (Junta → Oficina → Depto). Participante "Gestor de emergencias" agregado a tabla. | El cambio pide explícitamente: "En la fila de Vecino, agregar una nueva bifurcación que determine si el caso corresponde a una emergencia, y en caso de serlo, derivarlo a una nueva fila asociada al Gestor de emergencias." | *Bruno Mora* |
| **Diagrama TO-BE** (`02-rediseno-to-be.md`, `diagramas/to-be.puml`, `diagramas/to-be.drawio.png`) | En fila **Plataforma BarrioConectado**: bifurcación "¿Es emergencia?" → sí: deriva a fila **Gestor de emergencias** (analiza, deriva a autoridad, notifica); no: flujo normal (asigna depto → admin confirma → ejecución). | El cambio pide explícitamente: "En la fila de la plataforma Barrio Conectado, agregar una bifurcación que derive a la nueva fila de Gestor de emergencia." | *Bruno Mora* |
| **Diagrama de secuencia** (`10-diagramas-secuencia.md`, `diagramas/dss-03.puml`, `diagramas/dss-03.png`) | **Nuevo DSS-03** "Registrar reporte de emergencia" (CU-09, CU-10, HU-09). Participantes: Vecino, Sistema, Mapas, Notificaciones, Gestor de emergencias. Variantes: datos mínimos, validación ubicación, notificación urgente con canal alternativo. | El cambio introduce un nuevo flujo principal (reporte de emergencia) que requiere su propio diagrama de secuencia para mostrar la interacción simplificada, prioridad máxima y derivación automática al Gestor. | *Gabriel del Castillo* |
| **Diagrama de estado** (`11-diagramas-estado.md`, `diagramas/est-03.puml`, `diagramas/est-03.png`) | **Nuevo EST-03** "Ciclo de vida de Reporte de Emergencia". 8 estados: Recibido (Máxima prioridad) → En atención por Gestor → (Derivado a Autoridad → Resuelto) | El reporte de emergencia tiene un ciclo de vida distinto al reporte normal: prioridad máxima desde el inicio, atención por Gestor (no administrador genérico), derivación a autoridad externa, y posibilidad de retorno. EST-01 no cubre esto. | *Gabriel del Castillo* |
| **Matriz de trazabilidad** (`12-trazabilidad.md`) | Agregada fila **RP-13** vinculando HU-09 → CU-09, CU-10 → DSS-03 → EST-03 → clases: Usuario, Reporte, Categoría, Departamento, Ubicación, Notificación. | Cada nuevo requisito/historia debe trazarse a casos de uso, secuencias, estados y clases del dominio para mantener la matriz completa. | *Gabriel del Castillo* |
| **Requisitos** (`03-requisitos.md`) | Agregado **RP-13** (Funcional): "El sistema debe permitir al usuario reportar emergencias de estado crítico mediante una interfaz simplificada (mínimos toques), accesible directamente desde el menú principal, con prioridad máxima automática y derivación inmediata al Gestor de emergencias." Actividad TO-BE: "Reporta el problema en la app / Registra el reporte automáticamente / Deriva a Gestor de emergencias". | El cambio de requerimientos genera un nuevo requisito funcional que debe documentarse en la lista de requisitos de producto. | *Jesús Cortés* |
| **Atributos de calidad** (`06-atributos-calidad.md`) | **Sin cambios**. El documento menciona "botón de pánico", "mapa de incidentes", "contactos de emergencia" y "delincuencia" que son heredados de otro proyecto y se acordó ignorar (supuesto 2026-11-23). El cambio actual no afecta atributos de calidad nuevos. | El cambio solicitado es funcional (nuevo tipo de reporte), no introduce nuevos atributos de calidad (rendimiento, seguridad, usabilidad) más allá de los ya considerados (usabilidad en RP-09). | *Jesús Cortés* |

---

## Resumen de artefactos afectados

| Total | Modificados | Nuevos | Sin cambios |
|-------|-------------|--------|-------------|
| 11 | 8 | 2 (DSS-03, EST-03) | 1 (06-atributos-calidad.md) |

---

## Notas para la reflexión del jueves 26/11

- **Versión `cambio-validado`**: Esta especificación se hizo sin IA durante la sesión del martes 24/11, con supervisión del profesor.
- **Versión `entrega-eval2`**: Se implementará con IA (`/cin324-generar-app`) entre sesiones. Aquí se registrarán diferencias, supuestos del agente, pruebas fallidas, ambigüedades.
- **Preguntas clave por artefacto**:
  - ¿Fue suficiente lo especificado para que el agente generara código correcto?
  - ¿Qué faltó, sobró o estuvo mal?
  - ¿Qué se haría distinto?
