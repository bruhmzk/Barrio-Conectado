### Evaluación 2 - Martes 24 de Noviembre

# Historia de usuario
## HU-09 

Como usuario, quiero enviar un nuevo tipo de reporte, para reportar emergencias de estado critico.

En los criterios de aceptacion:

CA 1: Dado la brevedad en la que se necesita actuar, cuando se requiere publicar una emergencia se necesita reportarla con la menor cantidad de toques posibles. Entonces, se busca hacer la interfaz lo mas simple posible.

CA 2: Dado el poco tiempo en el que se debe operar el reporte, cuando se requiere publicar una emergencia se necesita localizar el apartado sin mucho esfuerzo. Entonces, se tiene que agregar el apartado visible desde el menú principal.

# Casos de uso

En los casos de usos agregar un nuevo actor llamado **Gestor de emergencias** de tipo humano y que se encargue de analizar el reporte y comunicarse con la municipalidad o alguna autoridad respectivamente.

Nuevo caso de uso para el vecino para que mande un reporte tipo emergencia.
El sexto caso de uso del administrador principal, ligarlo al nuevo actor; El gestor de emergencia.

# Modelo de dominio

En el modelo de dominio: Hay 2 opciones, modificar la entidad de _Reporte_ añadiendo un atributo de **"Máxima prioridad"**, contrastando con el de prioridad, o modificar la entidad de _Categoría_, añadiendo un atributo de **"Emergencia"**.

En la entidad de departamento, ahora esta puede llevar de nombre Gestor de emergencias.

# Diagrama AS-IS y TO-BE

## AS-IS

En el diagrama, en la fila de _Vecino_, agregar una nueva bifurcación que determine si el caso corresponde a una emergencia, y en caso de serlo, derivarlo a una nueva fila asociada al Gestor de emergencias. En caso que no lo sea, continua su ciclo normal.

## TO-BE

En la fila de la plataforma _Barrio Conectado_, agregar una bifurcación que derive a la nueva fila de Gestor de emergencia.


