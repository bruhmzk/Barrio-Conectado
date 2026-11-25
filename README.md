# Barrio Conectado — Sistema de Alerta y Coordinación Vecinal

**Barrio Conectado** es una plataforma de gestión comunitaria para canalizar los reportes de los vecinos sobre problemas de la vía pública (luminarias rotas, microbasurales, baches) hacia el municipio, con trazabilidad y priorización.

Este repositorio contiene la documentación de Ingeniería de Requisitos (Entregas 1 y 2) y la aplicación web generada historia por historia con OpenSpec (Entrega 3).

---

## Índice de documentación del proyecto

| # | Documento |
| :-: | :--- |
| **01** | [01-proceso-as-is.md](./01-proceso-as-is.md) |
| **02** | [02-rediseno-to-be.md](./02-rediseno-to-be.md) |
| **03** | [03-requisitos.md](./03-requisitos.md) |
| **04** | [04-historias-usuario.md](./04-historias-usuario.md) |
| **05** | [05-elicitacion.md](./05-elicitacion.md) |
| **06** | [06-atributos-calidad.md](./06-atributos-calidad.md) |
| **07** | [07-criterios-aceptacion.md](./07-criterios-aceptacion.md) |
| **08** | [08-modelo-dominio.md](./08-modelo-dominio.md) |
| **09** | [09-casos-de-uso.md](./09-casos-de-uso.md) |
| **10** | [10-diagramas-secuencia.md](./10-diagramas-secuencia.md) |
| **11** | [11-diagramas-estado.md](./11-diagramas-estado.md) |
| **12** | [12-trazabilidad.md](./12-trazabilidad.md) |

Las fichas confirmadas de cada historia están en [`.cin324/historias/`](./.cin324/historias/) y los cambios de OpenSpec en [`openspec/changes/`](./openspec/changes/).

---

## Aplicación generada

Estado actual (Entrega 3):

| Historia | Estado |
|---|---|
| HU-01 — Registrar un reporte | Implementada (cambio `hu-01-registrar-reporte`) |
| HU-02 — Consultar mis reportes | Implementada (cambio `hu-02-consultar-mis-reportes`) |
| HU-03 — Filtrar reportes para asignar personal | Implementada (cambio `hu-03-filtrar-reportes`) |
| HU-04 — Completar un reporte con nota de resolución | Implementada (cambio `hu-04-completar-reporte`) |
| HU-09 — Registrar reporte de emergencia | Implementada (cambio `hu-09-registrar-emergencia`) |

La aplicación es web, sencilla y sin autenticación real: se usa un **selector de usuario de demostración** (Vecino Demo, Vecino Demo 2, Vecina Emergencias, Administrador Demo y Gestor Emergencias Demo). Los sistemas externos se simulan mediante adaptadores: el **Servicio de mapas y geolocalización** y el **Sistema de Notificaciones**.

El panel de administración está en **GET /administracion/reportes** y requiere elegir **Administrador Demo** en el selector. Muestra número de seguimiento, categoría, prioridad, estado, departamento asignado y fecha de registro. Permite filtrar por **categoría**, **prioridad** (Alta / Media / Baja) y **estado** (Recibido / En revisión / Completado / Descartado); los filtros se combinan con **AND** y se conservan al aplicarlos. Sin filtros se muestran todos los reportes. La lista se ordena de **Alta → Media → Baja** y, en empate, por fecha de registro más reciente. Si no hay coincidencias, aparece «No hay resultados. Cambia los criterios de búsqueda» y el formulario sigue visible. La columna **Acción** muestra el enlace **Completar** solo para los reportes en **En revisión**.

### Stack

- **Lenguaje:** Python 3.12
- **Servidor web:** FastAPI + Uvicorn
- **Plantillas:** Jinja2 (renderizado en el servidor)
- **Base de datos:** SQLite (`data/app.db`), con la biblioteca estándar `sqlite3`
- **Pruebas:** pytest + `TestClient` de FastAPI

