# Environment Variables
set -gx BAT_THEME "Catppuccin Mocha"
set -gx COLORTERM 24bit
set -gx CR_TOKEN (cat ~/.github_token)
set -gx EDITOR hx
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx GITHUB_TOKEN (cat ~/.github_token)
set -gx GRAB_HOME ~/Work
set -gx PASSAGE_AGE rage
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx ZSTD_CLEVEL 19
set -gx ZSTD_NBTHREADS (math (sysctl -n hw.logicalcpu)/2)

# clear fish greeting
set -g fish_greeting

# Path updates
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.poetry/bin

# Configurations
if status --is-interactive
    fzf --fish | source
    starship init fish | source
    zoxide init --cmd cd fish | source
    mise activate fish | source

    set -gx ATUIN_NOBIND true
    atuin init fish | source

    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search

    bind \cE edit_command_buffer
end

# Aliases
function ea
    hx ~/.config/fish/config.fish
    source ~/.config/fish/config.fish && echo "aliases sourced --ok."
end

function chezmoi-cd
    cd (chezmoi source-path)
end

alias vim="nvim"
alias vi="nvim"
alias cat="bat"
alias df="df -h"
alias rg="rg -S"
alias ping="gping"
alias bcp="rsync -avzuhP"
alias sort="gsort"

alias ls="eza -lh --group-directories-first --icons=auto"
alias lsa="ls -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias lta="lt -a"
