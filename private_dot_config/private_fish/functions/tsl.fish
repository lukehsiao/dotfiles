# Fish port of Omarchy's tmux swarm layout ($OMARCHY_PATH/default/bash/fns/tmux)
function tsl --description 'Tmux swarm layout: the same command tiled across N panes'
    if not string match --quiet --regex '^[0-9]+$' -- "$argv[1]"
        echo "Usage: tsl <pane_count> [command]" >&2
        return 1
    end
    if not set -q TMUX
        echo "You must start tmux to use tsl." >&2
        return 1
    end

    set -l count $argv[1]
    set -l cmd $AI_AGENT
    test -n "$argv[2]"; and set cmd $argv[2]

    set -l current_dir $PWD

    tmux rename-window -t $TMUX_PANE (path basename $current_dir)

    set -l panes $TMUX_PANE
    while test (count $panes) -lt $count
        set -l new_pane (tmux split-window -h -t $panes[-1] -c $current_dir -P -F '#{pane_id}')
        set -a panes $new_pane
        # Re-tile after every split so tmux never runs out of room
        tmux select-layout -t $panes[1] tiled
    end

    for pane in $panes
        tmux send-keys -t $pane "$cmd" C-m
    end

    tmux select-pane -t $panes[1]
end