### Requisitos

- Python 3.11 o superior (probado con 3.12).
- En Windows, si el comando `python` abre la Microsoft Store, usa el intérprete instalado en
  `C:\Users\<usuario>\AppData\Local\Programs\Python\Python312\python.exe` o desactiva el alias
  «python.exe» en Configuración → Aplicaciones → Configuración avanzada de aplicaciones → Alias de ejecución de aplicaciones.

### Instalar

Desde la raíz del repositorio, en PowerShell:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Si PowerShell bloquea la activación, ejecuta una vez:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Crear la base y cargar datos de ejemplo

```powershell
python -m app.db.seed
```

Esto crea `data/app.db`, aplica las migraciones y carga:

- **Departamentos:** Alumbrado, Aseo, Obras y Gestor de emergencias.
- **Categorías:** Luminaria (urgencia media → Alumbrado), Microbasural (alta → Aseo), Bache (alta → Obras), Incendio, Emergencia médica y Accidente (las tres últimas con `esEmergencia` → Gestor de emergencias).
- **Usuarios de demostración:** Vecino Demo, Vecino Demo 2, Vecina Emergencias, Administrador Demo y Gestor Emergencias Demo (rol `gestor_emergencias`).
- **Reportes de ejemplo para HU-02:**
  - `BC-2026-000101` — *Vecino Demo*, Luminaria, **Recibido**, sin cambios de estado.
  - `BC-2026-000102` — *Vecino Demo*, Microbasural, **En revisión**, con el cambio `Recibido → En revisión` del `2026-11-20T10:15:00` registrado por *Administrador Demo*.
  - `BC-2026-000103` — *Vecino Demo 2*, Bache, **Recibido** (sirve para comprobar que un vecino no ve los reportes del otro).
- **Emergencias de ejemplo para HU-09:**
  - `BC-2026-000104` — *Vecina Emergencias*, Incendio, **Recibido**, prioridad **Máxima**, derivada al Gestor de emergencias.
  - `BC-2026-000105` — *Vecina Emergencias*, Accidente, **En atención por Gestor**, prioridad **Máxima**, con el cambio `Recibido → En atención por Gestor` registrado por *Gestor Emergencias Demo*.

El comando es idempotente: puedes ejecutarlo varias veces sin duplicar datos.

### Ejecutar

```powershell
uvicorn app.main:app --reload
```

Abre **http://localhost:8000**.

### Probar

```powershell
pytest
```

La suite incluye una prueba por cada escenario de HU-01 (registro exitoso, datos incompletos, ubicación válida, ubicación no válida y clasificación automática) y de HU-02 (lista de reportes propios, vecino sin reportes, historial de cambios de estado, más las variantes de reporte ajeno, reporte sin cambios y sin usuario seleccionado), además de pruebas de migraciones, conexión, número de seguimiento, adaptador de mapas y servicio de registro. También incluye las pruebas del cambio HU-03: consulta ordenada y filtrada, control del administrador de demostración y una prueba por cada escenario Gherkin. El cambio HU-04 aporta pruebas del adaptador de notificaciones, de la transición `completar_reporte`, del panel de administración y de los cuatro escenarios Gherkin (cierre exitoso, nota obligatoria, estado inválido y notificaciones no disponibles). El cambio HU-09 aporta una prueba por cada uno de los cinco escenarios Gherkin de emergencia, las pruebas de la migración `003_emergencias.sql`, del servicio de registro, del dominio y de la bandeja y toma de conocimiento del Gestor de emergencias.

> En Windows usa `& ".venv\Scripts\python.exe" -m pytest` si `pytest` no está en el PATH.

---

## Recorrido manual de HU-01

