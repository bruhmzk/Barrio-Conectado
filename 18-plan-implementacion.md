# 18. Plan de Implementación — Product Backlog, Sprints y Definition of Done

**Versión:** 1.0  
**Fecha:** 2026-08-15  
**Entrega:** 3 — Implementación  
**Proyecto:** Barrio Conectado

---

## 1. Visión del Producto

> **Barrio Conectado** es una plataforma digital que conecta a vecinos con la administración municipal para reportar, dar seguimiento y resolver problemas en la vía pública (luminarias, microbasurales, baches, señalética, veredas, parques, drenaje), mejorando la calidad de vida en los barrios y la eficiencia de la gestión municipal.

**Objetivo del MVP (Entrega 3):** Sistema funcional end-to-end que permita a vecinos crear reportes con foto y geolocalización, y a administradores gestionar, priorizar, asignar y dar seguimiento completo, con dashboard de métricas y consultas geoespaciales.

---

## 2. Arquitectura Técnica (Resumen)

| Capa | Tecnología | Justificación |
|------|------------|---------------|
| **API Backend** | Node.js 20 + Fastify / TypeScript | Performance, typing, ecosystem |
| **Base de Datos** | PostgreSQL 16 + PostGIS 3.4 | Geoespacial nativo, ACID, madurez |
| **ORM** | Prisma 5 + Raw SQL (triggers, RLS) | Type-safety + control SQL avanzado |
| **Auth** | JWT RS256 (jose) + Argon2id + OAuth2 (Google, Microsoft, ClaveÚnica) | Estándar, seguro, sin vendor lock-in |
| **Frontend** | React 18 + TypeScript + Vite + Tailwind CSS | Moderno, performante, design system |
| **Mapas** | MapLibre GL JS + MapTiler / OSM | Open source, vector tiles, offline-capable |
| **Estado** | TanStack Query (server) + Zustand (client) | Cache inteligente, minimal boilerplate |
| **Testing** | Jest + Testcontainers + Playwright + k6 | Pirámide completa |
| **CI/CD** | GitHub Actions + Docker + Kubernetes (kind/EKS) | GitOps, escalable |
| **Observabilidad** | OpenTelemetry + Prometheus + Grafana + Loki | Full stack monitoring |

---

## 3. Product Backlog — Épicas e Historias

### 3.1 Épicas (Nivel Alto)

| Épica ID | Nombre | Descripción | Valor de Negocio | Prioridad |
|----------|--------|-------------|------------------|-----------|
| **EPIC-AUTH** | Autenticación y Autorización | Login, registro, OAuth2, JWT, RBAC, rate limiting | Base de seguridad | 🔴 Crítica |
| **EPIC-REP-VEC** | Reportes Vecino | Crear reporte (wizard), listar mis reportes, ver detalle, historial, mapa proximidad | Core usuario final | 🔴 Crítica |
| **EPIC-REP-ADM** | Gestión Admin Reportes | Filtrar/listar, cambiar estado, ajustar prioridad, reasignar, confirmar asignación | Core operación municipal | 🔴 Crítica |
| **EPIC-GEO** | Geoespacial y Mapas | Consultas proximidad (vecino), mapa admin (bbox), clustering, heatmap | Diferenciador técnico | 🟠 Alta |
| **EPIC-CAT** | Catálogos y Configuración | CRUD Categorías, Departamentos, relaciones, prioridad base | Configuración flexible | 🟡 Media |
| **EPIC-DASH** | Dashboard y Exportación | KPIs tiempo real, gráficos tendencias, export CSV/Excel | Toma de decisiones | 🟠 Alta |
| **EPIC-NOTIF** | Notificaciones | Push, Email, In-app, cola async, reintentos | Engagement y transparencia | 🟡 Media |
| **EPIC-SEC** | Seguridad Transversal | Rate limiting, auditoría login, headers, CORS, sanitización | Compliance y confianza | 🔴 Crítica |
| **EPIC-DEVOPS** | Infraestructura y CI/CD | Docker, K8s, migraciones, seeding, pipelines, observabilidad | Entrega continua | 🟠 Alta |

---

### 3.2 Historias de Usuario Detalladas (Product Backlog)

> **Formato:** `PB-<EPIC>-<NN>` | **Story Points:** Fibonacci (1,2,3,5,8,13,21) | **Sprint Target:** S1, S2, S3...

