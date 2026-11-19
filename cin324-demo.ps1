<#
.SYNOPSIS
    Simula el flujo de skills del profesor (cin324-generar-app, cin324-auditar-repositorio, etc.)
    para demostración en clase sin necesidad de OpenCode/OpenSpec CLI.

.DESCRIPTION
    Este script demuestra el flujo completo que el profesor espera:
    1. Auditoría del repositorio (cin324-auditar-repositorio)
    2. Validación de historia (cin324-validar-historia)
    3. Especificación OpenSpec (propuesta)
    4. Generación de código
    5. Validación del sistema

.NOTAS
    - Solo para demostración - no modifica archivos reales
    - Muestra qué haría cada skill con los artefactos actuales
#>

param(
    [string]$Command = "help",
    [string]$Historia = "",
    [string]$Stack = "typescript"
)

$RepoRoot = "$PSScriptRoot"

function Show-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  CIN 324 - Skills Demo Runner (Simulación Profesor)             ║" -ForegroundColor Cyan
    Write-Host "║  Barrio Conectado - Entrega 3                                   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Show-Banner
    Write-Host "Uso: .\cin324-demo.ps1 <comando> [opciones]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Comandos disponibles:" -ForegroundColor Green
    Write-Host "  auditoria          - Simula cin324-auditar-repositorio (evalúa completitud)"
    Write-Host "  validar-historia   - Simula cin324-validar-historia (5 preguntas HU-xx)"
    Write-Host "  proponer           - Simula /opsx-propose (genera proposal.md, specs/, design.md, tasks.md)"
    Write-Host "  generar            - Simula /opsx-apply (genera código TypeScript/Python)"
    Write-Host "  validar-sistema    - Simula cin324-validar-sistema (feedback → cambios en artefactos)"
    Write-Host "  estado             - Muestra estado del proyecto (.cin324/proyecto.md)"
    Write-Host "  demo               - Ejecuta run-demo.ps1 (levanta la app)"
    Write-Host "  help               - Muestra esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Cyan
    Write-Host "  .\cin324-demo.ps1 auditoria" -ForegroundColor Gray
    Write-Host "  .\cin324-demo.ps1 validar-historia HU-01" -ForegroundColor Gray
    Write-Host "  .\cin324-demo.ps1 proponer HU-01" -ForegroundColor Gray
    Write-Host "  .\cin324-demo.ps1 generar HU-01" -ForegroundColor Gray
    Write-Host "  .\cin324-demo.ps1 demo" -ForegroundColor Gray
}

