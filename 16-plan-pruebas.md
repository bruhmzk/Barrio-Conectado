# 16. Plan de Pruebas y Casos de Prueba (Gherkin)

**Versión:** 1.0  
**Fecha:** 2026-08-15  
**Entrega:** 3 — Implementación y Pruebas  
**Proyecto:** Barrio Conectado

---

## 1. Introducción

### 1.1 Propósito
Este documento define la estrategia de pruebas, plan de pruebas y casos de prueba en formato **Gherkin** para validar el cumplimiento de los **Casos de Uso (CU-01 a CU-08)**, **Historias de Usuario (HU-01 a HU-08)**, **Reglas de Negocio (RN-01 a RN-15)** y **Atributos de Calidad (ISO 25010)** definidos en las entregas anteriores.

### 1.2 Alcance
| Módulo | Casos de Uso | Historias de Usuario | Prioridad |
|--------|--------------|---------------------|-----------|
| Autenticación y Autorización | CU-01, CU-02 | HU-01 | Crítica |
| Gestión de Reportes (Vecino) | CU-03 | HU-02, HU-03 | Crítica |
| Gestión de Reportes (Admin) | CU-04, CU-05, CU-06, CU-07 | HU-04, HU-05, HU-06, HU-07 | Crítica |
| Consultas Geoespaciales | CU-08 | HU-08 | Alta |
| Catálogos y Configuración | — | — | Media |
| Seguridad y Auditoría | RN-13, RN-14, RN-15 | — | Crítica |

### 1.3 Estrategia de Pruebas

#### Niveles de Prueba
| Nivel | Enfoque | Herramientas | Responsable |
|-------|---------|--------------|-------------|
| **Unitarias** | Funciones puras, validadores, transformadores, triggers DB | Jest + Supertest (API), pgTAP (SQL) | Dev |
| **Integración** | Endpoints REST, flujos auth, transacciones DB, colas notificaciones | Jest + Testcontainers (PostgreSQL+PostGIS) | Dev/QA |
| **Sistema (E2E)** | Flujos completos usuario, criterios aceptación Gherkin | Playwright / Cypress | QA |
| **Performance** | Carga API, consultas geoespaciales, migraciones | k6, pgBench | QA |
| **Seguridad** | AuthZ, rate limiting, inyección, tokens | OWASP ZAP, custom scripts | Sec/Dev |

#### Pirámide de Pruebas (Objetivo)
```
        ▲
       / \     E2E: ~50 escenarios críticos (Gherkin)
      /___\    
     /     \   Integración: ~200 tests (API + DB)
    /_______\ 
   /         \ Unitarias: ~500 tests (lógica pura, validadores)
  /___________\
```

### 1.4 Criterios de Aceptación Generales
- **Cobertura mínima:** 80% statements, 70% branches, 80% functions, 70% lines
- **Tiempo de ejecución CI:** < 10 min (unitarias + integración), < 30 min (E2E)
- **Flakiness:** 0 tests inestables en main
- **Trazabilidad:** Cada test vincula a CU/HU/RN/AC (ver matriz §6)

---

## 2. Casos de Prueba Gherkin

> **Convención:** Cada `Feature` = 1 Caso de Uso / Historia de Usuario principal.  
> `Scenario` = 1 Criterio de Aceptación (AC) o regla de negocio.  
> Tags: `@critica @alta @media @baja @seguridad @performance @geo @api @db @e2e`

---

### 2.1 CU-01 / HU-01: Autenticación y Gestión de Sesión

```gherkin
# tests/features/auth_login.feature
@critica @seguridad @api @e2e
Feature: CU-01 - Inicio de sesión y gestión de tokens
  Como usuario registrado
  Quiero autenticar me de forma segura
  Para acceder a funcionalidades según mi rol

  Background:
    Given existe un usuario "vecino@ejemplo.cl" con rol "vecino" y password "Vecino123!"
    And existe un usuario "admin@municipio.cl" con rol "admin" y password "Admin123!"
    And el sistema tiene configurado JWT RS256 con expiración 15 min access / 30 días refresh

  @login_exitoso_vecino
  Scenario: Vecino inicia sesión con credenciales válidas
    When envío POST /auth/login con email "vecino@ejemplo.cl" y password "Vecino123!"
    Then la respuesta tiene status 200
    And el body contiene "accessToken" (JWT válido RS256)
    And el body contiene "refreshToken" (opaque, 30 días)
    And el body contiene "usuario" con rol "vecino"
    And el header no expone "Set-Cookie" (stateless)

  @login_exitoso_admin
  Scenario: Admin inicia sesión con credenciales válidas
    When envío POST /auth/login con email "admin@municipio.cl" y password "Admin123!"
    Then la respuesta tiene status 200
    And el body contiene "usuario" con rol "admin"

  @login_fallido_password_incorrecto
  Scenario: Login falla con contraseña incorrecta
    When envío POST /auth/login con email "vecino@ejemplo.cl" y password "WrongPass123!"
    Then la respuesta tiene status 401
    And el body contiene error "Unauthorized"
    And se registra intento fallido en auditoria_login con exitoso=false

  @login_fallido_usuario_inexistente
  Scenario: Login falla con email no registrado (evita enumeración)
    When envío POST /auth/login con email "noexiste@ejemplo.cl" y password "Cualquiera123!"
    Then la respuesta tiene status 401
    And el mensaje de error es genérico "Credenciales inválidas"
    And el tiempo de respuesta es similar a usuario existente (mitigación timing attack)

  @login_bloqueo_fuerza_bruta
  Scenario: Cuenta se bloquea temporalmente tras 5 intentos fallidos
    Given el límite de intentos fallidos es 5 en ventana 15 min
    When repito 5 veces POST /auth/login con email "vecino@ejemplo.cl" y password incorrecto
    Then el 6to intento recibe status 429 (Too Many Requests)
    And el header "Retry-After" indica segundos de espera
    And en auditoria_login hay 5 registros con exitoso=false y 1 con status 429

  @refresh_token_valido
  Scenario: Renovar access token con refresh token válido
    Given obtuve "refreshToken" via login exitoso
    When envío POST /auth/refresh con el refreshToken
    Then la respuesta tiene status 200
    And nuevo "accessToken" es válido y distinto al anterior
    And nuevo "refreshToken" es rotado (distinto al enviado)
    And el refresh token anterior está revocado en BD

  @refresh_token_revocado
  Scenario: Refresh token revocado no permite renovar
    Given obtuve "refreshToken" via login
    And envié POST /auth/logout (revoca refresh token actual)
    When envío POST /auth/refresh con el mismo refreshToken
    Then la respuesta tiene status 401
    And error indica "Refresh token revocado o inválido"

  @logout_revoca_sesion_actual
  Scenario: Cerrar sesión revoca refresh token actual
    Given estoy autenticado con accessToken y refreshToken
    When envío POST /auth/logout con Authorization Bearer accessToken
    Then la respuesta tiene status 200
    And el refreshToken en BD tiene revocado=true y revocado_en=now()

  @logout_all_revoca_todas_sesiones
  Scenario: Cerrar todas las sesiones revoca todos los refresh tokens del usuario
    Given el usuario tiene 3 refresh tokens activos (móvil, web, tablet)
    When envío POST /auth/logout-all
    Then la respuesta tiene status 200
    And los 3 refresh tokens en BD tienen revocado=true

  @oauth_google_login
  Scenario: Login con Google OAuth2
    Given Google devuelve código de autorización válido
    When envío POST /auth/oauth con provider="google", code="...", redirectUri="..."
    Then la respuesta tiene status 200
    And se crea/actualiza usuario con email de Google
    And rol por defecto es "vecino"

  @jwt_claims_validos
  Scenario: Access token contiene claims esperados
    Given hago login y obtengo accessToken
    When decodifico el JWT (sin verificar firma)
    Then el payload contiene: sub (userId), email, rol, iat, exp, jti
    And exp - iat = 900 segundos (15 min)
    And alg = "RS256" en header
```

