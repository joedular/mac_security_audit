#!/bin/bash

# ==============================================================================
# Script:          mac_security_audit.sh
# Descripción:     Auditoría global de seguridad, persistencia y red para macOS
# Autor:           Jose Ulloa Araya
# Versión:         4.0.0
# Licencia:        MIT
# ==============================================================================

LOG_FILE="informe_seguridad_$(date +%Y%m%d_%H%M%S).txt"

# Redirigir salida tanto a consola como al archivo de registro
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================="
echo "    AUDITORIA GLOBAL DE SEGURIDAD EN MACOS v4.0   "
echo "    Autor: Jose Ulloa Araya                       "
echo "=================================================="
echo "Informe generado el: $(date)"
echo ""

# ------------------------------------------------
# MODULO 1: PERSISTENCIA Y ELEMENTOS DE INICIO
# ------------------------------------------------
echo "=== [1] PERSISTENCIA Y ELEMENTOS DE INICIO ==="
echo ""

echo "-> Agentes de usuario (~/Library/LaunchAgents):"
ls -la ~/Library/LaunchAgents 2>/dev/null || echo "Carpeta vacía o inaccesible."
echo ""

echo "-> Agentes de sistema (/Library/LaunchAgents):"
ls -la /Library/LaunchAgents 2>/dev/null || echo "Carpeta vacía o inaccesible."
echo ""

echo "-> Demonios de sistema (/Library/LaunchDaemons):"
ls -la /Library/LaunchDaemons 2>/dev/null || echo "Carpeta vacía o inaccesible."
echo ""

echo "-> Verificando archivos anómalos (no .plist) en persistencias:"
ANOMALIAS=$(find ~/Library/LaunchAgents /Library/LaunchAgents /Library/LaunchDaemons -type f ! -name "*.plist" 2>/dev/null)
if [ -n "$ANOMALIAS" ]; then
    echo "¡ATENCION! Se encontraron archivos no-plist:"
    echo "$ANOMALIAS"
    echo ""
    read -p "¿Deseas mover estos archivos a la Papelera? (s/n): " RESP
    if [[ "$RESP" =~ ^[SsYy]$ ]]; then
        mv $ANOMALIAS ~/.Trash/
        echo "Archivos movidos a la Papelera."
    fi
else
    echo "OK: Todas las persistencias tienen extensión .plist legítima."
fi
echo ""

echo "-> Tareas programadas en Cron:"
crontab -l 2>/dev/null || echo "No hay tareas crontab para el usuario actual."
sudo crontab -l 2>/dev/null || echo "No hay tareas crontab a nivel Root."
echo ""

echo "-> Archivos ocultos de autostart:"
ls -la /etc/rc.* /etc/launchd.conf ~/.config/autostart 2>/dev/null || echo "Sin archivos de inicio inusuales."
echo ""

# ------------------------------------------------
# MODULO 2: RED, PROXIES Y PERFILES DE SISTEMA
# ------------------------------------------------
echo "=== [2] RED, PROXIES Y PERFILES ==="
echo ""

echo "-> Perfiles de configuración instalados (MDM / Adware):"
profiles status 2>/dev/null
profiles list 2>/dev/null || echo "No hay perfiles de configuración instalados."
echo ""

echo "-> Servidores DNS configurados:"
scutil --dns | grep 'nameserver\[[0-9]*\]' | sort -u
echo ""

echo "-> Comprobando servidores Proxy activos:"
networksetup -listallnetworkservices | while read service; do
    if [[ "$service" != *"An asterisk"* ]]; then
        proxy=$(networksetup -getwebproxy "$service" 2>/dev/null | grep "Enabled: Yes")
        if [ -n "$proxy" ]; then
            echo "¡ALERTA! Proxy HTTP activo en la interfaz: $service"
        fi
    fi
done
echo ""

echo "-> Verificando redirecciones en el archivo Hosts (/etc/hosts):"
grep -v '^\s*$' /etc/hosts | grep -v '^\s*#'
echo ""

# ------------------------------------------------
# MODULO 3: PROCESOS Y CONEXIONES EN TIEMPO REAL
# ------------------------------------------------
echo "=== [3] PROCESOS Y CONEXIONES ACTIVAS ==="
echo ""

echo "-> Procesos ejecutándose desde carpetas temporales (/tmp /Users/Shared):"
PROC_TMP=$(ps aux | grep -iE '/tmp|/var/tmp|/Users/Shared' | grep -v 'grep')
if [ -n "$PROC_TMP" ]; then
    echo "¡ALERTA! Se detectaron los siguientes procesos:"
    echo "$PROC_TMP"
else
    echo "OK: Sin procesos ejecutándose desde carpetas temporales."
fi
echo ""

echo "-> Conexiones de red externas activas (Top 15):"
lsof -i -P -n | grep -i ESTABLISHED | head -n 15
echo ""

# ------------------------------------------------
# MODULO 4: CERTIFICADOS Y REPOSITORIO DE CLAVES
# ------------------------------------------------
echo "=== [4] REVISION DE CERTIFICADOS Y CA RAIZ ==="
echo ""

echo "-> Certificados raíz personalizados / modificados en el Llavero del Sistema:"
CERTS_RAIZ=$(security dump-keychain /Library/Keychains/System.keychain 2>/dev/null | grep -iE 'labl|desc' | grep -v 'Apple')
if [ -n "$CERTS_RAIZ" ]; then
    echo "Certificados no predeterminados de Apple encontrados en el Llavero del Sistema:"
    echo "$CERTS_RAIZ"
else
    echo "OK: Solo hay certificados estándar del sistema."
fi
echo ""

# ------------------------------------------------
# MODULO 5: ARCHIVOS Y PROTECCIONES DEL SISTEMA
# ------------------------------------------------
echo "=== [5] ARCHIVOS Y ESTADO DE SEGURIDAD ==="
echo ""

echo "-> Instaladores (.dmg / .pkg) recientes en Descargas (últimos 30 días):"
find ~/Downloads -type f \( -name "*.dmg" -o -name "*.pkg" \) -mtime -30 2>/dev/null || echo "Sin instaladores recientes."
echo ""

echo "-> Estado de la protección Gatekeeper:"
spctl --status
echo ""

echo "=================================================="
echo "          AUDITORIA COMPLETA FINALIZADA           "
echo "=================================================="
echo "Resultados guardados automáticamente en: $LOG_FILE"
