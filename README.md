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
| HU-02 — Consultar mis reportes | Pendiente |
| HU-03 — Filtrar reportes para asignar personal | Pendiente |
| HU-04 — Completar un reporte con nota de resolución | Pendiente |

La aplicación es web, sencilla y sin autenticación real: se usa un **selector de usuario de demostración** (Vecino / Administrador). Los sistemas externos se simulan mediante adaptadores; por ahora, el **Servicio de mapas y geolocalización**.

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

- **Departamentos:** Alumbrado, Aseo, Obras.
- **Categorías:** Luminaria (urgencia media → Alumbrado), Microbasural (alta → Aseo), Bache (alta → Obras).
- **Usuarios de demostración:** Vecino Demo y Administrador Demo.

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

La suite incluye una prueba por cada escenario de la especificación de HU-01 (registro exitoso, datos incompletos, ubicación válida, ubicación no válida y clasificación automática), además de pruebas de migraciones, conexión, número de seguimiento, adaptador de mapas y servicio de registro.

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

## Notas de la Entrega 3

- Cada historia se implementa en un cambio de OpenSpec (`openspec/changes/hu-xx-...`), revisado antes de escribir código.
- Los requisitos no funcionales (RP-09, RP-10, RP-11) se leen pero no se implementan.
- HU-02, HU-03 y HU-04 se implementarán en los siguientes ciclos, en ese orden.
