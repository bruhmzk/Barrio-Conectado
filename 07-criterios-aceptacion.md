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
Característica: [Nombre de la funcionalidad]

  Escenario: [Escenario principal]
    Dado [contexto]
    Cuando [acción]
    Entonces [resultado observable]

  Escenario: [Escenario alternativo o de error]
    Dado [contexto]
    Cuando [acción]
    Entonces [resultado esperado]
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
Característica: [Nombre de la funcionalidad]

  Escenario: [Escenario principal]
    Dado [contexto]
    Cuando [acción]
    Entonces [resultado observable]

  Escenario: [Escenario alternativo o de error]
    Dado [contexto]
    Cuando [acción]
    Entonces [resultado esperado]
```
