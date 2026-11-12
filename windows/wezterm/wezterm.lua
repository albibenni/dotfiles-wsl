local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Native Windows WezTerm starts Bash inside WSL, without a Linux GUI terminal.
config.wsl_domains = wezterm.default_wsl_domains()
local preferred = 'WSL:Ubuntu-26.04'
for _, domain in ipairs(config.wsl_domains) do
  domain.default_cwd = '~'
  if domain.name == preferred then config.default_domain = preferred end
end
-- If the distro has a different name, choose the first discovered WSL distro.
if not config.default_domain and #config.wsl_domains > 0 then
  config.default_domain = config.wsl_domains[1].name
end
config.launch_menu = {
  { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' }, domain = { DomainName = 'local' } },
}
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font_with_fallback {
  'CaskaydiaCove Nerd Font', 'JetBrainsMono Nerd Font', 'Cascadia Code',
}
config.font_size = 13
config.initial_cols = 140
config.initial_rows = 38
config.window_padding = { left = 12, right = 12, top = 8, bottom = 8 }
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 20000
config.audible_bell = 'Disabled'
-- Ctrl+Shift+Space: label and copy URLs, hashes and paths in visible output.
-- Ctrl+Shift+X: keyboard copy mode; Ctrl+Shift+P: command palette.
-- Ctrl+Shift+F: search scrollback. Standard bindings remain enabled.
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'p', mods = 'LEADER', action = act.PaneSelect {} },
  { key = 't', mods = 'LEADER', action = act.ShowLauncher },
}
return config
