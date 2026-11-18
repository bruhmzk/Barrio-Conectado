# 17. Wireframes y Mockups UI

**Versión:** 1.0  
**Fecha:** 2026-08-15  
**Entrega:** 3 — Implementación  
**Proyecto:** Barrio Conectado

---

## 1. Principios de Diseño

| Principio | Descripción |
|-----------|-------------|
| **Mobile First** | Diseño responsive desde 320px, breakpoints: 640px (tablet), 1024px (desktop), 1440px (wide) |
| **Accesibilidad WCAG 2.1 AA** | Contraste ≥ 4.5:1, foco visible, labels en formularios, ARIA landmarks, navegación teclado |
| **Diseño Atómico** | Tokens → Átomos → Moléculas → Organismos → Templates → Páginas |
| **Consistencia** | Sistema de diseño unificado (colores, tipografía, espaciado, iconografía) |
| **Feedback Inmediato** | Loading states, empty states, error states, success toasts, skeleton screens |

---

## 2. Sistema de Diseño (Design Tokens)

### 2.1 Paleta de Colores

```css
:root {
  /* Primarios - Municipio */
  --color-primary-50:  #E3F2FD;
  --color-primary-100: #BBDEFB;
  --color-primary-200: #90CAF9;
  --color-primary-300: #64B5F6;
  --color-primary-400: #42A5F5;
  --color-primary-500: #2196F3;  /* Primary */
  --color-primary-600: #1E88E5;
  --color-primary-700: #1976D2;
  --color-primary-800: #1565C0;
  --color-primary-900: #0D47A1;

  /* Secundarios - Categoría Luminaria (ejemplo) */
  --color-secondary-500: #FFD600;
  --color-secondary-600: #FFC400;

  /* Semánticos */
  --color-success-500: #2E7D32;
  --color-success-100: #C8E6C9;
  --color-warning-500: #EF6C00;
  --color-warning-100: #FFE0B2;
  --color-error-500: #C62828;
  --color-error-100: #FFCDD2;
  --color-info-500: #0277BD;
  --color-info-100: #B3E5FC;

  /* Neutros */
  --color-neutral-0:   #FFFFFF;
  --color-neutral-50:  #FAFAFA;
  --color-neutral-100: #F5F5F5;
  --color-neutral-200: #EEEEEE;
  --color-neutral-300: #E0E0E0;
  --color-neutral-400: #BDBDBD;
  --color-neutral-500: #9E9E9E;
  --color-neutral-600: #757575;
  --color-neutral-700: #616161;
  --color-neutral-800: #424242;
  --color-neutral-900: #212121;
  --color-neutral-950: #121212;

  /* Categoría-colores (para chips/badges) */
  --color-cat-luminaria:      #FFD600;
  --color-cat-microbasural:   #EF6C00;
  --color-cat-bache:          #C62828;
  --color-cat-senaletica:     #1565C0;
  --color-cat-vereda:         #2E7D32;
  --color-cat-parques:        #388E3C;
  --color-cat-drenaje:        #0277BD;
  --color-cat-otro:           #757575;
}
```

### 2.2 Tipografía

```css
:root {
  --font-family-base: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-family-mono: 'JetBrains Mono', 'Fira Code', monospace;

  --font-size-xs:    0.75rem;   /* 12px */
  --font-size-sm:    0.875rem;  /* 14px */
  --font-size-base:  1rem;      /* 16px */
  --font-size-lg:    1.125rem;  /* 18px */
  --font-size-xl:    1.25rem;   /* 20px */
  --font-size-2xl:   1.5rem;    /* 24px */
  --font-size-3xl:   1.875rem;  /* 30px */
  --font-size-4xl:   2.25rem;   /* 36px */

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;
}
```

### 2.3 Espaciado y Bordes

```css
:root {
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */
  --space-16: 4rem;    /* 64px */

  --radius-sm: 0.25rem;   /* 4px */
  --radius-md: 0.5rem;    /* 8px */
  --radius-lg: 0.75rem;   /* 12px */
  --radius-xl: 1rem;      /* 16px */
  --radius-full: 9999px;

  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -4px rgba(0,0,0,0.1);
  --shadow-xl: 0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1);
}
```

### 2.4 Iconografía
- **Librería:** Material Design Icons (Material Symbols) / Lucide React
- **Tamaños:** 16px (inline), 20px (botones), 24px (header), 32px (empty states)
- **Estilo:** Outlined (default), Filled (estados activos)

---

## 3. Componentes Base (Átomos y Moléculas)

### 3.1 Botones

