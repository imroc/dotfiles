vim.opt_local.wrap = false

local map = vim.keymap.set
local md = require("util.markdown")

map({ "n", "v" }, "gk", md.goto_previous_header, { buffer = 0, desc = "[P]Go to previous markdown header" })
map({ "n", "v" }, "gj", md.goto_next_header, { buffer = 0, desc = "[P]Go to next markdown header" })

-- gd: 链接同名本地文件跳转（无 LSP 时的 fallback，有 LSP 时由 lspconfig keys 覆盖）
map("n", "gd", md.follow_link, { buffer = 0, desc = "[P]Follow markdown link to local file" })
map("n", "zu", md.unfold_level_2, { buffer = 0, desc = "[P]Unfold all headings level 2 or above" })
map("n", "zi", md.fold_current, { buffer = 0, desc = "[P]Fold the heading cursor currently on" })
map("n", "zj", md.fold_level_1, { buffer = 0, desc = "[P]Fold all headings level 1 or above" })
map("n", "zk", md.fold_level_2, { buffer = 0, desc = "[P]Fold all headings level 2 or above" })
map("n", "zl", md.fold_level_3, { buffer = 0, desc = "[P]Fold all headings level 3 or above" })
map("n", "z;", md.fold_level_4, { buffer = 0, desc = "[P]Fold all headings level 4 or above" })

map("n", "<localleader>w", "", { buffer = 0, desc = "+[P]iwiki" })

local iwiki = require("util.iwiki")
map("n", "<localleader>ws", iwiki.save_iwiki_force, { buffer = 0, desc = "[P]Save (force)" })
map("n", "<localleader>wo", iwiki.open_iwiki, { buffer = 0, desc = "[P]Open in browser" })
map("n", "<localleader>wc", iwiki.open_iwiki_cmux, { buffer = 0, desc = "[P]Open in cmux browser" })
map("n", "<localleader>wi", iwiki.insert_image, { buffer = 0, desc = "[P]Insert image" })
map("n", "<localleader>wu", iwiki.copy_url, { buffer = 0, desc = "[P]Copy iwiki URL" })

map("n", "<localleader>e", md.export_pdf, { buffer = 0, desc = "[P]Export to PDF" })
map("n", "<localleader>l", md.convert_line_to_link, { buffer = 0, desc = "[P]Convert to markdown link" })
map("v", "<localleader>l", md.convert_selection_to_link, { buffer = 0, desc = "[P]Convert selection to markdown link" })

map("n", "<localleader>s", function()
  if iwiki.is_iwiki() then
    iwiki.save_iwiki()
  else
    vim.notify("未识别的 markdown 同步目标", vim.log.levels.WARN)
  end
end, { buffer = 0, desc = "[P]Sync markdown file" })