1. Abre http://localhost:8000.
2. En la cabecera, elige **Vecino Demo** en «Usuario de demostración». La página se recarga con la sesión de demostración.
3. Pulsa **Registrar un reporte**.
4. Completa:
   - **Categoría:** Bache.
   - **Descripción:** «Bache profundo en la esquina».
   - **Fotografía:** selecciona cualquier archivo de imagen.
   - **Latitud:** `-33.45` y **Longitud:** `-70.66`.
5. Pulsa **Enviar reporte**. Deberías ver la confirmación con un número de seguimiento `BC-AAAA-XXXXXX`, estado **Recibido**, prioridad **Alta** y departamento **Obras**.
6. Para probar los errores:
   - Envía el formulario con campos vacíos: el sistema rechaza el registro e indica los datos obligatorios que faltan.
   - Usa una latitud como `120`: el servicio de mapas simulado rechaza la ubicación y solicita una nueva.

> La fotografía se simula: se guarda solo el nombre del archivo, no el contenido de la imagen.

---

## Recorrido manual de HU-02

1. Abre http://localhost:8000 (después de crear la base y ejecutar la aplicación con los comandos anteriores).
2. En la cabecera están los enlaces **Inicio**, **Mis reportes** y **Registrar reporte**.

### Escenario 1 — Visualización exitosa del historial de reportes propios

1. Elige **Vecino Demo (vecino)** en «Usuario de demostración».
2. Pulsa **Mis reportes**. Deberías ver solo `BC-2026-000102` (**En revisión**, Microbasural) y `BC-2026-000101` (**Recibido**, Luminaria), con su fecha y categoría.
3. Confirma que **no aparece** `BC-2026-000103`, que pertenece a *Vecino Demo 2*.

### Escenario 2 — Consulta por un vecino sin reportes previos

1. Prepara un vecino vacío (no hay alta de usuarios en la interfaz):

   ```powershell
   python -c "import sqlite3; c=sqlite3.connect('data/app.db'); c.execute('INSERT OR IGNORE INTO usuarios (nombre, medio_contacto, rol) VALUES (?, ?, ?)', ('Vecino sin reportes', 'vacio@demo.cl', 'vecino')); c.commit()"
   ```

2. Recarga la página, elige **Vecino sin reportes (vecino)** y pulsa **Mis reportes**.
3. Deberías ver el mensaje «No existen reportes asociados a tu cuenta».

### Escenario 3 — Historial de cambios de estado de un reporte

1. Elige **Vecino Demo**, entra a **Mis reportes** y pulsa `BC-2026-000102`.
2. Deberías ver el estado actual **En revisión** y el historial con fecha `2026-11-20T10:15:00`, estado anterior **Recibido**, estado nuevo **En revisión** y nota `—` (vacía).
3. Vuelve a **Mis reportes** y abre `BC-2026-000101`: el estado actual es **Recibido** y aparece «Sin cambios de estado registrados».
4. Escribe directamente `http://localhost:8000/reportes/BC-2026-000103` con *Vecino Demo* seleccionado: el sistema responde **Reporte no encontrado** (404).
5. Sin usuario seleccionado (opción «— Selecciona —»), **Mis reportes** pide elegir un vecino de demostración antes de continuar.

> Consultar el detalle no modifica el estado del reporte: HU-02 es solo lectura.

---

## Recorrido manual de HU-03

Abre http://localhost:8000 y elige **Administrador Demo (administrador)** en el selector de la cabecera. En el menú aparece **Panel de administración**; también puedes entrar directamente a `GET /administracion/reportes`.

### Escenario 1 — Filtrado de reportes por categoría y alta prioridad

1. En el panel, selecciona **Microbasural** y **Alta**; deja **Estado** vacío.
2. Pulsa **Filtrar**.
3. Debería aparecer solo `BC-2026-000102` (**Microbasural**, **Alta**, **En revisión**, **Aseo**).

### Escenario 2 — Filtrado sin resultados coincidentes

