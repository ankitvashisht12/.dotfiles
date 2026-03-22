local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local HOME = os.getenv("HOME") or "/home/ankit"
local BIN = HOME .. "/.local/bin/"

-- ── Color Scheme: Ghostty (Tomorrow Night variant) ───────────

-- ── Font ─────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 13.0
config.line_height = 1.2

-- ── Transparency ─────────────────────────────────────────────
config.window_background_opacity = 0.96

-- ── Window ───────────────────────────────────────────────────
config.window_decorations = "RESIZE"
config.window_padding = { left = 14, right = 14, top = 10, bottom = 10 }
config.initial_cols = 140
config.initial_rows = 38

-- ── Cursor (Ghostty default: blinking block) ────────────────
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- ── Tab Bar ──────────────────────────────────────────────────
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

config.colors = {
  foreground = "#ffffff",
  background = "#282c34",
  cursor_bg = "#ffffff",
  cursor_fg = "#282c34",
  cursor_border = "#ffffff",
  selection_fg = "#282c34",
  selection_bg = "#ffffff",

  ansi = {
    "#1d1f21",  -- black
    "#cc6666",  -- red
    "#b5bd68",  -- green
    "#f0c674",  -- yellow
    "#81a2be",  -- blue
    "#b294bb",  -- magenta
    "#8abeb7",  -- cyan
    "#c5c8c6",  -- white
  },
  brights = {
    "#666666",  -- bright black
    "#d54e53",  -- bright red
    "#b9ca4a",  -- bright green
    "#e7c547",  -- bright yellow
    "#7aa6da",  -- bright blue
    "#c397d8",  -- bright magenta
    "#70c0b1",  -- bright cyan
    "#eaeaea",  -- bright white
  },

  tab_bar = {
    background = "#21252b",
    active_tab = { bg_color = "#282c34", fg_color = "#ffffff", intensity = "Bold" },
    inactive_tab = { bg_color = "#21252b", fg_color = "#666666" },
    inactive_tab_hover = { bg_color = "#282c34", fg_color = "#c5c8c6" },
    new_tab = { bg_color = "#21252b", fg_color = "#666666" },
    new_tab_hover = { bg_color = "#282c34", fg_color = "#c5c8c6" },
  },
}

-- ── Pane Dimming ─────────────────────────────────────────────
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.65 }

-- ── Performance ──────────────────────────────────────────────
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- ── PATH for spawned processes ───────────────────────────────
config.set_environment_variables = {
  PATH = BIN .. ":" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin:/bin"),
}

-- ── Leader Key ───────────────────────────────────────────────
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

-- ── Launch Menu ──────────────────────────────────────────────
config.launch_menu = {
  { label = " File Explorer (yazi)", args = { BIN .. "yazi" } },
  { label = " Git UI (lazygit)", args = { BIN .. "lazygit" } },
  { label = " Docker (lazydocker)", args = { BIN .. "lazydocker" } },
  { label = " System Monitor", args = { "top" } },
}

-- ── Helper: get cwd from current pane ────────────────────────
local function get_cwd(pane)
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri and cwd_uri.file_path then
    return cwd_uri.file_path
  end
  return HOME
end

-- ── Tool launchers (open in new tab, in current working dir) ─
local function open_yazi(window, pane)
  local cwd = get_cwd(pane)
  window:perform_action(act.SpawnCommandInNewTab {
    cwd = cwd,
    args = { BIN .. "yazi", cwd },
  }, pane)
end

local function open_lazygit(window, pane)
  local cwd = get_cwd(pane)
  window:perform_action(act.SpawnCommandInNewTab {
    cwd = cwd,
    args = { BIN .. "lazygit" },
  }, pane)
end

local function open_lazydocker(window, pane)
  local cwd = get_cwd(pane)
  window:perform_action(act.SpawnCommandInNewTab {
    cwd = cwd,
    args = { BIN .. "lazydocker" },
  }, pane)
end

local function open_diff(window, pane)
  local cwd = get_cwd(pane)
  window:perform_action(act.SpawnCommandInNewTab {
    cwd = cwd,
    args = { "bash", "-c", "export PATH=" .. BIN .. ":$PATH; echo '=== Git Diff ===' && git diff --stat && echo && git diff | delta; echo; read -p 'Press Enter to close...'" },
  }, pane)
end

-- ── Keybindings ──────────────────────────────────────────────
config.keys = {
  -- === TOOLS (direct Ctrl+Shift shortcuts, no leader needed) ===

  -- Ctrl+Shift+E  ->  File Explorer (yazi) in current dir
  { key = "E", mods = "CTRL|SHIFT", action = wezterm.action_callback(open_yazi) },

  -- Ctrl+Shift+G  ->  Git UI (lazygit) in current dir
  { key = "G", mods = "CTRL|SHIFT", action = wezterm.action_callback(open_lazygit) },

  -- Ctrl+Shift+D  ->  Git diff in current dir
  { key = "D", mods = "CTRL|SHIFT", action = wezterm.action_callback(open_diff) },

  -- Ctrl+Shift+K  ->  Lazydocker in current dir
  { key = "K", mods = "CTRL|SHIFT", action = wezterm.action_callback(open_lazydocker) },

  -- Ctrl+Shift+L  ->  Launch menu (clickable dropdown)
  { key = "L", mods = "CTRL|SHIFT", action = act.ShowLauncher },

  -- === LEADER shortcuts (Ctrl+a then key) ===

  -- Leader + e  ->  yazi in current dir
  { key = "e", mods = "LEADER", action = wezterm.action_callback(open_yazi) },

  -- Leader + g  ->  lazygit in current dir
  { key = "g", mods = "LEADER", action = wezterm.action_callback(open_lazygit) },

  -- Leader + d  ->  git diff in current dir
  { key = "d", mods = "LEADER", action = wezterm.action_callback(open_diff) },

  -- Leader + k  ->  lazydocker in current dir
  { key = "k", mods = "LEADER", action = wezterm.action_callback(open_lazydocker) },

  -- === PANE MANAGEMENT ===
  { key = "-", mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- === TABS ===
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },

  -- === MISC ===
  { key = "R", mods = "LEADER|SHIFT", action = act.ReloadConfiguration },
}

-- ── Status Bar ───────────────────────────────────────────────
wezterm.on("update-right-status", function(window, pane)
  local leader = ""
  if window:leader_is_active() then
    leader = "  LEADER  "
  end

  window:set_right_status(wezterm.format({
    { Background = { Color = "#21252b" } },
    { Foreground = { Color = "#666666" } },
    { Text = " ^+E Files | ^+G Git | ^+D Diff | ^+K Docker | ^+L Menu " },
    { Foreground = { Color = "#cc6666" } },
    { Text = leader },
  }))
end)

return config
