*.default=true
*.normal=true

default.fg={{ foreground }}

error.fg={{ red }}
warning.fg={{ yellow }}
success.fg={{ green }}

tab.fg={{ muted }}
tab.bg={{ background }}
tab.selected.fg={{ foreground }}
tab.selected.bg={{ background }}
tab.selected.bold=true

border.fg={{ muted }}
border.bold=true

msglist_unread.bold=true
msglist_flagged.fg={{ yellow }}
msglist_flagged.bold=true
msglist_result.fg={{ blue }}
msglist_result.bold=true
msglist_*.selected.bold=true
msglist_*.selected.fg={{ background }}
msglist_*.selected.bg={{ foreground }}

dirlist_*.selected.bold=true
dirlist_*.selected.fg={{ background }}
dirlist_*.selected.bg={{ foreground }}

# Inverted statusline: always contrasts because foreground/background are
# theme-designed to be readable against each other (matches the helix
# omarchy theme for a consistent look).
statusline_default.fg={{ background }}
statusline_default.bg={{ foreground }}
statusline_error.bold=true
statusline_success.bold=true

selector_focused.fg={{ background }}
selector_focused.bg={{ foreground }}

completion_default.selected.fg={{ background }}
completion_default.selected.bg={{ foreground }}

[viewer]
url.fg={{ blue }}
url.underline=true
header.bold=true
signature.dim=true
diff_meta.bold=true
diff_chunk.fg={{ blue }}
diff_chunk_func.fg={{ blue }}
diff_chunk_func.bold=true
diff_add.fg={{ green }}
diff_del.fg={{ red }}
quote_*.fg={{ muted }}
quote_1.fg={{ foreground }}
