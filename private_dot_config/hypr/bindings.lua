-- Personal keybinding overrides, loaded after Omarchy's defaults.
-- See current bindings and descriptions: omarchy menu keybindings --print

-- Drop preinstalled app/webapp bindings for apps I don't use.
hl.unbind("SUPER + SHIFT + D") -- Docker
hl.unbind("SUPER + SHIFT + SLASH") -- 1Password
hl.unbind("SUPER + SHIFT + X") -- X
hl.unbind("SUPER + SHIFT + ALT + X") -- X Post
hl.unbind("SUPER + SHIFT + ALT + G") -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages
hl.unbind("SUPER + SHIFT + ALT + E") -- HEY new email
hl.unbind("SUPER + SHIFT + S") -- Google Maps

-- Point the AI, calendar, email, and activity keys at my tools instead of
-- the Omarchy defaults (ChatGPT, Grok, HEY, btop).
o.rebind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai/new" })
o.rebind("SUPER + SHIFT + ALT + A", "Gemini", { webapp = "https://gemini.google.com/app" })
o.rebind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })
o.rebind("SUPER + SHIFT + E", "Email", { tui = "aerc" })
o.rebind("SUPER + SHIFT + T", "Activity", { tui = "btm" })

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.
