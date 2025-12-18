local M = {}

-- -- All of the section below is to show the git status on files found here
-- -- https://www.reddit.com/r/neovim/comments/1c37m7c/is_there_a_way_to_get_the_minifiles_plugin_to/
-- -- Which points to
-- -- https://gist.github.com/bassamsdata/eec0a3065152226581f8d4244cce9051#file-notes-md
local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
local autocmd = vim.api.nvim_create_autocmd

-- Cache for git status
local gitStatusCache = {}
local cacheTimeout = 2000 -- Cache timeout in milliseconds

local function isSymlink(path)
  local stat = vim.loop.fs_lstat(path)
  return stat and stat.type == "link"
end

---@type table<string, {symbol: string, hlGroup: string}>
---@param status string
---@return string symbol, string hlGroup
local function mapSymbols(status, is_symlink)
  local statusMap = {
    -- stylua: ignore start 
        [" M"] = { symbol = "✹", hlGroup  = "MiniDiffSignChange"}, -- Modified in the working directory
        ["M "] = { symbol = "•", hlGroup  = "MiniDiffSignChange"}, -- modified in index
        ["MM"] = { symbol = "≠", hlGroup  = "MiniDiffSignChange"}, -- modified in both working tree and index
        ["A "] = { symbol = "+", hlGroup  = "MiniDiffSignAdd"   }, -- Added to the staging area, new file
        ["AA"] = { symbol = "≈", hlGroup  = "MiniDiffSignAdd"   }, -- file is added in both working tree and index
        ["D "] = { symbol = "-", hlGroup  = "MiniDiffSignDelete"}, -- Deleted from the staging area
        ["AM"] = { symbol = "⊕", hlGroup  = "MiniDiffSignChange"}, -- added in working tree, modified in index
        ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange"}, -- Added in the index and deleted in the working directory
        ["R "] = { symbol = "→", hlGroup  = "MiniDiffSignChange"}, -- Renamed in the index
        ["U "] = { symbol = "‖", hlGroup  = "MiniDiffSignChange"}, -- Unmerged path
        ["UU"] = { symbol = "⇄", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged
        ["UA"] = { symbol = "⊕", hlGroup  = "MiniDiffSignAdd"   }, -- file is unmerged and added in working tree
        ["??"] = { symbol = "?", hlGroup  = "MiniDiffSignDelete"}, -- Untracked files
        ["!!"] = { symbol = "!", hlGroup  = "MiniDiffSignChange"}, -- Ignored files
    -- stylua: ignore end
  }

  local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
  local gitSymbol = result.symbol
  local gitHlGroup = result.hlGroup

  local symlinkSymbol = is_symlink and "↩" or ""

  -- Combine symlink symbol with Git status if both exist
  local combinedSymbol = (symlinkSymbol .. gitSymbol):gsub("^%s+", ""):gsub("%s+$", "")
  -- Change the color of the symlink icon from "MiniDiffSignDelete" to something else
  local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

  return combinedSymbol, combinedHlGroup
end

---@param cwd string
---@param callback function
---@return nil
local function fetchGitStatus(cwd, callback)
  local function on_exit(content)
    if content.code == 0 then
      callback(content.stdout)
      vim.g.content = content.stdout
    end
  end
  vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = cwd }, on_exit)
end

---@param str string|nil
---@return string
local function escapePattern(str)
  if not str then
    return ""
  end
  return (str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

---@param buf_id integer
---@param gitStatusMap table
---@return nil
local function updateMiniWithGit(buf_id, gitStatusMap)
  vim.schedule(function()
    local nlines = vim.api.nvim_buf_line_count(buf_id)
    local cwd = vim.fs.root(buf_id, ".git")
    local escapedcwd = escapePattern(cwd)
    if vim.fn.has("win32") == 1 then
      escapedcwd = escapedcwd:gsub("\\", "/")
    end

    for i = 1, nlines do
      local entry = require("mini.files").get_fs_entry(buf_id, i)
      if not entry then
        break
      end
      local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
      local status = gitStatusMap[relativePath]

      if status then
        local is_symlink = isSymlink(entry.path)
        local symbol, hlGroup = mapSymbols(status, is_symlink)
        vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
          -- NOTE: if you want the signs on the right uncomment those and comment
          -- the 3 lines after
          -- virt_text = { { symbol, hlGroup } },
          -- virt_text_pos = "right_align",
          sign_text = symbol,
          sign_hl_group = hlGroup,
          priority = 2,
        })
      else
      end
    end
  end)
end

-- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
---@param content string
---@return table
local function parseGitStatus(content)
  local gitStatusMap = {}
  -- lua match is faster than vim.split (in my experience )
  for line in content:gmatch("[^\r\n]+") do
    local status, filePath = string.match(line, "^(..)%s+(.*)")
    -- Split the file path into parts
    local parts = {}
    for part in filePath:gmatch("[^/]+") do
      table.insert(parts, part)
    end
    -- Start with the root directory
    local currentKey = ""
    for i, part in ipairs(parts) do
      if i > 1 then
        -- Concatenate parts with a separator to create a unique key
        currentKey = currentKey .. "/" .. part
      else
        currentKey = part
      end
      -- If it's the last part, it's a file, so add it with its status
      if i == #parts then
        gitStatusMap[currentKey] = status
      else
        -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
        if not gitStatusMap[currentKey] then
          gitStatusMap[currentKey] = status
        end
      end
    end
  end
  return gitStatusMap
end

---@param buf_id integer
---@return nil
local function updateGitStatus(buf_id)
  local cwd = vim.uv.cwd()
  if not cwd or not vim.fs.root(cwd, ".git") then
    return
  end

  local currentTime = os.time()
  if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
    updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
  else
    fetchGitStatus(cwd, function(content)
      local gitStatusMap = parseGitStatus(content)
      gitStatusCache[cwd] = {
        time = currentTime,
        statusMap = gitStatusMap,
      }
      updateMiniWithGit(buf_id, gitStatusMap)
    end)
  end
end

---@return nil
local function clearCache()
  gitStatusCache = {}
end

local function augroup(name)
  return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
end

