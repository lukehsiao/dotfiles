# Converted from Omarchy
# https://github.com/basecamp/omarchy/blob/dev/default/bash/fns/ssh-port-forwarding
function dip --description "Stop SSH port forwarding"
    if test (count $argv) -eq 0
        echo "Usage: dip <port1> [port2] ..."
        return 1
    end
    for port in $argv
        if pkill -f "ssh.*-L $port:localhost:$port"
            echo "Stopped forwarding port $port"
        else
            echo "No forwarding on port $port"
        end
    end
end