```tsx
// Variantes
<Button variant="primary">Acción principal</Button>      // bg-primary-600, hover:primary-700
<Button variant="secondary">Acción secundaria</Button>   // bg-neutral-100, border, hover:neutral-200
<Button variant="outline">Outline</Button>               // transparent, border-primary, text-primary
<Button variant="ghost">Ghost</Button>                   // transparent, hover:neutral-100
<Button variant="danger">Eliminar</Button>               // bg-error-500, hover:error-600
<Button variant="success">Completar</Button>             // bg-success-500

// Tamaños
<Button size="sm">Pequeño</Button>    // px-3 py-1.5 text-sm
<Button size="md">Mediano</Button>    // px-4 py-2 text-base
<Button size="lg">Grande</Button>     // px-6 py-3 text-lg

// Estados
<Button disabled>Deshabilitado</Button>
<Button loading>Cargando...</Button>   // Spinner interno
<Button fullWidth>Ancho completo</Button>
```

### 3.2 Inputs y Formularios

```tsx
<Input
  label="Email"
  type="email"
  placeholder="tu@email.cl"
  error="Email inválido"
  helperText="Usamos tu email para notificaciones"
  required
/>

<Textarea
  label="Descripción del problema"
  placeholder="Describe el problema con detalle (mín. 10 caracteres)"
  minLength={10}
  maxLength={2000}
  showCharCount
  rows={4}
/>

<Select
  label="Categoría"
  placeholder="Selecciona una categoría"
  options={[
    { value: 'uuid-luminaria', label: '💡 Luminaria - Prioridad Alta' },
    { value: 'uuid-bache', label: '🛣️ Bache - Prioridad Alta' },
    { value: 'uuid-microbasural', label: '🗑️ Microbasural - Prioridad Media' },
  ]}
  searchable
/>

<FileUpload
  label="Foto del problema"
  accept="image/jpeg,image/png,image/webp,image/heic"
  maxSizeMB={10}
  multiple={false}
  preview={true}
  dragAndDrop={true}
/>

<Checkbox label="Acepto términos y condiciones" required />
<RadioGroup name="prioridad" options={[{value:'Alta',label:'Alta'}, {value:'Media',label:'Media'}, {value:'Baja',label:'Baja'}]} />
<Switch label="Notificaciones push" defaultChecked />
```

### 3.3 Tarjetas (Cards)

```tsx
// Card Reporte (Lista Vecino)
<ReportCard
  numeroSeguimiento="REP-2025-000123"
  categoria={{ nombre: 'Luminaria', icono: 'lightbulb', color: '#FFD600' }}
  estado="EnRevisión"
  prioridad="Alta"
  descripcion="Lámpara fundida en poste esquina Av. Principal..."
  referenciaUbicacion="Esquina Av. Principal c/ Calle 5"
  creadoEn="2025-08-10T14:30:00Z"
  totalFotos={1}
  onPress={() => navigate('/reportes/uuid')}
/>

// Card Reporte Admin (con más info)
<AdminReportCard
  ...propsVecino
  vecinoNombre="María González"
  vecinoEmail="maria@ejemplo.cl"
  departamentoNombre="Alumbrado Público"
  adminAsignadoNombre="Juan Pérez"
  asignacionConfirmada={true}
  ultimaActualizacionEstado="2025-08-12T09:15:00Z"
  onReasignar={() => openReasignarModal()}
  onCambiarEstado={() => openEstadoModal()}
/>
```

### 3.4 Chips / Badges / Tags

```tsx
<Badge variant="estado" value="Ingresado" />      // bg-info-100 text-info-700
<Badge variant="estado" value="EnRevisión" />     // bg-warning-100 text-warning-700
<Badge variant="estado" value="Completado" />     // bg-success-100 text-success-700
<Badge variant="estado" value="Descartado" />     // bg-neutral-100 text-neutral-700

<Badge variant="prioridad" value="Alta" />        // bg-error-100 text-error-700 + icon ⚠️
<Badge variant="prioridad" value="Media" />       // bg-warning-100 text-warning-700
<Badge variant="prioridad" value="Baja" />        // bg-success-100 text-success-700

<CategoryChip categoria={{nombre:'Luminaria',icono:'lightbulb',color:'#FFD600'}} size="md" />
```

### 3.5 Navegación y Layout

```tsx
// Header Principal (App Bar)
<Header
  title="Barrio Conectado"
  user={{ nombre: 'María González', rol: 'vecino', avatarUrl: '...' }}
  onMenuPress={() => openDrawer()}
  onProfilePress={() => navigate('/perfil')}
  onLogout={() => logout()}
/>

// Bottom Navigation (Mobile)
<BottomNav
  items={[
    { icon: 'home', label: 'Inicio', href: '/', active: true },
    { icon: 'add_circle', label: 'Reportar', href: '/reportar' },
    { icon: 'list_alt', label: 'Mis Reportes', href: '/mis-reportes' },
    { icon: 'map', label: 'Mapa', href: '/mapa' },
    { icon: 'person', label: 'Perfil', href: '/perfil' },
  ]}
/>

// Sidebar Admin (Desktop)
<AdminSidebar
  items={[
    { icon: 'dashboard', label: 'Dashboard', href: '/admin' },
    { icon: 'assignment', label: 'Reportes', href: '/admin/reportes', badge: 23 },
    { icon: 'category', label: 'Categorías', href: '/admin/categorias' },
    { icon: 'business', label: 'Departamentos', href: '/admin/departamentos' },
    { icon: 'people', label: 'Usuarios', href: '/admin/usuarios' },
    { icon: 'analytics', label: 'Estadísticas', href: '/admin/estadisticas' },
    { icon: 'settings', label: 'Configuración', href: '/admin/config' },
  ]}
/>
```

