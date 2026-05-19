# JHT Chat 💬

Sistema de mensajería en tiempo real con FastAPI, React, MongoDB, Redis y RabbitMQ — todo orquestado con Docker.

---

## Prerequisitos

Antes de empezar necesitas instalar **2 programas**. Si ya los tienes, puedes saltarte esta sección.

---

### 1. Docker Desktop

Docker es el programa que levanta todos los servicios (base de datos, backend, frontend, etc.) sin que tengas que instalar nada más.

**Descarga:** https://www.docker.com/products/docker-desktop

**Pasos de instalación en Windows:**
1. Descarga el instalador `.exe` desde el link de arriba
2. Ejecútalo y sigue los pasos (Next → Next → Install)
3. Cuando termine, **reinicia el computador**
4. Después del reinicio, abre **Docker Desktop** desde el menú inicio
5. Espera a que el ícono de la ballena 🐳 en la barra de tareas diga **"Docker Desktop is running"**

> ⚠️ Si Windows te pide instalar **WSL2** durante el proceso, acepta — Docker lo necesita y Windows lo instala automáticamente.

**Para verificar que quedó bien instalado**, abre **PowerShell** y escribe:
```powershell
docker --version
```
Debe responder algo como: `Docker version 26.x.x`

---

### 2. Git

Git es el programa que permite clonar (descargar) el repositorio del proyecto.

**Descarga:** https://git-scm.com/downloads

**Pasos de instalación en Windows:**
1. Descarga el instalador `.exe` desde el link de arriba
2. Ejecútalo y deja **todas las opciones por defecto** — solo dale Next hasta terminar

**Para verificar que quedó bien instalado**, abre **PowerShell** y escribe:
```powershell
git --version
```
Debe responder algo como: `git version 2.x.x`

---

## Despliegue del proyecto

Una vez tengas Docker Desktop y Git instalados, sigue estos pasos.

### Paso 1 — Abrir PowerShell

En Windows, busca **PowerShell** en el menú inicio y ábrelo.

> 💡 También puedes usar la **Terminal de Windows** si la tienes instalada — funciona igual.

---

### Paso 2 — Clonar el repositorio

En **PowerShell**, escribe el siguiente comando y presiona Enter. Esto descarga el proyecto completo en tu computador:

```powershell
git clone https://github.com/dogor123/clase_12.git
```

Luego entra a la carpeta del proyecto:

```powershell
cd clase_12
```

---

### Paso 3 — Asegurarte de que Docker Desktop esté corriendo

Antes de continuar, verifica que Docker Desktop esté abierto y activo. En la barra de tareas (esquina inferior derecha) debe aparecer el ícono de la ballena 🐳 con el mensaje **"Docker Desktop is running"**.

Si no está abierto, búscalo en el menú inicio y ábrelo. Espera 1-2 minutos a que cargue completamente.

---

### Paso 4 — Ejecutar el script de despliegue

En **PowerShell**, estando dentro de la carpeta `clase_12`, ejecuta:

```powershell
.\deploy.ps1
```

> ⚠️ Si PowerShell te muestra un error de permisos como *"no se puede cargar el archivo"*, ejecuta primero este comando en **PowerShell** y luego vuelve a intentarlo:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
> ```

El script hará todo automáticamente:
- ✅ Verifica que Docker esté corriendo
- ✅ Crea el archivo de configuración (`.env`) solo
- ✅ Descarga todas las imágenes necesarias
- ✅ Construye y levanta todos los servicios
- ✅ Espera a que todo esté listo
- ✅ Abre el navegador con el chat funcionando

> ⏳ La **primera vez** puede tardar entre 3 y 10 minutos dependiendo de tu conexión a internet, porque descarga todas las imágenes de Docker. Las veces siguientes es casi instantáneo.

---

### Paso 5 — ¡Listo! Abrir el chat

Cuando el script termine, abrirá el navegador automáticamente. Si no lo abre, puedes entrar manualmente en tu navegador a:

```
http://localhost:5173
```

---

## URLs del sistema

Una vez desplegado, estos son todos los servicios disponibles:

| Servicio | URL | Credenciales |
|---|---|---|
| 💬 **Chat (Frontend)** | http://localhost:5173 | — |
| 📖 **API Swagger** | http://localhost:8000/docs | — |
| 🐇 **RabbitMQ UI** | http://localhost:15672 | usuario: `guest` / contraseña: `guest` |
| 📋 **Dozzle (Logs)** | http://localhost:9999 | — |
| 🐳 **Portainer (Docker)** | http://localhost:9000 | crear usuario al primer ingreso |
| 🔴 **Redis Commander** | http://localhost:8081 | — |

---

## Comandos útiles

Todos estos comandos se ejecutan en **PowerShell** dentro de la carpeta `clase_12`:

```powershell
# Ver el estado de todos los contenedores
docker compose ps

