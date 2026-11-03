#!/usr/bin/env bash

# Autostart personal del rice.
# No ejecutar repetidamente durante una sesión.

launch() {
    local pattern="$1"
    shift

    # No abrir otra instancia si ya existe un proceso coincidente.
    if pgrep -u "$(id -u)" -f -- "$pattern" >/dev/null 2>&1; then
        echo "Ya abierto: $*"
        return 0
    fi

    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Comando no encontrado: $1" >&2
        return 0
    fi

    echo "Iniciando: $*"
    "$@" >/dev/null 2>&1 &
    sleep 1
}

# Workspace 1
launch '/zen-bin' zen-browser

# Workspace 10
launch 'foot.*foot-init' foot --title foot-init

# Workspace 9
launch '[/ ]dolphin([ ]|$)' dolphin

# Workspace 3
launch '/vesktop/app.asar' vesktop
launch '(^|/)whatsie([ ]|$)' whatsie

# Workspace 5
launch '/obsidian/app.asar' obsidian

# Workspace 7
launch '(^|/)solanum([ ]|$)' solanum

# Workspace 2
launch '(^|/)(code|code-oss)([ ]|$)' code
launch '/desktop-plus' desktop-plus

# Workspace 4
launch 'FFPWA-01M1THMHBMYY2NME59SD1JHBVW' \
    firefoxpwa site launch 01M1THMHBMYY2NME59SD1JHBVW
launch '/prospect-mail' prospect-mail

# Workspace 6
launch '/steam.sh|/steam -' prime-run steam

# Workspace 8
launch 'youtube.music|youtube_music|yt-music' \
    gtk-launch yt-music.desktop

# KDE Connect
launch '(^|/)kdeconnectd([ ]|$)' kdeconnectd