### 3.6 Mapa (Geoespacial)

```tsx
<MapView
  center={[-33.0458, -71.5429]}  // [lat, lon] Santiago
  zoom={14}
  markers={reportes.map(r => ({
    id: r.id,
    position: [r.ubicacion.coordinates[1], r.ubicacion.coordinates[0]], // [lat, lon]
    icon: r.categoria.icono,
    color: r.categoria.color,
    onPress: () => navigate(`/reportes/${r.id}`),
    popup: {
      title: r.numeroSeguimiento,
      subtitle: r.categoria.nombre,
      description: r.referenciaUbicacion,
      estado: r.estado,
      prioridad: r.prioridad,
    }
  }))}
  clustering={true}
  clusterRadius={50}
  onRegionChange={({ center, zoom }) => fetchReportesInBounds(center, zoom)}
/>

// Capas: Heatmap, Clustering, Bounding Box
<MapLayer type="heatmap" data={reportes} radius={30} maxZoom={15} />
<MapLayer type="geojson" data={barriosGeoJSON} style={{ fillOpacity: 0.1, strokeWidth: 1 }} />
```

### 3.7 Notificaciones y Feedback

```tsx
// Toast global
<Toast
  type="success" | "error" | "warning" | "info"
  title="Reporte creado"
  message="Tu reporte REP-2025-000123 ha sido ingresado correctamente"
  duration={5000}
  action={{ label: 'Ver', onPress: () => navigate('/reportes/uuid') }}
/>

// Modal confirmación
<ConfirmModal
  open={true}
  title="¿Descartar reporte?"
  message="Esta acción no se puede deshacer. El vecino será notificado."
  confirmLabel="Descartar"
  cancelLabel="Cancelar"
  variant="danger"
  onConfirm={() => handleDescartar()}
  onCancel={() => setOpen(false)}
/>

// Empty State
<EmptyState
  icon="inbox"
  title="No hay reportes aún"
  description="Cuando crees tu primer reporte, aparecerá aquí."
  action={{ label: 'Crear reporte', href: '/reportar' }}
/>

// Skeleton Loading
<ReportCardSkeleton />  // Versión esqueleto de ReportCard
<AdminReportCardSkeleton />
```

---

## 4. Pantallas Principales (Wireframes)

> **Notación:** `[Componente]` = componente reutilizable | `{variable}` = dato dinámico | `→` = navegación

---

### 4.1 Flujo Autenticación

#### 4.1.1 Login
```
┌─────────────────────────────────────┐
│         BARRIO CONECTADO            │  ← Logo + Nombre
│     Gestión Comunitaria Municipal   │  ← Subtítulo
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Iniciar Sesión             │   │
│  ├─────────────────────────────┤   │
│  │  [Input Email]              │   │
│  │  [Input Password]  [👁]     │   │
│  │  [Checkbox] Recordarme      │   │
│  │  [Button Primary] Entrar    │   │
│  ├─────────────────────────────┤   │
│  │  ¿Olvidaste tu contraseña?  │   │
│  ├─────────────────────────────┤   │
│  │  ──────  O  ──────          │   │
│  │  [Button Outline Google]    │   │
│  │  [Button Outline Microsoft] │   │
│  │  [Button Outline ClaveÚnica]│   │
│  └─────────────────────────────┘   │
│                                     │
│  ¿No tienes cuenta? [Link Registro] │
└─────────────────────────────────────┘
```

#### 4.1.2 Registro
```
┌─────────────────────────────────────┐
│         BARRIO CONECTADO            │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Crear Cuenta               │   │
│  ├─────────────────────────────┤   │
│  │  [Input Nombre Completo]    │   │
│  │  [Input Email]              │   │
│  │  [Input Teléfono] (opcional)│   │
│  │  [Input Password]  [👁]     │   │
│  │  [Input Confirmar Password] │   │
│  │  [Checkbox] Acepto términos │   │
│  │  [Button Primary] Registrar │   │
│  └─────────────────────────────┘   │
│                                     │
│  ¿Ya tienes cuenta? [Link Login]    │
└─────────────────────────────────────┘
```

---

### 4.2 Flujo Vecino (Mobile First)