---

### 2.2 CU-02: Registro de Vecino

```gherkin
# tests/features/auth_registro.feature
@critica @api @e2e
Feature: CU-02 - Registro de nuevo vecino
  Como vecino no registrado
  Quiero crear mi cuenta
  Para poder reportar problemas en mi barrio

  @registro_exitoso
  Scenario: Registro exitoso con datos válidos
    When envío POST /usuarios/registro con email "nuevo@vecino.cl", nombre "Juan Pérez", password "Seguro123!", telefono "+56 9 1234 5678"
    Then la respuesta tiene status 201
    And el body contiene usuario con rol "vecino" y activo=true
    And password_hash en BD es Argon2id (no plain text)
    And se envía email de bienvenida (cola notificaciones)

  @registro_email_duplicado
  Scenario: Registro falla con email ya existente
    Given existe usuario con email "existente@vecino.cl"
    When envío POST /usuarios/registro con email "existente@vecino.cl" y datos válidos
    Then la respuesta tiene status 409 (Conflict)
    And error indica "Email ya registrado"

  @registro_password_debil
  Scenario: Registro falla con contraseña que no cumple política
    When envío POST /usuarios/registro con password "123" (muy corta)
    Then la respuesta tiene status 400
    And detalles de validación indican campo "password" código "min_length"

  @registro_email_invalido
  Scenario: Registro falla con formato email inválido
    When envío POST /usuarios/registro con email "no-es-email"
    Then la respuesta tiene status 400
    And detalles indican campo "email" código "pattern"
```

---

### 2.3 CU-03 / HU-02, HU-03: Crear y Consultar Reportes (Vecino)

```gherkin
# tests/features/reportes_vecino.feature
@critica @api @e2e @geo
Feature: CU-03 - Gestión de reportes por vecino
  Como vecino autenticado
  Quiero crear reportes con foto y ubicación
  Y consultar el estado de mis reportes
  Para dar seguimiento a los problemas de mi barrio

  Background:
    Given estoy autenticado como "vecino@ejemplo.cl" (accessToken válido)
    And existen categorías: "Luminaria" (Alta), "Microbasural" (Media), "Bache" (Alta)
    And existe departamento "Alumbrado Público" vinculado a "Luminaria"

  @crear_reporte_valido
  Scenario: Crear reporte con todos los campos válidos
    When envío POST /reportes con:
      | categoriaId     | <uuid-luminaria> |
      | descripcion     | "Lámpara fundida en poste esquina Av. Principal c/ Calle 5, sector oscuro y peligroso para peatones nocturnos" |
      | foto            | <base64-jpeg-valido-2mb> |
      | ubicacion       | {"type":"Point","coordinates":[-71.5429,-33.0458]} |
      | referenciaUbicacion | "Esquina Av. Principal c/ Calle 5, frente a plaza" |
    Then la respuesta tiene status 201
    And header Location contiene "/api/v1/reportes/<uuid>"
    And el body contiene reporte con:
      | numeroSeguimiento | matches "REP-\d{4}-\d{6}" |
      | estado            | "Ingresado" |
      | prioridad         | "Alta" (heredada de categoría) |
      | categoriaNombre   | "Luminaria" |
      | departamentoNombre| "Alumbrado Público" |
    And en BD: reporte.usuario_id = mi usuario_id
    And en BD: fotografias tiene 1 registro con reporte_id y orden=1
    And en BD: cambios_estado tiene 1 registro (Ingresado, nota="Reporte ingresado por vecino")
    And se encola notificación Push al vecino "Reporte REP-2025-000001 ingresado"

  @crear_reporte_sin_foto
  Scenario: Crear reporte falla sin foto (obligatoria)
    When envío POST /reportes sin campo "foto"
    Then la respuesta tiene status 400
    And detalles indican campo "foto" código "required"

  @crear_reporte_foto_invalida
  Scenario: Crear reporte falla con foto no-imagen o >10MB
    When envío POST /reportes con foto="base64-de-pdf" (tipo MIME application/pdf)
    Then la respuesta tiene status 422
    And error indica "Formato de imagen no soportado. Use JPEG, PNG, WebP o HEIC"

  @crear_reporte_ubicacion_fuera_chile
  Scenario: Crear reporte falla con coordenadas fuera de Chile continental
    When envío POST /reportes con ubicacion {"type":"Point","coordinates":[0,0]} (océano Atlántico)
    Then la respuesta tiene status 422
    And error indica "Ubicación fuera del área de cobertura (Chile continental)"

  @crear_reporte_categoria_inexistente
  Scenario: Crear reporte falla con categoriaId inexistente
    When envío POST /reportes con categoriaId "00000000-0000-0000-0000-000000000000"
    Then la respuesta tiene status 422
    And error indica "Categoría no encontrada o inactiva"

  @listar_mis_reportes_paginado
  Scenario: Listar mis reportes con paginación y filtro estado
    Given tengo 25 reportes: 10 Ingresado, 8 EnRevisión, 5 Completado, 2 Descartado
    When envío GET /reportes/mis?page=0&size=10&estado=Ingresado&sort=creadoEn,desc
    Then la respuesta tiene status 200
    And body.content tiene 10 items
    And todos tienen estado="Ingresado"
    And page.totalElements = 10
    And page.totalPages = 1

  @ver_detalle_mi_reporte
  Scenario: Ver detalle completo de mi reporte
    Given tengo reporte con id=<uuid-mio>
    When envío GET /reportes/<uuid-mio>
    Then la respuesta tiene status 200
    And body contiene: fotos[], historialEstados[], referenciaUbicacion, categoriaIcono, categoriaColor

  @ver_detalle_reporte_ajeno
  Scenario: Ver detalle de reporte ajeno devuelve 403
    Given existe reporte de otro vecino con id=<uuid-otro>
    When envío GET /reportes/<uuid-otro>
    Then la respuesta tiene status 403
    And error "Acceso denegado: reporte no pertenece al usuario"

  @ver_historial_estados
  Scenario: Ver historial de cambios de estado de mi reporte
    Given mi reporte pasó por: Ingresado → EnRevisión → Completado
    When envío GET /reportes/<uuid-mio>/historial
    Then la respuesta tiene status 200
    And body es array de 3 items con estadoAnterior, estadoNuevo, nota, usuarioNombre, timestamp
    And están ordenados por timestamp asc
```

