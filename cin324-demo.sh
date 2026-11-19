#!/usr/bin/env bash
# ============================================================
# CIN 324 - Skills Demo Runner (Simulación Profesor) - Linux/macOS
# Barrio Conectado - Entrega 3
# ============================================================

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

COMMAND="${1:-help}"
HISTORIA="${2:-}"
STACK="${3:-typescript}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  CIN 324 - Skills Demo Runner (Simulación Profesor)             ║${NC}"
    echo -e "${CYAN}║  Barrio Conectado - Entrega 3                                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    show_banner
    echo -e "${YELLOW}Uso: ./cin324-demo.sh <comando> [HU-xx] [stack]${NC}"
    echo ""
    echo -e "${GREEN}Comandos disponibles:${NC}"
    echo "  auditoria          - Simula cin324-auditar-repositorio (evalúa completitud)"
    echo "  validar-historia   - Simula cin324-validar-historia (5 preguntas HU-xx)"
    echo "  proponer           - Simula /opsx-propose (genera proposal.md, specs/, design.md, tasks.md)"
    echo "  generar            - Simula /opsx-apply (genera código TypeScript/Python)"
    echo "  validar-sistema    - Simula cin324-validar-sistema (feedback → cambios en artefactos)"
    echo "  estado             - Muestra estado del proyecto (.cin324/proyecto.md)"
    echo "  demo               - Ejecuta run-demo.sh (levanta la app)"
    echo "  help               - Muestra esta ayuda"
    echo ""
    echo -e "${CYAN}Ejemplos:${NC}"
    echo "  ./cin324-demo.sh auditoria"
    echo "  ./cin324-demo.sh validar-historia HU-01"
    echo "  ./cin324-demo.sh proponer HU-01"
    echo "  ./cin324-demo.sh generar HU-01"
    echo "  ./cin324-demo.sh demo"
}

run_auditoria() {
    show_banner
    echo -e "${GREEN}🔍 EJECUTANDO: cin324-auditar-repositorio${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    echo -e "${YELLOW}INFORME DE AUDITORÍA${NC}"
    echo -e "${YELLOW}=====================${NC}"
    echo ""

    artefactos=(
        "BPMN AS-IS|✅ Completo|01-proceso-as-is.md + diagramas/as-is.drawio.png|Contexto"
        "BPMN TO-BE|✅ Completo|02-rediseno-to-be.md + diagramas/to-be.drawio.png + tabla actividades|Contexto"
        "Historias Usuario (8)|✅ Completo|04-historias-usuario.md (HU-01..HU-08)|BLOQUEANTE"
        "Criterios Gherkin (8)|✅ Completo|07-criterios-aceptacion.md (todas con Dado/Cuando/Entonces)|BLOQUEANTE"
        "Modelo Dominio|✅ Completo|08-modelo-dominio.md + diagramas/modelo-dominio.puml (9 entidades)|BLOQUEANTE"
        "Casos de Uso (9)|✅ Completo|09-casos-de-uso.md (CU-01..CU-09) + diagrama|Importante"
        "Diagramas Estado (2)|✅ Completo|11-diagramas-estado.md (EST-01 Reporte, EST-02 Notificación)|Importante"
        "Diagramas Secuencia (6)|✅ Completo|10-diagramas-secuencia.md (DSS-01..DSS-06) + fuentes .puml|Importante"
        "Requisitos (12+4+1)|✅ Completo|03-requisitos.md (RP-01..RP-12, RY-01..RY-04, RP-12 derivado)|Contexto"
        "Atributos Calidad (9)|✅ Completo|06-atributos-calidad.md (ISO 25010 priorizados)|Contexto"
        "Trazabilidad|✅ Completo|12-trazabilidad.md (matriz bidireccional)|Contexto"
        "Arquitectura C4|✅ Completo|13-arquitectura.md (4 niveles + 8 ADRs)|Entrega 3"
        "Base Datos + Migraciones|✅ Completo|14-base-datos.md + migrations/V001-V007__*.sql|Entrega 3"
        "API OpenAPI 3.0|✅ Completo|15-api-openapi.md|Entrega 3"
        "Plan Pruebas|✅ Completo|16-plan-pruebas.md (100+ Gherkin + CI/CD)|Entrega 3"
        "Wireframes|✅ Completo|17-wireframes.md (Design System + todas pantallas)|Entrega 3"
        "Plan Implementación|✅ Completo|18-plan-implementacion.md (123 historias, 2 sprints, DoD/DoR)|Entrega 3"
    )

    bloqueantes=0
    importantes=0
    contexto=0
    entrega3=0

    for a in "${artefactos[@]}"; do
        IFS='|' read -r nombre estado evidencia importancia <<< "$a"
        icon="✅"
        color="$GREEN"
        case "$importancia" in
            "BLOQUEANTE") color="$RED"; ((bloqueantes++)) ;;
            "Importante") color="$YELLOW"; ((importantes++)) ;;
            "Contexto") color="$GREEN"; ((contexto++)) ;;
            "Entrega 3") color="$CYAN"; ((entrega3++)) ;;
        esac
        echo -e "${color}${icon} ${nombre} [${importancia}]${NC}"
        echo -e "${GRAY}   Evidencia: ${evidencia}${NC}"
    done

    echo ""
    echo -e "${YELLOW}RESUMEN:${NC}"
    echo -e "  Bloqueantes: ${bloqueantes}/3  ${GREEN}✅${NC}"
    echo -e "  Importantes: ${importantes}/3  ${GREEN}✅${NC}"
    echo -e "  Contexto:    ${contexto}/4  ${GREEN}✅${NC}"
    echo -e "  Entrega 3:   ${entrega3}/6  ${GREEN}✅${NC}"
    echo ""
    echo -e "${GREEN}🎯 VEREDICTO: SÍ - Sin bloqueantes. Documentación completa para generar código.${NC}"
    echo -e "${CYAN}   Puede continuar con: validar-historia HU-01${NC}"
}

