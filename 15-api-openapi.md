# Especificación API REST — Barrio Conectado (OpenAPI 3.0)

Este documento define el contrato completo de la API REST usando **OpenAPI 3.0.3** (YAML). Cubre todos los casos de uso (CU-01 a CU-08) y respeta los atributos de calidad (seguridad JWT, rate-limit, geoespacial).

---

## Archivos en el Repositorio

| Archivo | Descripción |
|---------|-------------|
| `15-api-openapi.md` | Este documento (resumen + enlaces) |
| `openapi/openapi.yaml` | Spec completa OpenAPI 3.0 (fuente única) |
| `openapi/components/schemas.yaml` | Esquemas reutilizables |
| `openapi/components/parameters.yaml` | Parámetros comunes |
| `openapi/components/responses.yaml` | Respuestas estándar |
| `openapi/paths/*.yaml` | Endpoints por recurso |

---

## Información General

```yaml
openapi: 3.0.3
info:
  title: Barrio Conectado API
  version: 1.0.0
  description: |
    API REST para la plataforma de gestión comunitaria **Barrio Conectado**.
    
    Permite a vecinos reportar problemas en la vía pública (luminarias, microbasurales, baches)
    y a administradores municipales gestionar, priorizar, asignar y dar seguimiento a los reportes.
    
    **Autenticación:** JWT Bearer Token (RS256) + OAuth2/OIDC (Google, Microsoft, ClaveÚnica)
    
    **Rate Limiting:** 100 req/min por usuario (burst 20), 1000 req/min por IP
    
    **Versión:** v1 (prefijo `/api/v1`)
  contact:
    name: Equipo Barrio Conectado
    email: dev@barrio-conectado.cl
  license:
    name: Académico - UV 2026
    url: https://github.com/bruhmzk/Barrio-Conectado

servers:
  - url: https://api.barrio-conectado.cl/api/v1
    description: Producción
  - url: https://staging-api.barrio-conectado.cl/api/v1
    description: Staging
  - url: http://localhost:3000/api/v1
    description: Desarrollo local

externalDocs:
  description: Documentación completa del proyecto
  url: https://github.com/bruhmzk/Barrio-Conectado
```

---

## Autenticación y Seguridad

### Esquemas de Seguridad

```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT Access Token (RS256, 15 min TTL).
        Obtener via POST /auth/login o POST /auth/refresh.
    OAuth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.barrio-conectado.cl/oauth/authorize
          tokenUrl: https://auth.barrio-conectado.cl/oauth/token
          scopes:
            profile: Acceso a perfil usuario
            email: Acceso a email
            offline_access: Refresh token
```

### Aplicación Global

```yaml
security:
  - BearerAuth: []
  - OAuth2: [profile, email]
```

> **Nota:** Endpoints públicos (`/auth/*`) sobrescriben con `security: []`.

---

## Códigos de Error Estándar

| Código | Significado | Cuándo se usa |
|--------|-------------|---------------|
| `400` | Bad Request | Body inválido, validación fallida |
| `401` | Unauthorized | Token faltante, expirado, inválido |
| `403` | Forbidden | Token válido pero sin permisos (rol) |
| `404` | Not Found | Recurso no existe |
| `409` | Conflict | Duplicado, transición inválida (EST-01) |
| `422` | Unprocessable Entity | Validación semántica (ej. nota vacía al completar) |
| `429` | Too Many Requests | Rate limit excedido |
| `500` | Internal Server Error | Error inesperado |
| `503` | Service Unavailable | Dependencia externa caída (maps, notificaciones) |

### Formato Error Response

```yaml
components:
  schemas:
    ErrorResponse:
      type: object
      required: [timestamp, status, error, message, path]
      properties:
        timestamp:
          type: string
          format: date-time
        status:
          type: integer
          example: 422
        error:
          type: string
          example: "Unprocessable Entity"
        message:
          type: string
          example: "La nota de resolución es obligatoria para completar el reporte"
        path:
          type: string
          example: "/api/v1/admin/reportes/uuid/estado"
        details:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              code:
                type: string
              message:
                type: string
```

---

## Esquemas Principales (Resumen)

