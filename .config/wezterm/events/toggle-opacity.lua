---@diagnostic disable: undefined-field
---@diagnostic disable: unused-local

local M = {}
local wezterm = require("wezterm")

M.setup = function()
	wezterm.on("toggle-opacity", function(window, pane)
		local overrides = window:get_config_overrides() or {}
		if not overrides.window_background_opacity then
			overrides.window_background_opacity = 0.90
		else
			overrides.window_background_opacity = nil
		end
		window:set_config_overrides(overrides)
	end)
end

return M
