*.default=true
*.normal=true

default.fg={{ foreground }}

error.fg={{ color1 }}
warning.fg={{ color3 }}
success.fg={{ color2 }}

tab.fg={{ color8 }}
tab.bg={{ background }}
tab.selected.fg={{ foreground }}
tab.selected.bg={{ background }}
tab.selected.bold=true

border.fg={{ color8 }}
border.bold=true

msglist_unread.bold=true
msglist_flagged.fg={{ color3 }}
msglist_flagged.bold=true
msglist_result.fg={{ color4 }}
msglist_result.bold=true
msglist_*.selected.bold=true
msglist_*.selected.fg={{ background }}
msglist_*.selected.bg={{ foreground }}

dirlist_*.selected.bold=true
dirlist_*.selected.fg={{ background }}
dirlist_*.selected.bg={{ foreground }}

# Inverted statusline: always contrasts because foreground/background are
# theme-designed to be readable against each other (matches the zellij and
# helix omarchy themes for a consistent look).
statusline_default.fg={{ background }}
statusline_default.bg={{ foreground }}
statusline_error.bold=true
statusline_success.bold=true

selector_focused.fg={{ background }}
selector_focused.bg={{ foreground }}

completion_default.selected.fg={{ background }}
completion_default.selected.bg={{ foreground }}

[viewer]
url.fg={{ color4 }}
url.underline=true
header.bold=true
signature.dim=true
diff_meta.bold=true
diff_chunk.fg={{ color4 }}
diff_chunk_func.fg={{ color4 }}
diff_chunk_func.bold=true
diff_add.fg={{ color2 }}
diff_del.fg={{ color1 }}
quote_*.fg={{ color8 }}
quote_1.fg={{ foreground }}