---

### 2.4 CU-04 / HU-04: Panel Admin - Filtrar y Listar Reportes

```gherkin
# tests/features/reportes_admin_filtrar.feature
@critica @api @e2e
Feature: CU-04 - Panel admin: filtrar y listar reportes
  Como administrador municipal
  Quiero filtrar y paginar todos los reportes
  Para priorizar y asignar trabajo a mi equipo

  Background:
    Given estoy autenticado como "admin@municipio.cl" (rol admin)
    And existen 100 reportes con variedad de estados, prioridades, categorías, departamentos, fechas

  @filtrar_por_estado_multiples
  Scenario: Filtrar por múltiples estados (checkbox UI)
    When envío GET /admin/reportes?estado=Ingresado&estado=EnRevisión&page=0&size=20
    Then la respuesta tiene status 200
    And todos los items tienen estado IN ("Ingresado","EnRevisión")
    And page.totalElements = count(Ingresado + EnRevisión)

  @filtrar_por_prioridad_categoria_depto
  Scenario: Combinar filtros: prioridad Alta + categoría Luminaria + departamento Alumbrado
    When envío GET /admin/reportes?prioridad=Alta&categoriaId=<uuid-luminaria>&departamentoId=<uuid-alumbrado>
    Then la respuesta tiene status 200
    And todos los items coinciden con los 3 filtros simultáneamente

  @filtrar_por_rango_fechas
  Scenario: Filtrar por rango de fechas (últimos 7 días)
    When envío GET /admin/reportes?fechaDesde=2025-08-01&fechaHasta=2025-08-07
    Then la respuesta tiene status 200
    And todos los items tienen creadoEn BETWEEN '2025-08-01' AND '2025-08-07 23:59:59'

  @busqueda_texto_libre
  Scenario: Búsqueda textual en número seguimiento, descripción, vecino
    When envío GET /admin/reportes?busqueda="REP-2025-000123"
    Then la respuesta tiene status 200
    And al menos 1 item tiene numeroSeguimiento contiene "REP-2025-000123"

  @ordenamiento_multiple
  Scenario: Ordenar por prioridad desc, luego creadoEn desc
    When envío GET /admin/reportes?sort=prioridad,desc&sort=creadoEn,desc
    Then la respuesta tiene status 200
    And items están ordenados: Alta > Media > Baja, y dentro de cada prioridad por fecha desc

  @respuesta_incluye_info_admin
  Scenario: Lista admin incluye campos adicionales (vecino, depto, admin asignado, confirmación)
    When envío GET /admin/reportes?page=0&size=5
    Then cada item tiene: vecinoNombre, vecinoEmail, departamentoNombre, adminAsignadoNombre, asignacionConfirmada, ultimaActualizacionEstado
```

---

### 2.5 CU-05 / HU-05: Cambiar Estado de Reporte (Admin)

```gherkin
# tests/features/reportes_admin_estado.feature
@critica @api @e2e @seguridad
Feature: CU-05 - Cambio de estado de reporte por admin
  Como administrador
  Quiero cambiar el estado de un reporte con nota obligatoria según transición
  Para reflejar el avance real de la gestión municipal

  Background:
    Given estoy autenticado como admin
    And existe reporte <uuid-rep> en estado "Ingresado", prioridad "Alta", asignado a depto "Alumbrado"

  @transicion_ingresado_enrevision
  Scenario: Ingresado → EnRevisión (nota opcional)
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="EnRevisión", nota="Iniciando revisión técnica"
    Then la respuesta tiene status 200
    And reporte.estado = "EnRevisión"
    And cambios_estado nuevo registro: anterior="Ingresado", nuevo="EnRevisión", nota="Iniciando revisión técnica"
    And notificación encolada: Push al vecino "Tu reporte REP-... está en revisión"

  @transicion_enrevision_completado_con_nota
  Scenario: EnRevisión → Completado (nota OBLIGATORIA = resolución)
    Given reporte está en "EnRevisión"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="Completado", nota="Lámpara reemplazada, funcionamiento verificado"
    Then la respuesta tiene status 200
    And reporte.estado = "Completado"
    And reporte.completado_en = now()
    And notificación encolada: Push + Email al vecino "Tu reporte REP-... ha sido COMPLETADO: Lámpara reemplazada..."

  @transicion_enrevision_completado_sin_nota_FALLA
  Scenario: EnRevisión → Completado SIN nota FALLA (validación RN-02)
    Given reporte está en "EnRevisión"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="Completado", nota=""
    Then la respuesta tiene status 422
    And error: "La nota de resolución es obligatoria para completar el reporte"
    And reporte.estado sigue siendo "EnRevisión"

  @transicion_ingresado_completado_FALLA
  Scenario: Ingresado → Completado DIRECTO FALLA (RN-01: transición inválida)
    Given reporte está en "Ingresado"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="Completado", nota="Resuelto"
    Then la respuesta tiene status 409 (Conflict)
    And error: "Transición inválida: Ingresado -> Completado (debe pasar por EnRevisión)"

  @transicion_cualquier_descartado_con_motivo
  Scenario: Cualquier estado → Descartado (nota OBLIGATORIA = motivo)
    Given reporte está en "EnRevisión"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="Descartado", nota="Duplicado de REP-2025-000045"
    Then la respuesta tiene status 200
    And reporte.estado = "Descartado"
    And notificación encolada: Push al vecino "Tu reporte REP-... fue DESCARTADO: Duplicado..."

  @transicion_completado_enrevision_FALLA
  Scenario: Completado → EnRevisión FALLA (RN-01: no retroceso desde terminal)
    Given reporte está en "Completado"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="EnRevisión", nota="Reabrir"
    Then la respuesta tiene status 409
    And error: "Transición inválida: Completado -> EnRevisión (estado terminal)"

  @transicion_descartado_cualquier_FALLA
  Scenario: Descartado → Cualquier estado FALLA (RN-01: estado terminal)
    Given reporte está en "Descartado"
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="Ingresado", nota="Error"
    Then la respuesta tiene status 409
    And error: "Transición inválida: Descartado -> Ingresado (estado terminal)"

  @auditoria_cambio_estado
  Scenario: Cada cambio de estado queda auditado con usuario admin
    When envío PATCH /admin/reportes/<uuid-rep>/estado con estado="EnRevisión", nota="..."
    Then en cambios_estado: usuario_id = mi admin_id, usuario_nombre = "Administrador Municipal"
```