#### 4.2.1 Home / Dashboard Vecino
```
┌─────────────────────────────────────┐
│  [Header] Barrio Conectado  [Perfil]│
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  📍 Tu ubicación: Santiago  │   │  ← Chip ubicación
│  │  [Button Primary Full]      │   │
│  │     +  NUEVO REPORTE        │   │  → /reportar
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  MIS REPORTES (3)           │   │  → /mis-reportes
│  ├─────────────────────────────┤   │
│  │  [ReportCard] REP-2025-001  │   │
│  │    💡 Luminaria  ● EnRevisión│   │
│  │    "Lámpara fundida..."     │   │
│  │    Esquina Av. Principal... │   │
│  │    10 ago 2025 · 1 foto     │   │
│  ├─────────────────────────────┤   │
│  │  [ReportCard] REP-2025-002  │   │
│  │    🛣️ Bache  ✓ Completado   │   │
│  │    "Gran bache en calzada..."│  │
│  │    Calle 5 entre Av...      │   │
│  │    5 ago 2025 · 2 fotos     │   │
│  └─────────────────────────────┘   │
│                                     │
│  [BottomNav] Home | Reportar | Mis | Mapa | Perfil
└─────────────────────────────────────┘
```

#### 4.2.2 Crear Reporte (Multi-step)
```
PASO 1: Categoría
┌─────────────────────────────┐
│  ←  Crear Reporte  (1/4)    │
├─────────────────────────────┤
│  ¿Qué quieres reportar?     │
│                             │
│  [CategoryChip Luminaria]   │  ← Grid 2 cols
│  [CategoryChip Microbasural]│
│  [CategoryChip Bache]       │
│  [CategoryChip Señalética]  │
│  [CategoryChip Vereda]      │
│  [CategoryChip Parques]     │
│  [CategoryChip Drenaje]     │
│  [CategoryChip Otro]        │
│                             │
│  [Button Primary] Siguiente │  → Paso 2
└─────────────────────────────┘

PASO 2: Ubicación + Foto
┌─────────────────────────────┐
│  ←  Crear Reporte  (2/4)    │
├─────────────────────────────┤
│  📍 Ubicación detectada     │
│  [MapView] ← Mapa interactivo│  ← Pin arrastrable
│  [Button Ghost] Usar GPS    │  ← Geolocalización
│                             │
│  📸 Foto del problema *     │
│  [FileUpload]               │  ← Preview + drag&drop
│                             │
│  📝 Referencia (opcional)   │
│  [Input "Esquina Av... frente a plaza"]│
│                             │
│  [Button Secondary] Atrás   [Button Primary] Siguiente → Paso 3
└─────────────────────────────┘

PASO 3: Descripción
┌─────────────────────────────┐
│  ←  Crear Reporte  (3/4)    │
├─────────────────────────────┤
│  Describe el problema *     │
│  [Textarea 4 rows]          │
│  "Lámpara fundida en poste esquina Av. Principal c/ Calle 5, sector oscuro y peligroso para peatones nocturnos"│
│  150/2000 caracteres        │
│                             │
│  [Button Secondary] Atrás   [Button Primary] Siguiente → Paso 4
└─────────────────────────────┘

PASO 4: Confirmación
┌─────────────────────────────┐
│  ←  Crear Reporte  (4/4)    │
├─────────────────────────────┤
│  ✅ Revisa tu reporte       │
│                             │
│  Categoría: 💡 Luminaria    │
│  Ubicación: [Mapa miniatura]│
│  Foto: [Thumbnail]          │
│  Descripción: "Lámpara..."  │
│                             │
│  [Button Secondary] Editar  [Button Primary] ENVIAR REPORTE
└─────────────────────────────┘

ÉXITO:
┌─────────────────────────────┐
│  ✅ Reporte Enviado         │
├─────────────────────────────┤
│  Tu reporte ha sido creado  │
│  Número de seguimiento:     │
│  REP-2025-000123            │
│                             │
│  [Button Primary] Ver mis reportes → /mis-reportes
│  [Button Outline] Crear otro → /reportar
└─────────────────────────────┘
```

#### 4.2.3 Mis Reportes (Lista con Filtros)
```
┌─────────────────────────────────────┐
│  [Header] Mis Reportes      [Filtro]│
├─────────────────────────────────────┤
│  [SegmentedControl]                 │
│  [Todos] [Ingresado] [EnRevisión]   │
│  [Completado] [Descartado]          │
├─────────────────────────────────────┤
│  [ReportCard] REP-2025-001          │
│    💡 Luminaria  ● EnRevisión  ⚠️   │
│    "Lámpara fundida en poste..."    │
│    Esquina Av. Principal c/ Calle 5 │
│    10 ago 2025 · 1 foto             │
│    [Badge] Prioridad: Alta          │
├─────────────────────────────────────┤
│  [ReportCard] REP-2025-002          │
│    🛣️ Bache  ✓ Completado          │
│    "Gran bache en calzada..."       │
│    Calle 5 entre Av. Principal...   │
│    5 ago 2025 · 2 fotos             │
│    [Badge] Prioridad: Alta          │
├─────────────────────────────────────┤
│  [ReportCard] REP-2025-003          │
│    🗑️ Microbasural  ✗ Descartado   │
│    "Acumulación de basura..."       │
│    Parque Central                   │
│    1 ago 2025 · 1 foto              │
│    [Badge] Prioridad: Media         │
├─────────────────────────────────────┤
│  [Pagination] ← 1 2 3 →             │
│                                     │
│  [BottomNav]                        │
└─────────────────────────────────────┘
```

