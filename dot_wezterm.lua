local wezterm = require 'wezterm'

return {
    color_scheme = "Solarized Dark (base16)",
    font = wezterm.font_with_fallback {
        { family = "Iosevka Term", stretch = "Normal", weight = "Regular" },
    },
    font_size = 11.0,
    check_for_updates = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    enable_tab_bar = false,
}
