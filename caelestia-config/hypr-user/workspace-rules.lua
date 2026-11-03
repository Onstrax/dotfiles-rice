-- ==========================================
-- Reglas personales de workspaces
-- ==========================================

-- Vesktop: quitar la etiqueta que lo envía
-- al workspace especial de comunicación.
hl.window_rule({
    match = { class = "^vesktop$" },
    tag = "-communication_app",
})

-- Vesktop: abrir en workspace normal 3.
hl.window_rule({
    match = { class = "^vesktop$" },
    workspace = "3 silent",
})

-- ==========================================
-- Distribucion personal de workspaces
-- ==========================================

-- Workspace 1: Zen Browser
hl.window_rule({
    match = { class = "^zen$" },
    workspace = "1 silent",
})

-- Workspace 2: VS Code
hl.window_rule({
    match = { class = "^(code|code-oss)$" },
    workspace = "2 silent",
})

-- Workspace 2: Desktop Plus
hl.window_rule({
    match = { class = "^desktop-plus$" },
    workspace = "2 silent",
})

-- Workspace 7: Solanum
hl.window_rule({
    match = { class = "^(solanum|org.gnome.Solanum)$" },
    workspace = "7 silent",
})

-- Workspace 9: Dolphin
hl.window_rule({
    match = { class = "^org.kde.dolphin$" },
    workspace = "9 silent",
})

-- Whatsie: workspace normal 3
hl.window_rule({
    match = { class = "^com[.]ktechpit[.]whatsie$" },
    workspace = "3 silent",
})

-- Steam: workspace normal 6
hl.window_rule({
    match = { class = "^steam$" },
    workspace = "6 silent",
})

-- YouTube Music: workspace normal 8
hl.window_rule({
    match = { class = "^com[.]github[.]th_ch[.]youtube_music$" },
    workspace = "8 silent",
})

-- Prospect Mail: workspace 4
hl.window_rule({
    match = { class = "^Prospect Mail$" },
    workspace = "4 silent",
})

-- Gmail Firefox PWA: workspace 4
hl.window_rule({
    match = { class = "^FFPWA-01M1THMHBMYY2NME59SD1JHBVW$" },
    workspace = "4 silent",
})

-- Obsidian: workspace 5
hl.window_rule({
    match = { class = "^(md[.]obsidian[.]Obsidian|obsidian|Obsidian)$" },
    workspace = "5 silent",
})

-- ==========================================
-- Terminal scratchpad
-- ==========================================

hl.window_rule({
    match = { class = "^scratchpad$" },
    workspace = "special:term",
})

-- ==========================================
-- Qalculate: calculadora flotante y centrada
-- ==========================================

hl.window_rule({
    match = { class = "^(qalculate-gtk|Qalculate-gtk|qalculate)$" },
    float = true,
    center = true,
    size = { 620, 520 },
})

-- ==========================================
-- Foot inicial: workspace 10
-- ==========================================

hl.window_rule({
    match = {
        class = "^foot$",
        title = "^foot-init$",
    },
    workspace = "10 silent",
})
