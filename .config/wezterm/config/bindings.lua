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
	-- new tab
	{ key = "n", mods = "SHIFT|SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	-- tab: navigation
	{ key = "[", mods = "SHIFT|SUPER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "SHIFT|SUPER", action = act.ActivateTabRelative(1) },
	{ key = "1", mods = "CTRL|SUPER", action = act.ActivateTab(0) },
	{ key = "2", mods = "CTRL|SUPER", action = act.ActivateTab(1) },
	{ key = "3", mods = "CTRL|SUPER", action = act.ActivateTab(2) },
	{ key = "4", mods = "CTRL|SUPER", action = act.ActivateTab(3) },
	{ key = "5", mods = "CTRL|SUPER", action = act.ActivateTab(4) },
	{ key = "6", mods = "CTRL|SUPER", action = act.ActivateTab(5) },
	{ key = "7", mods = "CTRL|SUPER", action = act.ActivateTab(6) },
	{ key = "8", mods = "CTRL|SUPER", action = act.ActivateTab(7) },
	{ key = "9", mods = "CTRL|SUPER", action = act.ActivateTab(-1) },

	-- pane
	--
	-- pane: split
	{ key = "-", mods = "SHIFT|SUPER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "SHIFT|SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- pane: zoom
	{ key = "Enter", mods = "SHIFT|SUPER", action = act.TogglePaneZoomState },
	-- pane: close
	{ key = "w", mods = "CTRL|SUPER", action = act.CloseCurrentPane({ confirm = false }) },
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
	-- enter resize font mode
	{
		key = "f",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_font",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
	-- enter resize pane mode
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
	-- enter tab mode
	{
		key = "t",
		mods = "SUPER",
		action = act.ActivateKeyTable({
			name = "tab",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
}

local key_tables = {
	resize_font = {
		{ key = "k", action = act.IncreaseFontSize },
		{ key = "j", action = act.DecreaseFontSize },
		{ key = "r", action = act.ResetFontSize },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	resize_pane = {
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	tab = {
		-- goto left/right tab
		{ key = "h", action = act.ActivateTabRelative(-1) },
		{ key = "l", action = act.ActivateTabRelative(1) },
		-- move tab to left/right
		{ key = "H", action = act.MoveTabRelative(-1) },
		{ key = "L", action = act.MoveTabRelative(1) },
		-- rename tab title
		{ key = "r", action = act.Multiple({ "PopKeyTable", act.EmitEvent("tabs.manual-update-tab-title") }) },
		-- reset tab title
		{ key = "R", action = act.Multiple({ "PopKeyTable", act.EmitEvent("tabs.reset-tab-title") }) },
		-- toggle tab-bar
		{ key = "t", action = act.EmitEvent("tabs.toggle-tab-bar") },
		-- new tab-bar
		{ key = "n", action = act.SpawnTab("CurrentPaneDomain") },
		-- close tab-bar
		{ key = "x", action = act.CloseCurrentTab({ confirm = false }) },
		-- quit tab mode
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
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
