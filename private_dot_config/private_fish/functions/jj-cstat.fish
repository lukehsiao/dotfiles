function jj-cstat -d "Compact the summary lines of jj --stat output read from stdin"
    if isatty stdin
        echo "usage: jj diff/show/log ... --stat | jj-cstat" >&2
        return 2
    end

    # string only reads stdin that is directly attached to it, not stdin
    # inherited through a function, so slurp the whole input with read
    # (which has no such restriction) and pass the lines as arguments.
    read --local --null input

    # jj always prints all three fields even when zero, so one regex can
    # require all of them. The leading .*? skips the graph prefix that
    # `jj log --stat` puts before each summary line, and --filter drops
    # every line that is not a summary line.
    string replace --regex --filter -- \
        '^.*?(\d+ files?) changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)$' \
        '$1, +$2, -$3' \
        (string split \n -- $input)
end