1. Selecciona **Luminaria**, **Alta** y **Completado**.
2. Pulsa **Filtrar**.
3. Debería aparecer «No hay resultados. Cambia los criterios de búsqueda»; los tres filtros siguen seleccionados y puedes modificarlos.

### Escenario 3 — Consulta combinada de categoría, prioridad y estado

1. Selecciona **Bache**, **Alta** y **Recibido**.
2. Pulsa **Filtrar**.
3. Debería aparecer solo `BC-2026-000103` con **Obras**; los tres valores siguen seleccionados.

### Escenario 4 — Visualización del departamento asignado y del estado en la lista

1. Pulsa **Limpiar filtros**.
2. Deberían aparecer los tres reportes en este orden: `BC-2026-000103` (Alta/Obras/Recibido), `BC-2026-000102` (Alta/Aseo/En revisión) y `BC-2026-000101` (Media/Alumbrado/Recibido).
3. Comprueba las columnas **Departamento** y **Estado**; «En revisión» se muestra tal cual, sin cambiar el estado de ningún reporte.

> Si no hay usuario o está seleccionado un vecino, el panel pide elegir un administrador de demostración. HU-03 es de solo lectura: no asigna personal ni cambia estados.

---

## Recorrido manual de HU-04

Abre http://localhost:8000 y elige **Administrador Demo (administrador)**. En **Panel de administración**, la fila de `BC-2026-000102` muestra el enlace **Completar** porque está **En revisión**. También puedes entrar directamente a `GET /administracion/reportes/BC-2026-000102/completar`.

La **nota de resolución** es obligatoria: se recorta antes de guardarse y no se permite una nota vacía o con solo espacios. El cierre solo se permite desde **En revisión** y escribe `Completado` en `reportes.estado` junto con un `CambioEstado` con la nota y el administrador que realizó la acción. El **Sistema de Notificaciones** se simula: muestra «aviso aceptado» o «aviso pendiente de envío» en la confirmación; para probar la caída, inicia la aplicación con `CIN324_NOTIFICACIONES_DISPONIBLES=0`. No se crea ninguna tabla `Notificación` ni `notificaciones`.

### Escenario 1 — Cierre exitoso de un reporte con justificación

1. Con **Administrador Demo**, pulsa **Completar** en `BC-2026-000102`.
2. Escribe «Microbasural retirado y verificado» en **Nota de resolución** y pulsa **Completar reporte**.
3. Deberías ver el reporte en estado **Completado** y el mensaje del aviso simulado: «aviso aceptado».
4. Cambia a **Vecino Demo**, entra a **Mis reportes** y abre `BC-2026-000102`: el estado actual es **Completado** y el historial muestra la nota registrada.

### Escenario 2 — Intento de cierre sin nota de resolución

1. Si ya completaste el reporte, vuelve a crear la base con `python -m app.db.seed` para recuperar `BC-2026-000102` en **En revisión**.
2. Con **Administrador Demo**, abre el formulario de `BC-2026-000102`.
3. Deja el campo **Nota de resolución** vacío o con espacios y pulsa **Completar reporte**.
4. Deberías ver «La nota de resolución es obligatoria»; el reporte sigue **En revisión** y no aparece un `CambioEstado` nuevo.

### Escenario 3 — Cierre de un reporte que no está En revisión

1. Con **Administrador Demo**, entra directamente a `/administracion/reportes/BC-2026-000101/completar`.
2. Escribe cualquier nota y pulsa **Completar reporte**.
3. Deberías ver «El reporte no está En revisión»; `BC-2026-000101` sigue **Recibido** y sin cambios de estado.

### Escenario 4 — Cierre con notificaciones no disponibles

1. Detén el servidor y vuelve a iniciarlo con la variable de entorno `CIN324_NOTIFICACIONES_DISPONIBLES=0`.
2. Vuelve a crear la base con `python -m app.db.seed` si el reporte ya estaba completado.
3. Con **Administrador Demo**, completa `BC-2026-000102` con una nota cualquiera.
4. El cierre queda registrado como **Completado** y la confirmación indica «aviso pendiente de envío». La base sigue sin tabla `notificaciones`.