---

### 2.6 CU-06 / HU-06: Ajustar Prioridad y Reasignar (Admin)

```gherkin
# tests/features/reportes_admin_prioridad_reasignar.feature
@critica @api @e2e
Feature: CU-06 - Ajuste de prioridad y reasignación de reportes
  Como administrador
  Quiero ajustar prioridad y reasignar reportes entre departamentos
  Para optimizar la carga de trabajo y tiempos de respuesta

  Background:
    Given estoy autenticado como admin
    And existe reporte <uuid-rep> en "EnRevisión", prioridad "Media", depto "Alumbrado"

  @ajustar_prioridad_alta
  Scenario: Subir prioridad de Media a Alta
    When envío PATCH /admin/reportes/<uuid-rep>/prioridad con prioridad="Alta", nota="Reportan riesgo eléctrico en poste"
    Then la respuesta tiene status 200
    And reporte.prioridad = "Alta"
    And notificación encolada a admin asignado: "Prioridad elevada a ALTA para REP-..."

  @ajustar_prioridad_baja
  Scenario: Bajar prioridad de Alta a Baja
    When envío PATCH /admin/reportes/<uuid-rep>/prioridad con prioridad="Baja", nota="Falso positivo, lámpara funcional"
    Then la respuesta tiene status 200
    And reporte.prioridad = "Baja"

  @reasignar_departamento_otro
  Scenario: Reasignar a otro departamento (limpia admin asignado)
    Given existe depto "Obras Viales" <uuid-obras>
    When envío PATCH /admin/reportes/<uuid-rep>/reasignar con departamentoId=<uuid-obras>, notas="En realidad es bache, no luminaria"
    Then la respuesta tiene status 200
    And reporte.departamento_id = <uuid-obras>
    And reporte.admin_asignado_id = NULL
    And reporte.asignacion_confirmada = false
    And en asignaciones: nuevo registro con usuario_id=NULL, confirmada=false
    And notificación encolada al nuevo depto: "Nuevo reporte asignado: REP-..."

  @reasignar_con_admin_especifico
  Scenario: Reasignar a departamento Y admin específico
    Given existe admin "juan@municipio.cl" <uuid-juan> en depto "Obras Viales"
    When envío PATCH /admin/reportes/<uuid-rep>/reasignar con departamentoId=<uuid-obras>, usuarioId=<uuid-juan>, notas="Asignar a Juan"
    Then la respuesta tiene status 200
    And reporte.admin_asignado_id = <uuid-juan>
    And reporte.asignacion_confirmada = false
    And en asignaciones: usuario_id=<uuid-juan>, confirmada=false
    And notificación Push a Juan: "Se te asignó reporte REP-... (pendiente confirmación)"

  @confirmar_asignacion_admin
  Scenario: Admin asignado confirma la asignación
    Given reporte tiene admin_asignado_id = mi_id, asignacion_confirmada = false
    When envío PATCH /admin/reportes/<uuid-rep>/confirmar-asignacion (endpoint implícito en reasignar o separado)
    Then reporte.asignacion_confirmada = true
    And asignaciones confirmada = true, confirmada_en = now()
```

---

### 2.7 CU-07 / HU-07: Estadísticas y Exportación (Admin)

```gherkin
# tests/features/admin_estadisticas_export.feature
@alta @api @e2e
Feature: CU-07 - Dashboard estadísticas y exportación
  Como administrador
  Quiero ver KPIs en tiempo real y exportar datos
  Para tomar decisiones basadas en datos y rendir cuentas

  Background:
    Given estoy autenticado como admin
    And hay datos históricos de 6 meses

  @estadisticas_dashboard_kpis
  Scenario: Obtener KPIs para dashboard
    When envío GET /admin/reportes/estadisticas
    Then la respuesta tiene status 200
    And body contiene: ingresados, enRevision, completados, descartados, prioridadAlta/Media/Baja
    And body contiene: ultimas24h, ultimos7d, ultimos30d, horasPromedioResolucion
    And horasPromedioResolucion calcula solo reportes Completado con (completado_en - creado_en)

  @exportar_csv_filtrado
  Scenario: Exportar reportes a CSV con filtros
    When envío GET /admin/reportes/exportar?formato=csv&estado=Completado&fechaDesde=2025-01-01&fechaHasta=2025-01-31
    Then la respuesta tiene status 200
    And header Content-Type = "text/csv"
    And header Content-Disposition = 'attachment; filename="reportes-2025-01.csv"'
    And body CSV tiene columnas: numeroSeguimiento,categoria,estado,prioridad,vecino,departamento,creadoEn,completadoEn,horasResolucion

  @exportar_xlsx
  Scenario: Exportar a Excel (xlsx)
    When envío GET /admin/reportes/exportar?formato=xlsx
    Then la respuesta tiene status 200
    And Content-Type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
```

---

### 2.8 CU-08 / HU-08: Consultas Geoespaciales

```gherkin
# tests/features/geoespacial.feature
@alta @api @geo @performance
Feature: CU-08 - Consultas geoespaciales (mapa y proximidad)
  Como vecino o admin
  Quiero ver reportes en mapa y buscar cercanos
  Para visualizar la distribución espacial de problemas

  Background:
    Given estoy autenticado
    And existen 50 reportes activos (Ingresado/EnRevisión) distribuidos en Santiago

  @reportes_cercanos_vecino
  Scenario: Vecino busca reportes en radio 500m de su ubicación
    When envío GET /reportes/cercanos?lat=-33.0458&lon=-71.5429&radio=500&limite=20
    Then la respuesta tiene status 200
    And Content-Type = "application/geo+json"
    And body es FeatureCollection con features type=Feature, geometry=Point
    And cada feature.properties tiene: id, numeroSeguimiento, categoriaNombre, categoriaIcono, categoriaColor, estado, prioridad, referenciaUbicacion, creadoEn
    And todos los reportes están dentro de 500m (ST_DWithin)
    And máximo 20 features (ordenados por distancia asc)

  @reportes_cercanos_radio_maximo
  Scenario: Radio máximo permitido 5000m
    When envío GET /reportes/cercanos?lat=-33.0458&lon=-71.5429&radio=10000
    Then la respuesta tiene status 400
    And error: "Radio máximo permitido: 5000 metros"

  @reportes_mapa_admin_bbox
  Scenario: Admin obtiene reportes en bounding box para mapa
    When envío GET /reportes/mapa?bbox=-71.6,-33.1,-71.5,-33.0&estado=Ingresado&estado=EnRevisión
    Then la respuesta tiene status 200
    And Content-Type = "application/geo+json"
    And todos los features están dentro del bbox (ST_MakeEnvelope + ST_Contains)
    And solo incluye estados Ingresado y EnRevisión

  @performance_consulta_geo_500ms
  Scenario: Consulta geoespacial responde en < 500ms (P95)
    Given 10,000 reportes activos en BD con índice GIST
    When ejecuto 100 consultas concurrentes GET /reportes/cercanos con lat/lon aleatorios en Santiago
    Then el percentil 95 de latencia < 500ms
    And no hay errores 5xx
```

