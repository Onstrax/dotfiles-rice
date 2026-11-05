# Arquitectura y fuentes de verdad

## Mapa de componentes

```text
GitHub/Onstrax/dotfiles-rice (main)
  └─ ~/dotfiles-rice/
     ├─ caelestia-config/           ← ~/.config/caelestia (enlace)
     │  ├─ hypr-user.lua            ← entrada de módulos propios
     │  ├─ hypr-vars.lua            ← aplicaciones y variables de la integración Lua
     │  ├─ hypr-user/
     │  │  ├─ keybinds.lua          ← binds personales
     │  │  ├─ workspace-rules.lua   ← reglas por clase/ventana
     │  │  ├─ hardware.lua          ← Home Assistant, RGB, música
     │  │  ├─ utilities.lua         ← comandos y suspensión
     │  │  ├─ autostart.lua         ← hook de inicio
     │  │  └─ gestures.lua          ← comentario/gestos específicos
     │  ├─ scripts/autostart.sh     ← lanzamiento de aplicaciones
     │  ├─ scripts/cachy-clean.sh   ← mantenimiento y backups rotativos
     │  ├─ shell.json              ← preferencias Caelestia
     │  └─ patches/                ← herramienta opcional de parches
     ├─ hypr/                      ← configuración Hyprland versionada
     └─ fish/                      ← configuración y funciones Fish versionadas

GitHub/Onstrax/caelestia-rice (juanes-rice)
  └─ ~/.config/quickshell/caelestia/ ← fuente QML; contiene build/lib locales

~/backups-rice/
  ├─ rice-master/                  ← restauración selectiva
  └─ cachy-clean/YYYYMMDD-HHMMSS/ ← hasta 5 generaciones
```

## Qué se carga en la sesión **actual**

- La sesión comprobada usa Hyprland **0.57, Lua**. `~/.config/hypr/hyprland.lua` es la entrada relevante. En la inspección de 2026-11-04 **no existía** `~/.config/hypr/hyprland.conf` como archivo activo, aunque el repositorio conserva uno heredado.
- `~/.config/caelestia/hypr-user.lua` requiere, por este orden: `keybinds`, `workspace-rules`, `hardware`, `utilities`, `autostart`; luego define el teclado `latam,us`.
- `~/.config/caelestia/hypr-vars.lua` define terminal, navegador, editor, explorador y variables de atajos/gestos usadas por la integración Lua.
- `~/.config/caelestia/scripts/autostart.sh` arranca las aplicaciones con comprobación de procesos existentes; `workspace-rules.lua` determina a qué workspace silencioso llega cada ventana.
- El CLI `caelestia` y Quickshell (`qs`) proporcionan la interfaz, bloqueo y comunicación con la shell.

**Advertencia:** los directorios `hypr/hyprland/*.conf` y `caelestia-config/hypr-user.d/*.conf` siguen versionados. No son evidencia de que la sesión los esté cargando. No editar el duplicado heredado para resolver un comportamiento Lua sin verificarlo primero.

## Configuración por categoría

| Quiero cambiar... | Archivo canónico probable |
|---|---|
| Idioma inicial | `caelestia-config/hypr-user.lua` (`kb_layout = "latam,us"`) |
| Aplicaciones por defecto/variables Lua | `caelestia-config/hypr-vars.lua` |
| Atajos personales | `caelestia-config/hypr-user/keybinds.lua` |
| Iluminación de habitación, RGB, música | `caelestia-config/hypr-user/hardware.lua` |
| Bloqueo/suspensión y utilidades | `caelestia-config/hypr-user/utilities.lua` |
| Ventanas y espacios de trabajo | `caelestia-config/hypr-user/workspace-rules.lua` |
| Eventos de arranque | `caelestia-config/hypr-user/autostart.lua` |
| Orden/comandos de programas al iniciar | `caelestia-config/scripts/autostart.sh` |
| Apariencia/opciones de Caelestia | `caelestia-config/shell.json` |
| Componentes de UI | Repositorio `caelestia-rice`, `modules/` y `services/` |
| Función `limpiar` | `fish/functions/limpiar.fish` → `scripts/cachy-clean.sh` |

## Límites del respaldo

`cachy-clean.sh` usa `rsync -a --delete` para copiar las rutas `~/dotfiles-rice`, `~/.config/hypr`, `~/.config/caelestia`, `~/.config/fish`, `~/.config/quickshell/caelestia` y `/etc/xdg/quickshell/caelestia` a una generación nueva. Incluye archivos **no rastreados por Git**, compilados, y posiblemente perfiles o secretos que existan bajo esas rutas; por eso **no debe publicarse**. **No** es imagen de sistema ni copia de paquetes, particiones, kernel o todo `/home`.

`rice-master` tiene un manifiesto y verifica un subconjunto de archivos; no equivale a clonar los dos repositorios y todo CachyOS.