run_validar_historia() {
    local HU="$1"
    if [[ -z "$HU" ]]; then
        echo -e "${RED}❌ Debe especificar HU-xx. Ej: ./cin324-demo.sh validar-historia HU-01${NC}"
        return
    fi

    show_banner
    echo -e "${GREEN}🔍 EJECUTANDO: cin324-validar-historia ${HU}${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    if [[ "$HU" == "HU-01" ]]; then
        echo -e "${YELLOW}📋 LEYENDO ARTEFACTOS PARA HU-01...${NC}"
        echo -e "${GRAY}   • Historia: 04-historias-usuario.md → HU-01${NC}"
        echo -e "${GRAY}   • Gherkin:  07-criterios-aceptacion.md → 2 escenarios${NC}"
        echo -e "${GRAY}   • TO-BE:    02-rediseno-to-be.md → Actividad 'Reporta el problema en la app'${NC}"
        echo -e "${GRAY}   • CU:       09-casos-de-uso.md → CU-01 'Registrar un reporte de incidente'${NC}"
        echo -e "${GRAY}   • Dominio:  08-modelo-dominio.md → Usuario, Reporte, Categoría, Ubicación, Fotografía${NC}"
        echo -e "${GRAY}   • Estado:   11-diagramas-estado.md → EST-01 (Recibido → EnRevisión → Completado/Descartado)${NC}"
        echo -e "${GRAY}   • Secuencia: 10-diagramas-secuencia.md → DSS-01 (validación geolocalización)${NC}"
        echo -e "${GRAY}   • Requisitos: RP-01, RP-02, RP-04, RP-05, RP-09${NC}"
        echo ""

        echo -e "${YELLOW}❓ LAS 5 PREGUNTAS DE CONFIRMACIÓN:${NC}"
        echo ""

        preguntas=(
            "1️⃣  ¿Con qué actividad del TO-BE se relaciona?|📖 Encontrado: 'Reporta el problema en la app' + 'Registra el reporte automáticamente'|💡 Propuesta: Esta HU cubre el registro inicial del reporte por el vecino (foto + GPS + descripción + categoría)."
            "2️⃣  ¿Qué caso de uso está relacionado?|📖 Encontrado: CU-01 'Registrar un reporte de incidente' (Actor: Vecino)|💡 Propuesta: Actor principal Vecino, sistemas externos: Geolocalización. Incluye validación coords."
            "3️⃣  ¿Qué entidades del modelo de dominio gestiona?|📖 Encontrado: Usuario (crea), Reporte (crea), Categoría (lee), Ubicación (crea 1:1), Fotografía (crea N:1)|💡 Propuesta: Crea Reporte con FK a Usuario, Categoría, Ubicación, y N Fotografías. Atributos obligatorios: descripción, lat/lng, categoria_id."
            "4️⃣  ¿Qué cambios de estado debe producir? (EST-01)|📖 Encontrado: Estado inicial 'Recibido' → (auto) 'EnRevisión' tras tomar conocimiento admin|💡 Propuesta: Al crear reporte → estado 'Recibido' + número seguimiento + prioridad auto + depto auto. No requiere acción admin aún."
            "5️⃣  ¿Cuál es el flujo de interacción? (DSS-01)|📖 Encontrado: Vecino → Sistema (datos) → Sistema → Geolocalización (validar) → Geolocalización → Sistema (OK/Error) → Sistema → Vecino (folio/Error)|💡 Propuesta: Flujo feliz valida coords → registra → devuelve folio. Flujo error coords inválidas → rechaza → pide nueva ubicación."
        )

        for p in "${preguntas[@]}"; do
            IFS='|' read -r pregunta encontrado propuesta <<< "$p"
            echo -e "${CYAN}${pregunta}${NC}"
            echo -e "${GRAY}${encontrado}${NC}"
            echo -e "${GREEN}${propuesta}${NC}"
            echo -ne "${YELLOW}   ❓ ¿Confirmas? (s/n): ${NC}"
            read -r r
            if [[ "$r" != "s" ]]; then
                echo -e "${YELLOW}   → Marcado como 'corregir: ...'${NC}"
            fi
            echo ""
        done

        echo -e "${GREEN}✅ FICHA HU-01 GENERADA EN .cin324/historias/HU-01.md${NC}"
        echo -e "${CYAN}   Próximo paso: proponer (OpenSpec) → ./cin324-demo.sh proponer HU-01${NC}"
    else
        echo -e "${YELLOW}⚠️  Solo HU-01 implementado en demo. Para otras HU, usar skill real en OpenCode.${NC}"
    fi
}