---

### 2.9 Catálogos (Categorías y Departamentos)

```gherkin
# tests/features/catalogos.feature
@media @api
Feature: Catálogos - Categorías y Departamentos
  Como usuario (vecino/admin)
  Quiero consultar catálogos activos
  Para seleccionar categoría al crear reporte / gestionar catálogos (admin)

  @listar_categorias_publico
  Scenario: Cualquier usuario lista categorías activas
    When envío GET /categorias (sin auth)
    Then status 200
    And array con 8 categorías (Luminaria, Microbasural, Bache, Señalética, Vereda, Parques/Plazas, Drenaje, Otro)
    And cada una tiene: id, nombre, descripcion, prioridadBase, icono, colorHex, activo=true

  @crear_categoria_admin
  Scenario: Admin crea nueva categoría
    Given soy admin
    When envío POST /categorias con nombre="Semáforos", prioridadBase="Alta", icono="traffic_light", colorHex="#FF0000"
    Then status 201
    And categoría creada con id UUID, activo=true

  @actualizar_categoria_admin
  Scenario: Admin actualiza categoría (cambio color/icono)
    Given soy admin y existe categoría "Luminaria" <uuid>
    When envío PATCH /categorias/<uuid> con colorHex="#FFA500", icono="lightbulb_outline"
    Then status 200
    And categoría actualizada

  @desactivar_categoria_admin
  Scenario: Admin desactiva categoría (soft delete)
    Given soy admin
    When envío DELETE /categorias/<uuid-luminaria>
    Then status 200
    And categoría.activo = false
    And GET /categorias ya no la incluye (filtro activo=true por defecto)

  @listar_departamentos
  Scenario: Listar departamentos activos
    When envío GET /departamentos
    Then status 200
    And 7 departamentos con email_contacto y telefono
```

---

### 2.10 Seguridad Transversal

```gherkin
# tests/features/seguridad_transversal.feature
@critica @seguridad @api
Feature: Seguridad transversal - AuthZ, Rate Limiting, Validación

  @rate_limiting_usuario
  Scenario: Rate limit 100 req/min por usuario (burst 20)
    Given soy usuario autenticado
    When hago 120 requests GET /reportes/mis en 60 segundos
    Then los primeros 100 responden 200
    And los siguientes 20 responden 429 con header Retry-After

  @rate_limiting_ip
  Scenario: Rate limit 1000 req/min por IP (anonimo)
    Given NO estoy autenticado
    When hago 1100 requests GET /categorias en 60 segundos desde misma IP
    Then los primeros 1000 responden 200
    And los siguientes 100 responden 429

  @jwt_expirado
  Scenario: Access token expirado (15 min) devuelve 401
    Given tengo accessToken generado hace 20 minutos
    When envío GET /reportes/mis con Authorization Bearer token_expirado
    Then status 401
    And error "Token JWT expirado o inválido"

  @jwt_firma_invalida
  Scenario: JWT con firma manipulada devuelve 401
    Given tengo accessToken válido
    And modifico el payload (cambio rol a "admin") sin firmar
    When envío request con token manipulado
    Then status 401
    And NO se ejecuta lógica de negocio (validación firma antes que authZ)

  @acceso_admin_sin_rol
  Scenario: Vecino intenta endpoint admin devuelve 403
    Given soy vecino autenticado
    When envío GET /admin/reportes
    Then status 403
    And error "Requiere rol ADMIN"

  @inyeccion_sql_ubicacion
  Scenario: Intento inyección SQL en parámetros geo devuelve 400
    When envío GET /reportes/cercanos?lat=-33.0458'; DROP TABLE reportes;--
    Then status 400 (validación tipo number rechaza string)
    And NO se ejecuta SQL arbitrario

  @xss_descripcion_reporte
  Scenario: Descripción con script XSS se sanitiza/escapa
    When envío POST /reportes con descripcion="<script>alert('xss')</script>Lámpara fundida"
    Then status 201
    And en BD descripcion guarda "<script>alert('xss')</script>Lámpara fundida" (escaped)
    Or en respuesta API el campo viene sanitizado

  @cors_origen_permitido
  Scenario: CORS permite origen frontend configurado
    When envío OPTIONS /reportes con Origin: https://app.barrio-conectado.cl
    Then status 200/204
    And header Access-Control-Allow-Origin: https://app.barrio-conectado.cl
    And header Access-Control-Allow-Credentials: true

  @cors_origen_no_permitido
  Scenario: CORS bloquea origen no configurado
    When envío OPTIONS /reportes con Origin: https://malicioso.com
    Then status 200/204 PERO sin header Access-Control-Allow-Origin
    Or status 403
```

---

### 2.11 Reglas de Negocio (RN) - Cobertura Explícita