| ID | Título | Descripción (Como... Quiero... Para...) | SP | Épica | Sprint | Dependencias |
|----|--------|------------------------------------------|----|-------|--------|--------------|
| **PB-AUTH-01** | Login email/password | Como usuario quiero iniciar sesión con email y password para acceder a mi cuenta | 5 | AUTH | S1 | DB, JWT keys |
| **PB-AUTH-02** | Registro vecino | Como vecino quiero registrarme para poder reportar problemas | 5 | AUTH | S1 | PB-AUTH-01 |
| **PB-AUTH-03** | OAuth2 (Google, Microsoft, ClaveÚnica) | Como usuario quiero entrar con mi cuenta institucional para no crear nueva contraseña | 8 | AUTH | S2 | Proveedores configurados |
| **PB-AUTH-04** | JWT Access + Refresh (rotación) | Como sistema quiero tokens seguros (RS256, 15min/30d, rotación) para auth stateless | 5 | AUTH | S1 | PB-AUTH-01 |
| **PB-AUTH-05** | Logout / Logout all | Como usuario quiero cerrar sesión (actual o todas) para seguridad | 3 | AUTH | S1 | PB-AUTH-04 |
| **PB-AUTH-06** | Rate limiting auth | Como sistema quiero limitar intentos login para prevenir fuerza bruta | 3 | AUTH | S1 | Redis/DB |
| **PB-AUTH-07** | RBAC middleware | Como API quiero validar rol (vecino/admin/moderador) en cada request | 3 | AUTH | S1 | PB-AUTH-04 |
| **PB-AUTH-08** | Auditoría login | Como admin quiero ver intentos login (éxito/fallo, IP, UA) para seguridad | 3 | AUTH | S2 | PB-AUTH-01 |
| **PB-AUTH-09** | Perfil usuario (GET/PATCH/DELETE /usuarios/me) | Como usuario quiero ver/editar mi perfil y eliminar mi cuenta | 3 | AUTH | S2 | PB-AUTH-01 |
| **PB-AUTH-10** | Admin: Listar/Ver usuarios | Como admin quiero gestionar usuarios (listar, ver, activar/desactivar) | 3 | AUTH | S2 | PB-AUTH-07 |

| **PB-REP-01** | Wizard crear reporte (4 pasos) | Como vecino quiero crear reporte guiado (categoría → ubicación+foto → descripción → confirmar) | 8 | REP-VEC | S1 | Categorías, Auth |
| **PB-REP-02** | Validaciones crear reporte | Como sistema quiero validar: foto obligatoria (JPEG/PNG/WebP/HEIC ≤10MB), ubicación Chile, descripción ≥10 chars, categoría activa | 5 | REP-VEC | S1 | PB-REP-01 |
| **PB-REP-03** | Auto-asignación prioridad + depto | Como sistema quiero setear prioridad base de categoría y departamento principal al crear reporte | 3 | REP-VEC | S1 | Triggers BD |
| **PB-REP-04** | Detección duplicados (RN-06) | Como sistema quiero detectar reporte similar (mismo vecino, ~10m, misma cat, 30d) y sugerir anexar | 5 | REP-VEC | S2 | PostGIS, Triggers |
| **PB-REP-05** | Listar mis reportes (paginado, filtros) | Como vecino quiero ver mis reportes con paginación y filtro por estado | 5 | REP-VEC | S1 | PB-REP-01 |
| **PB-REP-06** | Detalle reporte vecino | Como vecino quiero ver detalle completo: fotos, descripción, ubicación, historial estados | 5 | REP-VEC | S1 | PB-REP-01 |
| **PB-REP-07** | Historial estados | Como vecino quiero ver timeline de cambios de estado con nota, usuario, fecha | 3 | REP-VEC | S1 | Trigger cambios_estado |
| **PB-REP-08** | Mapa proximidad vecino | Como vecino quiero ver reportes cercanos en mapa (radio configurable, clustering) | 8 | GEO | S2 | PostGIS, MapLibre |
| **PB-REP-09** | Notificaciones push/email vecino | Como vecino quiero recibir notificación al crear reporte y en cada cambio de estado | 5 | NOTIF | S2 | Cola notificaciones |

