function copy --description "Copy stdin to clipboard via OSC 52"
    set -l tmp (mktemp)
    cat >$tmp
    set -l data (base64 < $tmp | tr -d '\n')
    rm -f $tmp
    if set -q TMUX
        printf "\033Ptmux;\033\033]52;c;%s\007\033\\" $data
    else
        printf "\033]52;c;%s\007" $data
    end
end