```gherkin
# tests/features/reglas_negocio.feature
@critica @api @db
Feature: Reglas de negocio - Validación a nivel BD y API

  @rn01_transiciones_validas
  Scenario: RN-01 - Solo transiciones de estado válidas permitidas (trigger BD)
    Given reporte en "Ingresado"
    When intento UPDATE directo en BD: UPDATE reportes SET estado='Completado' WHERE id=...
    Then la BD rechaza con error trigger: "Transición inválida: Ingresado -> Completado"
    And reporte.estado sigue "Ingresado"

  @rn02_nota_obligatoria_completado
  Scenario: RN-02 - Nota obligatoria para Completado (trigger BD)
    Given reporte en "EnRevisión"
    When intento UPDATE en BD: UPDATE reportes SET estado='Completado', nota_resolucion=NULL WHERE id=...
    Then la BD rechaza: "Nota de resolución obligatoria para estado Completado"

  @rn03_nota_obligatoria_descartado
  Scenario: RN-03 - Nota obligatoria para Descartado (trigger BD)
    Given reporte en "EnRevisión"
    When intento UPDATE en BD: UPDATE reportes SET estado='Descartado', nota_resolucion='' WHERE id=...
    Then la BD rechaza: "Motivo obligatorio para estado Descartado"

  @rn04_prioridad_heredada_categoria
  Scenario: RN-04 - Prioridad inicial heredada de categoría.base (trigger BD)
    Given categoría "Luminaria" tiene prioridad_base='Alta'
    When inserto reporte con categoria_id=<luminaria> SIN especificar prioridad
    Then reporte.prioridad = 'Alta' (trigger setea por defecto)

  @rn05_departamento_derivado_categoria
  Scenario: RN-05 - Departamento derivado de categoría (principal) (trigger BD)
    Given categoría "Bache" tiene categoria_departamento.es_principal=true con "Obras Viales"
    When inserto reporte con categoria_id=<bache> SIN especificar departamento_id
    Then reporte.departamento_id = <obras-viales> (trigger setea)

  @rn06_unico_reporte_activo_mismo_punto
  Scenario: RN-06 - Evitar duplicados: mismo vecino, misma ubicación (~10m), misma categoría, últimos 30 días
    Given vecino creó reporte "Luminaria" en punto P hace 5 días, estado="EnRevisión"
    When mismo vecino intenta crear otro reporte "Luminaria" en punto P+5m
    Then API devuelve 409: "Posible duplicado: reporte similar activo a 5 metros (REP-2025-000123)"
    And sugiere: "¿Desea agregar foto/comentario al reporte existente?"

  @rn07_foto_obligatoria
  Scenario: RN-07 - Foto obligatoria al crear reporte (validación API + BD NOT NULL)
    When creo reporte sin campo foto
    Then API 400: "La foto es obligatoria"

  @rn08_formato_imagen_valido
  Scenario: RN-08 - Formato imagen: JPEG, PNG, WebP, HEIC máx 10MB
    When creo reporte con foto base64 de PDF (application/pdf)
    Then API 422: "Formato no soportado"

  @rn09_ubicacion_chile_continental
  Scenario: RN-09 - Ubicación dentro de Chile continental (trigger BD CHECK constraint)
    When inserto reporte con ubicacion POINT(0 0) (océano)
    Then BD rechaza: CHECK constraint "chk_ubicacion_chile" violated

  @rn10_estado_terminal_no_cambia
  Scenario: RN-10 - Estados terminales (Completado, Descartado) no permiten cambios posteriores
    Given reporte en "Completado"
    When intento cualquier UPDATE de estado
    Then BD rechaza trigger: "Estado terminal no permite modificaciones"

  @rn11_admin_confirmacion_asignacion
  Scenario: RN-11 - Admin asignado debe confirmar asignación antes de actuar
    Given reporte asignado a admin Juan, confirmada=false
    When Juan intenta PATCH /admin/reportes/<id>/estado
    Then API 403: "Debe confirmar asignación antes de gestionar el reporte"

  @rn12_notificacion_cambio_estado
  Scenario: RN-12 - Todo cambio de estado encola notificación al vecino
    Given reporte de vecino María
    When admin cambia estado a "EnRevisión"
    Then en notificaciones: 1 registro destinatario=María, tipo=Push, estado=Pendiente, referencia_reporte=<id>

  @rn13_password_argon2id
  Scenario: RN-13 - Contraseñas hasheadas con Argon2id (nunca plain text)
    When registro usuario con password "MiPass123!"
    Then en BD usuarios.password_hash empieza con "$argon2id$"
    And longitud hash > 80 chars

  @rn14_jwt_rs256_15min
  Scenario: RN-14 - JWT RS256, access 15 min, refresh 30 días (rotación)
    When login exitoso
    Then accessToken: alg=RS256, exp-iat=900
    And refreshToken: opaque, expira_en = now() + 30 días
    And POST /auth/refresh rota refresh token (nuevo distinto, anterior revocado)

  @rn15_auditoria_login
  Scenario: RN-15 - Auditoría de login (exitosos y fallidos) con IP, user-agent
    When login (exitoso o fallido)
    Then en auditoria_login: 1 registro con usuario_id (o NULL), ip, user_agent, exitoso, creado_en
```

---

### 2.12 Atributos de Calidad (ISO 25010) - Pruebas No Funcionales

```gherkin
# tests/features/calidad_iso25010.feature
@performance @seguridad @compatibilidad @usabilidad
Feature: Atributos de calidad ISO 25010 - Pruebas no funcionales

  @performance_tiempo_respuesta_api
  Scenario: NFR-PERF-01 - Tiempo respuesta API p95 < 300ms (excluyendo geo)
    Given 1000 reportes en BD, 100 usuarios concurrentes
    When ejecuto carga 100 RPS durante 5 min en endpoints: /reportes/mis, /admin/reportes, /categorias
    Then p95 latencia < 300ms
    And tasa error < 0.1%

  @performance_consulta_geo
  Scenario: NFR-PERF-02 - Consulta geoespacial p95 < 500ms
    Given 10,000 reportes activos con índice GIST
    When 50 RPS en /reportes/cercanos durante 3 min
    Then p95 < 500ms
    And uso CPU BD < 70%

  @performance_throughput
  Scenario: NFR-PERF-03 - Throughput 200 RPS sostenido
    When carga constante 200 RPS mixto (70% lectura, 30% escritura) 10 min
    Then 0 timeouts, 0 errores 5xx
    And latencia p99 < 1000ms

  @disponibilidad_99_9
  Scenario: NFR-DISP-01 - Disponibilidad 99.9% (ventana mantenimiento 4h/mes)
    Given deployment en Kubernetes con 3 réplicas, health checks, rolling updates
    When simulo caída de 1 pod, rolling update, reinicio BD (failover)
    Then API recupera < 30s sin pérdida de requests (retry client-side)

  @seguridad_autenticacion_fuerte
  Scenario: NFR-SEG-01 - Autenticación fuerte (Argon2id, JWT RS256, rate limit)
    Given intentos de ataque: fuerza bruta, credential stuffing, token replay
    Then todos bloqueados/mitigados (rate limit, hash lento, tokens rotados, revocación)

  @seguridad_autorizacion_rbac
  Scenario: NFR-SEG-02 - Control de acceso basado en roles (RBAC) estricto
    Given matrix de permisos por rol/endpoint
    When pruebo todos los endpoints con cada rol
    Then solo accesos permitidos devuelven 2xx, resto 403/401

  @seguridad_datos_sensibles
  Scenario: NFR-SEG-03 - Datos sensibles protegidos (passwords, tokens, PII)
    When inspecciono BD, logs, respuesta API, memory dumps
    Then NO hay passwords en claro, refresh tokens completos, emails en logs
    And password_hash solo en BD, accessToken solo en header Authorization

  @compatibilidad_navegadores
  Scenario: NFR-COMP-01 - Frontend compatible Chrome, Firefox, Safari, Edge (últimas 2 versiones)
    When ejecuto suite E2E Playwright en matrix navegadores
    Then 0 fallos por compatibilidad CSS/JS/API

  @compatibilidad_api_versionado
  Scenario: NFR-COMP-02 - API versionado (/api/v1), retrocompatibilidad
    When lanzo v1.1 con campos opcionales nuevos
    Then clientes v1.0 siguen funcionando (campos nuevos ignorados)

  @usabilidad_accesibilidad_wcag
  Scenario: NFR-USAB-01 - Accesibilidad WCAG 2.1 AA (frontend)
    When auditoría automatizada (axe-core) + manual en flujos críticos
    Then 0 violaciones AA críticas (contraste, foco, labels, ARIA)

  @mantenibilidad_cobertura_tests
  Scenario: NFR-MANT-01 - Cobertura tests ≥ 80% statements
    When ejecuto suite completa con coverage
    Then statements ≥ 80%, branches ≥ 70%, functions ≥ 80%, lines ≥ 70%

  @portabilidad_contenedores
  Scenario: NFR-PORT-01 - Despliegue en contenedores (Docker/K8s) multi-arquitectura
    When builéo imagen multi-arch (amd64, arm64) y despliego en K8s kind
    Then aplicación inicia, health checks pasan, API responde
```