### Reporte (Core)

```yaml
components:
  schemas:
    ReporteResponse:
      type: object
      properties:
        id:
          type: string
          format: uuid
        numeroSeguimiento:
          type: string
          pattern: '^REP-\d{4}-\d{6}$'
          example: "REP-2025-001234"
        usuarioId:
          type: string
          format: uuid
        categoriaId:
          type: string
          format: uuid
        categoriaNombre:
          type: string
        departamentoId:
          type: string
          format: uuid
        departamentoNombre:
          type: string
        descripcion:
          type: string
        estado:
          type: string
          enum: [Ingresado, EnRevisión, Completado, Descartado]
        prioridad:
          type: string
          enum: [Alta, Media, Baja]
        ubicacion:
          type: object
          properties:
            type:
              type: string
              enum: [Point]
              example: "Point"
            coordinates:
              type: array
              items:
                type: number
              minItems: 2
              maxItems: 2
              example: [-70.6483, -33.4569]
          description: "GeoJSON Point (lng, lat) - WGS84"
        referenciaUbicacion:
          type: string
          example: "Esquina Av. Principal c/ Calle 5"
        fotos:
          type: array
          items:
            $ref: '#/components/schemas/FotoResponse'
        creadoEn:
          type: string
          format: date-time
        actualizadoEn:
          type: string
          format: date-time
        completadoEn:
          type: string
          format: date-time
          nullable: true
        historialEstados:
          type: array
          items:
            $ref: '#/components/schemas/CambioEstadoResponse'
```

### Crear Reporte (Request)

```yaml
    ReporteCreateRequest:
      type: object
      required: [categoriaId, descripcion, foto, ubicacion]
      properties:
        categoriaId:
          type: string
          format: uuid
          description: "ID de categoría válida (ver GET /categorias)"
        descripcion:
          type: string
          minLength: 10
          maxLength: 2000
          example: "Lámpara fundida en poste esquina, sector oscuro y peligroso"
        foto:
          type: string
          format: base64
          description: "Imagen base64 (JPEG/PNG/WebP, máx 10MB). O subir a /upload y enviar URL firmada"
        ubicacion:
          type: object
          required: [type, coordinates]
          properties:
            type:
              type: string
              enum: [Point]
              const: Point
            coordinates:
              type: array
              items:
                type: number
              minItems: 2
              maxItems: 2
              example: [-70.6483, -33.4569]
          description: "GeoJSON Point [longitude, latitude] WGS84"
        referenciaUbicacion:
          type: string
          maxLength: 300
          example: "Esquina Av. Principal c/ Calle 5, frente a plaza"
```

### Cambiar Estado (Admin Request)

```yaml
    ReporteEstadoUpdateRequest:
      type: object
      required: [estado, nota]
      properties:
        estado:
          type: string
          enum: [EnRevisión, Completado, Descartado]
        nota:
          type: string
          minLength: 5
          maxLength: 2000
          description: "Obligatoria para Completado (resolución) y Descartado (motivo)"
```

---

## Endpoints por Recurso

### Autenticación (`/auth`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `POST` | `/auth/login` | Login email/password o OAuth code | No | — |
| `POST` | `/auth/oauth` | Login con proveedor OAuth (Google, Microsoft, ClaveÚnica) | No | — |
| `POST` | `/auth/refresh` | Renovar access token con refresh token | No | — |
| `POST` | `/auth/logout` | Revocar refresh token actual | JWT | Cualquiera |
| `POST` | `/auth/logout-all` | Revocar todos los refresh tokens del usuario | JWT | Cualquiera |
| `GET` | `/auth/me` | Perfil del usuario autenticado | JWT | Cualquiera |

#### POST /auth/login

```yaml
paths:
  /auth/login:
    post:
      summary: Iniciar sesión con email y contraseña
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  format: password
                  minLength: 8
                rememberMe:
                  type: boolean
                  default: false
      responses:
        '200':
          description: Login exitoso
          content:
            application/json:
              schema:
                type: object
                properties:
                  accessToken:
                    type: string
                    description: "JWT RS256, 15 min"
                  refreshToken:
                    type: string
                    description: "Opaque token, 30 días (7 si !rememberMe)"
                  expiresIn:
                    type: integer
                    example: 900
                  tokenType:
                    type: string
                    example: "Bearer"
                  usuario:
                    $ref: '#/components/schemas/UsuarioResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/TooManyRequests'
```

