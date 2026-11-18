# Arquitectura de Software — Barrio Conectado

Este documento describe la arquitectura del sistema **Barrio Conectado** usando el modelo **C4** (Context, Containers, Components, Code) y complementa con diagrama de despliegue y decisiones arquitectónicas clave (ADR).

---

## 1. Contexto del Sistema (C4 Nivel 1)

### Diagrama de Contexto

**Fuente:** `./diagramas/arquitectura-contexto.puml`
**Imagen:** `./diagramas/arquitectura-contexto.png`

```plantuml
@startuml arquitectura-contexto
title C4 Nivel 1 — Contexto del Sistema: Barrio Conectado
skinparam shadowing false

Person(vecino, "Vecino", "Ciudadano que reporta problemas y consulta estado")
Person(admin, "Administrador\nMunicipal", "Funcionario que gestiona, prioriza y cierra reportes")
Person(moderador, "Moderador\nde Barrio", "Dirigente vecinal que valida y canaliza alertas")

System(bc, "Barrio Conectado", "Plataforma de gestión comunitaria\nde alertas y reportes vecinales")

System_Ext(maps, "Servicio de Mapas\n/ Geolocalización", "Validación de coordenadas,\nreferencias geográficas (Google Maps / OSM)")
System_Ext(notif, "Servicio de\nNotificaciones", "Envío push/email/SMS\n(Firebase Cloud Messaging, SendGrid, Twilio)")
System_Ext(auth, "Proveedor\nIdentidad", "Autenticación OAuth2/OIDC\n(Google, Microsoft, clave única)")

Rel(vecino, bc, "Reporta problemas\nConsulta sus reportes\nRecibe notificaciones", "HTTPS/REST\nFCM Push")
Rel(admin, bc, "Filtra y asigna reportes\nCambia estados\nReasigna departamentos", "HTTPS/REST")
Rel(moderador, bc, "Valida alertas\nCanaliza a municipio", "HTTPS/REST")

Rel(bc, maps, "Valida ubicación\nObtiene referencia", "HTTPS/REST")
Rel(bc, notif, "Envía notificaciones\npush/email/SMS", "HTTPS/REST")
Rel(bc, auth, "Autentica usuarios\nValida tokens", "HTTPS/OAuth2")

@enduml
```

### Descripción

| Elemento | Responsabilidad |
|----------|-----------------|
| **Vecino** | Actor principal: crea reportes (foto+ubicación), consulta historial, recibe notificaciones push |
| **Administrador Municipal** | Actor gestor: filtra, prioriza, asigna, completa/descarta reportes |
| **Moderador de Barrio** | Actor intermedio: valida alertas vecinales, canaliza a municipio |
| **Barrio Conectado (Sistema)** | Núcleo: API REST, lógica de negocio, persistencia, orquestación de notificaciones |
| **Servicio de Mapas** | Externo: valida coordenadas WGS84, devuelve referencia textual (calle, comuna) |
| **Servicio de Notificaciones** | Externo: FCM (push), SendGrid (email), Twilio (SMS) con reintentos y fallback |
| **Proveedor Identidad** | Externo: OAuth2/OIDC para login social / institucional; emite JWT |

---

## 2. Diagrama de Contenedores (C4 Nivel 2)

### Diagrama de Contenedores

**Fuente:** `./diagramas/arquitectura-contenedores.puml`
**Imagen:** `./diagramas/arquitectura-contenedores.png`

