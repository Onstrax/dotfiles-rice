#!/usr/bin/env bash

# Estética y Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}🚀 Iniciando Mantenimiento Integral de CachyOS${NC}\n"

# # 0. Backups de Seguridad (Configuraciones críticas)
# echo -e "${YELLOW}🔹 0/10 Creando copias de seguridad (.bak)...${NC}"

# # Lista de directorios a respaldar
# DIRECTORIOS=(
#     "/home/juanes/.config/hypr"
#     "/home/juanes/.config/caelestia"
#     "/etc/xdg/quickshell/caelestia"
# )

# for dir in "${DIRECTORIOS[@]}"; do
#     if [ -d "$dir" ]; then
#         echo -e "   Backing up: $dir -> ${dir}.bak"
#         # rsync -a: mantiene permisos y es recursivo
#         # --delete: borra en el .bak lo que ya no existe en el origen
#         sudo rsync -a --delete "${dir}/" "${dir}.bak/"
#     else
#         echo -e "${RED}   ⚠️  Advertencia: $dir no existe, saltando...${NC}"
#     fi
# done
# echo -e "${GREEN}✅ Backups finalizados.${NC}\n"

# 0. Backups de Seguridad (Configuraciones críticas)
echo -e "${YELLOW}🔹 0/10 Creando backups con timestamp...${NC}"

BACKUP_ROOT="/home/juanes/backups-rice/cachy-clean"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
MAX_BACKUPS=5

mkdir -p "$BACKUP_DIR"

# Formato:
# "origen|nombre-amigable-en-backup|requiere-sudo"
RUTAS_BACKUP=(
    "/home/juanes/.config/caelestia|home-config-caelestia|no"
    "/home/juanes/.config/quickshell/caelestia|home-config-quickshell-caelestia|no"
    "/home/juanes/.config/hypr|home-config-hypr|no"
    "/home/juanes/.local/share/caelestia/hypr|home-local-share-caelestia-hypr|no"
    "/etc/xdg/quickshell/caelestia|etc-xdg-quickshell-caelestia|yes"
)

for item in "${RUTAS_BACKUP[@]}"; do
    IFS="|" read -r origen nombre requiere_sudo <<< "$item"
    destino="${BACKUP_DIR}/${nombre}"

    if [ -d "$origen" ]; then
        echo -e "   Backup: $origen -> $destino"

        mkdir -p "$destino"

        if [ "$requiere_sudo" = "yes" ]; then
            sudo rsync -a --delete --chown=juanes:juanes "${origen}/" "${destino}/"
        else
            rsync -a --delete "${origen}/" "${destino}/"
        fi
    else
        echo -e "${RED}   ⚠️  Advertencia: $origen no existe, saltando...${NC}"
    fi
done

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

# 1. Actualización de Sistema y AUR
echo -e "${YELLOW}🔹 1/10 Actualizando sistema y paquetes AUR...${NC}"
if command -v yay &> /dev/null; then
    yay -Syu --noconfirm
else
    sudo pacman -Syu --noconfirm
fi
# Sincronizar plugins de Hyprland inmediatamente
echo -e "${YELLOW}   ➔ Sincronizando plugins de Hyprland...${NC}"
hyprpm update && hyprpm reload

# 2. Limpieza de Caché de Paquetes
echo -e "\n${YELLOW}🔹 2/10 Limpiando caché de paquetes antiguos (dejando los últimos 2)...${NC}"
sudo rm -rf /var/cache/pacman/pkg/download-*
sudo paccache -r -k 2
yay -Sc --noconfirm

# 3. Limpieza de Logs
echo -e "\n${YELLOW}🔹 3/10 Limpiando registros del sistema (logs) mayores a 7 días...${NC}"
sudo journalctl --vacuum-time=7d

# 4. Btrfs: Mantenimiento del Sistema de Archivos
echo -e "\n${YELLOW}🔹 4/10 Revisando y balanceando Btrfs...${NC}"
sudo btrfs filesystem df /
sudo btrfs balance start -dusage=75 -musage=75 / || echo "No se requería balanceo pesado."

# 5. Limpiar Dependencias Huérfanas
echo -e "\n${YELLOW}🔹 5/10 Eliminando paquetes huérfanos...${NC}"
if [ -n "$(pacman -Qdtq)" ]; then
    sudo pacman -Rns $(pacman -Qdtq) --noconfirm
else
    echo -e "${GREEN}No hay huérfanos que limpiar.${NC}"
fi

# 6. Optimizar Mirrors (CachyOS específico)
echo -e "\n${YELLOW}🔹 6/10 Optimizando espejos (Mirrors) para máxima velocidad...${NC}"
sudo cachyos-rate-mirrors
sudo pacman -Sy

# 7. SSD Trim
echo -e "\n${YELLOW}🔹 7/10 Optimizando celdas del SSD (fstrim)...${NC}"
sudo fstrim -v /

# 8. Actualizar DB de búsqueda (plocate)
echo -e "\n${YELLOW}🔹 8/10 Indexando archivos para búsqueda rápida (updatedb)...${NC}"
sudo updatedb

# 9. Diagnóstico Final
echo -e "\n${BLUE}${BOLD}🔍 Diagnóstico de errores:${NC}"
FAILED_SERVICES=$(systemctl --failed --quiet | grep "loaded" | wc -l)
if [ "$FAILED_SERVICES" -eq "0" ]; then
    echo -e "${GREEN}✅ No hay servicios fallidos.${NC}"
else
    echo -e "${RED}❌ Hay $FAILED_SERVICES servicios fallidos. Revisa con: systemctl --failed${NC}"
fi

echo -e "\n${GREEN}${BOLD}✨ Mantenimiento completado con éxito.${NC}"