| **PB-ADM-01** | Panel admin: Filtrar/listar reportes | Como admin quiero filtrar reportes por múltiples criterios (estado, prioridad, cat, depto, fecha, búsqueda texto) con paginación y ordenamiento | 8 | REP-ADM | S1 | Auth, Índices BD |
| **PB-ADM-02** | Detalle reporte admin | Como admin quiero ver info completa: vecino, depto, admin asignado, confirmación, historial, acciones | 5 | REP-ADM | S1 | PB-ADM-01 |
| **PB-ADM-03** | Cambiar estado (con validaciones RN-01,02,03) | Como admin quiero cambiar estado con nota obligatoria según transición (Ingresado→EnRevisión→Completado/Descartado) | 8 | REP-ADM | S1 | Triggers BD |
| **PB-ADM-04** | Ajustar prioridad | Como admin quiero subir/bajar prioridad con nota de justificación | 3 | REP-ADM | S1 | PB-ADM-02 |
| **PB-ADM-05** | Reasignar departamento (+ admin opcional) | Como admin quiero reasignar a otro depto y opcionalmente a admin específico, limpiando confirmación | 5 | REP-ADM | S2 | PB-ADM-02 |
| **PB-ADM-06** | Confirmar asignación (RN-11) | Como admin asignado quiero confirmar que me hago cargo antes de actuar | 3 | REP-ADM | S2 | PB-ADM-05 |
| **PB-ADM-07** | Notificaciones admin (asignación, prioridad) | Como admin quiero recibir push cuando me asignan reporte o cambia prioridad | 3 | NOTIF | S2 | PB-ADM-05 |
| **PB-ADM-08** | Admin: CRUD Categorías | Como admin quiero gestionar categorías (crear, editar, desactivar, icono, color, prioridad, depto principal/secundario) | 5 | CAT | S2 | PB-AUTH-10 |
| **PB-ADM-09** | Admin: CRUD Departamentos | Como admin quiero gestionar departamentos (nombre, descripción, email, teléfono, activo) | 3 | CAT | S2 | PB-AUTH-10 |
| **PB-ADM-10** | Admin: CRUD Usuarios | Como admin quiero listar, ver, activar/desactivar usuarios, cambiar rol | 3 | AUTH | S2 | PB-AUTH-10 |

| **PB-GEO-01** | Endpoint /reportes/cercanos (GeoJSON) | Como app quiero endpoint GeoJSON FeatureCollection para reportes en radio (ST_DWithin, índice GIST) | 5 | GEO | S1 | PostGIS, Índices |
| **PB-GEO-02** | Endpoint /reportes/mapa (BBox + filtros) | Como admin quiero GeoJSON en bounding box para mapa admin con filtro estado | 5 | GEO | S1 | PostGIS, Índices |
| **PB-GEO-03** | Mapa vecino (Mobile) | Como vecino quiero mapa full-screen con mi ubicación, clusters, popups, bottom sheet detalle | 8 | GEO | S2 | PB-GEO-01, MapLibre |
| **PB-GEO-04** | Mapa admin (Desktop) | Como admin quiero mapa split-view con lista, filtros sincronizados, heatmap toggle | 8 | GEO | S2 | PB-GEO-02, MapLibre |
| **PB-GEO-05** | Performance geo (<500ms p95) | Como sistema quiero consultas geo optimizadas (índices parciales, clustering DBSCAN) | 5 | GEO | S2 | PB-GEO-01,02 |

| **PB-DASH-01** | KPIs Dashboard (/admin/reportes/estadisticas) | Como admin quiero ver: contadores por estado, prioridad, últimas 24h/7d/30d, horas prom. resolución | 5 | DASH | S1 | Vistas materializadas / SQL |
| **PB-DASH-02** | Gráficos tendencias (30 días) | Como admin quiero gráficos: ingresados vs completados, por categoría, por estado+prioridad | 8 | DASH | S2 | Chart.js/Recharts, PB-DASH-01 |
| **PB-DASH-03** | Tabla por departamento | Como admin quiero tabla resumen por depto: ingresados, en rev, completados, tiempo prom. | 3 | DASH | S2 | PB-DASH-01 |
| **PB-DASH-04** | Exportar CSV/Excel | Como admin quiero exportar reportes filtrados a CSV y Excel | 5 | DASH | S2 | PB-ADM-01 |

| **PB-NOTIF-01** | Cola notificaciones (BD + Worker) | Como sistema quiero tabla notificaciones con estados (Pendiente/Enviado/Fallido), reintentos, prioridad por tipo | 5 | NOTIF | S1 | BD, Triggers |
| **PB-NOTIF-02** | Worker procesamiento (Push, Email) | Como sistema quiero worker que procese cola: FCM/APNs push, SMTP email, marque enviado/fallido, backoff exponencial | 8 | NOTIF | S2 | PB-NOTIF-01, FCM/SMTP |
| **PB-NOTIF-03** | Plantillas notificación | Como sistema quiero templates: reporte_creado, estado_cambiado, prioridad_cambiada, asignacion_nueva, reporte_completado, reporte_descartado | 3 | NOTIF | S2 | PB-NOTIF-01 |
| **PB-NOTIF-04** | Centro notificaciones in-app | Como usuario quiero ver historial notificaciones en app (lista, leer, eliminar) | 5 | NOTIF | S3 | PB-NOTIF-01 |

