# Print the agent command a layout should launch: the argument when one is
# given, otherwise the default. On omarchy the default is the launcher itself,
# `omarchy-agent --inline`, which resolves `omarchy default agent <name>`, adds
# that agent's auto-approve flag, and explains itself in the pane when nothing
# is configured, exactly like omarchy's own bash layouts. Elsewhere the default
# is $default_agent from config.fish.
function _resolve_agent --description 'Print the given agent command, or the default one when none is given'
    if test -n "$argv[1]"
        printf '%s\n' "$argv[1]"
    else if type -q omarchy-agent
        echo 'omarchy-agent --inline'
    else if test -n "$default_agent"
        printf '%s\n' "$default_agent"
    else
        echo 'No default agent set. Set default_agent in config.fish.' >&2
        return 1
    end
end