```plantuml
@startuml arquitectura-contenedores
title C4 Nivel 2 — Contenedores: Barrio Conectado
skinparam shadowing false

Person(vecino, "Vecino", "App móvil / PWA")
Person(admin, "Administrador\nMunicipal", "Panel web admin")
Person(moderador, "Moderador\nBarrio", "Panel web moderador")

System_Ext(maps, "Servicio Mapas", "Geolocalización")
System_Ext(notif, "Servicio Notificaciones", "FCM / Email / SMS")
System_Ext(auth, "Auth Provider", "OAuth2 / OIDC")

System_Boundary(c1, "Barrio Conectado") {
    Container(spa_vecino, "App Vecino\n(PWA / Flutter)", "React / Flutter", "Interfaz vecino: reportar, historial, notificaciones")
    Container(spa_admin, "Panel Admin\n(Web)", "React / Vue", "Interfaz admin: filtros, lista, detalle, acciones")
    Container(spa_mod, "Panel Moderador\n(Web)", "React / Vue", "Interfaz moderador: validar, canalizar")
    
    Container(api, "API Gateway\n/ BFF", "Node.js (NestJS/Express)\nTypeScript", "Punto de entrada único: routing, auth, rate-limit, logging")
    
    Container(svc_reportes, "Servicio\nReportes", "Node.js / Python\nFastAPI", "CRUD reportes, priorización, asignación, estados")
    Container(svc_usuarios, "Servicio\nUsuarios", "Node.js / Python\nFastAPI", "Gestión usuarios, roles, perfiles, autenticación JWT")
    Container(svc_notif, "Servicio\nNotificaciones", "Node.js / Python", "Cola notificaciones, reintentos, plantillas, proveedores")
    Container(svc_geo, "Servicio\nGeografía", "Node.js / Python", "Validación ubicación, caché referencias, límites comuna")
    
    ContainerDb(db, "Base de Datos\n(PostgreSQL + PostGIS)", "PostgreSQL 16\nPostGIS 3.4", "Persistencia: usuarios, reportes, categorías, deptos, auditoría, notificaciones")
    ContainerQueue(queue, "Cola de\nMensajes", "Redis / RabbitMQ", "Desacoplamiento: envío notificaciones, tareas asíncronas")
    ContainerCache(cache, "Caché\n(Redis)", "Redis 7", "Sesiones JWT, rate-limit, caché consultas frecuentes")
}

Rel(vecino, spa_vecino, "Usa", "HTTPS")
Rel(admin, spa_admin, "Usa", "HTTPS")
Rel(moderador, spa_mod, "Usa", "HTTPS")

Rel(spa_vecino, api, "Llamadas API", "HTTPS/REST + JWT")
Rel(spa_admin, api, "Llamadas API", "HTTPS/REST + JWT")
Rel(spa_mod, api, "Llamadas API", "HTTPS/REST + JWT")

Rel(api, svc_reportes, "Delega", "gRPC / REST interno")
Rel(api, svc_usuarios, "Delega", "gRPC / REST interno")
Rel(api, svc_notif, "Publica eventos", "Async / Cola")
Rel(api, svc_geo, "Consulta", "gRPC / REST interno")

Rel(svc_reportes, db, "Lee/Escribe", "SQL / Prisma / SQLAlchemy")
Rel(svc_usuarios, db, "Lee/Escribe", "SQL / Prisma / SQLAlchemy")
Rel(svc_notif, db, "Lee/Escribe", "SQL / Prisma / SQLAlchemy")
Rel(svc_geo, db, "Lee (caché)", "SQL / PostGIS")

Rel(svc_notif, queue, "Encola", "AMQP / Redis Streams")
Rel(svc_usuarios, cache, "Sesiones / Rate-limit", "Redis protocol")

Rel(svc_geo, maps, "Valida coords", "HTTPS/REST")
Rel(svc_notif, notif, "Envía push/email/SMS", "HTTPS/REST")
Rel(svc_usuarios, auth, "Valida tokens / Login", "HTTPS/OAuth2")

@enduml
```

### Contenedores y Tecnologías

