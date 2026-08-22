# Generated from the installed binary rather than vendored as a snapshot, so
# completions always match the version currently on PATH. Fish autoloads this
# file on the first typst completion of a session, so the cost is paid once.
if type -q typst
    typst completions fish | source
end
