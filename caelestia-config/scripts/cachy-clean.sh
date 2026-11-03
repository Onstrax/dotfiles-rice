#!/usr/bin/env bash

# Estética y Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}🚀 Iniciando Mantenimiento Integral de CachyOS${NC}\n"

# 0. Backups de Seguridad (Configuraciones críticas)
echo -e "${YELLOW}🔹 0/10 Creando backups con timestamp...${NC}"

BACKUP_ROOT="/home/juanes/backups-rice/cachy-clean"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
MAX_BACKUPS=5

mkdir -p "$BACKUP_DIR"

RUTAS_BACKUP=(
    "/home/juanes/dotfiles-rice|repo-dotfiles-rice|no"
    "/home/juanes/.config/hypr|hypr-activo|no"
    "/home/juanes/.config/caelestia|caelestia-config-activa|no"
    "/home/juanes/.config/fish|fish-activo|no"
    "/home/juanes/.config/quickshell/caelestia|repo-caelestia-rice|no"
    "/etc/xdg/quickshell/caelestia|etc-xdg-quickshell-caelestia|yes"
)

for item in "${RUTAS_BACKUP[@]}"; do
    IFS="|" read -r origen nombre requiere_sudo <<< "$item"
    destino="${BACKUP_DIR}/${nombre}"

    if [ -d "$origen" ]; then
        echo -e "   Backup: $origen -> $destino"
        mkdir -p "$destino"

        if [ "$requiere_sudo" = "yes" ]; then
            sudo rsync -a --delete --chown=juanes:juanes \
                "${origen}/" "${destino}/" || exit 1
        else
           rsync -a --delete \
               "${origen}/" "${destino}/" || exit 1
        fi
    else
        echo -e "${RED}   ✖ Falta una ruta de backup: $origen. No se rotarán backups.${NC}"
        exit 1
    fi
done

# Solo rotar después de que todas las copias finalizaron sin errores.
echo -e "   Rotando backups: conservando solo los ${MAX_BACKUPS} más recientes..."

if [ -n "$BACKUP_ROOT" ] && [ -d "$BACKUP_ROOT" ]; then
    mapfile -t BACKUPS_ANTIGUOS < <(
        find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d \
            -printf "%T@ %p\n" | sort -rn | tail -n +$((MAX_BACKUPS + 1)) | cut -d' ' -f2-
    )

    for backup_antiguo in "${BACKUPS_ANTIGUOS[@]}"; do
        echo -e "   Eliminando backup antiguo: $backup_antiguo"
        rm -rf "$backup_antiguo"
    done
fi

echo -e "${GREEN}✅ Backup creado en: ${BACKUP_DIR}${NC}"
echo -e "${GREEN}✅ Backups finalizados.${NC}\n"

# 1. Optimizar Mirrors (CachyOS específico)
echo -e "\n${YELLOW}🔹 1/10 Optimizando espejos (Mirrors) para máxima velocidad...${NC}"
sudo cachyos-rate-mirrors || { echo -e "${RED}Falló la actualización de mirrors.${NC}"; exit 1; }
# Evitar pacman -Sy aislado (sincronización sin actualización): yay/pacman -Syu lo hace junto.

# 2. Actualización de Sistema y AUR
echo -e "${YELLOW}🔹 2/10 Actualizando sistema y paquetes AUR...${NC}"
if command -v yay &> /dev/null; then
    yay -Syu --noconfirm || { echo -e "${RED}La actualización falló; se cancela la limpieza.${NC}"; exit 1; }
else
    sudo pacman -Syu --noconfirm || { echo -e "${RED}La actualización falló; se cancela la limpieza.${NC}"; exit 1; }
fi
# Sincronizar plugins de Hyprland inmediatamente
echo -e "${YELLOW}   ➔ Sincronizando plugins de Hyprland...${NC}"
if command -v hyprpm >/dev/null 2>&1; then
    if hyprpm update; then
        if ! hyprpm reload; then
            echo -e "${RED}⚠️ Falló la recarga de plugins de Hyprland.${NC}"
        fi
    else
        echo -e "${RED}⚠️ Falló la actualización de plugins. No se recargarán.${NC}"
    fi
fi

# 3. Limpieza de Caché de Paquetes
echo -e "\n${YELLOW}🔹 3/10 Limpiando caché de paquetes antiguos (dejando los últimos 2)...${NC}"
# Eliminar solo directorios temporales (no tocar otros archivos de caché).
sudo find /var/cache/pacman/pkg -mindepth 1 -maxdepth 1 -type d -name 'download-*' -exec rm -rf -- {} +
sudo paccache -r -k 2
if command -v yay >/dev/null 2>&1; then
    yay -Sc --noconfirm
fi

# 4. Limpieza de Logs
echo -e "\n${YELLOW}🔹 4/10 Limpiando registros del sistema (logs) mayores a 7 días...${NC}"
sudo journalctl --vacuum-time=7d

# 5. Btrfs: Mantenimiento del Sistema de Archivos
echo -e "\n${YELLOW}🔹 5/10 Revisando y balanceando Btrfs...${NC}"
sudo btrfs filesystem df /
if ! sudo btrfs balance start -dusage=75 -musage=75 /; then
    echo -e "${RED}⚠️ Falló el balanceo Btrfs; comprueba: sudo btrfs balance status /${NC}"
fi

# 6. Limpiar Dependencias Huérfanas
echo -e "\n${YELLOW}🔹 6/10 Eliminando paquetes huérfanos...${NC}"
mapfile -t paquetes_huerfanos < <(pacman -Qdtq)
if ((${#paquetes_huerfanos[@]})); then
    printf '   Huérfanos: %s\n' "${paquetes_huerfanos[*]}"
    sudo pacman -Rns --noconfirm -- "${paquetes_huerfanos[@]}"
else
    echo -e "${GREEN}No hay huérfanos que limpiar.${NC}"
fi

# 7. SSD Trim
echo -e "\n${YELLOW}🔹 7/10 Optimizando celdas del SSD (fstrim)...${NC}"
sudo fstrim -v /

# 8. Actualizar DB de búsqueda (plocate)
echo -e "\n${YELLOW}🔹 8/10 Indexando archivos para búsqueda rápida (updatedb)...${NC}"
sudo ionice -c3 nice -n 10 updatedb

# 9. Diagnóstico Final
echo -e "\n${BLUE}${BOLD}🔍 Diagnóstico de errores:${NC}"
FAILED_SERVICES=$(systemctl --failed --no-legend --plain | grep -c . || true)
if [ "$FAILED_SERVICES" -eq "0" ]; then
    echo -e "${GREEN}✅ No hay servicios fallidos.${NC}"
else
    echo -e "${RED}❌ Hay $FAILED_SERVICES servicios fallidos. Revisa con: systemctl --failed${NC}"
fi

echo -e "\n${BLUE}Espacio libre final:${NC}"
df -h / /home
echo -e "\n${GREEN}${BOLD}✨ Mantenimiento completado.${NC}"