| Contenedor | Tipo | Tech Stack | Responsabilidad |
|------------|------|------------|-----------------|
| **App Vecino (PWA/Flutter)** | Frontend móvil | React PWA / Flutter / React Native | UI nativa/híbrida: cámara, GPS, push, offline-first |
| **Panel Admin (Web)** | Frontend web | React / Vue + Tailwind | Dashboard, tablas filtradas, formularios de acción |
| **Panel Moderador (Web)** | Frontend web | React / Vue | Vista simplificada: validar, derivar |
| **API Gateway / BFF** | Backend (edge) | Node.js (NestJS/Express) + TypeScript | Terminación TLS, auth JWT, rate-limit, routing, logging, OpenAPI |
| **Servicio Reportes** | Microservicio | Node.js (NestJS) / Python (FastAPI) | Casos de uso CU-01,03,04,06,07,08; lógica de negocio core |
| **Servicio Usuarios** | Microservicio | Node.js / Python | Auth, registro, roles, perfiles, JWT, OAuth2 |
| **Servicio Notificaciones** | Microservicio | Node.js / Python | Plantillas, cola, reintentos, multi-canal (FCM/Email/SMS) |
| **Servicio Geografía** | Microservicio | Node.js / Python | Validación coords, reverse geocoding, límites comuna, caché |
| **PostgreSQL + PostGIS** | Base de datos | PostgreSQL 16 + PostGIS 3.4 | Persistencia transaccional + consultas geoespaciales |
| **Redis** | Caché / Cola | Redis 7 (Streams) | Sesiones, rate-limit, caché, cola mensajes |
| **RabbitMQ (opcional)** | Message Broker | RabbitMQ 3.12 | Cola robusta para notificaciones críticas |

---

## 3. Diagrama de Componentes (C4 Nivel 3) — Servicio Reportes

### Diagrama de Componentes (Servicio Core)

**Fuente:** `./diagramas/arquitectura-componentes-reportes.puml`
**Imagen:** `./diagramas/arquitectura-componentes-reportes.png`

```plantuml
@startuml arquitectura-componentes-reportes
title C4 Nivel 3 — Componentes: Servicio Reportes
skinparam shadowing false

Container_Boundary(svc, "Servicio Reportes") {
    Component(ctrl_reporte, "ReportesController", "NestJS Controller", "Endpoints REST: POST /reportes, GET /reportes, PATCH /reportes/{id}/estado")
    Component(ctrl_filtros, "FiltrosController", "NestJS Controller", "Endpoints: GET /reportes/filtros, GET /reportes/estadisticas")
    
    Component(svc_crear, "CrearReporteService", "Service", "Orquesta: validación, geocoding, prioridad, asignación, persistencia")
    Component(svc_estado, "CambiarEstadoService", "Service", "Valida transiciones EST-01, registra CambioEstado, dispara notificación")
    Component(svc_prioridad, "PrioridadService", "Service", "Calcula prioridad automática (categoría + urgencia + heurísticas)")
    Component(svc_asignacion, "AsignacionService", "Service", "Asigna/reasigna a departamento, gestiona confirmación admin")
    Component(svc_consulta, "ConsultaReportesService", "Service", "Filtros combinados, paginación, ordenamiento, exportación")
    
    Component(repo_reporte, "ReporteRepository", "Repository", "Acceso BD: CRUD, queries geoespaciales (PostGIS), índices")
    Component(repo_categoria, "CategoriaRepository", "Repository", "Catálogo categorías, prioridad base, departamento")
    Component(repo_depto, "DepartamentoRepository", "Repository", "Catálogo departamentos, capacidades")
    Component(repo_cambio, "CambioEstadoRepository", "Repository", "Audit trail inmutable de transiciones")
    Component(repo_asign, "AsignacionRepository", "Repository", "Histórico asignaciones y reasignaciones")
    
    Component(event_pub, "EventPublisher", "Publisher", "Publica eventos dominio: ReporteCreado, EstadoCambiado, Reasignado")
}

ContainerDb(db, "PostgreSQL + PostGIS", "Database", "Tablas: reportes, categorias, departamentos, cambios_estado, asignaciones")
ContainerQueue(queue, "Redis Streams / RabbitMQ", "Queue", "Eventos: reporte.creado, reporte.estado_cambiado, reporte.reasignado")
ContainerExt(geo, "Servicio Geografía", "External", "Validación coords, reverse geocoding")

Rel(ctrl_reporte, svc_crear, "Llama")
Rel(ctrl_reporte, svc_estado, "Llama")
Rel(ctrl_filtros, svc_consulta, "Llama")

Rel(svc_crear, repo_reporte, "Persiste")
Rel(svc_crear, svc_prioridad, "Calcula prioridad")
Rel(svc_crear, svc_asignacion, "Asigna depto inicial")
Rel(svc_crear, geo, "Valida ubicación")
Rel(svc_crear, event_pub, "Publica ReporteCreado")

Rel(svc_estado, repo_reporte, "Actualiza estado")
Rel(svc_estado, repo_cambio, "Registra auditoría")
Rel(svc_estado, event_pub, "Publica EstadoCambiado")

Rel(svc_prioridad, repo_categoria, "Lee prioridad base")
Rel(svc_asignacion, repo_depto, "Lee departamento")
Rel(svc_asignacion, repo_asign, "Registra asignación")
Rel(svc_asignacion, event_pub, "Publica Reasignado")

Rel(svc_consulta, repo_reporte, "Consulta con filtros")

Rel(repo_reporte, db, "SQL / PostGIS")
Rel(repo_categoria, db, "SQL")
Rel(repo_depto, db, "SQL")
Rel(repo_cambio, db, "SQL")
Rel(repo_asign, db, "SQL")

Rel(event_pub, queue, "Push evento")

@enduml
```

