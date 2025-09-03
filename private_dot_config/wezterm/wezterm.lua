local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Spawn a fish shell in login mode
config.default_prog = { 'fish', '-l' }
-- Slightly transparent and blurred background
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
-- Sets the font for the window frame (tab bar)
config.window_frame = {
    font = wezterm.font {
        family = "Iosevka Term",
        weight = "Bold"
    },
}
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font_with_fallback {
    -- "Berkeley Mono SemiCondensed",
    "Iosevka Term",
    "Fira Code"
}
config.font_size = 12.0
config.line_height = 0.9
config.check_for_updates = true
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.enable_tab_bar = true
config.adjust_window_size_when_changing_font_size = false

config.hyperlink_rules = wezterm.default_hyperlink_rules()

return config