| **PB-SEC-01** | Headers seguridad (Helmet) | Como API quiero headers: CSP, HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy | 2 | SEC | S1 | Fastify helmet |
| **PB-SEC-02** | CORS configurado | Como API quiero CORS restrictivo (origen frontend, credentials) | 2 | SEC | S1 | Fastify cors |
| **PB-SEC-03** | Sanitización inputs (XSS) | Como API quiero sanitizar/validar todos los inputs (descripción, referencia, búsqueda) | 3 | SEC | S1 | Zod/Joi schemas |
| **PB-SEC-04** | Rate limiting API (usuario/IP) | Como API quiero rate limit: 100 req/min user, 1000 req/min IP, burst 20 | 3 | SEC | S1 | Redis/DB |
| **PB-SEC-05** | Validación estricta GeoJSON | Como API quiero validar GeoJSON Point (coords [-180,180]x[-90,90], Chile continental) | 3 | SEC | S1 | Zod + PostGIS CHECK |
| **PB-SEC-06** | Secrets management | Como DevOps quiero gestionar secrets (JWT keys, DB password, OAuth secrets) via Vault/SealedSecrets | 3 | SEC | S2 | Kubernetes |

| **PB-DEV-01** | Dockerfile multi-stage (API + Frontend) | Como DevOps quiero imágenes optimizadas (node:20-alpine, distroless) | 3 | DEVOPS | S1 | - |
| **PB-DEV-02** | Docker Compose local (API, DB, Redis, Worker) | Como dev quiero `docker compose up` para entorno completo local | 3 | DEVOPS | S1 | - |
| **PB-DEV-03** | Migraciones Flyway/Prisma Migrate | Como dev quiero migraciones versionadas (V001-V007) aplicables en orden | 3 | DEVOPS | S1 | DB Schema |
| **PB-DEV-04** | Seed data script | Como dev quiero `npm run db:seed` para datos de prueba (categorías, deptos, admin, vecino) | 2 | DEVOPS | S1 | PB-DEV-03 |
| **PB-DEV-05** | GitHub Actions CI (lint, test, build, coverage) | Como equipo quiero pipeline que falle si lint/test/coverage no pasan | 5 | DEVOPS | S1 | - |
| **PB-DEV-06** | GitHub Actions CD (staging → production) | Como equipo quiero deploy automático a staging en merge main, manual a prod | 5 | DEVOPS | S2 | PB-DEV-05 |
| **PB-DEV-07** | Kubernetes manifests (Deployment, Service, Ingress, ConfigMap, Secret) | Como DevOps quiero manifests K8s listos para EKS/kind | 5 | DEVOPS | S2 | PB-DEV-01 |
| **PB-DEV-08** | Observabilidad (OTel, Prometheus, Grafana, Loki) | Como equipo quiero métricas, logs, traces, dashboards, alertas | 8 | DEVOPS | S3 | PB-DEV-07 |
| **PB-DEV-09** | Performance testing (k6) | Como equipo quiero script k6 para carga 200 RPS, umbrales p95 < 300ms | 5 | DEVOPS | S2 | PB-DEV-05 |

---

## 4. Plan de Sprints (2 Sprints de 2 semanas = 4 semanas)

### 4.1 Sprint 1 — "Core MVP: Auth + Reportes Básicos + Admin Lista + Geo Básico"
**Objetivo:** Vecino puede registrarse, login, crear reporte completo (wizard), ver sus reportes. Admin puede listar/filtrar reportes, ver detalle, cambiar estado. APIs geo básicas funcionando. CI/CD corriendo.

