set -x PATH $PATH /home/juanes/.cargo/bin
set -gx PATH /home/juanes/.local/flutter/bin $PATH
set -gx CHROME_EXECUTABLE (which brave)
fish_add_path /home/juanes/.local/flutter/bin
set -gx ANDROID_HOME /opt/android-sdk
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/platform-tools

# Aceleración por hardware global para modelos de IA locales
set -gx CUDA_VISIBLE_DEVICES 0
set -gx ORT_PROVIDER CUDAExecutionProvider
set -gx ONNXRUNTIME_PROVIDER CUDA

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi --cwd-file="$tmp" $argv
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

if status is-interactive
    # Starship custom prompt
    starship init fish | source
    zoxide init fish | source
    thefuck --alias | source
    fzf --fish | source
    source /usr/share/cachyos-fish-config/cachyos-config.fish

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    abbr cl 'clear'
    abbr cat 'bat'
    abbr hist 'history | fzf'
    abbr prev "fzf --preview 'bat --style=numbers --color=always {}'"
    abbr grep 'rg'
    abbr rand 'random choice'
    abbr abbrs 'nano ~/.config/fish/config.fish'
    abbr ani 'anifetch -w=71 /home/juanes/Videos/man.mp4'
    abbr snake 'nsnake'
    abbr tetris 'vitetris'
    abbr rice '~/.config/caelestia/patches/caelestia-rice/apply-rice-patches.sh'
    abbr fetch 'fetch --logo ~/.config/fetch/logo.txt --rotate-y'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end