#### 4.2.4 Detalle Reporte (Vecino)
```
┌─────────────────────────────────────┐
│  [Header] REP-2025-000123    [⋮]    │
├─────────────────────────────────────┤
│  [CategoryChip Luminaria] ● EnRevisión│
│  ⚠️ Prioridad: Alta               │
│                                     │
│  📸 [PhotoCarousel] 1/1            │  ← Swipe horizontal
│     [Foto grande con zoom]         │
│                                     │
│  📝 Descripción                    │
│  Lámpara fundida en poste esquina  │
│  Av. Principal c/ Calle 5, sector  │
│  oscuro y peligroso para peatones  │
│  nocturnos                         │
│                                     │
│  📍 Ubicación                      │
│  Esquina Av. Principal c/ Calle 5  │
│  [MiniMapa] → [Button] Ver en mapa │
│                                     │
│  📅 Creado: 10 ago 2025, 14:30     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  HISTORIAL DE ESTADOS       │   │
│  ├─────────────────────────────┤   │
│  │  ● Ingresado                │   │
│  │    10 ago 2025, 14:30       │   │
│  │    "Reporte ingresado por   │   │
│  │     vecino"                 │   │
│  ├─────────────────────────────┤   │
│  │  ● EnRevisión               │   │
│  │    12 ago 2025, 09:15       │   │
│  │    "Iniciando revisión      │   │
│  │     técnica" - Juan Pérez   │   │
│  └─────────────────────────────┘   │
│                                     │
│  [BottomNav]                        │
└─────────────────────────────────────┘
```

#### 4.2.5 Mapa Vecino (Proximidad)
```
┌─────────────────────────────────────┐
│  [Header] Mapa de Reportes   [📍]   │
├─────────────────────────────────────┤
│                                     │
│  [MapView Full Screen]              │
│  ● 💡 Luminaria (3)  ← Cluster     │
│  ● 🛣️ Bache (1)                    │
│  ● 🗑️ Microbasural (2)             │
│                                     │
│  [FloatingActionButton]             │
│  [+] Mi ubicación (GPS)             │
│                                     │
│  [BottomSheet - al tocar marker]    │
│  ┌─────────────────────────────┐   │
│  │  REP-2025-000123            │   │
│  │  💡 Luminaria  ● EnRevisión │   │
│  │  Esquina Av. Principal...   │   │
│  │  150m de ti                 │   │
│  │  [Button] Ver detalle       │   │
│  └─────────────────────────────┘   │
│                                     │
│  [BottomNav]                        │
└─────────────────────────────────────┘
```

---

### 4.3 Flujo Admin (Desktop - Sidebar Layout)

#### 4.3.1 Dashboard Admin
```
┌─────────────────────────────────────────────────────────────┐
│ [Header] Barrio Conectado - Admin        [Usuario] [🔔] [⋮] │
├──────────┬──────────────────────────────────────────────────┤
│          │                                                  │
│ [Side-   │  ┌──────────────────────────────────────────┐   │
│  bar]    │  │  RESUMEN EJECUTIVO                        │   │
│          │  ├──────────┬──────────┬──────────┬─────────┤   │
│  📊      │  │ 📥 127   │ 🔄 23    │ ✅ 89    │ 🗑️ 12   │   │
│  Dashboard│  │ Ingresados│ En Rev. │Completados│Descartados│ │
│          │  ├──────────┼──────────┼──────────┼─────────┤   │
│  📋      │  │ ⚠️ 45    │ ⚡ 67    │ 🟢 38    │ ⏱ 4.2h  │   │
│  Reportes │  │ Alta     │ Media    │ Baja     │ Prom.Resol│ │
│          │  └──────────┴──────────┴──────────┴─────────┘   │
│  🏷️       │                                                  │
│  Categorias│  ┌──────────────────────────────────────────┐   │
│          │  │  REPORTES RECIENTES (últimas 24h)          │   │
│  🏢      │  ├──────────────────────────────────────────┤   │
│  Departam.│  │  [AdminReportCard] REP-2025-00123        │   │
│          │  │    💡 Luminaria ● Ingresado ⚠️ Alta      │   │
│  👥      │  │    María González · Alumbrado Público    │   │
│  Usuarios │  │    Hace 2h · [Asignar] [Ver]             │   │
│          │  ├──────────────────────────────────────────┤   │
│  📈      │  │  [AdminReportCard] REP-2025-00122        │   │
│  Estadíst.│  │    🛣️ Bache ● EnRevisión ⚡ Media       │   │
│          │  │    Carlos López · Obras Viales · Juan P. │   │
│  ⚙️      │  │    Hace 4h · [Confirmar] [Ver]           │   │
│  Config  │  └──────────────────────────────────────────┘   │
│          │                                                  │
│          │  [Button Primary] Ver todos los reportes →     │
│          └──────────────────────────────────────────────────┘
└──────────┴──────────────────────────────────────────────────┘
```

