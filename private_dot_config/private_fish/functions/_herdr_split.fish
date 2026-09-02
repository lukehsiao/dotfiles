# Fish port of Omarchy's herdr split helper ($OMARCHY_PATH/default/bash/fns/herdr)
function _herdr_split --description 'Split a herdr pane and echo the id of the new pane'
    set -l pane_id $argv[1]
    set -l direction $argv[2]
    set -l ratio $argv[3]
    set -l cwd $argv[4]

    # The ratio is the share the original pane keeps, so 0.85 down leaves the
    # new pane the bottom 15%. Splits never steal focus without --focus.
    herdr pane split $pane_id --direction $direction --ratio $ratio --cwd $cwd --no-focus |
        jq -r '.result.pane.pane_id'
end
