# Criterios de aceptación (Gherkin)

## HU-01 — Registrar un reporte

Historia: Como vecino, quiero registrar un reporte adjuntando una foto, mi ubicación y una descripción, para informar a las autoridades de un problema de mi barrio de forma rápida y bien documentada.

```gherkin
Característica: [Nombre de la funcionalidad]

  Escenario: [Escenario principal]
    Dado [contexto inicial, en lenguaje del negocio]
    Y [otro dato del contexto, si hace falta]
    Cuando [acción del rol]
    Entonces [resultado observable]
    Y [otro resultado observable, si hace falta]

  Escenario: [Escenario alternativo o de error]
    Dado [contexto]
    Cuando [acción]
    Entonces [resultado esperado]
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
