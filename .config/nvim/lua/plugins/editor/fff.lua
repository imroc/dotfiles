return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- Build from source using the default ripgrep backend (not zlob).
    -- The prebuilt binary uses zlob, which does not respect the global
    -- gitignore file (~/.config/git/ignore). The ripgrep backend uses
    -- the `ignore` crate with git_global(true), which correctly honors
    -- global, local, and .git/info/exclude gitignore rules.
    local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
    local marker = plugin_dir .. '/target/release/.built-from-source'
    local done = false
    local err_msg = nil
    vim.system({ 'cargo', 'build', '--release' }, { cwd = plugin_dir }, function(result)
      if result.code ~= 0 then
        err_msg = 'Failed to build fff.nvim from source: ' .. (result.stderr or 'unknown error')
      else
        -- Create marker so init() knows the binary was built from source
        local f = io.open(marker, 'w')
        if f then f:close() end
        vim.schedule(function()
          vim.notify('fff.nvim: built from source (ripgrep backend)', vim.log.levels.INFO)
        end)
      end
      done = true
    end)
    -- Block until build completes (lazy.nvim build hook is synchronous)
    local timeout_ms = 1000 * 60 * 5 -- 5 minutes
    vim.wait(timeout_ms, function() return done end, 100)
    if err_msg then error(err_msg) end
  end,
  init = function()
    -- fff.nvim leaks LMDB reader slots (~17 per nvim session). When the
    -- 126-slot default limit is exhausted, MDB_READERS_FULL causes a
    -- segfault. This pre-load hook clears the lock file if reader slots
    -- are near full, preventing the crash.
    -- See: https://github.com/dmtrKovalenko/fff/issues (reader slot leak)
    local cache = vim.fn.stdpath("cache")
    local data = vim.fn.stdpath("data")
    local lock_files = {
      cache .. "/fff_nvim/lock.mdb",
      data .. "/fff_queries/lock.mdb",
    }
    for _, lock_file in ipairs(lock_files) do
      local f = io.open(lock_file, "rb")
      if f then
        local content = f:read("*a")
        f:close()
        -- LMDB lock file: maxreaders at offset 0x10 (4 bytes LE)
        -- Reader table starts at offset 0x80, each entry is 64 bytes
        -- Entry: txnid(8) + pid(4) + pad(4) + tid(8) + pad(32)
        if #content >= 0x84 then
          local max_readers = content:byte(0x11) + content:byte(0x12) * 256
          local used = 0
          local offset = 0x81 -- 1-indexed: offset 0x80 = byte 0x81
          while offset + 63 <= #content do
            -- Check if slot is used (pid field at offset+8 is non-zero)
            local pid_byte = content:byte(offset + 8)
            if pid_byte ~= 0 then
              used = used + 1
            end
            offset = offset + 64
          end
          -- If >90% slots used, delete lock file to reset reader table
          if used > max_readers * 0.9 then
            vim.schedule(function()
              vim.notify(
                string.format("fff.nvim: LMDB reader slots near full (%d/%d), clearing lock file", used, max_readers),
                vim.log.levels.WARN
              )
            end)
            os.remove(lock_file)
          end
        end
      end
    end

    -- Auto-rebuild from source if the binary is the prebuilt zlob version.
    -- The marker file is created by the build() function after successful
    -- cargo build --release. If it's missing, the binary was either
    -- downloaded (zlob, doesn't respect global gitignore) or doesn't exist.
    -- We trigger a background rebuild so the user doesn't need to manually
    -- run :Lazy build after syncing dotfiles to a new machine.
    vim.schedule(function()
      local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h')
      local marker = plugin_dir .. '/target/release/.built-from-source'
      local binary_ext = vim.uv.os_uname().sysname == 'Darwin' and 'dylib' or 'so'
      local binary = plugin_dir .. '/target/release/libfff_nvim.' .. binary_ext

      -- Binary doesn't exist yet — lazy.nvim will run build() on first install
      if not vim.uv.fs_stat(binary) then return end

      -- Marker exists — already built from source, nothing to do
      if vim.uv.fs_stat(marker) then return end

      -- Binary exists but no marker → prebuilt zlob version, need to rebuild
      if vim.fn.executable('cargo') == 0 then
        vim.notify(
          'fff.nvim: 当前使用预编译二进制 (zlob)，全局 gitignore 不生效。\n'
            .. '请安装 Rust 工具链后运行 :Lazy build fff.nvim 重新编译。',
          vim.log.levels.WARN
        )
        return
      end

      -- Check if a build is already in progress (lock file)
      local lock = plugin_dir .. '/target/release/.building'
      if vim.uv.fs_stat(lock) then return end

      -- Start background rebuild
      local f = io.open(lock, 'w')
      if f then f:close() end

      vim.notify(
        'fff.nvim: 检测到预编译二进制 (zlob)，正在后台从源码编译 (ripgrep 后端)...\n'
          .. '完成后需重启 nvim 生效。',
        vim.log.levels.INFO
      )

      vim.system({ 'cargo', 'build', '--release' }, { cwd = plugin_dir }, function(result)
        os.remove(lock)
        if result.code ~= 0 then
          vim.schedule(function()
            vim.notify(
              'fff.nvim: 后台编译失败: ' .. (result.stderr or 'unknown error') .. '\n'
                .. '请手动运行 :Lazy build fff.nvim',
              vim.log.levels.ERROR
            )
          end)
          return
        end
        -- Create marker
        local mf = io.open(marker, 'w')
        if mf then mf:close() end
        vim.schedule(function()
          vim.notify(
            'fff.nvim: 后台编译完成 (ripgrep 后端)，请重启 nvim 生效。',
            vim.log.levels.INFO
          )
        end)
      end)
    end)
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
    keymaps = {
      move_up = { "<Up>", "<C-p>", "<C-k>" },
      move_down = { "<Down>", "<C-n>", "<C-j>" },
      send_to_quickfix = "<C-t>",
    },
    layout = {
      prompt_position = "top",
      height = 0.8,
      width = 0.8,
      flex = false,
    },
  },
  keys = {
    {
      "ff",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "fg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "fz",
      function()
        require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "fc",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
    {
      "<leader><space>",
      function()
        require("fff").find_files({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Find Files (Root Dir)",
    },
    {
      "<leader>/",
      function()
        require("fff").live_grep({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Grep (Root Dir)",
    },
    {
      "<leader>ff",
      function()
        require("fff").find_files({ cwd = require("util.buffer").current_dir() })
      end,
      desc = "[P]Find Files (Current Dir)",
    },
    {
      "<leader>fc",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config") })
      end,
      desc = "[P]Find Config File (~/.config)",
    },
    {
      "<leader>fl",
      function()
        require("fff").find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
      end,
      desc = "[P]Find Lazy Plugin Files",
    },
    {
      "<leader>fda",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/aerospace") })
      end,
      desc = "[P]Find Aerospace Dotfiles",
    },
    {
      "<leader>fdb",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.local/bin") })
      end,
      desc = "[P]Find Bin",
    },
    {
      "<leader>fdf",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/fish") })
      end,
      desc = "[P]Find Fish Dotfiles",
    },
    {
      "<leader>fdk",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/kitty") })
      end,
      desc = "[P]Find Kitty Dotfiles",
    },
    {
      "<leader>fdn",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/nvim") })
      end,
      desc = "[P]Find Neovim Dotfiles",
    },
    {
      "<leader>fdz",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/zellij") })
      end,
      desc = "[P]Find Zellij Dotfiles",
    },
    {
      "<leader>gw",
      function()
        local output = vim.fn.systemlist("git worktree list --porcelain")
        if vim.v.shell_error ~= 0 then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        local worktrees = {}
        for _, line in ipairs(output) do
          local path = line:match("^worktree (.+)$")
          if path then
            table.insert(worktrees, path)
          end
        end
        if #worktrees == 0 then
          vim.notify("No worktrees found", vim.log.levels.WARN)
          return
        end
        if #worktrees == 1 then
          require("fff").find_files({ cwd = worktrees[1] })
          return
        end
        local names = {}
        local name_to_path = {}
        for _, path in ipairs(worktrees) do
          local name = vim.fn.fnamemodify(path, ":t")
          table.insert(names, name)
          name_to_path[name] = path
        end
        Snacks.picker.select(names, { prompt = "Worktree" }, function(name)
          if name then
            require("fff").find_files({ cwd = name_to_path[name] })
          end
        end)
      end,
      desc = "[P]Git Worktree Files",
    },
  },
}
