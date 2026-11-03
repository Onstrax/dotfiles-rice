# ==========================================
# Configuración personal Fish
# ==========================================

# Rutas de desarrollo
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/flutter/bin

if test -d /opt/android-sdk
    set -gx ANDROID_HOME /opt/android-sdk
    fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
    fish_add_path $ANDROID_HOME/platform-tools
end

if command -q brave
    set -gx CHROME_EXECUTABLE (command -s brave)
end

# ==========================================
# Yazi: navegar y conservar directorio
# ==========================================

function y --description "Abrir Yazi y cambiar al directorio seleccionado"
    if not command -q yazi
        echo "Yazi no está instalado"
        return 1
    end

    set -l tmp (mktemp -t yazi-cwd.XXXXXX)

    command yazi --cwd-file="$tmp" $argv
    set -l result $status

    if test -s "$tmp"
        set -l cwd (command cat -- "$tmp")

        if test -d "$cwd"
            builtin cd -- "$cwd"
        end
    end

    command rm -f -- "$tmp"
    return $result
end

# ==========================================
# Abreviaciones personales
# ==========================================

abbr --add cl 'clear'
abbr --add cat 'bat'
abbr --add grep 'rg'
abbr --add hist 'history | fzf'
abbr --add rand 'random choice'

abbr --add abbrs 'nano ~/.config/caelestia/user-config.fish'

abbr --add ani 'anifetch -w=71 ~/Videos/man.mp4'
abbr --add snake 'nsnake'
abbr --add tetris 'vitetris'

abbr --add rice '~/.config/caelestia/patches/caelestia-rice/apply-rice-patches.sh'

abbr --add fetch 'fetch --logo ~/.config/fetch/logo.txt --rotate-y'

# ==========================================
# Integraciones opcionales
# ==========================================

if command -q fzf
    fzf --fish | source
end

if command -q thefuck
    thefuck --alias | source
end