#### 4.3.2 Panel Reportes Admin (Lista con Filtros Avanzados)
```
┌─────────────────────────────────────────────────────────────┐
│ [Header]                                    [Exportar CSV]  │
├──────────┬──────────────────────────────────────────────────┤
│ [Sidebar]│  [FilterBar]                                     │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │ [MultiSelect Estado] [MultiSelect Prioridad]│  │
│          │  │ [MultiSelect Categoría] [MultiSelect Depto]  │  │
│          │  │ [DateRangePicker] [SearchInput "REP-..."]   │  │
│          │  │ [Button] Limpiar filtros   [SortSelect]     │  │
│          │  └────────────────────────────────────────────┘  │
│          ├──────────────────────────────────────────────────┤
│          │  [DataTable - Virtualized]                       │
│          │  ┌────┬─────────┬───────┬──────┬────┬────┬────┐  │
│          │  │#Seg│Categoría│Estado │Pri. │Vecino│Depto│Admin│  │
│          │  ├────┼─────────┼───────┼─────┼────┼────┼────┤  │
│          │  │001 │💡 Lum.  │Ingres.│⚠️Al │María │Alum.│  -  │  │
│          │  │002 │🛣️ Bach. │EnRev. │⚡Me │Carlos│Obras│Juan✓│  │
│          │  │003 │🗑️ Micro │Compl. │🟢Ba │Ana   │Aseo │Pedro│  │
│          │  │... │...      │...    │...  │...  │... │... │  │
│          │  └────┴─────────┴───────┴─────┴────┴────┴────┘  │
│          │  [Pagination] 1-20 de 1,247  [Rows per page: 20] │
└──────────┴──────────────────────────────────────────────────┘
```

#### 4.3.3 Detalle Reporte Admin (Side Panel / Modal)
```
┌─────────────────────────────────────────────────────────────┐
│ [Header] REP-2025-000123                    [×] [⋮]        │
├──────────┬──────────────────────────────────────────────────┤
│ [Sidebar]│                                                  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  [CategoryChip] 💡 Luminaria  ● EnRevisión  │  │
│          │  │  ⚠️ Prioridad: Alta    🏢 Depto: Alumbrado  │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  📸 FOTOS (1)                               │  │
│          │  │  [PhotoGrid] [Foto 1] [+ Agregar]          │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  📝 DESCRIPCIÓN                             │  │
│          │  │  "Lámpara fundida en poste esquina..."      │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  📍 UBICACIÓN                               │  │
│          │  │  Esquina Av. Principal c/ Calle 5           │  │
│          │  │  [MapView Mini]  [-33.0458, -71.5429]      │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  👤 VECINO                                  │  │
│          │  │  María González  ·  maria@ejemplo.cl        │  │
│          │  │  Tel: +56 9 1111 2222                       │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  ⚙️ ACCIONES                                │  │
│          │  │  [Select Estado] [EnRevisión ▼] [Cambiar]  │  │
│          │  │  [Input Nota*] "Iniciando revisión..."     │  │
│          │  │  [Select Prioridad] [Alta ▼] [Actualizar]  │  │
│          │  │  [Button] Reasignar → [Modal Depto/Admin]  │  │
│          │  │  [Button Danger] Descartar                 │  │
│          │  ├────────────────────────────────────────────┤  │
│          │  │  📋 HISTORIAL                               │  │
│          │  │  [Timeline] Ingresado → EnRevisión         │  │
│          │  └────────────────────────────────────────────┘  │
└──────────┴──────────────────────────────────────────────────┘
```

#### 4.3.4 Modal Reasignar
```
┌─────────────────────────────────────┐
│  Reasignar Reporte REP-2025-000123  │
├─────────────────────────────────────┤
│                                     │
│  Departamento destino *             │
│  [Select]                           │
│  ▼ Alumbrado Público      (actual)  │
│    Obras Viales                     │
│    Aseo y Ornato                    │
│    Tránsito y Transporte            │
│    Parques y Jardines               │
│    Drenaje y Alcantarillado         │
│    Obras Públicas General           │
│                                     │
│  Admin específico (opcional)        │
│  [Select Searchable]                │
│  ▼ Juan Pérez (Alumbrado)           │
│    Pedro Soto (Obras Viales)        │
│    Ana López (Aseo y Ornato)        │
│    — Sin asignar (solo departamento)│
│                                     │
│  Notas de reasignación              │
│  [Textarea] "En realidad es bache..."│
│                                     │
│  [Cancelar]      [Reasignar]        │
└─────────────────────────────────────┘
```

