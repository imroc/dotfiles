-- https://wezfurlong.org/wezterm/config/files.html
-- https://wezfurlong.org/wezterm/config/lua/config/index.html

local Config = require("config")
require("events.right-status").setup()
require("events.tab-title").setup()
require("events.new-tab-button").setup()
require("events.toggle-opacity").setup()

return Config:init():append(require("config.appearance")):append(require("config.bindings")).options
