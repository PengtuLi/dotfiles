local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Theme (GitHub Dark Default)
config.color_scheme = 'GitHub Dark'

-- Font
config.font = wezterm.font 'Maple Mono NF CN'
config.font_size = 16.0
-- Disable synthetic bold/italic
config.harfbuzz_features = { 'calt=1', 'cv01=1' }

-- Window padding
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- macOS: option key as alt (Left Option sends Escape, Right Option for special chars)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Key bindings
config.keys = {
  -- Tab navigation (Alt+number)
  { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(8) },

  -- Tab navigation (Alt+[ / Alt+])
  { key = '[', mods = 'ALT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'ALT', action = wezterm.action.ActivateTabRelative(1) },

  -- Copy/Paste
  { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },

  -- Scroll
  { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.ScrollByLine(-1) },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ScrollByLine(1) },
  { key = 'f', mods = 'ALT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'b', mods = 'ALT', action = wezterm.action.ScrollByPage(1) },

  -- Font size
  { key = '=', mods = 'ALT', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'ALT', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'ALT', action = wezterm.action.ResetFontSize },

  -- Window management
  { key = 'n', mods = 'ALT', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'ALT', action = wezterm.action.SpawnTab 'DefaultDomain' },
  { key = 'w', mods = 'ALT|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentPane { confirm = true } },
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },

  -- Split panes
  { key = 's', mods = 'ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Pane navigation
  { key = 'k', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'h', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },

  -- Pane resize
  { key = 'k', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 20 } },
  { key = 'j', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 20 } },
  { key = 'h', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 20 } },
  { key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 20 } },
  { key = '0', mods = 'ALT|SHIFT', action = wezterm.action.PaneSelect { mode = 'Activate' } },

  -- Reload config
  { key = ',', mods = 'ALT|SHIFT', action = wezterm.action.ReloadConfiguration },
}

-- Disable default key bindings
config.disable_default_key_bindings = false

-- Enable hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

return config
