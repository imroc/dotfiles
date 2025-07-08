---@diagnostic disable: missing-fields

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
  -- Move to the top of the file
  vim.cmd("normal! gg")
  -- Get the total number of lines
  local total_lines = vim.fn.line("$")
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    -- "^" -> Ensures the match is at the start of the line
    -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
    -- "%s" -> Matches any whitespace character after the "#" characters
    -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
    if line_content:match("^" .. string.rep("#", level) .. "%s") then
      -- Move the cursor to the current line
      vim.fn.cursor(line, 1)
      -- Fold the heading if it matches the level
      if vim.fn.foldclosed(line) == -1 then
        vim.cmd("normal! za")
      end
    end
  end
end

local function fold_markdown_headings(levels)
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    fold_headings_of_level(level)
  end
  vim.cmd("nohlsearch")
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
-- vim.keymap.set("n", "<CR>", function()
--   -- Get the current line number
--   local line = vim.fn.line(".")
--   -- Get the fold level of the current line
--   local foldlevel = vim.fn.foldlevel(line)
--   if foldlevel == 0 then
--     vim.notify("No fold found", vim.log.levels.INFO)
--   else
--     vim.cmd("normal! za")
--   end
-- end, { desc = "[P]Toggle fold" })

local M = {}

-- Search UP for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
function M.goto_previous_header()
  -- `?` - Start a search backwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! ?^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end

-- Search DOWN for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
function M.goto_next_header()
  -- `/` - Start a search forwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! /^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end

-- Unfold markdown headings of level 2 or above
-- Changed all the markdown folding and unfolding keymaps from <leader>mfj to
-- zj, zk, zl, z; and zu respectively lamw25wmal
function M.unfold_level_2()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd("silent update")
  -- vim.keymap.set("n", "<leader>mfu", function()
  -- Reloads the file to reflect the changes
  vim.cmd("edit!")
  vim.cmd("normal! zR") -- Unfold all headings
  vim.cmd("normal! zz") -- center the cursor line on screen
end

-- gk jummps to the markdown heading above and then folds it
-- zi by default toggles folding, but I don't need it lamw25wmal
function M.fold_current()
  M.goto_previous_header()
  -- This is to fold the line under the cursor
  vim.cmd("normal! za")
end

function fold_level(min_level)
  -- 保存更改并重新加载缓冲区
  vim.cmd("silent update")
  -- 重新加载文件以刷新折叠
  vim.cmd("edit!")
  -- 展开所有折叠，避免出现问题
  vim.cmd("normal! zR")

  local levels = {}
  for lv = 6, min_level, -1 do
    table.insert(levels, lv)
  end

  -- 调用折叠函数
  fold_markdown_headings(levels)
  -- 光标行居中
  vim.cmd("normal! zz")
end

-- fold markdown headings of level 4 or above
function M.fold_level_4()
  fold_level(4)
end

-- fold markdown headings of level 3 or above
function M.fold_level_3()
  fold_level(3)
end

-- fold markdown headings of level 3 or above
function M.fold_level_2()
  fold_level(2)
end

-- fold markdown headings of level 3 or above
function M.fold_level_1()
  fold_level(1)
end

return M