---

## 3. Datos de Prueba (Test Data)

### 3.1 Fixtures / Seed Data para Tests

```sql
-- tests/fixtures/seed_test_data.sql
-- Usuarios base
INSERT INTO usuarios (id, email, nombre, telefono, rol, password_hash, activo) VALUES
('11111111-1111-1111-1111-111111111111', 'admin@test.cl', 'Admin Test', '+56911111111', 'admin', '$argon2id$...', true),
('22222222-2222-2222-2222-222222222222', 'vecino1@test.cl', 'Vecino Uno', '+56922222222', 'vecino', '$argon2id$...', true),
('33333333-3333-3333-3333-333333333333', 'vecino2@test.cl', 'Vecino Dos', '+56933333333', 'vecino', '$argon2id$...', true),
('44444444-4444-4444-4444-444444444444', 'moderador@test.cl', 'Mod Test', '+56944444444', 'moderador', '$argon2id$...', true);

-- Categorías y Departamentos (subset de V005)
INSERT INTO categorias (id, nombre, descripcion, prioridad_base, icono, color_hex, activo) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Luminaria', 'Alumbrado público', 'Alta', 'lightbulb', '#FFD600', true),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Microbasural', 'Residuos en vía pública', 'Media', 'delete', '#EF6C00', true),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Bache', 'Hoyos en calzada', 'Alta', 'road', '#C62828', true);

INSERT INTO departamentos (id, nombre, descripcion, email_contacto, telefono, activo) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Alumbrado Público', 'Mantención luminarias', 'alumbrado@test.cl', '+5632111111', true),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Obras Viales', 'Baches y pavimento', 'obras@test.cl', '+5632222222', true);

INSERT INTO categoria_departamento (categoria_id, departamento_id, es_principal) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'dddddddd-dddd-dddd-dddd-dddddddddddd', true),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'dddddddd-dddd-dddd-dddd-dddddddddddd', true),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', true);
```

### 3.2 Factories / Builders (TypeScript/Jest)

```typescript
// tests/factories/reporte.factory.ts
export const createReporteDto = (overrides: Partial<ReporteCreateRequest> = {}): ReporteCreateRequest => ({
  categoriaId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  descripcion: 'Lámpara fundida en poste esquina, sector oscuro y peligroso para peatones',
  foto: validBase64Jpeg1MB,
  ubicacion: { type: 'Point', coordinates: [-71.5429, -33.0458] },
  referenciaUbicacion: 'Esquina Av. Principal c/ Calle 5',
  ...overrides,
});

export const createAdminUser = (): User => ({
  id: '11111111-1111-1111-1111-111111111111',
  email: 'admin@test.cl',
  rol: 'admin',
  // ...
});
```

---

## 4. Automatización y CI/CD

### 4.1 Pipeline de Pruebas (GitHub Actions / GitLab CI)

```yaml
# .github/workflows/test.yml
name: Test Pipeline

on: [push, pull_request]

jobs:
  unit-integration:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgis/postgis:16-3.4
        env:
          POSTGRES_DB: barrio_conectado_test
          POSTGRES_PASSWORD: test
        ports: [5432:5432]
        options: >-
          --health-cmd "pg_isready -U postgres"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run db:migrate:test  # Aplica V001-V007 en BD test
      - run: npm run db:seed:test     # Carga fixtures
      - run: npm run test:unit        # Jest unitarias
      - run: npm run test:integration # Jest integración (API + BD real)
      - run: npm run test:coverage    # Genera reporte coverage
      - uses: codecov/codecov-action@v3

  e2e:
    runs-on: ubuntu-latest
    needs: unit-integration
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - run: npm run start:prod &  # Levanta API en background
      - run: npx wait-on http://localhost:3000/api/v1/health
      - run: npm run test:e2e       # Playwright/Cypress contra API real
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: e2e-screenshots
          path: test-results/screenshots/

  performance:
    runs-on: ubuntu-latest
    needs: unit-integration
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: k6 run tests/performance/load-test.js
      - uses: actions/upload-artifact@v4
        with:
          name: k6-report
          path: k6-report.html

  security:
    runs-on: ubuntu-latest
    needs: unit-integration
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm audit --audit-level=high
      - uses: zaproxy/action-full-scan@v0.5.0
        with:
          target: 'http://localhost:3000'
```

### 4.2 Ejecución de Tests Gherkin

```typescript
// tests/bdd/steps/common.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { request, expect } from '@playwright/test';

Given('estoy autenticado como {string}', async (email: string) => {
  const loginRes = await request.post('/api/v1/auth/login', {
    data: { email, password: getTestPassword(email) }
  });
  expect(loginRes.status()).toBe(200);
  const { accessToken } = await loginRes.json();
  testContext.set('authToken', accessToken);
});

When('envío {string} {string} con:', async (method: string, endpoint: string, table: DataTable) => {
  const body = table.rowsHash();
  const headers: Record<string, string> = {};
  if (testContext.has('authToken')) {
    headers['Authorization'] = `Bearer ${testContext.get('authToken')}`;
  }
  testContext.set('lastResponse', await request[method.toLowerCase()](`/api/v1${endpoint}`, { data: body, headers }));
});

Then('la respuesta tiene status {int}', async (status: number) => {
  expect(testContext.get('lastResponse').status()).toBe(status);
});

Then('el body contiene {string} con valor {string}', async (field: string, value: string) => {
  const body = await testContext.get('lastResponse').json();
  expect(body[field]).toBe(value);
});
```

---

## 5. Matriz de Trazabilidad (Tests ↔ Requisitos)