### Usuarios (`/usuarios`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `POST` | `/usuarios/registro` | Registrar nuevo vecino | No | — |
| `GET` | `/usuarios/me` | Mi perfil | JWT | Cualquiera |
| `PATCH` | `/usuarios/me` | Actualizar mi perfil | JWT | Cualquiera |
| `DELETE` | `/usuarios/me` | Eliminar mi cuenta | JWT | Cualquiera |
| `GET` | `/usuarios/{id}` | Ver perfil (admin) | JWT | Admin |
| `GET` | `/usuarios` | Listar usuarios (admin) | JWT | Admin |

### Categorías (`/categorias`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `GET` | `/categorias` | Listar categorías activas | No | — |
| `GET` | `/categorias/{id}` | Detalle categoría | No | — |
| `POST` | `/categorias` | Crear categoría | JWT | Admin |
| `PATCH` | `/categorias/{id}` | Actualizar categoría | JWT | Admin |
| `DELETE` | `/categorias/{id}` | Desactivar categoría | JWT | Admin |

### Departamentos (`/departamentos`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `GET` | `/departamentos` | Listar departamentos activos | No | — |
| `GET` | `/departamentos/{id}` | Detalle departamento | No | — |

### Reportes - Vecino (`/reportes`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `POST` | `/reportes` | Crear reporte (foto + geo) | JWT | Vecino |
| `GET` | `/reportes/mis` | Listar mis reportes | JWT | Vecino |
| `GET` | `/reportes/{id}` | Detalle de mi reporte | JWT | Vecino (own) |
| `GET` | `/reportes/{id}/historial` | Historial de estados | JWT | Vecino (own) |

#### POST /reportes

```yaml
paths:
  /reportes:
    post:
      summary: Crear nuevo reporte (vecino)
      operationId: createReporte
      security:
        - BearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReporteCreateRequest'
      responses:
        '201':
          description: Reporte creado exitosamente
          headers:
            Location:
              schema:
                type: string
                format: uri
              description: "URL del reporte creado"
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ReporteResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '422':
          description: Validación fallida (ubicación inválida, categoría inexistente)
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              example:
                timestamp: "2025-08-15T14:30:00Z"
                status: 422
                error: "Unprocessable Entity"
                message: "Ubicación fuera de los límites de la comuna"
                path: "/api/v1/reportes"
        '429':
          $ref: '#/components/responses/TooManyRequests'
```

#### GET /reportes/mis

```yaml
  /reportes/mis:
    get:
      summary: Listar mis reportes (vecino)
      operationId: listMisReportes
      security:
        - BearerAuth: []
      parameters:
        - $ref: '#/components/parameters/Page'
        - $ref: '#/components/parameters/Size'
        - $ref: '#/components/parameters/EstadoFilter'
        - $ref: '#/components/parameters/Sort'
      responses:
        '200':
          description: Lista paginada de reportes del usuario
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PageResponse'
                properties:
                  content:
                    type: array
                    items:
                      $ref: '#/components/schemas/ReporteListItemResponse'
```

### Reportes - Admin (`/admin/reportes`)

| Método | Ruta | Descripción | Auth | Roles |
|--------|------|-------------|------|-------|
| `GET` | `/admin/reportes` | Filtrar y listar reportes | JWT | Admin |
| `GET` | `/admin/reportes/{id}` | Detalle completo (admin) | JWT | Admin |
| `PATCH` | `/admin/reportes/{id}/estado` | Cambiar estado + nota | JWT | Admin |
| `PATCH` | `/admin/reportes/{id}/prioridad` | Ajustar prioridad | JWT | Admin |
| `PATCH` | `/admin/reportes/{id}/reasignar` | Reasignar departamento | JWT | Admin |
| `GET` | `/admin/reportes/estadisticas` | KPIs dashboard | JWT | Admin |
| `GET` | `/admin/reportes/exportar` | Exportar CSV/Excel | JWT | Admin |

