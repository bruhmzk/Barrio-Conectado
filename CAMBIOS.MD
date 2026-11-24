### Evaluación 2 - Martes 24 de Noviembre

# Historia de usuario
## HU-09 

Como usuario, quiero enviar un nuevo tipo de reporte, para reportar emergencias de estado critico.

En los criterios de aceptacion:

CA 1: Dado la brevedad en la que se necesita actuar, cuando se requiere publicar una emergencia se necesita reportarla con la menor cantidad de toques posibles. Entonces, se busca hacer la interfaz lo mas simple posible.

CA 2: Dado el poco tiempo en el que se debe operar el reporte, cuando se requiere publicar una emergencia se necesita localizar el apartado sin mucho esfuerzo. Entonces, se tiene que agregar el apartado visible desde el menú principal.

# Casos de uso

En los casos de usos agregar un nuevo actor llamado **Gestor de emergencias** de tipo humano y que se encargue de analizar el reporte y comunicarse con la municipalidad o alguna autoridad respectivamente.

Nuevo caso de uso para el vecino para que mande un reporte tipo emergencia (CU-09).
Nuevo caso de uso para el Gestor de emergencias para gestionar el reporte de emergencia (CU-10).

# Modelo de dominio

En el modelo de dominio: Se opta por modificar la entidad de **Categoría** añadiendo un atributo de **"esEmergencia"** (boolean), y la entidad **Reporte** también recibe el atributo **"esEmergencia"** para identificación rápida.

En la entidad de departamento, ahora esta puede llevar de nombre "Gestor de emergencias".

# Diagrama AS-IS y TO-BE

## AS-IS

En el diagrama, en la fila de _Vecino_, agregar una nueva bifurcación que determine si el caso corresponde a una emergencia, y en caso de serlo, derivarlo a una nueva fila asociada al Gestor de emergencias. En caso que no lo sea, continua su ciclo normal.

## TO-BE

En la fila de la plataforma _Barrio Conectado_, agregar una bifurcación que derive a la nueva fila de Gestor de emergencia.

---

### Implementación completada - 2026-11-24

Se han implementado todos los cambios para la HU-09:

**Documentos actualizados:**
- 04-historias-usuario.md: Agregada HU-09 con CA1 y CA2
- 09-casos-de-uso.md: Agregado actor "Gestor de emergencias", CU-09 y CU-10
- 08-modelo-dominio.md: Atributos esEmergencia en Reporte y Categoría, Departamento actualizado
- 01-proceso-as-is.md: Participante Gestor de emergencias agregado, bifurcación en fila Vecino
- 02-rediseno-to-be.md: Bifurcación en fila Plataforma Barrio Conectado
- 07-criterios-aceptacion.md: Gherkin para HU-09 (2 escenarios)
- 10-diagramas-secuencia.md: Agregado DSS-03
- 11-diagramas-estado.md: Agregado EST-03
- 12-trazabilidad.md: Agregada fila RP-13
- 03-requisitos.md: Agregado RP-13

**Diagramas creados/actualizados:**
- diagramas/casos-de-uso.puml: Actor humano Emer, CU-09, CU-10, conexiones
- diagramas/modelo-dominio.puml: Atributos esEmergencia en Reporte y Categoría
- diagramas/dss-03.puml: Nuevo diagrama de secuencia para emergencias
- diagramas/est-03.puml: Nuevo diagrama de estado para ciclo de vida de emergencia