---

## 4. Diagrama de Despliegue

### Diagrama de Despliegue (Producción)

**Fuente:** `./diagramas/arquitectura-despliegue.puml`
**Imagen:** `./diagramas/arquitectura-despliegue.png`

```plantuml
@startuml arquitectura-despliegue
title Despliegue — Barrio Conectado (Producción)
skinparam shadowing false

Node("Cloud Provider\n(AWS / GCP / Azure / On-prem K8s)") {
    Node("Kubernetes Cluster\n(Managed EKS/GKE/AKS)") {
        Node("Namespace: barrio-conectado-prod") {
            Component("Ingress Controller\n(NGINX / Traefik)", "Ingress", "TLS termination, rate-limit, WAF")
            
            Component("api-gateway\n(Deployment x3)", "Pod", "NestJS/Express\nCPU: 500m, Mem: 512Mi\nHPA: 3-10 replicas")
            Component("svc-reportes\n(Deployment x3)", "Pod", "NestJS/FastAPI\nCPU: 1000m, Mem: 1Gi\nHPA: 3-15 replicas")
            Component("svc-usuarios\n(Deployment x2)", "Pod", "Node/Python\nCPU: 500m, Mem: 512Mi\nHPA: 2-8 replicas")
            Component("svc-notificaciones\n(Deployment x2)", "Pod", "Node/Python\nCPU: 500m, Mem: 512Mi\nHPA: 2-10 replicas")
            Component("svc-geografia\n(Deployment x2)", "Pod", "Node/Python\nCPU: 500m, Mem: 512Mi\nHPA: 2-6 replicas")
            
            Component("redis\n(StatefulSet)", "Pod", "Redis 7 Cluster\n3 masters + 3 replicas\nPersistencia AOF")
            Component("rabbitmq\n(StatefulSet)", "Pod", "RabbitMQ 3.12\nQuorum queues\nHA policy")
        }
    }
    
    Node("Managed Services") {
        Database("Cloud SQL\nPostgreSQL + PostGIS", "DB", "PostgreSQL 16\nPostGIS 3.4\nHA: Regional, Auto-failover\nBackups: Diarios + PITR") 
        Component("Cloud Storage\n(S3 / GCS / Blob)", "Storage", "Fotos reportes\nVersionado, Lifecycle, CDN")
        Component("Secret Manager", "Secrets", "JWT keys, DB pwd, API keys\nRotación automática")
        Component("Cert Manager\n(Let's Encrypt)", "Certs", "TLS 1.3 automático\nRenovación 30 días")
    }
    
    Node("Observabilidad") {
        Component("Prometheus +\nGrafana", "Monitoring", "Métricas: RED, USE, SLO\nAlertas: PagerDuty/Slack")
        Component("Loki +\nGrafana", "Logs", "Logs centralizados\nRetención 30d / 1a")
        Component("Tempo / Jaeger", "Tracing", "Distributed tracing\nMuestreo 10%")
    }
}

Node("CDN\n(CloudFront / Cloud CDN)") {
    Component("Static Assets\n+ Foto Proxy", "CDN", "Cache-Control, Imagen optimizada\nWebP/AVIF auto")
}

Node("Externos") {
    Component("Firebase Cloud\nMessaging", "FCM", "Push notifications\nAndroid/iOS/Web")
    Component("SendGrid /\nMailgun", "Email", "Email transaccional\nTemplates, Tracking")
    Component("Twilio /\nVonage", "SMS", "SMS fallback\nAlta prioridad")
    Component("Google Maps /\nOpenStreetMap", "Maps API", "Geocoding, Places\nStatic Maps")
    Component("Auth Provider\n(Google / Microsoft\n/ ClaveÚnica)", "OIDC", "OAuth2/OIDC\nJWKS validation")
}

' Relaciones
Rel("Ingress", "api-gateway", "Route /api/*", "HTTPS/mTLS")
Rel("api-gateway", "svc-reportes", "gRPC/REST", "Internal mTLS")
Rel("api-gateway", "svc-usuarios", "gRPC/REST", "Internal mTLS")
Rel("api-gateway", "svc-notificaciones", "Async", "Redis Streams")
Rel("api-gateway", "svc-geografia", "gRPC/REST", "Internal mTLS")

Rel("svc-reportes", "Cloud SQL", "SQL/PostGIS", "Pool: PgBouncer")
Rel("svc-usuarios", "Cloud SQL", "SQL", "Pool: PgBouncer")
Rel("svc-notificaciones", "Cloud SQL", "SQL", "Pool: PgBouncer")
Rel("svc-geografia", "Cloud SQL", "SQL (Read)", "Pool: PgBouncer")

Rel("svc-reportes", "redis", "Cache/Sessions", "Redis Protocol")
Rel("svc-usuarios", "redis", "Sessions/Rate-limit", "Redis Protocol")
Rel("svc-notificaciones", "rabbitmq", "Queue", "AMQP 1.0")

Rel("svc-notificaciones", "FCM", "Push", "HTTPS/FCMv1")
Rel("svc-notificaciones", "Email", "Email", "HTTPS/SMTP API")
Rel("svc-notificaciones", "SMS", "SMS", "HTTPS/REST")
Rel("svc-geografia", "Maps API", "Geocoding", "HTTPS/REST")
Rel("svc-usuarios", "OIDC", "Auth", "HTTPS/OIDC")

Rel("App Vecino", "CDN", "Assets/Fotos", "HTTPS")
Rel("App Vecino", "Ingress", "API", "HTTPS/WSS")
Rel("Panel Admin", "Ingress", "API", "HTTPS")

@enduml
```