#### 4.3.5 Estadísticas / Dashboard Detallado
```
┌─────────────────────────────────────────────────────────────┐
│ [Header] Estadísticas y KPIs                    [Filtro Fecha]│
├──────────┬──────────────────────────────────────────────────┤
│ [Sidebar]│                                                  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  KPIs PRINCIPALES                           │  │
│          │  ├──────────┬──────────┬──────────┬──────────┤  │
│          │  │ 📥 1,247 │ 🔄 234   │ ✅ 892   │ 🗑️ 115   │  │
│          │  │ Total    │ Activos  │ Complet. │ Descart. │  │
│          │  ├──────────┼──────────┼──────────┼──────────┤  │
│          │  │ ⚠️ 412   │ ⚡ 589   │ 🟢 246   │ ⏱ 18.5h │  │
│          │  │ Alta     │ Media    │ Baja     │ Prom.Res │  │
│          │  └──────────┴──────────┴──────────┴──────────┘  │
│          │                                                  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  TENDENCIA 30 DÍAS (Chart.js / Recharts)   │  │
│          │  │  [LineChart] Ingresados vs Completados     │  │
│          │  │  [BarChart] Por categoría                  │  │
│          │  │  [StackedBar] Por estado + prioridad       │  │
│          │  └────────────────────────────────────────────┘  │
│          │                                                  │
│          │  ┌────────────────────────────────────────────┐  │
│          │  │  POR DEPARTAMENTO                           │  │
│          │  │  [Table] Depto | Ingr. | EnRev | Compl. |T.R│  │
│          │  │  Alumbrado   | 234  |  45   |  189   | 12h│  │
│          │  │  Obras Viales| 189  |  67   |  123   | 24h│  │
│          │  │  Aseo y Ornato| 156 |  34   |  145   | 8h │  │
│          │  │  ...                                               │
│          │  └────────────────────────────────────────────┘  │
│          │                                                  │
│          │  [Button] Exportar CSV  [Button] Exportar Excel │
└──────────┴──────────────────────────────────────────────────┘
```

#### 4.3.6 Gestión Categorías / Departamentos
```
┌─────────────────────────────────────────────────────────────┐
│ [Header] Categorías                         [+ Nueva]       │
├──────────┬──────────────────────────────────────────────────┤
│ [Sidebar]│                                                  │
│          │  [DataTable]                                     │
│          │  ┌────┬────────┬────────┬────────┬─────┬─────┐  │
│          │  │Icon│Nombre  │Descrip.│Pri.Base│Depto│Act. │  │
│          │  ├────┼────────┼────────┼────────┼─────┼─────┤  │
│          │  │💡  │Luminar.│Alumbrad│Alta    │Alum.│ ✓   │  │
│          │  │🗑️  │Microbas│Residuos│Media   │Aseo │ ✓   │  │
│          │  │🛣️  │Bache   │Hoyos   │Alta    │Obras│ ✓   │  │
│          │  │... │...     │...     │...     │...  │...  │  │
│          │  └────┴────────┴────────┴────────┴─────┴─────┘  │
│          │                                                  │
│          │  [Modal Nueva Categoría]                         │
│          │  ┌────────────────────────────────────────┐     │
│          │  │ Nombre: [Input]                        │     │
│          │  │ Descripción: [Textarea]                │     │
│          │  │ Prioridad base: [Radio] Alta/Media/Baja│     │
│          │  │ Icono: [IconPicker]                    │     │
│          │  │ Color: [ColorPicker] #FFD600           │     │
│          │  │ Departamento principal: [Select]       │     │
│          │  │ Departamentos adicionales: [MultiSelect]│   │
│          │  │ [Cancelar] [Guardar]                   │     │
│          │  └────────────────────────────────────────┘     │
└──────────┴──────────────────────────────────────────────────┘
```

---

## 5. Responsive Breakpoints

| Componente | Mobile (<640px) | Tablet (640-1024px) | Desktop (>1024px) |
|------------|-----------------|---------------------|-------------------|
| **Header** | Hamburger menu + título centrado | Logo izq, acciones der | Logo izq, breadcrumbs, usuario der |
| **Navegación** | BottomNav (5 items) | Sidebar colapsable + TopNav | Sidebar fija (280px) |
| **Lista Reportes** | Cards apiladas, swipe actions | Grid 2 cols o Cards | DataTable (Admin) / Cards (Vecino) |
| **Detalle Reporte** | Full screen, bottom sheet historial | Side panel 60/40 | Side panel 30/70 o Modal |
| **Mapa** | Full screen, bottom sheet | Split 50/50 lista-mapa | Split 30/70 fijo |
| **Formularios** | Single column, full width | 2 columnas (label + input) | 2-3 columnas, max-width 600px |
| **Modales** | Full screen (bottom sheet) | Centered, max-w-md | Centered, max-w-lg |
| **Dashboard Admin** | Scroll vertical, cards apiladas | Grid 2x2 KPIs | Grid 4x1 KPIs + charts lado a lado |

---

## 6. Estados de UI (State Matrix)

| Componente | Empty | Loading | Error | Success | Disabled |
|------------|-------|---------|-------|---------|----------|
| **Lista Reportes** | EmptyState 📭 | Skeleton cards | Toast + Retry | - | - |
| **Crear Reporte** | - | Button loading | Inline field errors | Toast + Redirect | Submit disabled hasta validación |
| **Mapa** | EmptyState 🗺️ | Skeleton map tiles | Fallback imagen estática | Markers aparecen | - |
| **Login** | - | Button loading | Inline "Credenciales inválidas" | Redirect | - |
| **Filtros Admin** | - | Spinner en tabla | Toast "Error cargando" | Tabla actualizada | - |
| **Exportar** | - | Button loading + progress | Toast "Error generando" | Descarga automática | - |
| **Notificaciones** | EmptyState 🔔 | Skeleton list | - | Badge count actualiza | - |

