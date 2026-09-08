# Fish port of Omarchy's multi-project tmux layout ($OMARCHY_PATH/default/bash/fns/tmux)
function tdlm --description 'One tdl window per subdirectory of the current directory'
    set -l usage "Usage: tdlm [agent] [second_agent] (no agent: your default agent)"
    if contains -- "$argv[1]" -h --help
        echo $usage
        return 0
    end
    if test (count $argv) -gt 2
        echo $usage >&2
        return 1
    end
    if not set -q TMUX
        echo "You must start tmux to use tdlm." >&2
        return 1
    end

    set -l base_dir $PWD

    # tmux disallows dots and colons in session names
    tmux rename-session (path basename $base_dir | string replace --regex --all '[.:]' '-')

    # The window's shell parses the queued command, so every piece is escaped:
    # agent arguments may carry flags and spaces, directory names may carry
    # quotes. send-keys -l keeps tmux from reading the text as key names.
    set -l tdl_command (string join ' ' (string escape -- tdl $argv))

    set -l first true
    for dir in $base_dir/*/
        set -l dirpath (path normalize $dir)

        if test $first = true
            # Reuse the current window for the first project
            tmux send-keys -t $TMUX_PANE -l "cd "(string escape -- $dirpath)" && $tdl_command"
            tmux send-keys -t $TMUX_PANE C-m
            set first false
        else
            set -l pane_id (tmux new-window -c $dirpath -P -F '#{pane_id}')
            tmux send-keys -t $pane_id -l $tdl_command
            tmux send-keys -t $pane_id C-m
        end
    end
end
