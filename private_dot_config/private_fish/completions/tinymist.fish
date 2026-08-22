# Generated from the installed binary rather than vendored as a snapshot, so
# completions always match the version currently on PATH. Fish autoloads this
# file on the first tinymist completion of a session, so the cost is paid once.
if type -q tinymist
    tinymist completion fish | source
end
