-- Personal keybinding overrides, loaded after Omarchy's defaults.
-- See current bindings and descriptions: omarchy menu keybindings --print

-- Drop preinstalled app/webapp bindings for apps I don't use.
hl.unbind("SUPER + SHIFT + D") -- Docker
hl.unbind("SUPER + SHIFT + O") -- Obsidian (removed by `just _cleanup-omarchy`)
hl.unbind("SUPER + SHIFT + SLASH") -- 1Password
hl.unbind("SUPER + SHIFT + X") -- X
hl.unbind("SUPER + SHIFT + ALT + X") -- X Post
hl.unbind("SUPER + SHIFT + ALT + G") -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages
hl.unbind("SUPER + SHIFT + ALT + E") -- HEY new email
hl.unbind("SUPER + SHIFT + S") -- Google Maps

-- Point the AI, calendar, email, and activity keys at my tools instead of
-- the Omarchy defaults (ChatGPT, Grok, HEY, btop).
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai/new" })

hl.unbind("SUPER + SHIFT + ALT + A")
o.bind("SUPER + SHIFT + ALT + A", "Gemini", { webapp = "https://gemini.google.com/app" })

hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })

hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { tui = "aerc" })

hl.unbind("SUPER + CTRL + T")
o.bind("SUPER + CTRL + T", "Activity", { tui = "btm" })
