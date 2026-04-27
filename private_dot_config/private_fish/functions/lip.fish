# Converted from Omarchy
# https://github.com/basecamp/omarchy/blob/dev/default/bash/fns/ssh-port-forwarding
function lip --description "List active SSH port forwards"
    pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+"; or echo "No active forwards"
end