#### GET /admin/reportes (Filtros)

```yaml
  /admin/reportes:
    get:
      summary: Filtrar reportes (panel admin)
      operationId: filterReportesAdmin
      security:
        - BearerAuth: []
      parameters:
        - $ref: '#/components/parameters/Page'
        - $ref: '#/components/parameters/Size'
        - name: estado
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [Ingresado, EnRevisión, Completado, Descartado]
            style: form
            explode: true
        - name: prioridad
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [Alta, Media, Baja]
            style: form
            explode: true
        - name: categoriaId
          in: query
          schema:
            type: array
            items:
              type: string
              format: uuid
            style: form
            explode: true
        - name: departamentoId
          in: query
          schema:
            type: array
            items:
              type: string
              format: uuid
            style: form
            explode: true
        - name: fechaDesde
          in: query
          schema:
            type: string
            format: date
        - name: fechaHasta
          in: query
          schema:
            type: string
            format: date
        - name: busqueda
          in: query
          schema:
            type: string
          description: "Busca en número seguimiento, descripción, vecino"
        - $ref: '#/components/parameters/Sort'
      responses:
        '200':
          description: Lista paginada filtrada
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PageResponse'
                properties:
                  content:
                    type: array
                    items:
                      $ref: '#/components/schemas/ReporteAdminListItemResponse'
```

#### PATCH /admin/reportes/{id}/estado

```yaml
  /admin/reportes/{id}/estado:
    patch:
      summary: Cambiar estado de reporte (admin)
      operationId: updateReporteEstado
      security:
        - BearerAuth: []
      parameters:
        - $ref: '#/components/parameters/ReporteId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReporteEstadoUpdateRequest'
      responses:
        '200':
          description: Estado actualizado, notificación encolada
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ReporteResponse'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'
        '409':
          description: Transición inválida (ej. Ingresado -> Completado directo)
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '422':
          description: Nota vacía para Completado/Descartado
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
```

---

## Parámetros Comunes

```yaml
components:
  parameters:
    ReporteId:
      name: id
      in: path
      required: true
      schema:
        type: string
        format: uuid
      description: "ID del reporte (UUID)"
    
    Page:
      name: page
      in: query
      schema:
        type: integer
        minimum: 0
        default: 0
      description: "Página (base 0)"
    
    Size:
      name: size
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
      description: "Elementos por página"
    
    Sort:
      name: sort
      in: query
      schema:
        type: array
        items:
          type: string
          pattern: '^[a-zA-Z_]+,(asc|desc)$'
        style: form
        explode: true
      example: ["creadoEn,desc", "prioridad,desc"]
      description: "Ordenamiento: campo,dirección"
    
    EstadoFilter:
      name: estado
      in: query
      schema:
        type: string
        enum: [Ingresado, EnRevisión, Completado, Descartado]
```

---

## Respuestas de Paginación

```yaml
components:
  schemas:
    PageResponse:
      type: object
      required: [content, pageable, totalElements, totalPages, last, first, numberOfElements, size, number, empty]
      properties:
        content:
          type: array
          items: {}
        pageable:
          type: object
          properties:
            pageNumber:
              type: integer
            pageSize:
              type: integer
            sort:
              type: object
              properties:
                sorted:
                  type: boolean
                unsorted:
                  type: boolean
                empty:
                  type: boolean
            offset:
              type: integer
            paged:
              type: boolean
            unpaged:
              type: boolean
        totalElements:
          type: integer
        totalPages:
          type: integer
        last:
          type: boolean
        first:
          type: boolean
        numberOfElements:
          type: integer
        size:
          type: integer
        number:
          type: integer
        empty:
          type: boolean
```

---

## GeoJSON y Consultas Espaciales

### Endpoint: Reportes cercanos (Mapa Vecino)

