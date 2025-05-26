---@diagnostic disable: undefined-field

local wezterm = require("wezterm")
local gpu_adapters = require("utils.gpu-adapter")

return {
	-- font
	font_size = 12.5,
	font = wezterm.font_with_fallback({
		{ family = "JetBrainsMono Nerd Font", weight = "Bold" },
		{ family = "MesloLGS Nerd Font", weight = "Bold" },
	}),
	-- color
	term = "xterm-256color",
	color_scheme = "tokyonight_night",

	-- render
	front_end = "WebGpu",
	webgpu_power_preference = "HighPerformance",
	webgpu_preferred_adapter = gpu_adapters:pick_best(),
	-- freetype_load_flags = "NO_HINTING",
	-- freetype_load_target = "Light",
	-- freetype_render_target = "HorizontalLcd",
	-- cell_width = 0.9,
	animation_fps = 120,
	max_fps = 120,

	-- scrollbar
	enable_scroll_bar = false,

	-- window
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",

	-- enable kitty protocol support
	enable_kitty_graphics = true,
	enable_kitty_keyboard = true,

	-- cursor
	default_cursor_style = "SteadyBlock",
	cursor_blink_ease_out = "Constant",
	cursor_blink_ease_in = "Constant",
	cursor_blink_rate = 0,

	-- tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = true,
	tab_max_width = 25,
	show_tab_index_in_tab_bar = true,
	switch_to_last_active_tab_when_closing_tab = true,
}