function Run-Auditoria {
    Show-Banner
    Write-Host "🔍 EJECUTANDO: cin324-auditar-repositorio" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    $artefactos = @(
        @{Nombre="BPMN AS-IS"; Estado="✅ Completo"; Evidencia="01-proceso-as-is.md + diagramas/as-is.drawio.png"; Importancia="Contexto"},
        @{Nombre="BPMN TO-BE"; Estado="✅ Completo"; Evidencia="02-rediseno-to-be.md + diagramas/to-be.drawio.png + tabla actividades"; Importancia="Contexto"},
        @{Nombre="Historias Usuario (8)"; Estado="✅ Completo"; Evidencia="04-historias-usuario.md (HU-01..HU-08)"; Importancia="BLOQUEANTE"},
        @{Nombre="Criterios Gherkin (8)"; Estado="✅ Completo"; Evidencia="07-criterios-aceptacion.md (todas con Dado/Cuando/Entonces)"; Importancia="BLOQUEANTE"},
        @{Nombre="Modelo Dominio"; Estado="✅ Completo"; Evidencia="08-modelo-dominio.md + diagramas/modelo-dominio.puml (9 entidades)"; Importancia="BLOQUEANTE"},
        @{Nombre="Casos de Uso (9)"; Estado="✅ Completo"; Evidencia="09-casos-de-uso.md (CU-01..CU-09) + diagrama"; Importancia="Importante"},
        @{Nombre="Diagramas Estado (2)"; Estado="✅ Completo"; Evidencia="11-diagramas-estado.md (EST-01 Reporte, EST-02 Notificación)"; Importancia="Importante"},
        @{Nombre="Diagramas Secuencia (6)"; Estado="✅ Completo"; Evidencia="10-diagramas-secuencia.md (DSS-01..DSS-06) + fuentes .puml"; Importancia="Importante"},
        @{Nombre="Requisitos (12+4+1)"; Estado="✅ Completo"; Evidencia="03-requisitos.md (RP-01..RP-12, RY-01..RY-04, RP-12 derivado)"; Importancia="Contexto"},
        @{Nombre="Atributos Calidad (9)"; Estado="✅ Completo"; Evidencia="06-atributos-calidad.md (ISO 25010 priorizados)"; Importancia="Contexto"},
        @{Nombre="Trazabilidad"; Estado="✅ Completo"; Evidencia="12-trazabilidad.md (matriz bidireccional)"; Importancia="Contexto"},
        @{Nombre="Arquitectura C4"; Estado="✅ Completo"; Evidencia="13-arquitectura.md (4 niveles + 8 ADRs)"; Importancia="Entrega 3"},
        @{Nombre="Base Datos + Migraciones"; Estado="✅ Completo"; Evidencia="14-base-datos.md + migrations/V001-V007__*.sql"; Importancia="Entrega 3"},
        @{Nombre="API OpenAPI 3.0"; Estado="✅ Completo"; Evidencia="15-api-openapi.md"; Importancia="Entrega 3"},
        @{Nombre="Plan Pruebas"; Estado="✅ Completo"; Evidencia="16-plan-pruebas.md (100+ Gherkin + CI/CD)"; Importancia="Entrega 3"},
        @{Nombre="Wireframes"; Estado="✅ Completo"; Evidencia="17-wireframes.md (Design System + todas pantallas)"; Importancia="Entrega 3"},
        @{Nombre="Plan Implementación"; Estado="✅ Completo"; Evidencia="18-plan-implementacion.md (123 historias, 2 sprints, DoD/DoR)"; Importancia="Entrega 3"}
    )

    Write-Host "INFORME DE AUDITORÍA" -ForegroundColor Yellow
    Write-Host "=====================" -ForegroundColor Yellow
    Write-Host ""

    $bloqueantes = 0
    $importantes = 0
    $contexto = 0
    $entrega3 = 0

    foreach ($a in $artefactos) {
        $icon = if ($a.Estado -like "✅*") { "✅" } elseif ($a.Estado -like "⚠️*") { "⚠️" } else { "❌" }
        $color = if ($a.Importancia -eq "BLOQUEANTE") { "Red" } elseif ($a.Importancia -eq "Importante") { "Yellow" } else { "Green" }

        Write-Host "$icon $($a.Nombre) [$($a.Importancia)]" -ForegroundColor $color
        Write-Host "   Evidencia: $($a.Evidencia)" -ForegroundColor Gray

        switch ($a.Importancia) {
            "BLOQUEANTE" { $bloqueantes++ }
            "Importante" { $importantes++ }
            "Contexto" { $contexto++ }
            "Entrega 3" { $entrega3++ }
        }
    }

    Write-Host ""
    Write-Host "RESUMEN:" -ForegroundColor Yellow
    Write-Host "  Bloqueantes: $bloqueantes/3  ✅" -ForegroundColor Green
    Write-Host "  Importantes: $importantes/3  ✅" -ForegroundColor Green
    Write-Host "  Contexto:    $contexto/4  ✅" -ForegroundColor Green
    Write-Host "  Entrega 3:   $entrega3/6  ✅" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 VEREDICTO: SÍ - Sin bloqueantes. Documentación completa para generar código." -ForegroundColor Green
    Write-Host "   Puede continuar con: validar-historia HU-01" -ForegroundColor Cyan
}

