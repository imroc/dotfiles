---@diagnostic disable: undefined-field

local wezterm = require("wezterm")
local act = wezterm.action

local keys = {
	-- misc/useful --
	--
	-- search string
	{ key = "f", mods = "SUPER", action = act.Search({ CaseInSensitiveString = "" }) },
	-- open url
	{
		key = "u",
		mods = "LEADER",
		action = wezterm.action.QuickSelectArgs({
			label = "open url",
			patterns = {
				"\\((https?://\\S+)\\)",
				"\\[(https?://\\S+)\\]",
				"\\{(https?://\\S+)\\}",
				"<(https?://\\S+)>",
				"\\bhttps?://\\S+[)/a-zA-Z0-9-]+",
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("opening: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},

	-- tab
	--
	-- tab: navigation
	{ key = "[", mods = "LEADER", action = act.MoveTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.MoveTabRelative(1) },
	{ key = "[", mods = "SHIFT|SUPER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "SHIFT|SUPER", action = act.ActivateTabRelative(1) },
	{ key = "1", mods = "SUPER", action = act.ActivateTab(0) },
	{ key = "2", mods = "SUPER", action = act.ActivateTab(1) },
	{ key = "3", mods = "SUPER", action = act.ActivateTab(2) },
	{ key = "4", mods = "SUPER", action = act.ActivateTab(3) },
	{ key = "5", mods = "SUPER", action = act.ActivateTab(4) },
	{ key = "6", mods = "SUPER", action = act.ActivateTab(5) },
	{ key = "7", mods = "SUPER", action = act.ActivateTab(6) },
	{ key = "8", mods = "SUPER", action = act.ActivateTab(7) },
	{ key = "9", mods = "SUPER", action = act.ActivateTab(-1) },
	-- tab: title
	{ key = "r", mods = "LEADER", action = act.EmitEvent("tabs.manual-update-tab-title") },
	{ key = "R", mods = "LEADER", action = act.EmitEvent("tabs.reset-tab-title") },
	-- tab: hide tab-bar
	{ key = "T", mods = "LEADER", action = act.EmitEvent("tabs.toggle-tab-bar") },
	-- tab: new tab-bar
	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	-- tab: close tab-bar
	{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },

	-- pane
	--
	-- pane: split
	{ key = "-", mods = "SHIFT|SUPER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "SHIFT|SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- pane: zoom
	{ key = "Enter", mods = "SHIFT|SUPER", action = act.TogglePaneZoomState },
	-- pane: navigation
	{ key = "h", mods = "SHIFT|SUPER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "SHIFT|SUPER", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "SHIFT|SUPER", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "SHIFT|SUPER", action = act.ActivatePaneDirection("Down") },
	{
		key = "P",
		mods = "LEADER",
		action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }),
	},

	-- cursor movement --
	{ key = "LeftArrow", mods = "SUPER", action = act.SendString("\u{1b}OH") },
	{ key = "RightArrow", mods = "SUPER", action = act.SendString("\u{1b}OF") },
	{ key = "Backspace", mods = "SUPER", action = act.SendString("\u{15}") },

	-- copy mode
	{ key = "c", mods = "SHIFT|SUPER", action = act.ActivateCopyMode },

	-- copy/paste --
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

	-- window --
	-- window: spawn windows
	{ key = "N", mods = "LEADER", action = act.SpawnWindow },
	{ key = "b", mods = "LEADER", action = act.EmitEvent("toggle-opacity") },

	-- panes: scroll pane
	{ key = "u", mods = "LEADER", action = act.ScrollByLine(-5) },
	{ key = "d", mods = "LEADER", action = act.ScrollByLine(5) },
	{ key = "PageUp", mods = "NONE", action = act.ScrollByPage(-0.75) },
	{ key = "PageDown", mods = "NONE", action = act.ScrollByPage(0.75) },

	-- key-tables --
	-- resizes fonts
	{
		key = "f",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_font",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
	-- resize panes
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

return {
	disable_default_key_bindings = true,
	-- disable_default_mouse_bindings = true,
	leader = { key = "Space", mods = "SHIFT|SUPER" },
	keys = keys,
	key_tables = key_tables,
	mouse_bindings = mouse_bindings,
}
