-- ==========================================
-- Autostart personal del rice
-- ==========================================

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
    hl.exec_cmd(
        home .. "/.config/caelestia/scripts/autostart.sh"
    )
end)