| Historia | SP | Responsable | Estado | Notas |
|----------|----|-------------|--------|-------|
| PB-AUTH-01 Login | 5 | Backend | ✅ Done | JWT RS256, Argon2id |
| PB-AUTH-02 Registro | 5 | Backend | ✅ Done | Email único, validación |
| PB-AUTH-04 JWT Refresh | 5 | Backend | ✅ Done | Rotación, revocación |
| PB-AUTH-06 Rate Limit Auth | 3 | Backend | ✅ Done | 5 intentos/15min |
| PB-AUTH-07 RBAC Middleware | 3 | Backend | ✅ Done | Roles: vecino/admin |
| PB-REP-01 Wizard Crear Reporte | 8 | Fullstack | 🔄 In Progress | 4 pasos, validaciones |
| PB-REP-02 Validaciones Reporte | 5 | Backend | 🔄 In Progress | Foto, geo, desc, cat |
| PB-REP-03 Auto-asignación | 3 | Backend | ✅ Done | Triggers BD |
| PB-REP-05 Listar Mis Reportes | 5 | Fullstack | ⏳ Pending | Paginación, filtros |
| PB-REP-06 Detalle Reporte Vecino | 5 | Frontend | ⏳ Pending | Fotos, historial, mapa |
| PB-REP-07 Historial Estados | 3 | Backend | ✅ Done | Trigger cambios_estado |
| PB-ADM-01 Panel Admin Filtrar | 8 | Fullstack | 🔄 In Progress | Multi-filtro, paginación |
| PB-ADM-02 Detalle Admin | 5 | Frontend | ⏳ Pending | Info completa + acciones |
| PB-ADM-03 Cambiar Estado | 8 | Fullstack | 🔄 In Progress | Validaciones RN-01,02,03 |
| PB-ADM-04 Ajustar Prioridad | 3 | Backend | ⏳ Pending | Nota justificación |
| PB-GEO-01 /reportes/cercanos | 5 | Backend | ✅ Done | GeoJSON, ST_DWithin |
| PB-GEO-02 /reportes/mapa | 5 | Backend | ✅ Done | BBox, filtros |
| PB-DASH-01 KPIs Dashboard | 5 | Backend | ⏳ Pending | SQL agregaciones |
| PB-NOTIF-01 Cola Notificaciones | 5 | Backend | 🔄 In Progress | Tabla + triggers |
| PB-SEC-01 Helmet Headers | 2 | Backend | ✅ Done | CSP, HSTS, etc. |
| PB-SEC-02 CORS | 2 | Backend | ✅ Done | Origen frontend |
| PB-SEC-03 Sanitización | 3 | Backend | 🔄 In Progress | Zod schemas |
| PB-SEC-04 Rate Limit API | 3 | Backend | ✅ Done | 100/u, 1000/IP |
| PB-SEC-05 Validación GeoJSON | 3 | Backend | ✅ Done | Zod + CHECK BD |
| PB-DEV-01 Dockerfile | 3 | DevOps | ✅ Done | Multi-stage |
| PB-DEV-02 Docker Compose | 3 | DevOps | ✅ Done | API, PG, Redis, Worker |
| PB-DEV-03 Migraciones | 3 | Backend | ✅ Done | V001-V007 |
| PB-DEV-04 Seed Data | 2 | Backend | ✅ Done | Categorías, admin, vecino |
| PB-DEV-05 CI Pipeline | 5 | DevOps | 🔄 In Progress | Lint, test, build, coverage |

**Total SP Sprint 1:** ~112 SP (≈ 8 desarrolladores × 2 semanas × 7 SP/semana = 112 SP capacity)

**Definition of Done Sprint 1:**
- [ ] Todas las historias "Done" pasan tests unitarias + integración (≥80% coverage)
- [ ] API docs OpenAPI actualizadas y publicadas
- [ ] Docker Compose levanta entorno completo en < 2 min
- [ ] Migraciones aplican limpio en BD vacía
- [ ] Seed data crea usuarios de prueba funcionales
- [ ] CI pipeline verde en main
- [ ] Demo funcional: vecino crea reporte → admin ve en panel → cambia estado → vecino ve notificación

---

### 4.2 Sprint 2 — "Geo Avanzado + Dashboard + Notificaciones + OAuth + Admin CRUD + CD"
**Objetivo:** Mapas interactivos (vecino + admin), dashboard con gráficos, notificaciones push/email funcionando, OAuth2, CRUD catálogos/deptos/usuarios admin, CD a staging.

