#!/usr/bin/env bash
# ============================================================
# BARRIO CONECTADO - Demo Runner (Linux/macOS)
# CIN 324 - Ingeniería de Requisitos - UV 2026
# Entrega 3 - Implementación
# ============================================================

set -euo pipefail

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/barrio-conectado-demo"
PORT="${1:-3000}"
DEV_MODE="${2:-false}"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          BARRIO CONECTADO - Demo Entrega 3                  ║${NC}"
echo -e "${CYAN}║    CIN 324 - Ingeniería de Requisitos - UV 2026             ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ ! -d "$DEMO_DIR" ]]; then
    echo -e "${RED}❌ No se encuentra la carpeta del demo en: $DEMO_DIR${NC}"
    echo -e "${YELLOW}Clona el repo completo o verifica la ruta.${NC}"
    exit 1
fi

cd "$DEMO_DIR"

# Verificar node_modules
if [[ ! -d "node_modules" ]]; then
    echo -e "${YELLOW}📦 Instalando dependencias...${NC}"
    npm install
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Error instalando dependencias${NC}"
        exit 1
    fi
fi

# Inicializar BD y seed
echo -e "${YELLOW}🗄️  Inicializando base de datos (SQLite + sql.js)...${NC}"
npm run db:init
npm run db:seed

if [[ "$DEV_MODE" == "true" ]] || [[ "$DEV_MODE" == "dev" ]]; then
    echo -e "${GREEN}🚀 Iniciando en MODO DESARROLLO (hot reload)...${NC}"
    echo -e "   URL: ${CYAN}http://localhost:$PORT${NC}"
    echo -e "   Vecino demo: ${GRAY}maria.gonzalez@email.cl / vecino123${NC}"
    echo -e "   Admin demo:  ${GRAY}admin@municipalidad.cl / admin123${NC}"
    echo ""
    npm run dev
else
    echo -e "${YELLOW}🔨 Compilando TypeScript...${NC}"
    npm run build
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Error compilando${NC}"
        exit 1
    fi

    echo -e "${GREEN}🚀 Iniciando servidor de producción...${NC}"
    echo -e "   URL: ${CYAN}http://localhost:$PORT${NC}"
    echo -e "   Vecino demo: ${GRAY}maria.gonzalez@email.cl / vecino123${NC}"
    echo -e "   Admin demo:  ${GRAY}admin@municipalidad.cl / admin123${NC}"
    echo ""
    PORT=$PORT npm start
fi