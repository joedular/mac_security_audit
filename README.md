# macOS Security Audit Script

Un script de bash ligero e integral diseñado para auditar la seguridad, detectar elementos de persistencia, revisar configuraciones de red y analizar procesos activos en sistemas macOS.

**Autor:** Jose Ulloa Araya  
**Versión:** 4.0.0  
**Licencia:** MIT  

---

## Características

* **Persistencia:** Revisa LaunchAgents, LaunchDaemons, Cron jobs y scripts de inicio automático.
* **Red y DNS:** Detecta perfiles de configuración (MDM/Adware), proxies activos, DNS modificados y alteraciones en `/etc/hosts`.
* **Procesos y Conexiones:** Identifica procesos corriendo desde carpetas temporales (`/tmp`, `/Users/Shared`) y conexiones red activas.
* **Certificados:** Escanea el Llavero del Sistema buscando Autoridades Certificadoras (CA) o certificados raíz no nativos.
* **Integridad del Sistema:** Comprueba el estado de Gatekeeper e instaladores recientes en la carpeta de Descargas.
* **Reportes Automáticos:** Exporta automáticamente los hallazgos a un archivo de texto `.txt` con marca de tiempo.

---

## Uso

1. Clona este repositorio o descarga el archivo `mac_security_audit.sh`:
   ```bash
   git clone https://github.com/joedular/mac-security-audit.git
   cd mac-security-audit

2. Otorga permisos de ejecución al script:
    ```bash
    chmod +x mac_security_audit.sh

3. Ejecuta el script en la Terminal:
    ```bash
    ./mac_security_audit.sh
