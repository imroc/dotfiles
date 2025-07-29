vim.opt_local.wrap = true

local map = vim.keymap.set
local md = require("util.markdown")

map({ "n", "v" }, "gk", md.goto_previous_header, { buffer = 0, desc = "[P]Go to previous markdown header" })
map({ "n", "v" }, "gj", md.goto_next_header, { buffer = 0, desc = "[P]Go to next markdown header" })
map("n", "zu", md.unfold_level_2, { buffer = 0, desc = "[P]Unfold all headings level 2 or above" })
map("n", "zi", md.fold_current, { buffer = 0, desc = "[P]Fold the heading cursor currently on" })
map("n", "zj", md.fold_level_1, { buffer = 0, desc = "[P]Fold all headings level 1 or above" })
map("n", "zk", md.fold_level_2, { buffer = 0, desc = "[P]Fold all headings level 2 or above" })
map("n", "zl", md.fold_level_3, { buffer = 0, desc = "[P]Fold all headings level 3 or above" })
map("n", "z;", md.fold_level_4, { buffer = 0, desc = "[P]Fold all headings level 4 or above" })

map("n", "<localleader>w", "", { buffer = 0, desc = "+[P]iwiki" })

local iwiki = require("util.iwiki")
map("n", "<localleader>ws", iwiki.save_iwiki, { buffer = 0, desc = "[P]Save" })
map("n", "<localleader>wo", iwiki.open_iwiki, { buffer = 0, desc = "[P]Open in browser" })
map("n", "<localleader>wi", iwiki.insert_image, { buffer = 0, desc = "[P]Insert image" })
