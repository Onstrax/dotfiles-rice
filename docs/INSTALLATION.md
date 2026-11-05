# Instalación y recuperación desde cero

> **Estado:** guía de reconstrucción parcial basada en rutas y repositorios verificados, no instalador automatizado ni procedimiento de reinstalación integral probado. Probar las dependencias en cada equipo antes de asumir que el sistema quedará idéntico.

## 0. Requisitos y alcance

- CachyOS/Arch con Hyprland **compatible con configuración Lua**; en la sesión aprobada se utilizó Hyprland 0.57.
- Fish, Git, GitHub SSH y acceso a ambos repositorios.
- Quickshell, CLI de Caelestia, compilador CMake/Ninja y dependencias de la versión QML clonada.
- Herramientas de usuario necesarias según los scripts: `jq`, `rsync`, `playerctl`, `hyprctl`, `foot`, `code`, `docker` (Home Assistant), `msi-perkeyrgb`, etc. Los programas de autostart son opcionales, pero fallarán si faltan.
- Hardware y monitor son específicos de este equipo; no reutilizar reglas de monitores o RGB a ciegas.

**Fuera de Git:** contraseñas, tokens Home Assistant, cuentas/autenticación, paquetes del sistema, configuración de servicios externos, compilados y estados de las aplicaciones. Reconstruirlos por separado.

## 1. Clonar sin sobrescribir configuraciones existentes

```fish
# Ejecutar solo tras confirmar que las rutas están libres:
test ! -e ~/dotfiles-rice; and git clone -b main git@github.com:Onstrax/dotfiles-rice.git ~/dotfiles-rice
mkdir -p ~/.config/quickshell
test ! -e ~/.config/quickshell/caelestia; and git clone -b juanes-rice git@github.com:Onstrax/caelestia-rice.git ~/.config/quickshell/caelestia
```

**No** mover ni borrar directorios de configuración existentes en una máquina con trabajo previo sin inspección. La configuración activa usa `~/.config/caelestia` como enlace a `~/dotfiles-rice/caelestia-config`; reinstalar el resto de enlaces y la estructura `~/.config/hypr`, `~/.config/fish` **solo después** de confirmar la topología real del sistema que se va a reconstruir. No se incluye un comando de `ln -sfn` destructivo deliberadamente.

## 2. Comprobar el código antes de usarlo

```fish
git -C ~/dotfiles-rice branch --show-current
git -C ~/.config/quickshell/caelestia branch --show-current
git -C ~/dotfiles-rice status -sb
git -C ~/.config/quickshell/caelestia status -sb
```

Esperado: `main` y `juanes-rice`, sin modificaciones locales.

## 3. Compilar la shell (instalación manual; revisar antes de ejecutar)

El README original upstream del repositorio Caelestia explica sus dependencias, opciones CMake y rutas de instalación. **La copia fuente local no basta**: el proyecto utiliza plugin C++/QML, `build/`, `lib/` e instalación del sistema.

Ejemplo de **referencia upstream**, no ejecutado ni validado para una reinstalación nueva:

```fish
cd ~/.config/quickshell/caelestia
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
# Tras revisar el destino de instalación de esta versión:
# sudo cmake --install build
```

Verificar destino de librerías, QML y CLI antes de utilizar `sudo`. Instalar dependencias indicadas en el README original que corresponda exactamente al commit elegido; puede cambiar con upstream.

## 4. Recuperar las personalizaciones externas

- Recrear las rutas `~/.config/caelestia`, `~/.config/hypr` y `~/.config/fish` según los enlaces/archivos del equipo (ver [arquitectura](ARCHITECTURE.md)).
- Asegurar que `~/.config/hypr/hyprland.lua` arranque la configuración adecuada.
- Revisar `~/.config/caelestia/hypr-user.lua` y `hypr-vars.lua`; los binds y reglas están en módulos Lua.
- Configurar monitores, clase de teclado, GPU y RGB para el hardware nuevo.
- Recrear secretos **fuera de Git**, como `~/.config/homeassistant-rice/token`, con permisos privados y valores nuevos. Nunca copiarlos a README, commits ni incidencias.
- Verificar el lanzador `~/.local/bin/start-caelestia.fish` y el comando `caelestia` antes de iniciar la sesión. La ubicación de este lanzador no aparece entre los archivos versionados de `dotfiles-rice`: hay que restaurarlo desde una fuente propia confiable o reconstruir su función y verificarlo manualmente.

## 5. Prueba de aceptación

```fish
hyprctl configerrors
hyprctl devices -j | jq -r '.keyboards[] | .name + " → " + .active_keymap'
pgrep -af 'qs -c caelestia'
```

Después de iniciar sesión: probar idioma latinoamericano y `Super+Espacio`, atajos bloqueados, autostart y workspaces (VS Code clase `com.microsoft.VSCode` en el 2), audio, RGB, Home Assistant, bloqueo y suspensión. Solo cuando todo funcione, crear la copia maestra con `restore-rice --refresh` (si la utilidad está instalada).

## 6. Recuperación sin reinstalación

Para errores en archivos **versionados**, preferir `git diff`, comparación con `origin` y restauración selectiva; para fallos tras `limpiar`, examinar primero la instantánea `cachy-clean/YYYYMMDD-HHMMSS` correspondiente. No hacer sincronización masiva con `--delete` sobre las configuraciones activas sin inspeccionar destino, origen y diferencias.
