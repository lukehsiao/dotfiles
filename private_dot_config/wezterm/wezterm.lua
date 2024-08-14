local wezterm = require 'wezterm'

return {

    -- Slightly transparent and blurred background
    window_background_opacity = 0.9,
    macos_window_background_blur = 30,
    -- Removes the title bar, leaving only the tab bar. Keeps
    -- the ability to resize by dragging the window's edges.
    -- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
    -- you want to keep the window controls visible and integrate
    -- them into the tab bar.
    window_decorations = 'RESIZE',
    -- Sets the font for the window frame (tab bar)
    window_frame = {
        -- Berkeley Mono for me again, though an idea could be to try a
        -- serif font here instead of monospace for a nicer look?
        font = wezterm.font {
            family = "Iosevka Term",
            weight = "Bold"
        },
        font_size = 11.0,
    },

    color_scheme = "Selenized Dark",
    font = wezterm.font_with_fallback {
        "Berkeley Mono",
        "Iosevka Term",
        "Fira Code"
    },
    font_size = 12.0,
    line_height = 0.9,
    cell_width = 0.9,
    check_for_updates = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    enable_tab_bar = true,

    hyperlink_rules = {
        -- Linkify things that look like URLs and the host has a TLD name.
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
            format = '$0',
        },

        -- linkify email addresses
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
            format = 'mailto:$0',
        },

        -- file:// URI
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = [[\bfile://\S*\b]],
            format = '$0',
        },

        -- Linkify things that look like URLs with numeric addresses as hosts.
        -- E.g. http://127.0.0.1:8000 for a local development server,
        -- or http://192.168.1.1 for the web interface of many routers.
        {
            regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
            format = '$0',
        },

        -- Make task numbers clickable
        -- The first matched regex group is captured in $1.
        {
            regex = [[\bHSI-(\d+)\b]],
            format = 'https://linear.app/hsiao/issue/$0',
        },
        {
            regex = [[\bNS-(\d+)\b]],
            format = 'https://linear.app/numbersstation/issue/$0',
        },

        -- Make username/project paths clickable. This implies paths like the following are for GitHub.
        -- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
        -- As long as a full URL hyperlink regex exists above this it should not match a full URL to
        -- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
        {
            regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
            format = 'https://www.github.com/$1/$3',
        },
    },
}
