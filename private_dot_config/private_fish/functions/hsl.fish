# Fish port of Omarchy's herdr swarm layout ($OMARCHY_PATH/default/bash/fns/herdr)
function hsl --description 'Herdr swarm layout: the same command tiled across N panes'
    if not string match --quiet --regex '^[1-9][0-9]*$' -- "$argv[1]"
        echo "Usage: hsl <pane_count> [command]" >&2
        return 1
    end
    if not set -q HERDR_PANE_ID
        echo "You must start herdr to use hsl." >&2
        return 1
    end

    set -l count $argv[1]
    set -l cmd $AI_AGENT
    test -n "$argv[2]"; and set cmd $argv[2]

    set -l current_dir $PWD

    herdr tab rename $HERDR_TAB_ID (path basename $current_dir) >/dev/null

    # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
    set -l cols (math "ceil(sqrt($count))")

    # Even columns come from splitting the rightmost one off at 1/(cols-k+1)
    # each time, which keeps the list in left-to-right order. These loops count
    # explicitly because `seq 0` prints nothing with GNU seq but "1 0" with BSD
    # seq, which would add a stray split on macOS.
    set -l columns $HERDR_PANE_ID
    set -l k 1
    while test $k -lt $cols
        set -a columns (_herdr_split $columns[-1] right (math -s4 "1 / ($cols - $k + 1)") $current_dir)
        set k (math $k + 1)
    end

    # Split each column into its share of rows, again evenly and top-to-bottom.
    # The first count % cols columns take the extra row.
    set -l panes
    set -l index 0
    while test $index -lt $cols
        set -l rows (math "floor($count / $cols)")
        if test $index -lt (math "$count % $cols")
            set rows (math $rows + 1)
        end

        set -l last $columns[(math $index + 1)]
        set -a panes $last

        set -l j 1
        while test $j -lt $rows
            set last (_herdr_split $last down (math -s4 "1 / ($rows - $j + 1)") $current_dir)
            set -a panes $last
            set j (math $j + 1)
        end

        set index (math $index + 1)
    end

    for pane in $panes
        herdr pane run $pane "$cmd" >/dev/null
    end
end
