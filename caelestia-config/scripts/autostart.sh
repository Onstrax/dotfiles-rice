#!/bin/bash

# Función para lanzar apps con un pequeño retraso
launch() {
    $1 &
    sleep 0.5
}

# 1. Apps con clase personalizada (para que la regla solo les afecte a ellas)
launch "zen-browser --class=zen-init"    # Brave usa el signo =
launch "foot --title foot-init"      # Usaremos el título para foot
launch "dolphin"

# 2. El resto de aplicaciones
launch "vesktop"
launch "whatsie"
launch "obsidian"
launch "solanum"
launch "code"
launch "desktop-plus"
launch "firefoxpwa site launch 01M1THMHBMYY2NME59SD1JHBVW"
launch "prospect-mail"
launch "prime-run steam"
launch "gtk-launch yt-music.desktop"