-- Change the default Omarchy look'n'feel.

-- Use round window corners.
hl.config({
  decoration = {
    rounding = 8,
  },
})

-- Make floating windows larger than the 875x600 default. Parenthesized
-- expressions match the windowrule syntax Omarchy itself uses for
-- monitor-relative geometry (see upstream default/hypr/apps/pip.lua).
o.window({ tag = "floating-window" }, { size = { "(monitor_w*0.55)", "(monitor_h*0.60)" } })

-- Float btm like the other system TUIs (Omarchy only tags btop).
o.window("org.omarchy.btm", { tag = "+floating-window" })