# Ver logs en tiempo real (Ctrl+C para salir)
docker compose logs -f

# Apagar todo (sin borrar los datos)
docker compose down

# Apagar todo y borrar la base de datos
docker compose down -v

# Reiniciar todo
docker compose restart
```

---

## Para apagar el sistema

En **PowerShell**, dentro de la carpeta `clase_12`:

```powershell
docker compose down
```

---

## Arquitectura del sistema

```
Cliente (React)
      │
      │ HTTP / WebSocket
      ▼
   FastAPI (:8000)
      │
   ┌──┴──────────────────┐
   │          │           │
MongoDB     Redis     RabbitMQ
(datos)  (sesiones)  (mensajería)
```

---

## Servicios incluidos

| Contenedor | Tecnología | Rol |
|---|---|---|
| `backend_service` | FastAPI (Python) | API REST + WebSocket |
| `frontend_service` | React + Nginx | Interfaz de usuario |
| `mongodb_service` | MongoDB 7 | Base de datos principal |
| `redis_service` | Redis 7 | Cache de sesiones y presencia |
| `rabbitmq_service` | RabbitMQ 3 | Cola de mensajes para broadcast |
| `dozzle_logs` | Dozzle | Visor de logs en tiempo real |
| `portainer` | Portainer CE | Panel de administración Docker |
| `redis_commander` | Redis Commander | Visor de claves Redis |


---

## ¿Qué hace automáticamente `deploy.ps1`?

El script `deploy.ps1` fue diseñado para que cualquier persona pueda desplegar el sistema con un solo comando, incluso si no tiene experiencia previa con Docker.

El script realiza automáticamente las siguientes tareas:

- ✅ Verifica que Docker Desktop esté corriendo
- ✅ Crea el archivo `.env` automáticamente si no existe
- ✅ Limpia contenedores anteriores para evitar conflictos
- ✅ Construye las imágenes Docker necesarias
- ✅ Levanta todos los servicios automáticamente
- ✅ Muestra el estado de los contenedores
- ✅ Abre el frontend automáticamente en el navegador
- ✅ Maneja errores básicos de despliegue

Gracias a esto, el usuario no necesita instalar Python, Node.js, MongoDB, Redis ni RabbitMQ localmente.

---

## Solución de problemas comunes

### Error: "la ejecución de scripts está deshabilitada"

Si PowerShell muestra un error similar a:

```powershell
No se puede cargar el archivo deploy.ps1 porque la ejecución de scripts está deshabilitada
```

Ejecuta este comando en PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Luego vuelve a ejecutar:

```powershell
.\deploy.ps1
```

---

### Docker Desktop no está corriendo

Si aparece un error relacionado con Docker:

```powershell
Docker Desktop no esta corriendo
```

Abre Docker Desktop desde el menú inicio y espera a que la ballena 🐳 indique:

```text
Docker Desktop is running
```

---

### El primer despliegue tarda demasiado

Es normal. La primera vez Docker descarga todas las imágenes necesarias (MongoDB, Redis, RabbitMQ, etc.). Dependiendo de tu internet puede tardar varios minutos.

Los siguientes despliegues serán mucho más rápidos.