### Infraestructura como Código (Resumen)

| Recurso | Herramienta | Detalle |
|---------|-------------|---------|
| **Kubernetes** | Terraform + Helm | EKS/GKE/AKS module, Helm charts por microservicio |
| **Base de Datos** | Terraform | Cloud SQL module (HA, PostGIS, backups, PITR) |
| **Redis / RabbitMQ** | Terraform + Helm | Bitnami charts, StatefulSets, persistencia |
| **Secretos** | External Secrets Operator | Sincroniza desde Secret Manager / Vault a K8s secrets |
| **Certificados** | cert-manager | Let's Encrypt (staging → prod), DNS challenge |
| **Observabilidad** | kube-prometheus-stack + Grafana | Dashboards SLO, alertas multi-canal |

---

## 5. Decisiones Arquitectónicas (ADR)

### ADR-001: Arquitectura Modular Monolítica Inicial → Microservicios

| Estado | Aceptada |
|--------|----------|
| **Contexto** | Equipo pequeño (4 devs), dominio acotado, time-to-market crítico |
| **Decisión** | Iniciar con **modular monolith** (NestJS modules) desplegado como unidad; extraer microservicios cuando: (a) escalamiento independiente necesario, (b) equipos separados, (c) stack tecnológico divergente |
| **Consecuencias** | + Simplicidad operativa inicial, transacciones ACID fáciles, refactor seguro<br>- Acoplamiento temporal, escalado todo-o-nada |

