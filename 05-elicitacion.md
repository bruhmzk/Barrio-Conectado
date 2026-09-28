# Elicitación de requisitos

Se aplicaron dos técnicas: una entrevista a una dirigente vecinal y una revisión documental de sistemas de reclamos de otros municipios. Ambas sirvieron para contrastar el flujo AS-IS modelado en [01-proceso-as-is.md](./01-proceso-as-is.md) y para respaldar los requisitos de [03-requisitos.md](./03-requisitos.md).

## Técnica: Revisión documental

- **Revisado por:** Bruno Mora, Gabriel del Castillo, Cristobal Cartagena y Jesús Cortés
- **Evidencia:** [capturas de cada documento, guardadas en `./evidencia/`]

### Documentos revisados

1. Artículo de La Voz (Córdoba, Argentina) sobre la gestión de reclamos de alumbrado y bacheo mediante la app "Ciudadana": [enlace](https://grupoclarin-la-voz-prod.cdn.arcpublishing.com/politica/cambiaron-gestion-del-alumbrado-y-ahora-apuntan-al-bacheo)
2. Trámite "Atención de solicitud de fallas en el servicio de alumbrado público" de la empresa eléctrica EERSA (Ecuador), en gob.ec: [enlace](https://www.gob.ec/eersa/tramites/atencion-solicitud-fallas-servicio-alumbrado-publico)
3. Resolución del Síndic de Greuges de la Comunitat Valenciana (España) sobre la falta de respuesta a reclamos de alumbrado público: [enlace](https://www.elsindic.com/resoluciones/expedientes/2025/202504882/12437922.pdf)

### Hallazgos principales

- **Documento 1:** en Córdoba, los reclamos de alumbrado, bacheo, cloacas y basurales entran por una sola app y se derivan a las distintas reparticiones municipales, y quedan geolocalizados en un mapa. Los resultados difieren mucho por categoría: en alumbrado se había resuelto más del 90% de los pedidos, mientras que de 2.479 baches geolocalizados solo se había reparado el 8,1%. Esto respalda tener un canal único, ubicación en el reporte y una priorización por categoría (RP-01, RP-04, RP-05).
- **Documento 2:** el trámite en línea pide los datos del reclamante, el tipo de reclamo y la dirección con referencias, y al registrarlo entrega un número de reclamo con el que se puede consultar el estado. Esto respalda el número de seguimiento y la consulta de estado (RP-02, RP-03, HU-02).
- **Documento 3:** el Síndic señaló que un municipio publicaba su trámite de reclamos de alumbrado sin plazo de resolución, algo contrario al derecho del ciudadano a recibir respuesta en un plazo no superior a un mes. Esto respalda las notificaciones y la trazabilidad de los cambios de estado (RP-08, HU-05).