| Historia | SP | Responsable | Estado | Notas |
|----------|----|-------------|--------|-------|
| PB-AUTH-03 OAuth2 | 8 | Backend | ⏳ Pending | Google, Microsoft, ClaveÚnica |
| PB-AUTH-05 Logout/All | 3 | Backend | ⏳ Pending | Revocación tokens |
| PB-AUTH-08 Auditoría Login | 3 | Backend | ⏳ Pending | Tabla + endpoint admin |
| PB-AUTH-09 Perfil Usuario | 3 | Fullstack | ⏳ Pending | GET/PATCH/DELETE /me |
| PB-AUTH-10 Admin Usuarios | 3 | Fullstack | ⏳ Pending | Listar, ver, activar |
| PB-REP-04 Detección Duplicados | 5 | Backend | ⏳ Pending | PostGIS + trigger |
| PB-REP-08 Mapa Proximidad Vecino | 8 | Frontend | ⏳ Pending | MapLibre, clusters, bottom sheet |
| PB-REP-09 Notificaciones Vecino | 5 | Fullstack | ⏳ Pending | Push + Email en cambios |
| PB-ADM-05 Reasignar Depto/Admin | 5 | Fullstack | ⏳ Pending | Modal, limpiar confirmación |
| PB-ADM-06 Confirmar Asignación | 3 | Frontend | ⏳ Pending | Botón en detalle |
| PB-ADM-07 Notificaciones Admin | 3 | Fullstack | ⏳ Pending | Push asignación/prioridad |
| PB-ADM-08 CRUD Categorías | 5 | Fullstack | ⏳ Pending | Modal, iconos, colores, deptos |
| PB-ADM-09 CRUD Departamentos | 3 | Fullstack | ⏳ Pending | Modal simple |
| PB-GEO-03 Mapa Vecino Mobile | 8 | Frontend | ⏳ Pending | PB-GEO-01, MapLibre |
| PB-GEO-04 Mapa Admin Desktop | 8 | Frontend | ⏳ Pending | Split view, heatmap |
| PB-GEO-05 Performance Geo | 5 | Backend | ⏳ Pending | Índices parciales, EXPLAIN |
| PB-DASH-02 Gráficos Tendencias | 8 | Frontend | ⏳ Pending | Chart.js/Recharts |
| PB-DASH-03 Tabla por Depto | 3 | Frontend | ⏳ Pending | Resumen KPIs |
| PB-DASH-04 Exportar CSV/Excel | 5 | Backend | ⏳ Pending | Streaming response |
| PB-NOTIF-02 Worker Procesamiento | 8 | Backend | ⏳ Pending | FCM, SMTP, backoff |
| PB-NOTIF-03 Plantillas | 3 | Backend | ⏳ Pending | 6 templates |
| PB-SEC-06 Secrets Management | 3 | DevOps | ⏳ Pending | Vault/SealedSecrets |
| PB-DEV-06 CD Pipeline | 5 | DevOps | ⏳ Pending | Staging auto, Prod manual |
| PB-DEV-07 K8s Manifests | 5 | DevOps | ⏳ Pending | Deployment, Svc, Ingress |
| PB-DEV-09 k6 Performance | 5 | QA/DevOps | ⏳ Pending | Script + umbrales CI |

**Total SP Sprint 2:** ~124 SP

**Definition of Done Sprint 2:**
- [ ] OAuth2 funcional con 3 proveedores (cuentas de prueba)
- [ ] Mapa vecino: GPS → clusters → popup → detalle (mobile)
- [ ] Mapa admin: split view, sincronía lista-mapa, heatmap toggle
- [ ] Dashboard: KPIs + 3 gráficos + tabla depto + export CSV/Excel
- [ ] Notificaciones: worker procesa cola, FCM push + SMTP email, reintentos
- [ ] Admin CRUD: categorías (icono, color, deptos), departamentos, usuarios
- [ ] CD: merge a main → deploy staging automático; tag → deploy prod manual
- [ ] K8s: manifests aplican en kind local, health checks pasan
- [ ] Performance: k6 200 RPS p95 < 300ms API, < 500ms geo
- [ ] Demo completa end-to-end con datos realistas

---

### 4.3 Sprint 3 (Opcional/Buffer) — "Pulido, Observabilidad, Accesibilidad, Documentación"
**Objetivo:** Hardening, observabilidad completa, accesibilidad WCAG 2.1 AA, documentación usuario/admin, pruebas de carga prolongada, bug bash.

| Historia | SP | Responsable | Estado |
|----------|----|-------------|--------|
| PB-NOTIF-04 Centro Notificaciones In-App | 5 | Frontend | ⏳ |
| PB-DEV-08 Observabilidad Completa | 8 | DevOps | ⏳ |
| Accesibilidad WCAG 2.1 AA (auditoría + fixes) | 8 | Frontend | ⏳ |
| Documentación Usuario (Guía Vecino + Admin) | 5 | Tech Writer | ⏳ |
| Documentación Técnica (API, DB, Deploy, Troubleshooting) | 5 | Backend/DevOps | ⏳ |
| Pruebas de carga 24h (soak test) | 5 | QA | ⏳ |
| Bug Bash + Retrospectiva | 3 | Equipo | ⏳ |

---

## 5. Definition of Done (DoD) — Nivel Historia

Una historia se considera **Done** cuando **TODOS** los criterios se cumplen:

| Categoría | Criterio |
|-----------|----------|
| **Código** | ✅ Implementado según especificación (OpenAPI, Gherkin, Wireframes) |
| | ✅ Code review aprobado (mín. 1 reviewer, sin comentarios bloqueantes) |
| | ✅ Lint pasa (`npm run lint` / `eslint --max-warnings=0`) |
| | ✅ TypeScript strict mode sin errores (`tsc --noEmit`) |
| **Tests** | ✅ Tests unitarias nuevas/actualizadas (≥80% coverage en código nuevo) |
| | ✅ Tests de integración para endpoints nuevos (Jest + Testcontainers) |
| | ✅ Tests E2E para flujos críticos (Playwright) |
| | ✅ Tests Gherkin pasan (Cucumber) |
| | ✅ Tests de performance (k6) si aplica (geo, carga) |
| **Base de Datos** | ✅ Migración versionada (V###__descripcion.sql) creada y probada |
| | ✅ Rollback documentado (DOWN migration o script) |
| | ✅ Índices necesarios creados (EXPLAIN ANALYZE verificado) |
| | ✅ Triggers/RLS/CHECK constraints probados |
| **API** | ✅ OpenAPI spec actualizada (components, paths, examples) |
| | ✅ Validación de entrada (Zod/Joi) en todos los endpoints |
| | ✅ Manejo de errores consistente (ErrorResponse, códigos) |
| | ✅ Rate limiting aplicado |
| **Frontend** | ✅ Componentes reutilizables (Storybook documentado) |
| | ✅ Responsive: mobile, tablet, desktop (verificado visual) |
| | ✅ Accesibilidad: axe-core 0 violaciones AA, navegação teclado, screen reader |
| | ✅ Estados: loading, empty, error, success implementados |
| | ✅ Internacionalización (i18n) keys preparadas (es-CL) |
| **Seguridad** | ✅ Sin vulnerabilidades críticas/altas (`npm audit`) |
| | ✅ Headers seguridad presentes |
| | ✅ CORS restrictivo |
| | ✅ Sanitización XSS en campos de texto libre |
| **DevOps** | ✅ Dockerfile actualizado si cambia dependencias |
| | ✅ Docker Compose levanta servicio nuevo |
| | ✅ Variables de entorno documentadas (.env.example) |
| | ✅ Secrets NO en código (usar Vault/SealedSecrets) |
| **Documentación** | ✅ README actualizado si cambia setup |
| | ✅ CHANGELOG actualizado (Keep a Changelog) |
| | ✅ Diagramas arquitectura actualizados si cambia estructura |

---

## 6. Definition of Ready (DoR) — Para entrar a Sprint

Una historia está **Ready** para Sprint Planning cuando:

- [ ] Descripción clara: "Como [rol] quiero [acción] para [beneficio]"
- [ ] Criterios de aceptación escritos (formato Gherkin Given/When/Then)
- [ ] Wireframes/mockups vinculados (Figma/Storybook/17-wireframes.md)
- [ ] Endpoint OpenAPI definido (request/response/schemas)
- [ ] Dependencias identificadas y resueltas o en sprint anterior
- [ ] Estimación en Story Points acordada por equipo (Planning Poker)
- [ ] Tareas técnicas desglosadas (sub-tareas en Jira/GitHub Projects)
- [ ] Diseño DB confirmado (migración borrador revisada)
- [ ] No hay bloqueos externos (aprobaciones, credenciales, APIs terceros)

---

## 7. Matriz de Riesgos y Mitigación

| Riesgo | Probabilidad | Impacto | Mitigación | Dueño |
|--------|--------------|---------|------------|-------|
| Complejidad PostGIS/geo queries | Alta | Alto | Spike técnico S1 día 1-2; índices GIST + parciales; EXPLAIN ANALYZE obligatorio | Backend Lead |
| OAuth2 ClaveÚnica (certificados, entorno prueba) | Media | Alto | Usar sandbox ClaveÚnica; mock en CI; documentar proceso prod | Backend |
| FCM/APNs push setup (certificados, keys) | Media | Medio | Configurar en S2 temprano; usar FCM HTTP v1 API; fallback email | Backend |
| Performance mapas (tiles, clustering) | Media | Alto | Vector tiles (MapTiler/OSM); clustering cliente + servidor; lazy load | Frontend Lead |
| Migraciones DB en prod (datos existentes) | Baja | Crítico | Solo ADD column/nullable; backfill scripts separados; test en staging | Backend/DevOps |
| Rate limiting Redis vs DB | Media | Medio | Empezar con DB (tabla rate_limits); migrar a Redis si >10k RPS | Backend |
| Scope creep (nuevas features stakeholders) | Alta | Medio | Product Owner prioriza; todo nuevo → Icebox; solo bugs críticos en sprint | PO |
| Ausencia de tester dedicado | Media | Alto | Devs escriben tests; QA shared en Sprint Review; automatizar todo | Equipo |
| Integración continua lenta | Media | Medio | Cache Docker layers; parallel jobs; testcontainers reusables | DevOps |

---

## 8. Métricas de Seguimiento (KPIs de Sprint)

| Métrica | Objetivo | Herramienta | Frecuencia |
|---------|----------|-------------|------------|
| **Velocity** | ~110-120 SP/sprint | GitHub Projects / Jira | Por sprint |
| **Sprint Burndown** | Línea ideal | GitHub Projects | Diario |
| **Coverage (nuevo código)** | ≥ 80% | Codecov / SonarCloud | Por PR |
| **Bugs escapados a staging** | 0 críticos, < 5 menores | GitHub Issues | Por release |
| **Lead Time (PR → Merge)** | < 24h | GitHub Insights | Semanal |
| **Deploy Frequency** | 1/día (staging) | GitHub Actions | Diario |
| **MTTR (Mean Time To Recovery)** | < 30 min | Grafana Alerts | Por incidente |
| **Performance p95 API** | < 300ms | k6 / Grafana | Por PR + release |
| **Performance p95 Geo** | < 500ms | k6 / Grafana | Por PR + release |
| **Accessibility Score** | 100% (axe-core) | Playwright + axe | Por PR |

---

## 9. Ceremonias Scrum

| Ceremonia | Frecuencia | Duración | Participantes | Objetivo |
|-----------|------------|----------|---------------|----------|
| **Sprint Planning** | Inicio sprint | 2h | Todo el equipo + PO | Seleccionar PBIs, desglosar tareas, comprometer SP |
| **Daily Standup** | Diario | 15 min | Dev team | Sincronizar: ayer, hoy, bloqueos |
| **Backlog Refinement** | 1-2/semana | 1h | PO + Tech Lead + 2-3 devs | Preparar PBIs próximos sprints (DoR) |
| **Sprint Review** | Fin sprint | 1.5h | Equipo + Stakeholders | Demo funcional, feedback, actualizar PB |
| **Sprint Retrospective** | Fin sprint | 1h | Equipo | Qué bien, qué mejorar, action items |
| **Tech Sync** | Semanal | 30 min | Tech Leads + Arquitecto | Decisiones técnicas, deuda, spikes |

---

## 10. Stack de Herramientas de Gestión

| Área | Herramienta | Uso |
|------|-------------|-----|
| **Backlog / Sprint Board** | GitHub Projects (Board v2) | Epics, Issues, Sprints, Iteration fields |
| **Código / PRs** | GitHub | Repo, Branch protection, Reviews, Actions |
| **CI/CD** | GitHub Actions | Lint, Test, Build, Deploy, Security Scan |
| **Documentación** | Markdown en repo + GitHub Wiki | ADRs, Runbooks, API Docs (Redocly) |
| **Diagramas** | PlantUML (repo) + Mermaid (Wiki) | Arquitectura, BD, Secuencias |
| **Diseño UI** | Figma (referencia) + Storybook (componentes) | Wireframes, Design System, Visual tests |
| **Comunicación** | Slack / Discord | Daily async, alerts, incidents |
| **Incidencias** | GitHub Issues + PagerDuty (prod) | Bug tracking, on-call |
| **Métricas** | Grafana + Prometheus + Loki | Dashboards, Alertas, Logs |

---

## 11. Próximos Pasos Inmediatos (Week 1 Sprint 1)

| Día | Actividad | Responsable | Entregable |
|-----|-----------|-------------|------------|
| **Lunes** | Sprint Planning + Setup repos | Todo el equipo | Sprint Backlog confirmado, repos creados |
| **Martes** | Spike PostGIS + Migraciones V001-V007 | Backend Lead | BD local con schema completo, índices |
| **Miércoles** | Auth: Login + Registro + JWT + RBAC | Backend 1-2 | Endpoints /auth/login, /auth/refresh, /usuarios/registro |
| **Jueves** | Auth: Rate limit + Helmet + CORS + Zod | Backend 1 | Middleware seguridad base |
| **Viernes** | Reportes: Wizard paso 1-2 (Cat + Ubic+Foto) | Fullstack 1-2 | UI + API crear reporte (parcial) |
| **Fin de semana** | Buffer / Bug fixing / Docs | - | - |

---

## 12. Aprobación y Firmas

| Rol | Nombre | Firma | Fecha |
|-----|--------|-------|-------|
| **Product Owner** | | | |
| **Tech Lead / Arquitecto** | | | |
| **Scrum Master** | | | |
| **Equipo Desarrollo** | | | |

---

*Fin del documento — Plan de Implementación v1.0*