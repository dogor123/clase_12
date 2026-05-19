# ============================================
# JHT Chat - Despliegue Automatico
# ============================================

Clear-Host

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " JHT Chat - Despliegue Automatico" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

# -------------------------------------------------
# Verificar Docker
# -------------------------------------------------

Write-Host ">>> Verificando que Docker este corriendo..." -ForegroundColor Yellow

try {
    docker info | Out-Null
    Write-Host "[OK] Docker esta activo." -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Docker Desktop no esta corriendo." -ForegroundColor Red
    Write-Host "Abre Docker Desktop y vuelve a intentarlo." -ForegroundColor Yellow
    pause
    exit
}

# -------------------------------------------------
# Verificar archivo .env
# -------------------------------------------------

Write-Host ">>> Verificando archivo de configuracion (.env)..." -ForegroundColor Yellow

if (!(Test-Path ".\backend_chat\.env")) {

    if (Test-Path ".\backend_chat\.env.example") {
        Copy-Item ".\backend_chat\.env.example" ".\backend_chat\.env"
        Write-Host "[OK] No se encontro .env, creandolo automaticamente..." -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] No existe backend_chat\.env.example" -ForegroundColor Red
        pause
        exit
    }
}
else {
    Write-Host "[OK] Archivo .env encontrado." -ForegroundColor Green
}

# -------------------------------------------------
# Limpiar contenedores anteriores
# -------------------------------------------------

Write-Host ">>> Limpiando contenedores anteriores..." -ForegroundColor Yellow

docker compose down --remove-orphans 2>$null

# Eliminar contenedores conflictivos si existen
$containers = @(
    "dozzle_logs",
    "portainer",
    "frontend_service",
    "backend_service",
    "mongodb_service",
    "redis_service",
    "rabbitmq_service",
    "redis_commander"
)

foreach ($container in $containers) {
    docker rm -f $container 2>$null | Out-Null
}

Write-Host "[OK] Limpieza completada." -ForegroundColor Green

# -------------------------------------------------
# Construir y levantar servicios
# -------------------------------------------------

Write-Host ">>> Construyendo y levantando servicios..." -ForegroundColor Cyan

docker compose up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Ocurrio un problema al levantar los contenedores." -ForegroundColor Red
    Write-Host "Revisa los logs con: docker compose logs -f" -ForegroundColor Yellow
    pause
    exit
}

# -------------------------------------------------
# Mostrar estado
# -------------------------------------------------

Write-Host ""
Write-Host ">>> Estado de los contenedores:" -ForegroundColor Yellow
docker compose ps

# -------------------------------------------------
# URLs finales
# -------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Sistema desplegado correctamente" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Frontend Chat:        http://localhost:5173" -ForegroundColor White
Write-Host "Backend Swagger:      http://localhost:8000/docs" -ForegroundColor White
Write-Host "RabbitMQ:             http://localhost:15672" -ForegroundColor White
Write-Host "Portainer:            http://localhost:9000" -ForegroundColor White
Write-Host "Dozzle Logs:          http://localhost:9999" -ForegroundColor White
Write-Host "Redis Commander:      http://localhost:8081" -ForegroundColor White

Write-Host ""
Write-Host ">>> Abriendo frontend en el navegador..." -ForegroundColor Yellow

Start-Process "http://localhost:5173"

Write-Host ""
Write-Host "[OK] Despliegue finalizado." -ForegroundColor Green
