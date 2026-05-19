#!/bin/bash
# ============================================================
#  deploy.sh - Script de despliegue automatico para Linux/Mac
#  JHT Chat - Sistema de mensajeria distribuido
#  Uso: bash deploy.sh
# ============================================================

set -e

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'

step()  { echo -e "\n${CYAN}>>> $1${NC}"; }
ok()    { echo -e "    ${GREEN}[OK] $1${NC}"; }
fail()  { echo -e "    ${RED}[ERROR] $1${NC}"; }
info()  { echo -e "    ${YELLOW}$1${NC}"; }

clear
echo -e "${MAGENTA}============================================${NC}"
echo -e "${MAGENTA}   JHT Chat - Despliegue Automatico        ${NC}"
echo -e "${MAGENTA}============================================${NC}"

# ── PASO 1: Verificar Docker ─────────────────────────────────
step "Verificando que Docker este corriendo..."

if ! docker info > /dev/null 2>&1; then
    fail "Docker no esta corriendo."
    info "Inicia Docker y vuelve a ejecutar: bash deploy.sh"
    exit 1
fi
ok "Docker esta activo."

# ── PASO 2: Verificar archivo .env del backend ───────────────
step "Verificando archivo de configuracion (.env)..."

if [ ! -f "./backend_chat/.env" ]; then
    info "No se encontro .env, creandolo automaticamente..."
    cp ./backend_chat/.env.example ./backend_chat/.env
    ok ".env creado desde .env.example"
    info "Twilio desactivado (registro sin OTP activo)"
else
    ok ".env ya existe."
fi

# ── PASO 3: Levantar todos los contenedores ──────────────────
step "Construyendo e iniciando todos los servicios..."
info "Esto puede tardar varios minutos la primera vez."

docker compose up --build -d

# ── PASO 4: Esperar a que el backend este listo ──────────────
step "Esperando a que todos los servicios esten listos..."

MAX=30
i=0
LISTO=false

while [ $i -lt $MAX ] && [ "$LISTO" = "false" ]; do
    sleep 3
    i=$((i+1))
    info "Intento $i/$MAX - Verificando backend..."

    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs | grep -q "200"; then
        LISTO=true
    fi
done

if [ "$LISTO" = "false" ]; then
    info "El backend tardo mas de lo esperado. Verifica con: docker compose logs backend"
else
    ok "Todos los servicios estan listos."
fi

# ── PASO 5: Resumen ───────────────────────────────────────────
echo -e "\n${MAGENTA}============================================${NC}"
echo -e "${GREEN}   Sistema desplegado exitosamente!        ${NC}"
echo -e "${MAGENTA}============================================${NC}"

echo -e "\n  ${NC}Servicios disponibles:"
echo -e "  ${GRAY}----------------------------------------${NC}"
echo -e "  ${GREEN}Chat (Frontend)    ->  http://localhost:5173${NC}"
echo -e "  ${GREEN}API / Swagger      ->  http://localhost:8000/docs${NC}"
echo -e "  ${YELLOW}RabbitMQ UI        ->  http://localhost:15672  (guest/guest)${NC}"
echo -e "  ${YELLOW}Dozzle (Logs)      ->  http://localhost:9999${NC}"
echo -e "  ${YELLOW}Portainer (Docker) ->  http://localhost:9000${NC}"
echo -e "  ${YELLOW}Redis Commander    ->  http://localhost:8081${NC}"
echo -e "  ${GRAY}----------------------------------------${NC}"

echo -e "\n  ${NC}Comandos utiles:"
echo -e "  ${GRAY}Ver logs en tiempo real  ->  docker compose logs -f${NC}"
echo -e "  ${GRAY}Ver estado contenedores  ->  docker compose ps${NC}"
echo -e "  ${GRAY}Apagar todo              ->  docker compose down${NC}"
echo -e "  ${GRAY}Reiniciar todo           ->  docker compose restart${NC}\n"

# Abrir navegador (funciona en Mac y la mayoría de Linux con entorno gráfico)
if command -v open > /dev/null 2>&1; then
    open http://localhost:5173
elif command -v xdg-open > /dev/null 2>&1; then
    xdg-open http://localhost:5173
fi
