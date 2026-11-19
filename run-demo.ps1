<#
.SYNOPSIS
    Ejecuta el demo Barrio Conectado (Entrega 3 - Implementación)

.DESCRIPTION
    Script para levantar rápidamente la aplicación demo con Express + TypeScript + SQLite (sql.js)
    Incluye: autenticación (vecino/admin), reportes con geolocalización, fotos, estados, notificaciones

.NOTAS
    - Usa SQLite en memoria (sql.js WASM) - no requiere PostgreSQL instalado
    - Datos de prueba se cargan automáticamente (seed)
    - Puerto por defecto: 3000
#>

param(
    [int]$Port = 3000,
    [switch]$DevMode = $false
)

$DemoPath = "$PSScriptRoot\barrio-conectado-demo"

if (-not (Test-Path $DemoPath)) {
    Write-Error "No se encuentra la carpeta del demo en: $DemoPath"
    Write-Host "Clona el repo completo o verifica la ruta." -ForegroundColor Yellow
    exit 1
}

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          BARRIO CONECTADO - Demo Entrega 3                  ║" -ForegroundColor Cyan
Write-Host "║    CIN 324 - Ingeniería de Requisitos - UV 2026             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Set-Location $DemoPath

# Verificar node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error instalando dependencias"
        exit 1
    }
}

# Inicializar BD y seed
Write-Host "🗄️  Inicializando base de datos (SQLite + sql.js)..." -ForegroundColor Yellow
npm run db:init
npm run db:seed

if ($DevMode) {
    Write-Host "🚀 Iniciando en MODO DESARROLLO (hot reload)..." -ForegroundColor Green
    Write-Host "   URL: http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "   Vecino demo: maria.gonzalez@email.cl / vecino123" -ForegroundColor Gray
    Write-Host "   Admin demo:  admin@municipalidad.cl / admin123" -ForegroundColor Gray
    Write-Host ""
    npm run dev
} else {
    Write-Host "🔨 Compilando TypeScript..." -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error compilando"
        exit 1
    }

    Write-Host "🚀 Iniciando servidor de producción..." -ForegroundColor Green
    Write-Host "   URL: http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "   Vecino demo: maria.gonzalez@email.cl / vecino123" -ForegroundColor Gray
    Write-Host "   Admin demo:  admin@municipalidad.cl / admin123" -ForegroundColor Gray
    Write-Host ""
    $env:PORT = $Port
    npm start
}