run_proponer() {
    local HU="$1"
    if [[ -z "$HU" ]]; then
        echo -e "${RED}❌ Debe especificar HU-xx. Ej: ./cin324-demo.sh proponer HU-01${NC}"
        return
    fi

    show_banner
    echo -e "${GREEN}📝 EJECUTANDO: /opsx-propose (OpenSpec) para ${HU}${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    echo -e "${YELLOW}🔧 Verificando OpenSpec CLI...${NC}"
    echo -e "${GRAY}   (En demo: simulamos - el CLI real requiere 'npm install -g @fission-ai/openspec')${NC}"
    echo ""

    echo -e "${CYAN}📋 Generando cambio: hu-01-registrar-reporte${NC}"
    echo ""

    archivos=(
        "openspec/changes/hu-01-registrar-reporte/proposal.md"
        "openspec/changes/hu-01-registrar-reporte/specs/registrar-reporte/spec.md"
        "openspec/changes/hu-01-registrar-reporte/design.md"
        "openspec/changes/hu-01-registrar-reporte/tasks.md"
    )

    for a in "${archivos[@]}"; do
        echo -e "${GREEN}   ✍️  Creando: ${a}${NC}"
    done

    echo ""
    echo -e "${YELLOW}📄 CONTENIDO SIMULADO DE PROPOSAL.MD:${NC}"
    echo -e "${GRAY}   # Propuesta: HU-01 Registrar Reporte${NC}"
    echo -e "${GRAY}   ## Por qué: Permite a vecino reportar incidentes con foto+GPS (RP-01, RP-02)${NC}"
    echo -e "${GRAY}   ## Alcance: POST /api/reportes, validación Zod, auto-prioridad, auto-depto, folio${NC}"
    echo -e "${GRAY}   ## Fuera de alcance: Notificaciones (HU-05), OAuth (RP-12), Mapas${NC}"
    echo ""
    echo -e "${YELLOW}📄 CONTENIDO SIMULADO DE SPECS/REGISTRAR-REPORTE/SPEC.MD:${NC}"
    echo -e "${GRAY}   # Especificación: Registrar Reporte${NC}"
    echo -e "${GRAY}   ## Requisitos: RP-01, RP-02, RP-04, RP-05, RP-09${NC}"
    echo -e "${GRAY}   ## Escenarios Gherkin (de 07-criterios-aceptacion.md):${NC}"
    echo -e "${GRAY}   - Escenario: Registro exitoso con todos los datos${NC}"
    echo -e "${GRAY}   - Escenario: Intento de registro con datos incompletos${NC}"
    echo ""
    echo -e "${YELLOW}📄 CONTENIDO SIMULADO DE DESIGN.MD:${NC}"
    echo -e "${GRAY}   # Diseño Técnico: HU-01${NC}"
    echo -e "${GRAY}   ## Tablas (Modelo Dominio 08-modelo-dominio.md):${NC}"
    echo -e "${GRAY}   - usuarios, reportes, categorias, ubicaciones, fotografias${NC}"
    echo -e "${GRAY}   ## Endpoints (OpenAPI 15-api-openapi.md):${NC}"
    echo -e "${GRAY}   - POST /api/v1/reportes (crear)${NC}"
    echo -e "${GRAY}   ## Transiciones Estado (EST-01):${NC}"
    echo -e "${GRAY}   - [*] → Recibido (auto-asigna prioridad + depto)${NC}"
    echo ""
    echo -e "${YELLOW}📄 CONTENIDO SIMULADO DE TASKS.MD:${NC}"
    echo -e "${GRAY}   - [ ] T01: Crear migration V008_reportes.sql (si no existe en V002)${NC}"
    echo -e "${GRAY}   - [ ] T02: Implementar POST /api/reportes (validación Zod + auto-prioridad)${NC}"
    echo -e "${GRAY}   - [ ] T03: Crear servicio Geolocalización mock (interfaz + implementación simulada)${NC}"
    echo -e "${GRAY}   - [ ] T04: Tests unitarios (2 escenarios Gherkin)${NC}"
    echo -e "${GRAY}   - [ ] T05: Test integración: flujo completo crear → validar → folio${NC}"
    echo ""
    echo -e "${GREEN}✅ ESPECIFICACIONES GENERADAS EN openspec/changes/hu-01-registrar-reporte/${NC}"
    echo -e "${CYAN}   Próximo paso: REVISAR specs → ./cin324-demo.sh generar HU-01${NC}"
}

