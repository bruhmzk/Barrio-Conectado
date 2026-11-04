# Criterios de aceptación (Gherkin)

## HU-01 — Registrar un reporte

Historia: Como vecino, quiero registrar un reporte adjuntando una foto, mi ubicación y una descripción, para informar a las autoridades de un problema de mi barrio de forma rápida y bien documentada.

```gherkin
Característica: Registro de reportes de incidentes

  Escenario: Registro exitoso de un reporte con todos los datos
    Dado que un vecino autenticado se encuentra en la plataforma 
    Y dispone de una fotografia, ubicacion valida y descripcion del problema
    Cuando envia el reporte del incidente
    Entonces el sistema registra el reporte con estado "Ingresado"
    Y asigna un numero de folio unico para el seguimiento del vecino

  Escenario: Intento de registro con datos incompletos
    Dado que un vecuno esta redactando un reporte de incidente
    Cuando intenta enviar el reporte sin adjuntar una descripcion o ubicacion valida
    Entonces el sistema rechaza el registro 
    Y solicita que se completen los datos obligatorios antes de continuar
```

## HU-02 — Consultar mis reportes

Historia: Como vecino, quiero consultar el historial y el estado de mis reportes enviados, para saber en qué etapa está cada uno sin tener que llamar ni ir al municipio.

```gherkin
Característica: Consulta de historial de reportes

  Escenario: Visualización exitosa del historial de reportes activos
    Dado que un vecino ha registrado uno o más reportes previamente
    Cuando solicita consultar el historial de sus solicitudes
    Entonces el sistema despliega la lista de todos sus incidentes reportados
    Y muestra el estado actualizado de cada uno de ellos.

Escenario: Escenario: Consulta de historial por un vecino sin reportes previos
    Dado que un vecino nunca ha registrado un reporte de incidente
    Cuando solicita consultar el historial de sus solicitudes
    Entonces el sistema muestra una lista vacía
    Y le notifica que no existen reportes asociados a su cuenta.
```

## HU-03 — Filtrar reportes para asignar personal

Historia: Como administrador municipal, quiero filtrar los reportes por categoría y prioridad, para asignar personal a la reparación empezando por los casos más críticos.

```gherkin
Característica: Filtrado y priorizacion de reportes 

  Escenario: Filtrado de reportes por alta priorizacion 
    Dado que el administrador municipal revisa la lista general de incidentes
    Cuando aplica un filtro por categoria especifica y prioridad alta
    Entonces el sistema muestra unicamente los reportes que coinciden con esos criterios
    Y los ordena mostrando primero los mas urgentes.

  Escenario: Filtrado sin resultados coincidentes 
    Dado que el administrador municipal revisa la lista de incidentes
    Cuando aplica un filtro para una categoria que no tiene reportes activos
    Entonces el sistema indica que no hay resultados
    Y mantiene la opcion de cambiar los criterios de busqueda
```

## HU-04 — Completar un reporte con nota de resolución

Historia: Como administrador municipal, quiero cambiar el estado de un reporte a "Completado" y añadir una nota de resolución, para dejar constancia del trabajo realizado y que el vecino pueda verlo.

```gherkin
Característica: Resolución de reportes de incidentes

  Escenario: Escenario: Cierre exitoso de un reporte con justificación
    Dado que un reporte se encuentra en estado de revisión o en proceso
    Cuando el administrador municipal cambia el estado a "Completado" y adjunta una nota de resolución
    Entonces el sistema actualiza definitivamente el estado del reporte
    Y notifica al vecino creador que su incidente ha sido resuelto junto con la nota adjunta.

  Escenario: Escenario: Intento de cierre de reporte sin nota de resolución
    Dado que un reporte se encuentra en proceso de atención
    Cuando el administrador municipal intenta cambiar el estado a "Completado" dejando la nota de resolución en blanco
    Entonces el sistema impide la actualización del estado
    Y requiere que se ingrese obligatoriamente la constancia del trabajo realizado.
```
