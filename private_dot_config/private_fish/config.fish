# Initialize starship
starship init fish | source

# Aliases
function ea
    vim ~/.config/fish/config.fish
    source ~/.config/fish/config.fish && echo "aliases sourced --ok."
end

alias cat="bat"
alias df="df -h"
alias rg="rg -S -p"
alias ping="prettyping --nolegend"
alias bcp="rsync -avzuhP"
alias lofi="mpv \"https://www.youtube.com/watch?v=5qap5aO4i9A\" --no-video &> /dev/null"
alias cal="ncal -bS"

alias ls="exa"
alias ll="ls -l --group-directories-first"
alias la="ll -a"
alias tree="ls -T"

function pdfembed
    pdftocairo -pdf $argv[1] emb_$argv[1] &&
    echo "Embedded output: emb_$argv[1]"
end
