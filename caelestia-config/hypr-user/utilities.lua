-- ==========================================
-- Utilidades personales
-- ==========================================

-- Handy: Push-to-Talk con NVIDIA CUDA
local handy_cmd =
    "env CUDA_VISIBLE_DEVICES=0 "
    .. "ORT_PROVIDER=CUDAExecutionProvider "
    .. "ONNXRUNTIME_PROVIDER=CUDA "
    .. "handy --toggle-transcription"

-- Iniciar transcripción al presionar
hl.bind(
    "CTRL + Space",
    hl.dsp.exec_cmd(handy_cmd)
)

-- Finalizar transcripción al soltar
hl.bind(
    "CTRL + Space",
    hl.dsp.exec_cmd(handy_cmd),
    { release = true }
)

-- Bloquear con Caelestia y suspender el equipo
hl.bind(
    "SUPER + SHIFT + L",
    hl.dsp.exec_cmd(
        os.getenv("HOME")
        .. "/.config/caelestia/scripts/lock_and_suspend.sh"
    ),
    { locked = true }
)

-- ==========================================
-- Mantenimiento de Caelestia Shell
-- ==========================================

local manage_caelestia =
    os.getenv("HOME")
    .. "/.config/caelestia/scripts/manage_caelestia.sh"

-- Eliminar posibles binds originales.
hl.unbind("CTRL + SUPER + SHIFT + R")
hl.unbind("CTRL + SUPER + ALT + R")

-- Detener Caelestia.
hl.bind(
    "CTRL + SUPER + SHIFT + R",
    hl.dsp.exec_cmd(manage_caelestia .. " stop")
)

-- Reiniciar Caelestia usando nuestro lanzador.
hl.bind(
    "CTRL + SUPER + ALT + R",
    hl.dsp.exec_cmd(manage_caelestia .. " restart")
)
