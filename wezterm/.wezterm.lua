-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font Settings
config.font_size = 14
config.line_height = 1.1
config.font = wezterm.font('Berkeley Mono', { weight = 'Regular' })

-- Colors
config.colors = {
  cursor_bg = 'white',
  cursor_border = 'white',
}

-- Appereance
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = 'Rosé Pine (Gogh)'

-- Miscellaneous Settings
config.max_fps = 120
config.prefer_egl = true

-- Finally, return the configuration to wezterm:
return config