run_generar() {
    local HU="$1"
    if [[ -z "$HU" ]]; then
        echo -e "${RED}❌ Debe especificar HU-xx. Ej: ./cin324-demo.sh generar HU-01${NC}"
        return
    fi

    show_banner
    echo -e "${GREEN}⚙️  EJECUTANDO: /opsx-apply (Generar código) para ${HU}${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    echo -e "${CYAN}📦 Stack configurado: TypeScript + Express + SQLite (sql.js) + Zod${NC}"
    echo -e "${GRAY}   (Producción real: NestJS/FastAPI + PostgreSQL + PostGIS + Prisma/TypeORM)${NC}"
    echo ""

    archivos=(
        "src/routes/reportes.ts (POST /reportes)"
        "src/repositories/reportes.ts (createReporte, findReporteById)"
        "src/models/reporte.ts (CrearReporteDTO, Reporte interface)"
        "src/views/reportes/nuevo.ejs (formulario wizard 3 pasos)"
        "tests/reportes.test.ts (2 escenarios Gherkin)"
    )

    for a in "${archivos[@]}"; do
        echo -e "${GREEN}   ⚡ Generando: ${a}${NC}"
        sleep 0.3
    done

    echo ""
    echo -e "${YELLOW}🧪 EJECUTANDO TESTS AUTOMÁTICOS...${NC}"
    echo -e "${GREEN}   ✅ Test: Registro exitoso con todos los datos${NC}"
    echo -e "${GREEN}   ✅ Test: Intento de registro con datos incompletos${NC}"
    echo ""
    echo -e "${GREEN}🎉 CÓDIGO GENERADO Y TESTS PASANDO${NC}"
    echo ""
    echo -e "${YELLOW}📋 GUÍA PARA PROBAR (como en guia-probar-y-cerrar.md):${NC}"
    echo -e "${GRAY}   1. Ejecutar: ./run-demo.sh${NC}"
    echo -e "${GRAY}   2. Abrir: http://localhost:3000${NC}"
    echo -e "${GRAY}   3. Login: maria.gonzalez@email.cl / vecino123${NC}"
    echo -e "${GRAY}   4. Ir a: 'Nuevo Reporte' → Llenar formulario → Enviar${NC}"
    echo -e "${GRAY}   5. Verificar: Aparece folio BC-2025-XXXXX + estado 'Recibido'${NC}"
    echo -e "${GRAY}   6. Admin: admin@municipalidad.cl / admin123 → Ver reporte en panel${NC}"
    echo ""
    echo -e "${CYAN}   Próximo paso: VALIDAR SISTEMA → ./cin324-demo.sh validar-sistema${NC}"
}