function Run-ValidarHistoria {
    param($HU)

    if (-not $HU) {
        Write-Host "❌ Debe especificar HU-xx. Ej: .\cin324-demo.ps1 validar-historia HU-01" -ForegroundColor Red
        return
    }

    Show-Banner
    Write-Host "🔍 EJECUTANDO: cin324-validar-historia $HU" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    # Simular lectura de artefactos para HU-01
    if ($HU -eq "HU-01") {
        Write-Host "📋 LEYENDO ARTEFACTOS PARA HU-01..." -ForegroundColor Yellow
        Write-Host "   • Historia: 04-historias-usuario.md → HU-01" -ForegroundColor Gray
        Write-Host "   • Gherkin:  07-criterios-aceptacion.md → 2 escenarios" -ForegroundColor Gray
        Write-Host "   • TO-BE:    02-rediseno-to-be.md → Actividad 'Reporta el problema en la app'" -ForegroundColor Gray
        Write-Host "   • CU:       09-casos-de-uso.md → CU-01 'Registrar un reporte de incidente'" -ForegroundColor Gray
        Write-Host "   • Dominio:  08-modelo-dominio.md → Usuario, Reporte, Categoría, Ubicación, Fotografía" -ForegroundColor Gray
        Write-Host "   • Estado:   11-diagramas-estado.md → EST-01 (Recibido → EnRevisión → Completado/Descartado)" -ForegroundColor Gray
        Write-Host "   • Secuencia: 10-diagramas-secuencia.md → DSS-01 (validación geolocalización)" -ForegroundColor Gray
        Write-Host "   • Requisitos: RP-01, RP-02, RP-04, RP-05, RP-09" -ForegroundColor Gray
        Write-Host ""

        Write-Host "❓ LAS 5 PREGUNTAS DE CONFIRMACIÓN:" -ForegroundColor Yellow
        Write-Host ""

        # Pregunta 1
        Write-Host "1️⃣  ¿Con qué actividad del TO-BE se relaciona?" -ForegroundColor Cyan
        Write-Host "   📖 Encontrado: 'Reporta el problema en la app' + 'Registra el reporte automáticamente'" -ForegroundColor Gray
        Write-Host "   💡 Propuesta: Esta HU cubre el registro inicial del reporte por el vecino (foto + GPS + descripción + categoría)." -ForegroundColor Green
        Write-Host "   ❓ ¿Confirmas? (s/n): " -NoNewline
        $r = Read-Host
        if ($r -ne 's') { Write-Host "   → Marcado como 'corregir: ...'" -ForegroundColor Yellow }

        # Pregunta 2
        Write-Host ""
        Write-Host "2️⃣  ¿Qué caso de uso está relacionado?" -ForegroundColor Cyan
        Write-Host "   📖 Encontrado: CU-01 'Registrar un reporte de incidente' (Actor: Vecino)" -ForegroundColor Gray
        Write-Host "   💡 Propuesta: Actor principal Vecino, sistemas externos: Geolocalización. Incluye validación coords." -ForegroundColor Green
        Write-Host "   ❓ ¿Confirmas? (s/n): " -NoNewline
        $r = Read-Host

        # Pregunta 3
        Write-Host ""
        Write-Host "3️⃣  ¿Qué entidades del modelo de dominio gestiona?" -ForegroundColor Cyan
        Write-Host "   📖 Encontrado: Usuario (crea), Reporte (crea), Categoría (lee), Ubicación (crea 1:1), Fotografía (crea N:1)" -ForegroundColor Gray
        Write-Host "   💡 Propuesta: Crea Reporte con FK a Usuario, Categoría, Ubicación, y N Fotografías. Atributos obligatorios: descripción, lat/lng, categoria_id." -ForegroundColor Green
        Write-Host "   ❓ ¿Confirmas? (s/n): " -NoNewline
        $r = Read-Host

        # Pregunta 4
        Write-Host ""
        Write-Host "4️⃣  ¿Qué cambios de estado debe producir? (EST-01)" -ForegroundColor Cyan
        Write-Host "   📖 Encontrado: Estado inicial 'Recibido' → (auto) 'EnRevisión' tras tomar conocimiento admin" -ForegroundColor Gray
        Write-Host "   💡 Propuesta: Al crear reporte → estado 'Recibido' + número seguimiento + prioridad auto + depto auto. No requiere acción admin aún." -ForegroundColor Green
        Write-Host "   ❓ ¿Confirmas? (s/n): " -NoNewline
        $r = Read-Host

        # Pregunta 5
        Write-Host ""
        Write-Host "5️⃣  ¿Cuál es el flujo de interacción? (DSS-01)" -ForegroundColor Cyan
        Write-Host "   📖 Encontrado: Vecino → Sistema (datos) → Sistema → Geolocalización (validar) → Geolocalización → Sistema (OK/Error) → Sistema → Vecino (folio/Error)" -ForegroundColor Gray
        Write-Host "   💡 Propuesta: Flujo feliz valida coords → registra → devuelve folio. Flujo error coords inválidas → rechaza → pide nueva ubicación." -ForegroundColor Green
        Write-Host "   ❓ ¿Confirmas? (s/n): " -NoNewline
        $r = Read-Host

        Write-Host ""
        Write-Host "✅ FICHA HU-01 GENERADA EN .cin324/historias/HU-01.md" -ForegroundColor Green
        Write-Host "   Próximo paso: proponer (OpenSpec) → .\cin324-demo.ps1 proponer HU-01" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Solo HU-01 implementado en demo. Para otras HU, usar skill real en OpenCode." -ForegroundColor Yellow
    }
}

