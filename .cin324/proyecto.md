# Estado del proyecto — generación de la aplicación

## Proyecto
- Nombre: Barrio Conectado
- Repositorio de documentación: esta carpeta (raíz del repositorio)
- Última auditoría: 2026-11-23 — resultado: con supuestos

## Mapa de artefactos (rutas detectadas)
| Artefacto | Ruta(s) | Estado |
|-----------|---------|--------|
| BPMN AS-IS | `01-proceso-as-is.md`, `diagramas/as-is.drawio.png` | completo |
| BPMN TO-BE | `02-rediseno-to-be.md`, `diagramas/to-be.drawio.png` | completo |
| Historias de usuario | `04-historias-usuario.md` (HU-01…HU-08) | completo |
| Criterios Gherkin | `07-criterios-aceptacion.md` (HU-01…HU-04) | parcial (HU-05…HU-08 sin Gherkin) |
| Modelo de dominio | `diagramas/modelo-dominio.puml`, `08-modelo-dominio.md` | completo |
| Casos de uso | `09-casos-de-uso.md`, `diagramas/casos-de-uso.puml` | parcial (la tabla lista CU-01…CU-04; el `.puml` incluye CU-01…CU-08) |
| Diagramas de estado | `11-diagramas-estado.md`, `diagramas/est-01.puml`, `diagramas/est-02.puml` | completo |
| Diagramas de secuencia | `10-diagramas-secuencia.md`, `diagramas/dss-01.puml`, `diagramas/dss-02.puml` | completo |
| Requisitos y atributos de calidad | `03-requisitos.md`, `06-atributos-calidad.md` | completo |

## Supuestos acordados (por elementos faltantes o dudosos)
- 2026-11-23, confirmado por el estudiante: el estado inicial del reporte es **«Recibido»** (alineado con el modelo de dominio y EST-01; se descarta «Ingresado» del Gherkin de HU-01).
- 2026-11-23, confirmado por el estudiante: se elimina «En proceso»; un reporte solo puede completarse desde **«EnRevisión»** (según EST-01).
- 2026-11-23, confirmado por el estudiante: la priorización automática de HU-06 usa `urgenciaBase` de la categoría (alta→Alta, media→Media, baja→Baja); el administrador puede ajustarla manualmente.
- 2026-11-23, confirmado por el estudiante: el texto de `06-atributos-calidad.md` sobre «botón de pánico», «mapa de incidentes», «contactos de emergencia» y «delincuencia» es heredado de otro proyecto; se ignora y no se implementa (los no funcionales no se implementan).
- 2026-11-23, confirmado por el estudiante: para esta Entrega 3 se implementan solo HU-01, HU-02, HU-03 y HU-04, en ese orden (son las que tienen Gherkin y caso de uso). HU-05…HU-08 quedan pendientes.
- 2026-11-23, observación de auditoría: los BPMN solo están como PNG; no hay `.bpmn`/`.drawio` editable. No bloquea la generación.

## Stack (se define una sola vez)
- Lenguaje y framework: Python 3.12 + FastAPI + Jinja2
- Base de datos: SQLite — archivo `data/app.db` (biblioteca estándar `sqlite3`)
- Pruebas: pytest + TestClient de FastAPI (httpx)
- Cómo instalar: `python -m venv .venv` → `.venv\Scripts\activate` → `pip install -r requirements.txt`
- Cómo ejecutar: `python -m app.db.seed` → `uvicorn app.main:app --reload` — URL: http://localhost:8000
- Cómo probar: `pytest`
- Nota de entorno (2026-11-23): Python 3.12.10 y OpenSpec 2.1.1 instalados. En sesiones nuevas `python` resuelve a `C:\Users\jesus\AppData\Local\Programs\Python\Python312\python.exe`; si el alias de Microsoft Store interfiere, usar esa ruta completa.

## Historias
| Historia | Estado | Cambio de OpenSpec | Fecha | Observaciones |
|----------|--------|--------------------|-------|----------------|
| HU-01 | hecha | `hu-01-registrar-reporte` → archivado como `2026-11-23-hu-01-registrar-reporte` | 2026-11-23 | 15/15 tareas; 18 pruebas; validado por el estudiante sin observaciones |
| HU-02 | en curso | — | 2026-11-23 | Validación de la historia en curso |
| HU-03 | pendiente | — | — | Filtrar reportes para asignar personal |
| HU-04 | pendiente | — | — | Completar reporte con nota de resolución |
| HU-05 | pendiente | — | — | Sin Gherkin; fuera de esta entrega |
| HU-06 | pendiente | — | — | Sin Gherkin/CU; fuera de esta entrega |
| HU-07 | pendiente | — | — | Sin Gherkin/CU; fuera de esta entrega |
| HU-08 | pendiente | — | — | Sin Gherkin/CU; fuera de esta entrega |

## Validaciones
| Historia | Informe | Estado | Fecha |
|----------|---------|--------|-------|
| HU-01 | — | verificado en el sistema, sin observaciones | 2026-11-23 |

## Cambios posteriores
| Cambio | Historia afectada | Motivo | Fecha |
|--------|-------------------|--------|-------|
| — | — | — | — |
