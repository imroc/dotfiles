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

-- 将当前 markdown 文件导出为 PDF 到 ~/Downloads 并复制到系统粘贴板
function M.export_pdf()
  -- 保存当前缓冲区
  vim.cmd("silent update")

  local filepath = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t:r") -- 不含扩展名的文件名
  local output_dir = vim.fn.expand("~/Downloads")
  local output_path = output_dir .. "/" .. filename .. ".pdf"

  vim.notify("正在导出 PDF ...", vim.log.levels.INFO)

  -- 使用 pandoc + xelatex 转换，支持中文
  local pandoc_dir = vim.fn.stdpath("config") .. "/pandoc"
  local preamble_path = pandoc_dir .. "/pdf-preamble.tex"
  local filter_path = pandoc_dir .. "/table-grid.lua"

  local cmd = {
    "pandoc",
    filepath,
    "-o",
    output_path,
    "--pdf-engine=xelatex",
    "--template=eisvogel",
    "--toc",
    "--syntax-highlighting=tango",
    "-V",
    "CJKmainfont=PingFang SC",
    "-V",
    "geometry:margin=2.5cm",
    "-V",
    "toc-title=目录",
    "-V",
    "toc-own-page=true",
    "-V",
    "colorlinks=true",
  }

  -- LaTeX preamble（longtable 包加载等）
  if vim.fn.filereadable(preamble_path) == 1 then
    table.insert(cmd, "-H")
    table.insert(cmd, preamble_path)
  end

  -- Lua filter（表格竖线样式）
  if vim.fn.filereadable(filter_path) == 1 then
    table.insert(cmd, "--lua-filter=" .. filter_path)
  end

  -- 确保 pandoc 能找到 xelatex（basictex 安装路径）
  local env_path = (vim.env.PATH or "") .. ":/Library/TeX/texbin"

  vim.system(cmd, { env = { PATH = env_path } }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("PDF 导出失败: " .. (result.stderr or "未知错误"), vim.log.levels.ERROR)
        return
      end

      -- 用 NSPasteboard API 将 PDF 文件复制到系统粘贴板
      local applescript = string.format(
        [[use framework "AppKit"
set pb to current application's NSPasteboard's generalPasteboard()
pb's clearContents()
set fileURL to current application's NSURL's fileURLWithPath:"%s"
pb's writeObjects:{fileURL}]],
        output_path
      )
      vim.system({ "osascript", "-e", applescript }, {}, function(cp_result)
        vim.schedule(function()
          if cp_result.code == 0 then
            vim.notify("PDF 已导出到 " .. output_path .. " 并复制到粘贴板", vim.log.levels.INFO)
          else
            vim.notify(
              "PDF 已导出到 " .. output_path .. "，但复制到粘贴板失败: " .. (cp_result.stderr or ""),
              vim.log.levels.WARN
            )
          end
        end)
      end)
    end)
  end)
end

-- URL 匹配模式（Lua pattern）
local url_pattern = "https?://[%w%-%.%_%~%:%/%?%#%[%]%@%!%$%&%'%(%)%*%+%,%;%%=%{%}]+"

--- 从字符串中提取"文本"和"URL"，按冒号（英文/中文）分隔
--- 逻辑：先找到 URL，再检查 URL 前面是否有冒号分隔的文本
--- 中文冒号是 UTF-8 多字节字符（\xef\xbc\x9a），Lua pattern 的字符类无法匹配
local function extract_text_and_url(s)
  -- 先提取末尾的 URL
  local url = s:match("(" .. url_pattern .. ")%s*$")
  if not url then
    return nil, nil
  end

  -- 获取 URL 前面的部分
  local url_start = s:find(url, 1, true)
  if not url_start or url_start <= 1 then
    return nil, url
  end

  local before_url = s:sub(1, url_start - 1)
  -- 去掉末尾的冒号和空格（中文冒号 \xef\xbc\x9a 或英文冒号 :）
  local text = before_url:match("^(.-)%s*\xef\xbc\x9a%s*$")
    or before_url:match("^(.-)%s*:%s*$")
    or before_url:match("^(.-)%s+$")
  if text and text ~= "" then
    return text, url
  end

  return nil, url
end

--- Normal 模式：将当前行的 list item 转换为 markdown 链接
--- 支持格式：
---   - 文本: URL  →  - [文本](URL)
---   - 文本：URL  →  - [文本](URL)    （中文冒号）
---   - URL         →  - [链接](URL)    （光标选中"链接"方便替换）
function M.convert_line_to_link()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  -- 提取 list item 前缀（支持 -, *, + 和有序列表）
  local prefix = line:match("^(%s*[%-%*%+] )")
    or line:match("^(%s*[%-%*%+] %[.%] )") -- checkbox: - [x]
    or line:match("^(%s*%d+%. )")
  if not prefix then
    -- 不是 list item，尝试整行处理
    prefix = ""
  end

  local content = line:sub(#prefix + 1)

  -- 尝试匹配 "文本: URL" 或 "文本：URL"（冒号后可选空格）
  local text, url = extract_text_and_url(content)

  if text and url and text ~= "" then
    -- 有文本和链接
    text = text:gsub("%s+$", "") -- 去掉文本末尾空格
    local new_line = prefix .. "[" .. text .. "](" .. url .. ")"
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  else
    -- 尝试匹配纯 URL
    url = content:match("^(" .. url_pattern .. ")%s*$")
    if url then
      local new_line = prefix .. "[](" .. url .. ")"
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
      -- 光标移到 [] 中间，进入插入模式等待用户输入链接文本
      vim.api.nvim_win_set_cursor(0, { row, #prefix + 1 })
      vim.cmd("startinsert")
    else
      vim.notify("当前行未找到 URL", vim.log.levels.WARN)
    end
  end
end

--- Visual 模式：将选中文本转换为 markdown 链接
--- - 选中的是 URL       →  [](URL)              光标在 [] 中间
--- - 选中的是普通文本   →  [text](剪贴板URL)    若剪贴板有 URL 则自动填入
---                      →  [text]()              否则光标在 () 中间
--- - 选中的是 文本+URL  →  [text](URL)           （冒号/空格分隔）
function M.convert_selection_to_link()
  -- 获取选区内容
  -- 先退出 visual mode 以更新 marks
  vim.cmd('normal! "zy')
  local selected = vim.fn.getreg("z")
  -- 去掉首尾空白
  selected = selected:gsub("^%s+", ""):gsub("%s+$", "")

  -- 情况3：文本 + URL（冒号或空格分隔）
  local text, url = extract_text_and_url(selected)
  if text and url and text ~= "" then
    text = text:gsub("%s+$", "")
    local replacement = "[" .. text .. "](" .. url .. ")"
    vim.fn.setreg("z", replacement)
    vim.cmd('normal! gv"zp')
    return
  end

  -- 情况1：选中的是纯 URL
  url = selected:match("^(" .. url_pattern .. ")$")
  if url then
    local replacement = "[](" .. url .. ")"
    vim.fn.setreg("z", replacement)
    vim.cmd('normal! gv"zp')
    -- 光标移到 [] 中间（等待输入链接文本）
    vim.fn.search("\\[\\]", "b")
    vim.cmd("normal! l")
    vim.cmd("startinsert")
    return
  end

  -- 情况2：选中的是普通文本
  -- 检查系统剪贴板中是否有 URL，有则自动填入
  local clipboard = vim.fn.getreg("+")
  local clipboard_url = clipboard and clipboard:match("^%s*(https?://[^%s]+)%s*$")
  if clipboard_url then
    local replacement = "[" .. selected .. "](" .. clipboard_url .. ")"
    vim.fn.setreg("z", replacement)
    vim.cmd('normal! gv"zp')
  else
    local replacement = "[" .. selected .. "]()"
    vim.fn.setreg("z", replacement)
    vim.cmd('normal! gv"zp')
    -- 光标移到 () 中间（等待输入 URL）
    vim.fn.search("]()", "b", vim.fn.line("."))
    -- search 找到的是 ] 位置，需要移动到 ( 后面
    vim.cmd("normal! 2l")
    vim.cmd("startinsert")
  end
end

--- 获取光标所在位置的 markdown 链接
--- 支持两种格式：
---   [text](url)  — 标准 markdown 链接，返回 text, url
---   [[text]]     — wiki link，返回 text, nil
--- 不在链接上时返回 nil, nil
local function get_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 转为 1-based

  -- 先检查 wiki link [[text]]
  local search_start = 1
  while true do
    local ws = line:find("%[%[", search_start)
    if not ws then
      break
    end
    local we = line:find("%]%]", ws + 2)
    if we and col >= ws and col <= we + 1 then
      local text = line:sub(ws + 2, we - 1)
      if text ~= "" then
        return text, nil
      end
    end
    search_start = (we or ws) + 1
  end

  -- 再检查标准 markdown 链接 [text](url)
  search_start = 1
  while true do
    local bracket_start = line:find("%[", search_start)
    if not bracket_start then
      break
    end
    -- 跳过 wiki link 的第二个 [
    if bracket_start > 1 and line:sub(bracket_start - 1, bracket_start - 1) == "[" then
      search_start = bracket_start + 1
    else
      -- 找匹配的 ]
      local depth = 1
      local pos = bracket_start + 1
      local bracket_end
      while pos <= #line do
        local ch = line:sub(pos, pos)
        if ch == "[" then
          depth = depth + 1
        elseif ch == "]" then
          depth = depth - 1
          if depth == 0 then
            bracket_end = pos
            break
          end
        end
        pos = pos + 1
      end

      if bracket_end and line:sub(bracket_end + 1, bracket_end + 1) == "(" then
        local paren_start = bracket_end + 2
        local paren_depth = 1
        pos = paren_start
        local paren_end
        while pos <= #line do
          local ch = line:sub(pos, pos)
          if ch == "(" then
            paren_depth = paren_depth + 1
          elseif ch == ")" then
            paren_depth = paren_depth - 1
            if paren_depth == 0 then
              paren_end = pos
              break
            end
          end
          pos = pos + 1
        end

        if paren_end and col >= bracket_start and col <= paren_end then
          local text = line:sub(bracket_start + 1, bracket_end - 1)
          local url = line:sub(paren_start, paren_end - 1)
          return text, url
        end

        search_start = (paren_end or pos) + 1
      else
        search_start = (bracket_end or pos) + 1
      end
    end
  end
  return nil, nil
end

--- markdown gd 增强：光标在链接上时，优先跳转到项目中同名的本地 md 文件
--- 支持 [text](url) 和 [[text]] 两种格式
--- 条件：链接文字非空、项目中存在同名 .md 文件
---   对于 [text](url)：额外要求 url 是 http(s) 链接
--- 不满足条件时回退默认 gd（vim.lsp.buf.definition）
function M.follow_link()
  local text, url = get_link_under_cursor()

  if not text or text == "" then
    vim.lsp.buf.definition()
    return
  end

  -- [text](url) 格式：要求 url 是 http(s) 链接才走本地文件搜索
  if url and not url:match("^https?://") then
    vim.lsp.buf.definition()
    return
  end

  -- 获取当前文件所在 git 仓库的根目录，非 git 仓库则 fallback 到默认 gd
  local file_dir = vim.fn.expand("%:p:h")
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
    vim.lsp.buf.definition()
    return
  end
  local root = git_root
  local escaped = vim.fn.escape(text, "[]?*")
  local results = vim.fn.globpath(root, "**/" .. escaped .. ".md", false, true)

  -- 过滤掉当前文件自身
  local current_file = vim.fn.expand("%:p")
  results = vim.tbl_filter(function(f)
    return vim.fn.fnamemodify(f, ":p") ~= current_file
  end, results)

  if #results == 0 then
    vim.lsp.buf.definition()
    return
  elseif #results == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(results[1]))
  else
    vim.ui.select(results, {
      prompt = "选择要跳转的文件:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":~:.")
      end,
    }, function(choice)
      if choice then
        vim.cmd("edit " .. vim.fn.fnameescape(choice))
      end
    end)
  end
end

return M