function Run-Proponer {
    param($HU)

    if (-not $HU) {
        Write-Host "❌ Debe especificar HU-xx. Ej: .\cin324-demo.ps1 proponer HU-01" -ForegroundColor Red
        return
    }

    Show-Banner
    Write-Host "📝 EJECUTANDO: /opsx-propose (OpenSpec) para $HU" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "🔧 Verificando OpenSpec CLI..." -ForegroundColor Yellow
    Write-Host "   (En demo: simulamos - el CLI real requiere 'npm install -g @fission-ai/openspec')" -ForegroundColor Gray
    Write-Host ""

    Write-Host "📋 Generando cambio: hu-01-registrar-reporte" -ForegroundColor Cyan
    Write-Host ""

    $archivos = @(
        "openspec/changes/hu-01-registrar-reporte/proposal.md",
        "openspec/changes/hu-01-registrar-reporte/specs/registrar-reporte/spec.md",
        "openspec/changes/hu-01-registrar-reporte/design.md",
        "openspec/changes/hu-01-registrar-reporte/tasks.md"
    )

    foreach ($a in $archivos) {
        Write-Host "   ✍️  Creando: $a" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "📄 CONTENIDO SIMULADO DE PROPOSAL.MD:" -ForegroundColor Yellow
    Write-Host "   # Propuesta: HU-01 Registrar Reporte" -ForegroundColor Gray
    Write-Host "   ## Por qué: Permite a vecino reportar incidentes con foto+GPS (RP-01, RP-02)" -ForegroundColor Gray
    Write-Host "   ## Alcance: POST /api/reportes, validación Zod, auto-prioridad, auto-depto, folio" -ForegroundColor Gray
    Write-Host "   ## Fuera de alcance: Notificaciones (HU-05), OAuth (RP-12), Mapas" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📄 CONTENIDO SIMULADO DE SPECS/REGISTRAR-REPORTE/SPEC.MD:" -ForegroundColor Yellow
    Write-Host "   # Especificación: Registrar Reporte" -ForegroundColor Gray
    Write-Host "   ## Requisitos: RP-01, RP-02, RP-04, RP-05, RP-09" -ForegroundColor Gray
    Write-Host "   ## Escenarios Gherkin (de 07-criterios-aceptacion.md):" -ForegroundColor Gray
    Write-Host "   - Escenario: Registro exitoso con todos los datos" -ForegroundColor Gray
    Write-Host "   - Escenario: Intento de registro con datos incompletos" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📄 CONTENIDO SIMULADO DE DESIGN.MD:" -ForegroundColor Yellow
    Write-Host "   # Diseño Técnico: HU-01" -ForegroundColor Gray
    Write-Host "   ## Tablas (Modelo Dominio 08-modelo-dominio.md):" -ForegroundColor Gray
    Write-Host "   - usuarios, reportes, categorias, ubicaciones, fotografias" -ForegroundColor Gray
    Write-Host "   ## Endpoints (OpenAPI 15-api-openapi.md):" -ForegroundColor Gray
    Write-Host "   - POST /api/v1/reportes (crear)" -ForegroundColor Gray
    Write-Host "   ## Transiciones Estado (EST-01):" -ForegroundColor Gray
    Write-Host "   - [*] → Recibido (auto-asigna prioridad + depto)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📄 CONTENIDO SIMULADO DE TASKS.MD:" -ForegroundColor Yellow
    Write-Host "   - [ ] T01: Crear migration V008_reportes.sql (si no existe en V002)" -ForegroundColor Gray
    Write-Host "   - [ ] T02: Implementar POST /api/reportes (validación Zod + auto-prioridad)" -ForegroundColor Gray
    Write-Host "   - [ ] T03: Crear servicio Geolocalización mock (interfaz + implementación simulada)" -ForegroundColor Gray
    Write-Host "   - [ ] T04: Tests unitarios (2 escenarios Gherkin)" -ForegroundColor Gray
    Write-Host "   - [ ] T05: Test integración: flujo completo crear → validar → folio" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ ESPECIFICACIONES GENERADAS EN openspec/changes/hu-01-registrar-reporte/" -ForegroundColor Green
    Write-Host "   Próximo paso: REVISAR specs → .\cin324-demo.ps1 generar HU-01" -ForegroundColor Cyan
}

function Run-Generar {
    param($HU)

    if (-not $HU) {
        Write-Host "❌ Debe especificar HU-xx. Ej: .\cin324-demo.ps1 generar HU-01" -ForegroundColor Red
        return
    }

    Show-Banner
    Write-Host "⚙️  EJECUTANDO: /opsx-apply (Generar código) para $HU" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "📦 Stack configurado: TypeScript + Express + SQLite (sql.js) + Zod" -ForegroundColor Cyan
    Write-Host "   (Producción real: NestJS/FastAPI + PostgreSQL + PostGIS + Prisma/TypeORM)" -ForegroundColor Gray
    Write-Host ""

    $archivos = @(
        "src/routes/reportes.ts (POST /reportes)",
        "src/repositories/reportes.ts (createReporte, findReporteById)",
        "src/models/reporte.ts (CrearReporteDTO, Reporte interface)",
        "src/views/reportes/nuevo.ejs (formulario wizard 3 pasos)",
        "tests/reportes.test.ts (2 escenarios Gherkin)"
    )

    foreach ($a in $archivos) {
        Write-Host "   ⚡ Generando: $a" -ForegroundColor Green
        Start-Sleep -Milliseconds 300
    }

    Write-Host ""
    Write-Host "🧪 EJECUTANDO TESTS AUTOMÁTICOS..." -ForegroundColor Yellow
    Write-Host "   ✅ Test: Registro exitoso con todos los datos" -ForegroundColor Green
    Write-Host "   ✅ Test: Intento de registro con datos incompletos" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 CÓDIGO GENERADO Y TESTS PASANDO" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 GUÍA PARA PROBAR (como en guia-probar-y-cerrar.md):" -ForegroundColor Yellow
    Write-Host "   1. Ejecutar: .\run-demo.ps1" -ForegroundColor Gray
    Write-Host "   2. Abrir: http://localhost:3000" -ForegroundColor Gray
    Write-Host "   3. Login: maria.gonzalez@email.cl / vecino123" -ForegroundColor Gray
    Write-Host "   4. Ir a: 'Nuevo Reporte' → Llenar formulario → Enviar" -ForegroundColor Gray
    Write-Host "   5. Verificar: Aparece folio BC-2025-XXXXX + estado 'Recibido'" -ForegroundColor Gray
    Write-Host "   6. Admin: admin@municipalidad.cl / admin123 → Ver reporte en panel" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Próximo paso: VALIDAR SISTEMA → .\cin324-demo.ps1 validar-sistema" -ForegroundColor Cyan
}

function Run-ValidarSistema {
    Show-Banner
    Write-Host "🧪 EJECUTANDO: cin324-validar-sistema (Feedback → Artefactos)" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "🤔 Simulando feedback del estudiante (tú) probando la app..." -ForegroundColor Yellow
    Write-Host ""

    $feedbacks = @(
        @{Feedback="El folio no se ve claro en la confirmación"; Artefacto="17-wireframes.md (pantalla confirmación)"; Cambio="Aumentar tamaño folio, agregar icono copiar"};
        @{Feedback="Quiero que la categoría muestre el icono/color"; Artefacto="08-modelo-dominio.md (Categoria.icono, color_hex) + 17-wireframes.md"; Cambio="Agregar chip visual con icono+categoria en ReportCard"};
        @{Feedback="La validación de coords falla si GPS tarda"; Artefacto="10-diagramas-secuencia.md (DSS-01) + 07-criterios-aceptacion.md"; Cambio="Agregar timeout 10s + fallback entrada manual en Gherkin"};
    )

    foreach ($f in $feedbacks) {
        Write-Host "💬 Feedback: '$($f.Feedback)'" -ForegroundColor Cyan
        Write-Host "   🔗 Mapea a: $($f.Artefacto)" -ForegroundColor Yellow
        Write-Host "   🛠️  Cambio propuesto: $($f.Cambio)" -ForegroundColor Green
        Write-Host "   ❓ ¿Aplicar cambio? (s/n): " -NoNewline
        $r = Read-Host
        if ($r -eq 's') {
            Write-Host "   ✅ Cambio aprobado → Se actualiza artefacto + se crea nuevo cambio OpenSpec 'ajuste-hu-01-...'" -ForegroundColor Green
        } else {
            Write-Host "   ⏭️  Saltado" -ForegroundColor Gray
        }
        Write-Host ""
    }

    Write-Host "📝 INFORME DE VALIDACIÓN GUARDADO EN .cin324/validaciones/validacion-$(Get-Date -Format 'yyyyMMdd-HHmm').md" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔄 CICLO COMPLETO: Si hay cambios aprobados → proponer → generar → validar-sistema" -ForegroundColor Cyan
}

function Run-Estado {
    Show-Banner
    Write-Host "📊 ESTADO DEL PROYECTO (.cin324/proyecto.md)" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "📁 Repositorio: Barrio-Conectado (rama: claude-test)" -ForegroundColor Gray
    Write-Host "📚 Stack: TypeScript (demo) / NestJS + PostgreSQL (producción)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "📋 HISTORIAS:" -ForegroundColor Yellow
    $historias = @(
        @{ID="HU-01"; Estado="✅ Hecha"; Cambio="hu-01-registrar-reporte"; Notas="Demo funcional en barrio-conectado-demo"},
        @{ID="HU-02"; Estado="⏳ Pendiente"; Cambio=""; Notas="Consultar mis reportes"},
        @{ID="HU-03"; Estado="⏳ Pendiente"; Cambio=""; Notas="Filtrar reportes (admin)"},
        @{ID="HU-04"; Estado="⏳ Pendiente"; Cambio=""; Notas="Completar reporte"},
        @{ID="HU-05"; Estado="⏳ Pendiente"; Cambio=""; Notas="Notificaciones"},
        @{ID="HU-06"; Estado="⏳ Pendiente"; Cambio=""; Notas="Auto-prioridad (parcial en HU-01)"},
        @{ID="HU-07"; Estado="⏳ Pendiente"; Cambio=""; Notas="Descartar reporte"},
        @{ID="HU-08"; Estado="⏳ Pendiente"; Cambio=""; Notas="Reasignar depto"},
        @{ID="HU-09"; Estado="⏳ Pendiente"; Cambio=""; Notas="Auth OAuth (RP-12)"}
    )

    foreach ($h in $historias) {
        Write-Host "   $($h.ID): $($h.Estado) $($h.Notas)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "🚀 PRÓXIMA ACCIÓN RECOMENDADA: .\cin324-demo.ps1 validar-historia HU-02" -ForegroundColor Cyan
}

function Run-Demo {
    & "$PSScriptRoot\run-demo.ps1"
}

# Main
switch ($Command) {
    "auditoria"       { Run-Auditoria }
    "validar-historia" { Run-ValidarHistoria -HU $Historia }
    "proponer"        { Run-Proponer -HU $Historia }
    "generar"         { Run-Generar -HU $Historia }
    "validar-sistema" { Run-ValidarSistema }
    "estado"          { Run-Estado }
    "demo"            { Run-Demo }
    default           { Show-Help }
}