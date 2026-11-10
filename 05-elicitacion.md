# Elicitación de requisitos

Se aplicaron dos técnicas: **revisión documental** de sistemas de reclamos de otros municipios y **entrevistas semiestructuradas** a vecinos y funcionarios municipales. Ambas sirven para contrastar el flujo AS-IS modelado en [01-proceso-as-is.md](./01-proceso-as-is.md) y para respaldar los requisitos de [03-requisitos.md](./03-requisitos.md).

## Técnica 1: Revisión documental

- **Revisado por:** Bruno Mora, Gabriel del Castillo, Cristobal Cartagena y Jesús Cortés
- **Evidencia:** [capturas de cada documento, guardadas en `./evidencia/`]

### Documentos revisados

1. Artículo de La Voz (Córdoba, Argentina) sobre la gestión de reclamos de alumbrado y bacheo mediante la app "Ciudadana": [link](https://www.lavoz.com.ar/politica/cambiaron-gestion-del-alumbrado-y-ahora-apuntan-al-bacheo/)
2. Trámite "Atención de solicitud de fallas en el servicio de alumbrado público" de la empresa eléctrica EERSA (Ecuador), en gob.ec: [link](https://www.gob.ec/eersa/tramites/atencion-solicitud-fallas-servicio-alumbrado-publico)
3. Resolución del Síndic de Greuges de la Comunitat Valenciana (España) sobre la falta de respuesta a reclamos de alumbrado público: [link](https://www.elsindic.com/resoluciones/expedientes/2025/202504882/12437922.pdf)

### Hallazgos principales

- **Documento 1:** en Córdoba, los reclamos de alumbrado, bacheo, cloacas y basurales entran por una sola app y se derivan a las distintas reparticiones municipales, y quedan geolocalizados en un mapa. Los resultados difieren mucho por categoría: en alumbrado se había resuelto más del 90% de los pedidos, mientras que de 2.479 baches geolocalizados solo se había reparado el 8,1%. Esto respalda tener un canal único, ubicación en el reporte y una priorización por categoría (RP-01, RP-04, RP-05).
- **Documento 2:** el trámite en línea pide los datos del reclamante, el tipo de reclamo y la dirección con referencias, y al registrarlo entrega un número de reclamo con el que se puede consultar el estado. Esto respalda el número de seguimiento y la consulta de estado (RP-02, RP-03, HU-02).
- **Documento 3:** el Síndic señaló que un municipio publicaba su trámite de reclamos de alumbrado sin plazo de resolución, algo contrario al derecho del ciudadano a recibir respuesta en un plazo no superior a un mes. Esto respalda las notificaciones y la trazabilidad de los cambios de estado (RP-08, HU-05).

---

## Técnica 2: Entrevistas semiestructuradas

- **Realizadas por:** Cristobal Cartagena y Jesús Cortés
- **Participantes:** 4 vecinos de distintos barrios (2 adultos mayores, 2 adultos jóvenes) y 2 funcionarios municipales (1 de Oficina de Partes, 1 de Obras Públicas)
- **Evidencia:** [grabaciones y transcripciones resumidas en `./evidencia/entrevistas/`]
- **Guion base:** [ver anexo al final del documento]

### Hallazgos principales

| Entrevistado | Hallazgo clave | Requisitos respaldados |
|---|---|---|
| Vecino A (adulto mayor) | "Nunca sé si mi reclamo llegó; llamo y me dicen que lo anotan, pero no me dan número" | RP-02 (número de seguimiento), RP-03 (consulta estado), RP-08 (notificaciones) |
| Vecino B (adulto joven) | "Uso WhatsApp para todo; si la app no me deja adjuntar foto fácil, no la uso" | RP-01 (foto obligatoria), RP-09 (≤ 3 pasos), Métrica 3.1 (≤ 2 toques alerta) |
| Vecino C (adulto mayor) | "Los botones chicos me cuesta; necesito ver grande y con contraste" | Métrica 3.3 (WCAG 2.1 AA, botones ≥ 48×48 dp) |
| Vecino D (adulto joven) | "Quiero saber en qué va mi reclamo sin abrir la app; que me avise al celular" | RP-08, RP-11 (notificación push ≤ 5 min), HU-05 |
| Funcionario Oficina de Partes | "Recibimos papeles, WhatsApp, llamadas; se pierden y no sabemos cuáles son urgentes" | RP-01 (canal único), RP-04 (priorización automática), RP-05 (asignación por categoría) |
| Funcionario Obras Públicas | "A veces nos mandan baches que son de alumbrado; perdemos tiempo reasignando" | RP-05, HU-08 (reasignación con registro), RP-06 (filtros por categoría/prioridad) |

### Síntesis cruzada (Documental + Entrevistas)

| Tema | Documental | Entrevistas | Convergencia |
|---|---|---|---|
| Canal único | App municipal única (Doc 1) | "Todo por WhatsApp o llamada, nada unificado" (Vecinos, Funcionarios) | **Alta** — RP-01 crítico |
| Trazabilidad | Número de reclamo + consulta estado (Doc 2) | "Nunca me dan número, no sé en qué va" (Vecinos) | **Alta** — RP-02, RP-03, RP-08 |
| Priorización | Resultados dispares por categoría (Doc 1) | "No sabemos cuáles son urgentes" (Oficina de Partes) | **Alta** — RP-04, HU-06 |
| Plazos de respuesta | Derecho a respuesta ≤ 1 mes (Doc 3) | "Quiero aviso en el celular al instante" (Vecinos) | **Media** — RP-11 (push ≤ 5 min) más estricto que plazo legal |
| Accesibilidad | No abordado explícitamente | Botones grandes, contraste, simpleza (Vecinos A, C) | **Nuevo** — Métrica 3.3 (WCAG 2.1 AA) |

---

### Anexo: Guion base de entrevista (resumen)

**Para vecinos:**
1. ¿Cómo reporta hoy un problema en su barrio (luminaria, basural, bache)?
2. ¿Qué información le piden? ¿Le dan un número de seguimiento?
3. ¿Cómo se entera del avance? ¿Le avisaron alguna vez?
4. ¿Usa smartphone? ¿Qué apps usa habitualmente?
5. ¿Qué le frustraría al usar una app para reportar?

**Para funcionarios:**
1. ¿Por qué canales llegan los reclamos hoy?
2. ¿Cómo se priorizan? ¿Hay criterios escritos?
3. ¿Cómo se asignan a departamentos? ¿Hay reasignaciones frecuentes?
4. ¿Qué información necesitan para cerrar un reporte?
5. ¿Qué dolores tiene el proceso actual?
