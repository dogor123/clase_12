# ============================================================
#  deploy.ps1 - Script de despliegue automatico para Windows
#  JHT Chat - Sistema de mensajeria distribuido
#  Uso: .\deploy.ps1
# ============================================================

$ErrorActionPreference = "Stop"

# Colores para mensajes
function Write-Step  { param($msg) Write-Host "`n>>> $msg" -ForegroundColor Cyan }
function Write-OK    { param($msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Fail  { param($msg) Write-Host "    [ERROR] $msg" -ForegroundColor Red }
function Write-Info  { param($msg) Write-Host "    $msg" -ForegroundColor Yellow }

Clear-Host
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "   JHT Chat - Despliegue Automatico" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta

# ── PASO 1: Verificar Docker ─────────────────────────────────
Write-Step "Verificando que Docker este corriendo..."

try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw }
    Write-OK "Docker esta activo."
} catch {
    Write-Fail "Docker no esta corriendo."
    Write-Info "Por favor abre Docker Desktop y espera a que cargue completamente."
    Write-Info "Luego vuelve a ejecutar este script."
    exit 1
}

# ── PASO 2: Verificar archivo .env del backend ───────────────
Write-Step "Verificando archivo de configuracion (.env)..."

$envPath = ".\backend_chat\.env"

if (-Not (Test-Path $envPath)) {
    Write-Info "No se encontro .env, creandolo automaticamente..."
    Copy-Item ".\backend_chat\.env.example" $envPath
    Write-OK ".env creado desde .env.example"
    Write-Info "Twilio desactivado (registro sin OTP activo)"
} else {
    Write-OK ".env ya existe."
}

# ── PASO 3: Levantar todos los contenedores ──────────────────
Write-Step "Construyendo e iniciando todos los servicios..."
Write-Info "Esto puede tardar varios minutos la primera vez (descarga de imagenes)."
Write-Info "Las proximas veces sera mucho mas rapido."

docker compose up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Fail "Hubo un error al levantar los servicios."
    Write-Info "Revisa los logs con: docker compose logs"
    exit 1
}

# ── PASO 4: Esperar a que los servicios esten listos ─────────
Write-Step "Esperando a que todos los servicios esten listos..."

$maxIntentos = 30
$intento = 0
$backendListo = $false

while ($intento -lt $maxIntentos -and -not $backendListo) {
    Start-Sleep -Seconds 3
    $intento++
    Write-Info "Intento $intento/$maxIntentos - Verificando backend..."

    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/docs" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $backendListo = $true
        }
    } catch {
        # Aun no esta listo, seguir esperando
    }
}

if (-not $backendListo) {
    Write-Info "El backend tardo mas de lo esperado. Verifica con: docker compose logs backend"
} else {
    Write-OK "Todos los servicios estan listos."
}

# ── PASO 5: Mostrar resumen ───────────────────────────────────
Write-Host "`n============================================" -ForegroundColor Magenta
Write-Host "   Sistema desplegado exitosamente!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Magenta

Write-Host "`n  Servicios disponibles:" -ForegroundColor White
Write-Host "  ----------------------------------------" -ForegroundColor Gray
Write-Host "  Chat (Frontend)    ->  http://localhost:5173" -ForegroundColor Green
Write-Host "  API / Swagger      ->  http://localhost:8000/docs" -ForegroundColor Green
Write-Host "  RabbitMQ UI        ->  http://localhost:15672  (guest/guest)" -ForegroundColor Yellow
Write-Host "  Dozzle (Logs)      ->  http://localhost:9999" -ForegroundColor Yellow
Write-Host "  Portainer (Docker) ->  http://localhost:9000" -ForegroundColor Yellow
Write-Host "  Redis Commander    ->  http://localhost:8081" -ForegroundColor Yellow
Write-Host "  ----------------------------------------" -ForegroundColor Gray

Write-Host "`n  Comandos utiles:" -ForegroundColor White
Write-Host "  Ver logs en tiempo real  ->  docker compose logs -f" -ForegroundColor Gray
Write-Host "  Ver estado contenedores  ->  docker compose ps" -ForegroundColor Gray
Write-Host "  Apagar todo              ->  docker compose down" -ForegroundColor Gray
Write-Host "  Reiniciar todo           ->  docker compose restart" -ForegroundColor Gray
Write-Host ""

# Abrir el navegador automaticamente
Write-Step "Abriendo el chat en el navegador..."
Start-Sleep -Seconds 2
Start-Process "http://localhost:5173"
