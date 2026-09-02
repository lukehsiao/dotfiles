# Fish port of Omarchy's herdr dev layout ($OMARCHY_PATH/default/bash/fns/herdr)
function hdl --description 'Herdr dev layout: editor, agent, terminal'
    if test (count $argv) -gt 2
        echo "Usage: hdl [agent] [second_agent]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hdl." >&2
        return 1
    end

    set -l agent $AI_AGENT
    test -n "$argv[1]"; and set agent $argv[1]

    set -l current_dir $PWD

    # HERDR_PANE_ID identifies the pane we run in and stays stable even if
    # the focused pane changes while the layout is being built.
    set -l editor_pane $HERDR_PANE_ID

    herdr tab rename $HERDR_TAB_ID (path basename $current_dir) >/dev/null

    # Terminal strip along the bottom 15%, leaving most height for the editor
    _herdr_split $editor_pane down 0.85 $current_dir >/dev/null

    # Agent column on the right 30%, wide enough for agent output
    set -l agent_pane (_herdr_split $editor_pane right 0.7 $current_dir)

    if test -n "$argv[2]"
        set -l agent2_pane (_herdr_split $agent_pane down 0.5 $current_dir)
        herdr pane run $agent2_pane "$argv[2]" >/dev/null
    end

    herdr pane run $agent_pane "$agent" >/dev/null
    herdr pane run $editor_pane "$EDITOR ." >/dev/null
end