> Si no hay usuario seleccionado o está elegido un vecino, la pantalla de cierre pide «Selecciona un administrador de demostración para completar el reporte» y no escribe en la base.

---

## Recorrido manual de HU-09

El apartado **Emergencia** está en el menú y como botón rojo en la pantalla de inicio: un toque abre el formulario y otro lo envía. Cualquier usuario de demostración puede reportar una emergencia; solo **Gestor Emergencias Demo** ve la bandeja y puede tomar conocimiento. La ubicación viene precargada con coordenadas de demostración y se valida con el Servicio de mapas simulado.

### Escenario 1 — Registro exitoso de una emergencia con interfaz simplificada

1. Elige **Vecino Demo** y pulsa **Emergencia** en Inicio.
2. El formulario solo pide **tipo** y **ubicación** (precargada); la descripción es opcional. Elige **Incendio** y pulsa **Enviar emergencia**.
3. Deberías ver la confirmación con el número de seguimiento, estado **Recibido**, prioridad **Máxima**, departamento **Gestor de emergencias** y el mensaje de que el gestor fue notificado.
4. Cambia a **Gestor Emergencias Demo** y abre **Bandeja de emergencias**: la nueva emergencia aparece al inicio, en estado **Recibido**.

### Escenario 2 — Acceso directo desde el menú principal

1. En la pantalla principal, el botón **Emergencia** y el enlace del menú llevan directamente a `/emergencias/nueva`, sin pasos intermedios.
2. El formulario no ofrece las categorías normales (Luminaria, Microbasural, Bache) ni pide fotografía: solo los datos mínimos.

### Escenario 3 — Datos mínimos incompletos

1. En el formulario de emergencia deja el tipo sin seleccionar y borra la latitud.
2. Pulsa **Enviar emergencia**.
3. Deberías ver «Falta el tipo de emergencia.» y «Falta la ubicación.»; no se crea ningún reporte.

### Escenario 4 — Ubicación no válida

1. Selecciona un tipo y escribe `999` en latitud.
2. Pulsa **Enviar emergencia**.
3. Deberías ver «La ubicación no es válida. Ingresa una nueva ubicación.» y el reporte no se registra.

### Escenario 5 — Derivación con notificaciones no disponibles

1. Detén el servidor y vuelve a iniciarlo con `CIN324_NOTIFICACIONES_DISPONIBLES=0`.
2. Registra una emergencia con datos completos.
3. La confirmación indica «El aviso al Gestor de emergencias quedó pendiente de envío»; la emergencia igual queda derivada y en la bandeja del gestor aparece la columna **Aviso** como «Pendiente de envío».

### Toma de conocimiento del Gestor

1. Elige **Gestor Emergencias Demo** y abre **Bandeja de emergencias**.
2. Abre `BC-2026-000104` (Incendio, **Recibido**) y pulsa **Tomar conocimiento**.
3. El estado pasa a **En atención por Gestor** y el historial muestra el cambio con la fecha y el gestor responsable.
4. Si lo intentas sobre `BC-2026-000105` (ya en atención), verás «La emergencia no está en estado Recibido» y no se registra un cambio nuevo.

> El panel de administración también muestra las emergencias: la prioridad **Máxima** aparece primero en el orden y las nuevas opciones se agregan a los filtros de prioridad y estado.

---

## Notas de la Entrega 3

- Cada historia se implementa en un cambio de OpenSpec (`openspec/changes/hu-xx-...`), revisado antes de escribir código.
- Los requisitos no funcionales (RP-09, RP-10, RP-11) se leen pero no se implementan.
- Las cuatro historias están implementadas; HU-04 quedó registrada en el cambio `hu-04-completar-reporte`, archivado el 2026-11-23, y validada por el estudiante sin observaciones.
