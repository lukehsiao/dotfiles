# Fish port of Omarchy's tmux dev layout ($OMARCHY_PATH/default/bash/fns/tmux)
function tdl --description 'Tmux dev layout: editor, agent, terminal'
    if test (count $argv) -gt 2
        echo "Usage: tdl [agent] [second_agent]" >&2
        return 1
    end
    if not set -q TMUX
        echo "You must start tmux to use tdl." >&2
        return 1
    end

    set -l agent $AI_AGENT
    test -n "$argv[1]"; and set agent $argv[1]

    set -l current_dir $PWD

    # TMUX_PANE identifies the pane we run in and stays stable even if
    # the active window changes while the layout is being built.
    set -l editor_pane $TMUX_PANE

    tmux rename-window -t $editor_pane (path basename $current_dir)

    # Terminal strip along the bottom 15%, leaving most height for the editor
    tmux split-window -v -l 15% -t $editor_pane -c $current_dir

    # Agent column on the right 30%, wide enough for agent output
    set -l agent_pane (tmux split-window -h -l 30% -t $editor_pane -c $current_dir -P -F '#{pane_id}')

    if test -n "$argv[2]"
        set -l agent2_pane (tmux split-window -v -t $agent_pane -c $current_dir -P -F '#{pane_id}')
        tmux send-keys -t $agent2_pane "$argv[2]" C-m
    end

    tmux send-keys -t $agent_pane "$agent" C-m
    tmux send-keys -t $editor_pane "$EDITOR ." C-m

    tmux select-pane -t $editor_pane
end