run_validar_sistema() {
    show_banner
    echo -e "${GREEN}🧪 EJECUTANDO: cin324-validar-sistema (Feedback → Artefactos)${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    echo -e "${YELLOW}🤔 Simulando feedback del estudiante (tú) probando la app...${NC}"
    echo ""

    feedbacks=(
        "El folio no se ve claro en la confirmación|17-wireframes.md (pantalla confirmación)|Aumentar tamaño folio, agregar icono copiar"
        "Quiero que la categoría muestre el icono/color|08-modelo-dominio.md (Categoria.icono, color_hex) + 17-wireframes.md|Agregar chip visual con icono+categoria en ReportCard"
        "La validación de coords falla si GPS tarda|10-diagramas-secuencia.md (DSS-01) + 07-criterios-aceptacion.md|Agregar timeout 10s + fallback entrada manual en Gherkin"
    )

    for f in "${feedbacks[@]}"; do
        IFS='|' read -r feedback artefacto cambio <<< "$f"
        echo -e "${CYAN}💬 Feedback: '${feedback}'${NC}"
        echo -e "${YELLOW}   🔗 Mapea a: ${artefacto}${NC}"
        echo -e "${GREEN}   🛠️  Cambio propuesto: ${cambio}${NC}"
        echo -ne "${YELLOW}   ❓ ¿Aplicar cambio? (s/n): ${NC}"
        read -r r
        if [[ "$r" == "s" ]]; then
            echo -e "${GREEN}   ✅ Cambio aprobado → Se actualiza artefacto + se crea nuevo cambio OpenSpec 'ajuste-hu-01-...'${NC}"
        else
            echo -e "${GRAY}   ⏭️  Saltado${NC}"
        fi
        echo ""
    done

    echo -e "${GREEN}📝 INFORME DE VALIDACIÓN GUARDADO EN .cin324/validaciones/validacion-$(date +%Y%m%d-%H%M).md${NC}"
    echo ""
    echo -e "${CYAN}🔄 CICLO COMPLETO: Si hay cambios aprobados → proponer → generar → validar-sistema${NC}"
}

run_estado() {
    show_banner
    echo -e "${GREEN}📊 ESTADO DEL PROYECTO (.cin324/proyecto.md)${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo ""

    echo -e "${GRAY}📁 Repositorio: Barrio-Conectado (rama: claude-test)${NC}"
    echo -e "${GRAY}📚 Stack: TypeScript (demo) / NestJS + PostgreSQL (producción)${NC}"
    echo ""

    echo -e "${YELLOW}📋 HISTORIAS:${NC}"
    historias=(
        "HU-01|✅ Hecha|hu-01-registrar-reporte|Demo funcional en barrio-conectado-demo"
        "HU-02|⏳ Pendiente||Consultar mis reportes"
        "HU-03|⏳ Pendiente||Filtrar reportes (admin)"
        "HU-04|⏳ Pendiente||Completar reporte"
        "HU-05|⏳ Pendiente||Notificaciones"
        "HU-06|⏳ Pendiente||Auto-prioridad (parcial en HU-01)"
        "HU-07|⏳ Pendiente||Descartar reporte"
        "HU-08|⏳ Pendiente||Reasignar depto"
        "HU-09|⏳ Pendiente||Auth OAuth (RP-12)"
    )

    for h in "${historias[@]}"; do
        IFS='|' read -r id estado cambio notas <<< "$h"
        echo -e "${GRAY}   ${id}: ${estado} ${notas}${NC}"
    done

    echo ""
    echo -e "${CYAN}🚀 PRÓXIMA ACCIÓN RECOMENDADA: ./cin324-demo.sh validar-historia HU-02${NC}"
}

run_demo() {
    "$SCRIPT_DIR/run-demo.sh"
}

case "$COMMAND" in
    auditoria)       run_auditoria ;;
    validar-historia) run_validar_historia "$HISTORIA" ;;
    proponer)        run_proponer "$HISTORIA" ;;
    generar)         run_generar "$HISTORIA" ;;
    validar-sistema) run_validar_sistema ;;
    estado)          run_estado ;;
    demo)            run_demo ;;
    *)               show_help ;;
esac