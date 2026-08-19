# Fish port of Omarchy's multi-project tmux layout ($OMARCHY_PATH/default/bash/fns/tmux)
function tdlm --description 'One tdl window per subdirectory of the current directory'
    if test (count $argv) -gt 2
        echo "Usage: tdlm [agent] [second_agent]" >&2
        return 1
    end
    if not set -q TMUX
        echo "You must start tmux to use tdlm." >&2
        return 1
    end

    set -l base_dir $PWD

    # tmux disallows dots and colons in session names
    tmux rename-session (path basename $base_dir | string replace --regex --all '[.:]' '-')

    set -l first true
    for dir in $base_dir/*/
        set -l dirpath (path normalize $dir)

        if test $first = true
            # Reuse the current window for the first project
            tmux send-keys -t $TMUX_PANE "cd '$dirpath' && tdl $argv" C-m
            set first false
        else
            set -l pane_id (tmux new-window -c $dirpath -P -F '#{pane_id}')
            tmux send-keys -t $pane_id "tdl $argv" C-m
        end
    end
end
