-- Keybinds personales
-- Se cargan después de los keybinds originales de Caelestia.

-- Liberar Super + Z (antes: mover ventanas)
hl.unbind("SUPER + Z")

-- Super + Z: Zen Browser
hl.bind(
    "SUPER + Z",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^zen$' zen-browser"
    )
)

-- ==========================================
-- Aplicaciones personales
-- ==========================================

-- Brave
hl.bind("SUPER + B", hl.dsp.exec_cmd("brave"))

-- Obsidian (abrir o enfocar)
hl.bind(
    "SUPER + O",
    hl.dsp.exec_cmd(
        os.getenv("HOME") .. "/.config/caelestia/scripts/toggle_obsidian.sh"
    )
)

-- Desktop Plus
hl.bind(
    "SUPER + H",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^desktop-plus$' desktop-plus"
    )
)

-- YouTube Music
hl.bind(
    "SUPER + Y",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^com[.]github[.]th_ch[.]youtube_music$' gtk-launch yt-music.desktop"
    )
)

-- Solanum
hl.bind(
    "SUPER + SHIFT + P",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^(solanum|org.gnome.Solanum)$' solanum"
    )
)

-- ==========================================
-- Aplicaciones personales recuperadas
-- ==========================================

-- Vesktop
hl.bind(
    "SUPER + D",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^vesktop$' vesktop"
    )
)

-- Steam con NVIDIA
hl.bind(
    "SUPER + S",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^steam$' prime-run steam"
    )
)

-- Whatsie
hl.bind(
    "SUPER + W",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^com[.]ktechpit[.]whatsie$' whatsie"
    )
)

-- VS Code: reemplazar el bind original
hl.unbind("SUPER + C")

hl.bind(
    "SUPER + C",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^(code|code-oss)$' code"
    )
)

-- Dolphin: reemplazar el bind original
hl.unbind("SUPER + E")

hl.bind(
    "SUPER + E",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^org.kde.dolphin$' dolphin"
    )
)

-- ==========================================
-- Prospect Mail / Outlook
-- ==========================================

hl.bind(
    "SUPER + SHIFT + O",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^Prospect Mail$' prospect-mail"
    )
)

-- ==========================================
-- Gmail (Firefox PWA)
-- ==========================================

hl.bind(
    "SUPER + G",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/focus_or_launch.sh '^FFPWA-01M1THMHBMYY2NME59SD1JHBVW$' firefoxpwa site launch 01M1THMHBMYY2NME59SD1JHBVW"
    )
)

-- ==========================================
-- Terminal scratchpad: Super + Shift + T
-- ==========================================

hl.bind(
    "SUPER + SHIFT + T",
    hl.dsp.exec_cmd(
        "~/.config/caelestia/scripts/toggle_term.sh"
    )
)

-- ==========================================
-- Cambiar teclado inglés/español
-- Super + Space
-- ==========================================

-- Alternar teclado inglés / español
hl.unbind("SUPER + Space")

hl.bind(
    "SUPER + Space",
    hl.dsp.exec_cmd(
        "hyprctl switchxkblayout at-translated-set-2-keyboard next"
    )
)

-- ==========================================
-- Panel de sesión: Super + Delete
-- ==========================================

hl.bind(
    "SUPER + Delete",
    hl.dsp.exec_cmd(
        "caelestia shell drawers toggle session"
    )
)

