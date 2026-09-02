# Fish port of Omarchy's multi-project herdr layout ($OMARCHY_PATH/default/bash/fns/herdr)
function hdlm --description 'One hdl tab per subdirectory of the current directory'
    if test (count $argv) -gt 2
        echo "Usage: hdlm [agent] [second_agent]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hdlm." >&2
        return 1
    end

    set -l base_dir $PWD

    herdr workspace rename $HERDR_WORKSPACE_ID (path basename $base_dir) >/dev/null

    set -l first true
    for dir in $base_dir/*/
        set -l dirpath (path normalize $dir)

        if test $first = true
            # Reuse the current tab for the first project
            herdr pane run $HERDR_PANE_ID "cd '$dirpath' && hdl $argv" >/dev/null
            set first false
        else
            set -l pane_id (herdr tab create --workspace $HERDR_WORKSPACE_ID --cwd $dirpath --no-focus |
                jq -r '.result.root_pane.pane_id')
            herdr pane run $pane_id "hdl $argv" >/dev/null
        end
    end
end
