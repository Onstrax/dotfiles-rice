# Caelestia Rice Patch System

Sistema interactivo para reaplicar cambios personales despues de una actualizacion de Caelestia.

## Flujo recomendado

1. Actualizar el sistema.
2. Probar Caelestia tal como quedo con los cambios del mantenedor.
3. Si quieres recuperar cambios personales, ejecutar:

```bash
~/.config/caelestia/patches/caelestia-rice/apply-rice-patches.sh
```

Como `~/.config/caelestia` apunta a `~/dotfiles-rice/caelestia-config`, el sistema tambien vive en:

```text
~/dotfiles-rice/caelestia-config/patches/caelestia-rice
```

## Parches incluidos

- RunCat en la barra izquierda.
- Reloj 24h + segundero.
- Festivos de Colombia en calendario.
- CPU/GPU old-style en Performance.
- Timer tab completo.
- Session panel buttons y comandos.
- Delay de hover en dashboard, launcher y utilities.

## Backups

Cada corrida crea backups en:

```text
~/backups-rice/rice-patches/YYYYMMDD-HHMMSS
```

## Variables opcionales

Puedes cambiar rutas sin editar los scripts:

```bash
QS_DIR=/ruta/a/quickshell/caelestia ./apply-rice-patches.sh
BACKUP_ROOT=/ruta/backups ./apply-rice-patches.sh
```

## Notas

Los GIF de `assets/` no se parchean. Si el mantenedor los cambia, se dejan como queden.