### ADR-002: Base de Datos Compartida vs. Por Servicio

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **Base de datos compartida** (PostgreSQL único) con esquemas lógicos por dominio (`reportes`, `usuarios`, `notificaciones`, `geografia`) |
| **Justificación** | PostGIS requiere extensión compartida; consultas transversales frecuentes (reportes + usuarios + categoría); equipo pequeño |
| **Migración futura** | Schemas → bases separadas + CDC (Debezium) para sincronía |

### ADR-003: Comunicación Síncrona vs. Asíncrona

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **Híbrido**: Síncrona (gRPC/REST) para queries y comandos con respuesta inmediata; Asíncrona (Redis Streams / RabbitMQ) para eventos de dominio y notificaciones |
| **Patrón** | *Transactional Outbox* para garantizar consistencia evento-BD |

### ADR-004: Autenticación y Autorización

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **JWT stateless** (RS256) emitido por Auth Service; validación en API Gateway (JWKS cache); roles en `claim` (`vecino`, `admin`, `moderador`); OAuth2/OIDC para login social/institucional |
| **Refresh** | Refresh tokens rotativos en Redis (TTL 30d), access token TTL 15min |

### ADR-005: Almacenamiento de Fotos

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **Object Storage (S3/GCS)** + CDN; nunca en BD ni filesystem local; URLs firmadas (pre-signed) para subida/descarga; optimización automática (WebP, resize) en edge |
| **Seguridad** | Bucket privado, ACL por usuario, escaneo antivirus (ClamAV en lambda) |

### ADR-006: Geolocalización y PostGIS

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **PostGIS nativo** para consultas espaciales (ST_DWithin, ST_Contains, ST_Intersects); índices GiST; caché de referencias en Redis; servicio geografía valida límites comuna |
| **Precisión** | WGS84 (SRID 4326), `GEOGRAPHY` type para metros reales |

### ADR-007: Notificaciones Multi-canal con Fallback

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **Push (FCM) → Email → SMS** en cascada; cola con prioridad; reintentos exponenciales (1m, 5m, 15m); idempotencia por `notification_id`; estado `Pendiente/Enviada/Fallida` en BD |
| **SLA** | RP-11: ≤ 5 min (push), ≤ 15 min (email), ≤ 30 min (SMS) |

### ADR-008: Observabilidad y SLO

| Estado | Aceptada |
|--------|----------|
| **Decisión** | **Four Golden Signals** (Latency, Traffic, Errors, Saturation) + **SLO**: API 99.5% < 500ms p95, Disponibilidad 99.5%, Notificaciones 99% entregadas en 5min |
| **Herramientas** | Prometheus + Grafana (métricas), Loki (logs), Tempo (traces), Alertmanager (rutas) |

---

## 6. Modelos de Datos Físicos (Esquema BD)

> Ver documento dedicado: **`14-base-datos.md`** (MER, DDL, migraciones, índices PostGIS)

Resumen de tablas principales:

| Tabla | Propósito | Índices Clave |
|-------|-----------|---------------|
| `usuarios` | Usuarios + roles | PK(id), UK(email), idx(rol) |
| `reportes` | Entidad core | PK(id), UK(numero_seguimiento), idx(estado, prioridad, categoria_id, created_at), **GiST(ubicacion)** |
| `categorias` | Catálogo | PK(id), UK(nombre) |
| `departamentos` | Catálogo | PK(id), UK(nombre) |
| `cambios_estado` | Auditoría inmutable | PK(id), idx(reporte_id, timestamp) |
| `asignaciones` | Trazabilidad asignación | PK(id), idx(reporte_id), idx(usuario_id, confirmada) |
| `notificaciones` | Cola envío | PK(id), idx(destinatario_id, estado), idx(estado, reintentos) |
| `fotografias` | Evidencias | PK(id), idx(reporte_id) |

---

## 7. Contrato API (OpenAPI 3.0)

> Ver documento dedicado: **`15-api-openapi.md`** (spec completa YAML/JSON)

