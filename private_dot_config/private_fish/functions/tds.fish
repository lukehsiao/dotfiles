# Fish port of Omarchy's tmux dev square ($OMARCHY_PATH/default/bash/fns/tmux)
function tds --description 'Tmux dev square: editor, diff watch, terminal, agent'
    if test (count $argv) -gt 1
        echo "Usage: tds [agent]" >&2
        return 1
    end
    if not set -q TMUX
        echo "You must start tmux to use tds." >&2
        return 1
    end

    set -l agent $AI_AGENT
    test -n "$argv[1]"; and set agent $argv[1]

    set -l current_dir $PWD
    set -l editor_pane $TMUX_PANE

    tmux rename-window -t $editor_pane (path basename $current_dir)

    # Even four-way square: editor top left, diff watch top right,
    # terminal bottom left, agent bottom right
    set -l terminal_pane (tmux split-window -v -l 50% -t $editor_pane -c $current_dir -P -F '#{pane_id}')
    set -l diff_pane (tmux split-window -h -l 50% -t $editor_pane -c $current_dir -P -F '#{pane_id}')
    set -l agent_pane (tmux split-window -h -l 50% -t $terminal_pane -c $current_dir -P -F '#{pane_id}')

    tmux send-keys -t $editor_pane -l "$EDITOR ."
    tmux send-keys -t $editor_pane C-m
    tmux send-keys -t $diff_pane -l "hunk diff 'trunk()..@' --watch"
    tmux send-keys -t $diff_pane C-m
    tmux send-keys -t $agent_pane -l "$agent"
    tmux send-keys -t $agent_pane C-m

    tmux select-pane -t $editor_pane
end