| Test ID | Feature/Scenario | CU | HU | RN | AC | Attr. Calidad |
|---------|------------------|----|----|----|----|---------------|
| T-AUTH-01 | login_exitoso_vecino | CU-01 | HU-01 | RN-13, RN-14 | AC-01 | Seguridad |
| T-AUTH-02 | login_fallido_password_incorrecto | CU-01 | HU-01 | RN-15 | AC-02 | Seguridad |
| T-AUTH-03 | login_bloqueo_fuerza_bruta | CU-01 | HU-01 | RN-15 | AC-03 | Seguridad |
| T-AUTH-04 | refresh_token_valido | CU-01 | HU-01 | RN-14 | AC-04 | Seguridad |
| T-AUTH-05 | oauth_google_login | CU-01 | HU-01 | RN-14 | AC-05 | Seguridad |
| T-REG-01 | registro_exitoso | CU-02 | HU-01 | RN-13 | AC-06 | Seguridad |
| T-REP-01 | crear_reporte_valido | CU-03 | HU-02 | RN-04,05,07,08,09 | AC-07 | Funcionalidad |
| T-REP-02 | crear_reporte_sin_foto | CU-03 | HU-02 | RN-07 | AC-08 | Funcionalidad |
| T-REP-03 | crear_reporte_ubicacion_fuera_chile | CU-03 | HU-02 | RN-09 | AC-09 | Funcionalidad |
| T-REP-04 | listar_mis_reportes_paginado | CU-03 | HU-03 | - | AC-10 | Funcionalidad |
| T-REP-05 | ver_detalle_mi_reporte | CU-03 | HU-03 | - | AC-11 | Funcionalidad |
| T-REP-06 | ver_detalle_reporte_ajeno | CU-03 | HU-03 | - | AC-12 | Seguridad |
| T-ADM-01 | filtrar_por_estado_multiples | CU-04 | HU-04 | - | AC-13 | Funcionalidad |
| T-ADM-02 | busqueda_texto_libre | CU-04 | HU-04 | - | AC-14 | Funcionalidad |
| T-ADM-03 | transicion_ingresado_enrevision | CU-05 | HU-05 | RN-01, RN-12 | AC-15 | Funcionalidad |
| T-ADM-04 | transicion_enrevision_completado_con_nota | CU-05 | HU-05 | RN-01, RN-02, RN-12 | AC-16 | Funcionalidad |
| T-ADM-05 | transicion_enrevision_completado_sin_nota_FALLA | CU-05 | HU-05 | RN-02 | AC-17 | Funcionalidad |
| T-ADM-06 | transicion_ingresado_completado_FALLA | CU-05 | HU-05 | RN-01 | AC-18 | Funcionalidad |
| T-ADM-07 | ajustar_prioridad_alta | CU-06 | HU-06 | - | AC-19 | Funcionalidad |
| T-ADM-08 | reasignar_departamento_otro | CU-06 | HU-06 | RN-11 | AC-20 | Funcionalidad |
| T-ADM-09 | estadisticas_dashboard_kpis | CU-07 | HU-07 | - | AC-21 | Funcionalidad |
| T-ADM-10 | exportar_csv_filtrado | CU-07 | HU-07 | - | AC-22 | Funcionalidad |
| T-GEO-01 | reportes_cercanos_vecino | CU-08 | HU-08 | - | AC-23 | Performance/Geo |
| T-GEO-02 | reportes_mapa_admin_bbox | CU-08 | HU-08 | - | AC-24 | Performance/Geo |
| T-SEC-01 | rate_limiting_usuario | - | - | RN-15 | - | Seguridad |
| T-SEC-02 | jwt_expirado | - | - | RN-14 | - | Seguridad |
| T-SEC-03 | acceso_admin_sin_rol | - | - | - | - | Seguridad |
| T-RN-01 | rn01_transiciones_validas | - | - | RN-01 | - | Integridad BD |
| T-RN-02 | rn02_nota_obligatoria_completado | - | - | RN-02 | - | Integridad BD |
| T-RN-03 | rn06_unico_reporte_activo_mismo_punto | - | - | RN-06 | - | Integridad BD |
| T-PERF-01 | performance_tiempo_respuesta_api | - | - | - | - | Performance |
| T-PERF-02 | performance_consulta_geo | - | - | - | - | Performance |

---

## 6. Definición de Listo (Definition of Done) para Pruebas

| Criterio | Descripción |
|----------|-------------|
| ✅ **Cobertura** | ≥ 80% statements, ≥ 70% branches en código nuevo/modificado |
| ✅ **Gherkin** | Todos los AC de CU/HU tienen al menos 1 Scenario Gherkin |
| ✅ **E2E Críticos** | 100% flujos críticos (login, crear reporte, cambiar estado, reasignar) tienen test E2E |
| ✅ **RN en BD** | Reglas RN-01 a RN-10 validadas via triggers BD (tests directos SQL) |
| ✅ **Performance** | Benchmarks k6 pasan umbrales (p95 < 300ms API, < 500ms geo) |
| ✅ **Seguridad** | 0 vulnerabilidades críticas/altas en `npm audit` y OWASP ZAP |
| ✅ **Flakiness** | 0 tests inestables en 3 ejecuciones consecutivas |
| ✅ **Documentación** | README tests actualizado, instrucciones ejecución local |
| ✅ **CI Verde** | Pipeline completo pasa en main y PRs |

---

## 7. Herramientas y Stack de Testing

| Capa | Herramienta | Versión | Propósito |
|------|-------------|---------|-----------|
| Unitarias/Integración | Jest | 29.x | Test runner, assertions, mocking |
| HTTP Client Tests | Supertest | 6.x | Test endpoints Express/Fastify |
| BD Test | Testcontainers | 10.x | PostgreSQL+PostGIS efímero en Docker |
| BDD/Gherkin | @cucumber/cucumber | 10.x | Ejecutar .feature files |
| E2E Web | Playwright | 1.40+ | Browser automation multi-navegador |
| Performance | k6 | 0.47+ | Pruebas de carga |
| Seguridad | OWASP ZAP | 2.14+ | Escaneo activo/pasivo |
| Coverage | Istanbul (jest --coverage) | - | Reportes cobertura |
| CI/CD | GitHub Actions | - | Orquestación pipeline |

---

## 8. Riesgos y Mitigaciones en Pruebas

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Tests geoespaciales lentos en CI | Alta | Medio | Usar BD con datos reducidos (100 reportes), índices GIST, separar suite performance |
| Flakiness en E2E (timing, red) | Media | Alto | Retry automático (3x), waits explícitos, test data isolada por test |
| Datos de prueba contaminan entre tests | Media | Alto | Transacciones rollback por test (Jest), TRUNCATE CASCADE entre suites |
| Rate limiting interfiere tests carga | Alta | Medio | Desactivar rate limit en entorno test (feature flag) o usar IPs separadas |
| Triggers BD RN-01/02 difíciles de testar aislados | Media | Medio | Tests directos SQL con pgTAP + tests API que validan respuesta 409/422 |
| Tokens JWT expiración en tests largos | Baja | Medio | Mock `Date.now()` o generar tokens con exp largo en test helpers |

---

## 9. Próximos Pasos

1. **Implementar infraestructura de tests**: Configurar Jest, Testcontainers, Playwright en repo
2. **Escribir tests unitarios**: Validadores, transformadores, helpers de auth, geo
3. **Escribir tests de integración**: Endpoints auth, reportes, catálogos, admin
4. **Implementar steps Gherkin**: Conectar .feature files con code (Cucumber/Playwright)
5. **Ejecutar primera pasada CI**: Validar pipeline, ajustar timeouts, fix flakiness
6. **Benchmark performance**: Línea base k6, definir umbrales reales
7. **Security scan**: OWASP ZAP baseline, corregir hallazgos
8. **Documentar**: `TESTING.md` con instrucciones local, CI, debug

---

*Fin del documento — Plan de Pruebas y Casos de Prueba Gherkin v1.0*