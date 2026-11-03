-- ==========================================
-- Hardware y dispositivos personales
-- ==========================================

-- Home Assistant: Ctrl + Shift + 0-9
-- Control de intensidad de las luces del cuarto

local script = os.getenv("HOME")
    .. "/.config/caelestia/scripts/brillo_luz.sh"

for i = 0, 9 do
    local key = "CTRL + SHIFT + " .. tostring(i)

    hl.bind(
        key,
        hl.dsp.exec_cmd(script .. " " .. tostring(i)),
        { locked = true }
    )
end

-- ==========================================
-- Home Assistant: rotación de colores
-- Ctrl + Shift + tecla a la izquierda del 1
-- ==========================================

hl.bind(
    "CTRL + SHIFT + grave",
    hl.dsp.exec_cmd(
        os.getenv("HOME")
        .. "/.config/caelestia/scripts/color_luz.sh"
    )
)

-- ==========================================
-- Calculadora
-- ==========================================

-- F1: nueva calculadora flotante escalonada
hl.bind(
    "F1",
    hl.dsp.exec_cmd(
        os.getenv("HOME")
        .. "/.config/caelestia/scripts/open_qalculate.sh"
    )
)

-- ==========================================
-- Teclado MSI: RGB persistente
-- ==========================================

local rgb_script =
    os.getenv("HOME")
    .. "/.config/caelestia/scripts/keyboard_rgb.sh"

-- F7: apagar, conservando el último efecto
hl.bind(
    "F7",
    hl.dsp.exec_cmd(rgb_script .. " off")
)

-- F8: restaurar si está apagado; avanzar si está encendido
hl.bind(
    "F8",
    hl.dsp.exec_cmd(rgb_script .. " next")
)

-- ==========================================
-- Controles multimedia
-- ==========================================

hl.bind(
    "F9",
    hl.dsp.exec_cmd("playerctl play-pause")
)

hl.bind(
    "F10",
    hl.dsp.exec_cmd("playerctl previous")
)

hl.bind(
    "F11",
    hl.dsp.exec_cmd("playerctl next")
)
