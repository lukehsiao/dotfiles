# Converted from Omarchy
# https://github.com/basecamp/omarchy/blob/dev/default/bash/fns/ssh-port-forwarding
function lip --description "List active SSH port forwards"
    set -l found false
    # BSD pgrep lacks Linux's -a (print full command line), so it only
    # emits bare PIDs on macOS. Parse ps output instead so we can show
    # the forwarded port, which is what dip takes as an argument.
    ps -axo pid=,command= | while read -l pid cmd
        set -l m (string match -r -- 'ssh.*-L ([0-9]+):localhost:([0-9]+)' $cmd)
        or continue
        set -l host (string match -r -- '(\S+)$' $cmd)
        set found true
        echo "Forwarding localhost:$m[2] -> $host[2]:$m[3] (pid $pid)"
    end
    if not $found
        echo "No active forwards"
    end
end
