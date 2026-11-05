# Mantenimiento y control de cambios

## Principio

La instalación activa es el estado que se prueba; GitHub guarda la versión **aprobada**. `rice-master` se actualiza **después** de probar y hacer push. `cachy-clean` guarda instantáneas previas al mantenimiento, rotando a cinco. No ejecutarlo solo para crear una copia.

## Flujo para cambios personales (Fish)

```fish
# 1. Examinar las diferencias
git -C ~/dotfiles-rice status -sb
git -C ~/dotfiles-rice diff --check
git -C ~/dotfiles-rice diff
# 2. Recargar y probar el escritorio
hyprctl reload
hyprctl configerrors
# 3. Tras probar: stage selectivo, commit, push (NUNCA git add . a ciegas)
# git -C ~/dotfiles-rice add -- RUTA1 RUTA2
# git -C ~/dotfiles-rice commit -m "Descripción"
# git -C ~/dotfiles-rice push origin main
# 4. Solo tras push correcto
# restore-rice --refresh
# restore-rice --check
```

En `caelestia-rice`, rama `juanes-rice`: mismos principios para QML. Evitar cambiar dos repositorios si solo uno tiene modificaciones. Verificar que ambas ramas locales coincidan con `origin`.

## Herramientas existentes

- **`limpiar`**, definida en `fish/functions/limpiar.fish`, ejecuta `~/.config/caelestia/scripts/cachy-clean.sh`. Fue revisada y se decidió **no modificarla**.
- **`cachy-clean.sh`**: primero crea instantánea con `rsync`, retiene cinco directorios; después mirrors CachyOS, `yay -Syu` o `pacman -Syu`, `hyprpm`, cachés, journal, balanceo Btrfs, paquetes huérfanos, TRIM e indexación. Efectúa operaciones reales y algunas destructivas; no ejecutarlo como prueba ni asumir que hace rollback de paquetes.
- **`restore-rice --check`**: compara lo guardado en la copia maestra con el estado actual. `--refresh` sobreescribe la maestra vigente preservando automáticamente la anterior en `rice-master-before-*`. Si se desea exactamente dos carpetas en `~/backups-rice`, borrar **solo después de validar** ese histórico recién creado.
- **Sistema opcional de parches** en `caelestia-config/patches/caelestia-rice/`: herramienta interactiva que, si se ejecuta, crea otros respaldos en `~/backups-rice/rice-patches`; no forma parte del flujo normal y contradice la política de dos directorios hasta limpiarlos conscientemente.

## Antes de actualizar

1. `git status -sb` en ambos repositorios; confirmar limpio y sincronizado.
2. `restore-rice --check`; si ya hay diferencias, investigar antes de refrescar.
3. Comprobar espacio, energía/estabilidad y disponibilidad de red.
4. Ejecutar `limpiar` **solo cuando realmente se desea mantenimiento del sistema**; guardar su salida si ocurre un fallo.

## Después de actualizar

```fish
hyprctl configerrors
pgrep -af 'qs -c caelestia'
git -C ~/dotfiles-rice status -sb
git -C ~/.config/quickshell/caelestia status -sb
restore-rice --check
find ~/backups-rice/cachy-clean -mindepth 1 -maxdepth 1 -type d -printf '%f
'
```

Probar audio, teclas especiales, luz, bloqueo, workspaces y VS Code. Si el fallo proviene de paquetes (kernel, driver, plugin), **las copias de configuración no revierten esos paquetes**: usar mecanismos de recuperación del sistema adecuados.

## Condiciones para detenerse

- Diferencias no entendidas en `git status`.
- `restore-rice --check` falla antes de refrescar.
- `hyprctl configerrors` devuelve errores.
- El destino de `rsync` no está verificado.
- `git pull` o rebase propone integrar upstream sin revisión de cambios personalizados.

## Seguridad

Credenciales fuera de Git; `~/.config/homeassistant-rice/token` no se versiona. Los snapshots locales pueden copiar información sensible: no publicarlos ni adjuntarlos íntegros. No almacenar claves, números de serie ni secretos en documentación.
