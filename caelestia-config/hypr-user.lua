-- ==========================================
-- Configuraciones personales de Hyprland
-- ==========================================

-- Atajos personalizados
require("hypr-user.keybinds")

-- Reglas de ubicación de aplicaciones
require("hypr-user.workspace-rules")

-- Modulos de Hardware
require("hypr-user.hardware")

-- Modulo de utilidades
require("hypr-user.utilities")

-- Inicio automático de aplicaciones personales
require("hypr-user.autostart")

-- Evitar eventos duplicados de brillo del dispositivo ACPI.
-- Las teclas Fn siguen funcionando desde el teclado principal.
hl.device({
    name = "video-bus",
    keybinds = false,
})

-- ==========================================
-- Distribuciones de teclado personales
-- ==========================================

hl.config({
    input = {
        kb_layout = "latam,us",
        kb_variant = ",",
    },
})
