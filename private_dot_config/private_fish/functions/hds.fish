# Fish port of Omarchy's herdr dev square ($OMARCHY_PATH/default/bash/fns/herdr)
function hds --description 'Herdr dev square: editor, diff watch, terminal, agent'
    if test (count $argv) -gt 1
        echo "Usage: hds [agent]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hds." >&2
        return 1
    end

    set -l agent $AI_AGENT
    test -n "$argv[1]"; and set agent $argv[1]

    set -l current_dir $PWD
    set -l editor_pane $HERDR_PANE_ID

    herdr tab rename $HERDR_TAB_ID (path basename $current_dir) >/dev/null

    # Even four-way square: editor top left, diff watch top right,
    # terminal bottom left, agent bottom right
    set -l terminal_pane (_herdr_split $editor_pane down 0.5 $current_dir)
    set -l diff_pane (_herdr_split $editor_pane right 0.5 $current_dir)
    set -l agent_pane (_herdr_split $terminal_pane right 0.5 $current_dir)

    herdr pane run $editor_pane "$EDITOR ." >/dev/null
    herdr pane run $diff_pane "hunk diff 'trunk()..@' --watch" >/dev/null
    herdr pane run $agent_pane "$agent" >/dev/null
end
