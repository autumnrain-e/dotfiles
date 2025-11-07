-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font Settings
config.font_size = 15
config.line_height = 1
config.font = wezterm.font('FiraCode Nerd Font Mono', { weight = 'Regular' })
-- config.font = wezterm.font_with_fallback({
--   { family = 'Berkeley Mono' },
--   { family = 'Symbols Nerd Font Mono', scale = 0.9 },
-- })

-- Colors
config.colors = {
  cursor_bg = 'white',
  cursor_border = 'white',
}

-- Appereance
config.window_decorations = 'RESIZE'
config.enable_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'

config.color_scheme = 'Gruvbox dark, pale (base16)'

-- Key Bindings
config.keys = {
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.SendString 'clear\n',
  },
  -- Navigate between panes with Ctrl+Shift+h/j/k/l
  {
    key = 'h',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Left' },
  {
    key = 'l',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Right' },
  {
    key = 'k',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Up' },
  {
    key = 'j',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Down' },
}

-- Miscellaneous Settings
config.max_fps = 120
config.prefer_egl = true

-- Finally, return the configuration to wezterm:
return config