---

## 7. Accesibilidad (A11y) Checklist por Pantalla

| Pantalla | Landmarks | Headings | Focus Order | ARIA Labels | Contraste | Teclado | Screen Reader |
|----------|-----------|----------|-------------|-------------|-----------|---------|---------------|
| Login | `<main>` | h1 "Iniciar Sesión" | Email → Pass → Check → Btn → OAuth | Inputs labeled | ✅ | Tab/Enter | ✅ |
| Registro | `<main>` | h1 "Crear Cuenta" | Nombre → Email → Tel → Pass → Conf → Check → Btn | ✅ | ✅ | ✅ | ✅ |
| Home Vecino | `<header>`, `<main>`, `<nav>` | h1 "Mis Reportes", h2 "Nuevo Reporte" | FAB → Lista → BottomNav | FAB aria-label="Nuevo reporte" | ✅ | ✅ | ✅ |
| Crear Reporte (steps) | `<main>` | h1 "Crear Reporte (1/4)" | Stepper → Campos → Nav btns | Stepper aria-current="step" | ✅ | ✅ | ✅ |
| Mis Reportes | `<main>` | h1 "Mis Reportes" | Filtros → Lista → Paginación | Chip estado aria-label="Estado: EnRevisión" | ✅ | ✅ | ✅ |
| Detalle Reporte | `<main>` | h1 "REP-2025-000123" | Foto → Desc → Ubic → Historial → Acciones | Timeline aria-live="polite" | ✅ | ✅ | ✅ |
| Mapa | `<main>` | h1 "Mapa de Reportes" | FAB GPS → Markers → BottomSheet | Marker role="button" aria-label="REP-001 Luminaria" | ✅ | ✅ | ✅ |
| Dashboard Admin | `<header>`, `<aside>`, `<main>` | h1 "Dashboard", h2 "KPIs", h2 "Recientes" | Sidebar → KPIs → Tabla → Acciones | DataTable sortable headers | ✅ | ✅ | ✅ |
| Panel Reportes Admin | `<main>` | h1 "Gestión de Reportes" | Filtros → Tabla → Paginación | MultiSelect aria-multiselectable | ✅ | ✅ | ✅ |
| Detalle Admin | `<main>` / `<dialog>` | h1 "REP-2025-000123" | Fotos → Desc → Acciones → Historial | Select estado aria-required="true" | ✅ | ✅ | ✅ |
| Estadísticas | `<main>` | h1 "Estadísticas" | Filtros → KPIs → Gráficos → Tablas | Charts: role="img" aria-label="Gráfico tendencia 30 días" | ✅ | ✅ | ✅ |

---

## 8. Assets y Recursos Necesarios

| Asset | Formato | Tamaños | Ubicación |
|-------|---------|---------|-----------|
| Logo Barrio Conectado | SVG + PNG | 32, 64, 128, 256, 512px | `/public/assets/logo/` |
| Favicon | ICO + PNG | 16, 32, 48, 64px | `/public/favicon.ico` |
| Iconos Categorías | SVG | 24x24px (outline) | `/public/assets/icons/categorias/` |
| Ilustraciones Empty States | SVG | 200x200, 300x300px | `/public/assets/illustrations/` |
| Placeholder Foto Reporte | SVG | 400x300px | `/public/assets/placeholders/` |
| Mapa Base Tiles | Vector (MapLibre) | - | CDN / Self-hosted |
| Fuentes Inter | WOFF2 | Variable font | `/public/fonts/` |

---

## 9. Próximos Pasos Implementación UI

1. **Setup Design System**: Storybook + Tailwind CSS config con tokens
2. **Component Library**: Implementar átomos/moléculas (Button, Input, Card, Badge, Modal, MapView)
3. **Layouts**: AuthLayout, VecinoLayout (BottomNav), AdminLayout (Sidebar)
4. **Páginas Core**: Login, Registro, Home, CrearReporte (Wizard), MisReportes, DetalleReporte, Mapa
5. **Admin Pages**: Dashboard, ReportesTable, ReporteDetail, Estadisticas, Categorias, Departamentos, Usuarios
6. **Integración API**: React Query / TanStack Query + Axios interceptors (auth, errors, loading)
7. **Estado Global**: Zustand / Redux Toolkit (auth, user, filtros, notificaciones)
8. **Testing UI**: Storybook visual regression (Chromatic), Playwright E2E
9. **Accesibilidad**: axe-core en CI, pruebas manuales con NVDA/VoiceOver
10. **Performance**: Bundle analyzer, code splitting, lazy loading, image optimization

---

*Fin del documento — Wireframes y Mockups UI v1.0*