Endpoints principales:

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `POST` | `/api/v1/auth/login` | Login (OIDC / credentials) | No | — |
| `POST` | `/api/v1/auth/refresh` | Refresh access token | No | — |
| `POST` | `/api/v1/reportes` | Crear reporte (foto + geo) | JWT | `vecino` |
| `GET` | `/api/v1/reportes/mis` | Listar mis reportes | JWT | `vecino` |
| `GET` | `/api/v1/reportes/{id}` | Detalle reporte + historial | JWT | `vecino` (own) / `admin` |
| `GET` | `/api/v1/admin/reportes` | Filtrar reportes (admin) | JWT | `admin` |
| `PATCH` | `/api/v1/admin/reportes/{id}/estado` | Cambiar estado + nota | JWT | `admin` |
| `PATCH` | `/api/v1/admin/reportes/{id}/prioridad` | Ajustar prioridad | JWT | `admin` |
| `PATCH` | `/api/v1/admin/reportes/{id}/reasignar` | Reasignar departamento | JWT | `admin` |
| `GET` | `/api/v1/admin/estadisticas` | Dashboard KPIs | JWT | `admin` |

---

## 8. Seguridad (Resumen)

| Capa | Medida |
|------|--------|
| **Red** | VPC privada, Security Groups restrictivos, Ingress solo 443, mTLS interno |
| **Transporte** | TLS 1.3 obligatorio, HSTS, Certificate Transparency monitoring |
| **Aplicación** | Helmet/CORS/CSRF, Rate-limit (100 req/min/user), Input validation (Zod/Pydantic), Parameterized queries |
| **Auth** | JWT RS256, JWKS rotation, Short-lived access (15m), Refresh rotation, MFA opcional admin |
| **Datos** | Cifrado en reposo (AES-256), Cifrado en tránsito, PII minimizada, Hash Argon2id |
| **Secrets** | External Secrets Operator, Rotación automática, Sin secretos en código/imágenes |
| **Auditoría** | Log estructurado (JSON), Correlation ID, Immutable audit trail (`cambios_estado`) |

---

## 9. Rendimiento y Escalabilidad

| Componente | Estrategia |
|------------|------------|
| **API Gateway** | Horizontal scaling (HPA CPU>70%), Connection pooling (PgBouncer) |
| **Servicio Reportes** | Read replicas para consultas, Particionado por fecha (futuro), Índices compuestos + GiST |
| **Notificaciones** | Worker pool consumidor (RabbitMQ), Batch sending FCM (1000/req), Prioridad alta cola separada |
| **Caché** | Redis Cluster: Sesiones (TTL 30m), Rate-limit (sliding window), Catálogos (categorías, deptos) |
| **CDN** | Cache-Control: `public, max-age=31536000, immutable` para assets; `private, max-age=3600` para fotos |
| **BD** | Connection pooling (PgBouncer 100 conn), Read replicas, Autovacuum tuned, `work_mem` 64MB |

---

## 10. Archivos de Arquitectura en el Repositorio

| Archivo | Descripción |
|---------|-------------|
| `13-arquitectura.md` | Este documento |
| `14-base-datos.md` | MER, DDL PostgreSQL+PostGIS, migraciones, seeds |
| `15-api-openapi.md` | Spec OpenAPI 3.0 completa (YAML) |
| `16-plan-pruebas.md` | Plan de pruebas, casos de prueba, matriz trazabilidad |
| `17-wireframes.md` | Wireframes/Mockups (Mermaid/HTML) flujos principales |
| `18-plan-implementacion.md` | Product Backlog, Sprint 1-2, DoD, riesgos |
| `diagramas/arquitectura-contexto.puml` | C4 Nivel 1 |
| `diagramas/arquitectura-contenedores.puml` | C4 Nivel 2 |
| `diagramas/arquitectura-componentes-reportes.puml` | C4 Nivel 3 (Servicio Reportes) |
| `diagramas/arquitectura-despliegue.puml` | Despliegue K8s + Cloud |
| `diagramas/mer.puml` | Modelo Entidad-Relación (PlantUML) |

---

> **Próximo paso:** Generar `14-base-datos.md` con MER detallado, DDL completo y migraciones.