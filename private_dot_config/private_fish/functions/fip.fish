# Converted from Omarchy
# https://github.com/basecamp/omarchy/blob/dev/default/bash/fns/ssh-port-forwarding
function fip --description "SSH port forward to host"
    if test (count $argv) -lt 2
        echo "Usage: fip <host> <port1> [port2] ..."
        return 1
    end
    set -l host $argv[1]
    for port in $argv[2..]
        if ssh -f -N -L "$port:localhost:$port" $host
            echo "Forwarding localhost:$port -> $host:$port"
        end
    end
end