```yaml
paths:
  /reportes/cercanos:
    get:
      summary: Reportes en radio (para mapa vecino)
      operationId: getReportesCercanos
      security:
        - BearerAuth: []
      parameters:
        - name: lat
          in: query
          required: true
          schema:
            type: number
            format: double
            minimum: -90
            maximum: 90
        - name: lon
          in: query
          required: true
          schema:
            type: number
            format: double
            minimum: -180
            maximum: 180
        - name: radio
          in: query
          schema:
            type: integer
            minimum: 100
            maximum: 5000
            default: 500
          description: "Radio en metros"
        - name: limite
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 200
            default: 50
      responses:
        '200':
          description: FeatureCollection GeoJSON
          content:
            application/geo+json:
              schema:
                type: object
                properties:
                  type:
                    type: string
                    const: FeatureCollection
                  features:
                    type: array
                    items:
                      $ref: '#/components/schemas/ReporteGeoJSONFeature'
```

### Feature GeoJSON

```yaml
components:
  schemas:
    ReporteGeoJSONFeature:
      type: object
      properties:
        type:
          type: string
          const: Feature
        geometry:
          type: object
          required: [type, coordinates]
          properties:
            type:
              type: string
              const: Point
            coordinates:
              type: array
              items:
                type: number
              minItems: 2
              maxItems: 2
        properties:
          type: object
          properties:
            id:
              type: string
              format: uuid
            numeroSeguimiento:
              type: string
            categoriaNombre:
              type: string
            categoriaIcono:
              type: string
            categoriaColor:
              type: string
            estado:
              type: string
            prioridad:
              type: string
            referenciaUbicacion:
              type: string
            creadoEn:
              type: string
              format: date-time
```

---

## Webhooks / Callbacks (Notificaciones)

```yaml
components:
  callbacks:
    notificacionEntregada:
      '{$request.body#/callbackUrl}':
        post:
          summary: Callback cuando notificación se entrega/fall
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    notificacionId:
                      type: string
                      format: uuid
                    estado:
                      type: string
                      enum: [Enviada, Fallida]
                    proveedorId:
                      type: string
                    enviadoEn:
                      type: string
                      format: date-time
                    error:
                      type: string
          responses:
            '200':
              description: Callback recibido
```

---

## Rate Limiting Headers

Todas las respuestas incluyen:

```yaml
headers:
  X-RateLimit-Limit:
    schema:
      type: integer
    description: "Límite de requests en ventana actual"
  X-RateLimit-Remaining:
    schema:
      type: integer
    description: "Requests restantes"
  X-RateLimit-Reset:
    schema:
      type: integer
    description: "Unix timestamp cuando se resetea la ventana"
  Retry-After:
    schema:
      type: integer
    description: "Segundos para reintentar (solo 429)"
```

---

## Versionado y Deprecación

- **Versión en URL:** `/api/v1/`
- **Deprecación:** Header `Sunset` + `Link: <v2>; rel="successor-version"`
- **Changelog:** `/api/changelog` o GitHub Releases

---

## Testing y Documentación Interactiva

| Herramienta | Uso |
|-------------|-----|
| **Swagger UI** | `/docs` - Explorar y probar endpoints |
| **Redoc** | `/redoc` - Documentación de referencia |
| **Postman Collection** | `openapi/postman-collection.json` - Importar en Postman |
| **Prism Mock** | `npx @stoplight/prism mock openapi.yaml` - Servidor mock |
| **Contract Tests** | Pact / Spring Cloud Contract - Consumer-driven contracts |

---

## Archivo OpenAPI Completo

El archivo YAML completo (`openapi/openapi.yaml`) incluye:
- Todos los schemas detallados con validaciones
- Todos los endpoints con request/response examples
- Security requirements por endpoint
- Callbacks para notificaciones
- Extensiones `x-*` para codegen (x-controller, x-handler, etc.)

```bash
# Validar spec
npx @redocly/openapi-cli lint openapi/openapi.yaml

# Generar cliente TypeScript
npx @openapitools/openapi-generator-cli generate -i openapi/openapi.yaml -g typescript-axios -o generated/client

# Generar servidor NestJS
npx @openapitools/openapi-generator-cli generate -i openapi/openapi.yaml -g nestjs -o generated/server
```

---

> **Próximo paso:** Generar `16-plan-pruebas.md` con plan de pruebas y casos de prueba derivados de Gherkin.