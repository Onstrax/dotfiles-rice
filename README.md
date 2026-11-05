# Juanes · CachyOS / Hyprland / Caelestia rice

Configuración personal **canónica** del escritorio en CachyOS. Rama única: `main`. Repositorio complementario de QML y compilación: [Onstrax/caelestia-rice](https://github.com/Onstrax/caelestia-rice), rama `juanes-rice`.

> Estado de referencia revisado: 2026-11-04; `dotfiles-rice` en `a1232b3`, `caelestia-rice` en `309631c4`. Es una fotografía documental, **no** una versión que deba restaurarse automáticamente en el futuro.

## Dos repositorios, tres mecanismos

| Función | Ruta | Finalidad |
|---|---|---|
| Dotfiles en Git | `~/dotfiles-rice` | Configuración personal y scripts |
| Caelestia QML en Git | `~/.config/quickshell/caelestia` | Fuente personalizada de Quickshell y compilación |
| Copia maestra | `~/backups-rice/rice-master` | Captura local verificable por `restore-rice --check` |
| Instantáneas de mantenimiento | `~/backups-rice/cachy-clean` | Hasta cinco generaciones creadas por `limpiar` |

Los **repositorios** son la fuente de verdad para el código. `rice-master` y `cachy-clean` son mecanismos locales de recuperación con propósitos distintos. **Nunca subir** instantáneas, tokens o perfiles de usuario a Git.

## Lectura inicial

- [Arquitectura y rutas](docs/ARCHITECTURE.md): qué archivo controla cada parte.
- [Instalación y reconstrucción](docs/INSTALLATION.md): recuperación desde una instalación nueva, distinguiendo pasos confirmados y manuales.
- [Mantenimiento](docs/MAINTENANCE.md): flujo seguro Git → pruebas → copia maestra.
- [Caelestia personalizado](https://github.com/Onstrax/caelestia-rice): código QML, construcción y upstream.

## Validación rápida (Fish)

```fish
for repo in ~/dotfiles-rice ~/.config/quickshell/caelestia
    git -C "$repo" status -sb
end
restore-rice --check
hyprctl configerrors
pgrep -af 'qs -c caelestia'
```

Esperado en el estado aprobado: `main...origin/main`, `juanes-rice...origin/juanes-rice`, 47 archivos íntegros y sin errores de Hyprland. El número de archivos puede cambiar si el restaurador evoluciona.

**Nota importante:** Hyprland activo usa **Lua** (`hyprland.lua` y `hypr-user.lua`). El repositorio aún incluye `.conf` heredados, que no deben tomarse como configuración activa sin inspeccionar la carga efectiva.