M.create_autocmd = function(opts)
  autocmd("User", {
    group = augroup("start"),
    pattern = "MiniFilesExplorerOpen",
    -- pattern = { "minifiles" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      updateGitStatus(bufnr)
    end,
  })

  autocmd("User", {
    group = augroup("close"),
    pattern = "MiniFilesExplorerClose",
    callback = function()
      clearCache()
    end,
  })

  autocmd("User", {
    group = augroup("update"),
    pattern = "MiniFilesBufferUpdate",
    callback = function(sii)
      local bufnr = sii.data.buf_id
      local cwd = vim.fn.expand("%:p:h")
      if gitStatusCache[cwd] then
        updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
      end
    end,
  })

  -- Create an autocmd to set buffer-local mappings when a `mini.files` buffer is opened
  autocmd("User", {
    -- Updated pattern to match what Echasnovski has in the documentation
    -- https://github.com/echasnovski/mini.nvim/blob/c6eede272cfdb9b804e40dc43bb9bff53f38ed8a/doc/mini-files.txt#L508-L529
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf_id = args.data.buf_id
      -- Ensure opts.custom_keymaps exists
      local keymaps = opts.custom_keymaps or {}

      -- Copy the current file or directory to the lamw25wmal system clipboard
      -- NOTE: This works only on macOS
      vim.keymap.set("n", keymaps.copy_to_clipboard, function()
        -- Get the current entry (file or directory)
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          -- Build the osascript command to copy the file or directory to the clipboard
          local cmd = string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], path)
          local result = vim.fn.system(cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
          else
            vim.notify("Copied to system clipboard: " .. path)
          end
        else
          vim.notify("No file or directory selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Copy file/directory to clipboard" })

      -- ZIP current file or directory and copy to the system clipboard
      vim.keymap.set("n", keymaps.zip_and_copy, function()
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local name = vim.fn.fnamemodify(path, ":t") -- Extract the file or directory name
          local parent_dir = vim.fn.fnamemodify(path, ":h") -- Get the parent directory
          local timestamp = os.date("%y%m%d%H%M%S") -- Append timestamp to avoid duplicates
          local zip_path = string.format("/tmp/%s_%s.zip", name, timestamp) -- Path in macOS's tmp directory
          -- Create the zip file
          local zip_cmd = string.format(
            "cd %s && zip -r %s %s",
            vim.fn.shellescape(parent_dir),
            vim.fn.shellescape(zip_path),
            vim.fn.shellescape(name)
          )
          local result = vim.fn.system(zip_cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify("Failed to create zip file: " .. result, vim.log.levels.ERROR)
            return
          end
          -- Copy the zip file to the system clipboard
          local copy_cmd =
            string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], vim.fn.fnameescape(zip_path))
          local copy_result = vim.fn.system(copy_cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify("Failed to copy zip file to clipboard: " .. copy_result, vim.log.levels.ERROR)
            return
          end
          vim.notify(zip_path, vim.log.levels.INFO)
          vim.notify("Zipped and copied to clipboard: ", vim.log.levels.INFO)
        else
          vim.notify("No file or directory selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Zip and copy to clipboard" })

      -- Paste the current file or directory from the system clipboard into the current directory in mini.files
      -- NOTE: This works only on macOS
      vim.keymap.set("n", keymaps.paste_from_clipboard, function()
        local curr_entry = require("mini.files").get_fs_entry() -- Get the current file system entry
        if not curr_entry then
          vim.notify("Failed to retrieve current entry in mini.files.", vim.log.levels.ERROR)
          return
        end
        local curr_dir = curr_entry.fs_type == "directory" and curr_entry.path
          or vim.fn.fnamemodify(curr_entry.path, ":h") -- Use parent directory if entry is a file
        -- vim.notify("Current directory: " .. curr_dir, vim.log.levels.INFO)
        local script = [[
            tell application "System Events"
              try
                set theFile to the clipboard as alias
                set posixPath to POSIX path of theFile
                return posixPath
              on error
                return "error"
              end try
            end tell
          ]]
        local output = vim.fn.system("osascript -e " .. vim.fn.shellescape(script)) -- Execute AppleScript command
        if vim.v.shell_error ~= 0 or output:find("error") then
          vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
          return
        end
        local source_path = output:gsub("%s+$", "") -- Trim whitespace from clipboard output
        if source_path == "" then
          vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
          return
        end
        local dest_path = curr_dir .. "/" .. vim.fn.fnamemodify(source_path, ":t") -- Destination path in current directory
        local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path }
          or { "cp", source_path, dest_path } -- Construct copy command
        local result = vim.fn.system(copy_cmd) -- Execute the copy command
        if vim.v.shell_error ~= 0 then
          vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
          return
        end
        -- vim.notify("Pasted " .. source_path .. " to " .. dest_path, vim.log.levels.INFO)
        require("mini.files").synchronize() -- Refresh mini.files to show updated directory content
        vim.notify("Pasted successfully.", vim.log.levels.INFO)
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Paste from clipboard" })

      -- Copy the current file or directory path (relative to home) to clipboard
      vim.keymap.set("n", keymaps.copy_path, function()
        -- Get the current entry (file or directory)
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          -- Convert path to be relative to home directory
          local home_dir = vim.fn.expand("~")
          local relative_path = curr_entry.path:gsub("^" .. home_dir, "~")
          vim.fn.setreg("+", relative_path) -- Copy the relative path to the clipboard register
          vim.notify("Path copied to clipboard: " .. relative_path)
        else
          vim.notify("No file or directory selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Copy relative path to clipboard" })

      -- Preview the selected image in macOS Quick Look
      --
      -- NOTE: This is for macOS, to preview in a neovim popup see below
      --
      -- This wonderful Idea was suggested by @iduran in my youtube video:
      -- https://youtu.be/BzblG2eV8dU
      --
      -- Don't use "i" as it conflicts wit "insert"
      vim.keymap.set("n", keymaps.preview_image, function()
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          -- Preview the file using Quick Look
          vim.system({ "qlmanage", "-p", curr_entry.path }, {
            stdout = false,
            stderr = false,
          })
          -- Activate Quick Look window after a small delay
          vim.defer_fn(function()
            vim.system({ "osascript", "-e", 'tell application "qlmanage" to activate' })
          end, 200)
        else
          vim.notify("No file selected", vim.log.levels.WARN)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Preview with macOS Quick Look" })

      vim.keymap.set("n", keymaps.open_zellij, function()
        -- Get the current entry (file or directory)
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local parent_dir = vim.fn.fnamemodify(path, ":h") -- Get the parent directory
          require("util.zellij").open_float(parent_dir)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Open Zellij" })

      vim.keymap.set("n", keymaps.open_terminal, function()
        -- Get the current entry (file or directory)
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local parent_dir = vim.fn.fnamemodify(path, ":h") -- Get the parent directory
          require("util.term").goto(parent_dir)
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Open Terminal" })

      vim.keymap.set("n", keymaps.search_text, function()
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local parent_dir = vim.fn.fnamemodify(path, ":h")
          require("util.picker").grep({ cwd = parent_dir })
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Search Text" })

      vim.keymap.set("n", keymaps.search_plaintext, function()
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local parent_dir = vim.fn.fnamemodify(path, ":h")
          require("util.picker").grep({ cwd = parent_dir, regex = false })
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Search Plain Text" })

      vim.keymap.set("n", keymaps.find_files, function()
        local curr_entry = require("mini.files").get_fs_entry()
        if curr_entry then
          local path = curr_entry.path
          local parent_dir = vim.fn.fnamemodify(path, ":h")
          require("util.picker").files({ cwd = parent_dir })
        end
      end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Find Files" })
    end,
  })
end

M.open_current_dir = function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")
  if vim.fn.filereadable(buf_name) == 1 then
    -- Pass the full file path to highlight the file
    require("mini.files").open(buf_name, true)
  elseif vim.fn.isdirectory(dir_name) == 1 then
    -- If the directory exists but the file doesn't, open the directory
    require("mini.files").open(dir_name, true)
  else
    -- If neither exists, fallback to the current working directory
    require("mini.files").open(vim.uv.cwd(), true)
  end
end

M.open_cwd = function()
  require("mini.files").open(vim.uv.cwd(), false)
end

return M
