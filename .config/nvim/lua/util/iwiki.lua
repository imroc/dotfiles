---@diagnostic disable: undefined-global
-- Used for sync markdown file to tencent iwiki (tencent internal wiki platform)
local M = {}

local buffer = require("util.buffer")
local job = require("util.job")

local cmd = "iwiki"

-- 图片下载相关
local image_cache_dir = vim.fn.stdpath("cache") .. "/iwiki/images"
local downloading = {} -- 正在下载的 attachment id 集合

function M.is_iwiki()
  local dir = vim.fn.expand("%:p:h")
  return vim.fn.filereadable(dir .. "/iwiki.json") == 1
end


--- 从当前文件的 iwiki.json 获取文档 ID
--- @return string|nil doc_id
function M.get_doc_id()
  local file_path = buffer.absolute_path()
  local name = vim.fn.fnamemodify(file_path, ":t:r")
  local json_file = vim.fn.expand("%:p:h") .. "/iwiki.json"
  if vim.fn.filereadable(json_file) ~= 1 then
    return nil
  end
  local content = table.concat(vim.fn.readfile(json_file), "")
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" then
    return nil
  end
  local doc_id = data[name]
  if not doc_id then
    -- 全角 ／ 转回 / 再查一次
    local converted = name:gsub("／", "/")
    doc_id = data[converted]
  end
  return doc_id and tostring(doc_id) or nil
end

local function save_iwiki_impl(force)
  local file_path = buffer.absolute_path()
  local extra = force and " --force" or ""
  job.run_script(cmd .. ' save "' .. file_path .. '"' .. extra, {
    on_exit = function(j, code, signal)
      if code == 0 then
        vim.notify("Successfully synced to iwiki")
      else
        local result = j:stderr_result()
        if next(result) == nil then
          result = j:result()
        end
        if next(result) ~= nil then
          local msg = table.concat(result, "\n")
          vim.notify(msg, vim.log.levels.ERROR)
        end
      end
    end,
  })
end

function M.save_iwiki()
  save_iwiki_impl(false)
end

function M.save_iwiki_force()
  save_iwiki_impl(true)
end

function M.open_iwiki()
  local file_path = buffer.absolute_path()

  -- SSH 环境：远程获取文档 URL，通过 mac-bridge 让 Mac 打开浏览器
  local mac_bridge = require("util.mac_bridge")
  if mac_bridge.available() then
    local result = vim.fn.system({ cmd, "url", file_path })
    if vim.v.shell_error == 0 and result ~= "" then
      local url = result:gsub("%s+$", "")
      mac_bridge.send("url", { url = url })
      vim.notify("已在 Mac 打开: " .. url)
    else
      vim.notify("无法获取文档 URL", vim.log.levels.ERROR)
    end
    return
  end

  -- 本地环境：iwiki open 直接用 macOS open 打开
  job.run_script(cmd .. ' open "' .. file_path .. '"')
end

function M.open_iwiki_cmux()
  local file_path = buffer.absolute_path()
  local cmux = require("util.cmux")
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = cmd,
    args = { "url", file_path },
  }):sync()
  if code == 0 and result and next(result) ~= nil then
    cmux.open_browser(result[1], { same_pane = true })
    -- 等页面加载后关闭侧边栏(Cmd+Opt+,)和 TOC(Opt+[)
    vim.defer_fn(function()
      vim.fn.jobstart({
        "osascript",
        "-e",
        'tell application "System Events" to tell process "cmux" to keystroke "," using {command down, option down}',
      })
      vim.defer_fn(function()
        vim.fn.jobstart({
          "osascript",
          "-e",
          'tell application "System Events" to tell process "cmux" to keystroke "[" using {option down}',
        })
      end, 800)
    end, 2000)
  else
    vim.notify("无法获取文档 URL", vim.log.levels.ERROR)
  end
end

function M.insert_image()
  local file_path = buffer.absolute_path()
  local register = vim.v.register

  -- SSH 环境：通过 mac-bridge 回调 Mac 上传剪贴板图片
  local mac_bridge = require("util.mac_bridge")
  if mac_bridge.available() then
    local doc_id = M.get_doc_id()
    if not doc_id then
      vim.notify("无法获取 iwiki 文档 ID（当前文件不在 iwiki 目录？）", vim.log.levels.ERROR)
      return
    end
    vim.notify("正在上传图片到 iwiki...")
    local result = mac_bridge.send_sync("iwiki_image", { doc_id = doc_id })
    if result and result.ok and result.image_md then
      vim.notify("图片上传成功")
      vim.fn.setreg(register, result.image_md)
      -- 在当前行下方插入
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_set_lines(0, pos[1], pos[1], false, { result.image_md })
    else
      local err = (result and result.error) or "未知错误"
      vim.notify("上传失败: " .. err, vim.log.levels.ERROR)
    end
    return
  end

  -- 本地环境：直接调用 iwiki upload（原逻辑）
  vim.notify("uploading image to iwiki...")
  local Job = require("plenary.job")
  Job:new({
    command = cmd,
    args = { "upload", file_path },
    on_exit = vim.schedule_wrap(function(j, code)
      local result = j:result()
      local msg = (result and next(result) ~= nil) and table.concat(result, "\n") or ""

      if code == 0 then
        if msg ~= "" then
          vim.notify("successfully upload image to iwiki")
          vim.fn.setreg(register, msg)
        else
          vim.notify("empty result", vim.log.levels.WARN)
        end
      else
        local stderr = j:stderr_result()
        local err_msg = (stderr and next(stderr) ~= nil) and table.concat(stderr, "\n") or msg
        vim.notify("failed to upload image to iwiki: " .. err_msg, vim.log.levels.ERROR)
      end
    end),
  }):start()
end

function M.copy_url()
  local file_path = buffer.absolute_path()
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = cmd,
    args = { "url", file_path },
  }):sync()

  if code == 0 and result and next(result) ~= nil then
    local url = result[1]
    vim.fn.setreg("+", url)
    vim.notify("Copied: " .. url)
  else
    local msg = (result and next(result) ~= nil) and table.concat(result, "\n") or "无法获取文档 URL"
    vim.notify(msg, vim.log.levels.ERROR)
  end
end

--- 从 URL 中提取 attachmentid
---@param src string
---@return string|nil
function M.extract_attachment_id(src)
  return src:match("attachmentid=(%d+)")
end

--- 检查是否是 iwiki 图片 URL
---@param src string
---@return boolean
function M.is_iwiki_image(src)
  return src:match("/tencent/api/attachments/s3/url%?attachmentid=%d+") ~= nil
end

--- 获取缓存文件路径
---@param id string
---@return string
function M.get_image_cache_path(id)
  return image_cache_dir .. "/" .. id .. ".png"
end

--- 检查缓存是否存在
---@param id string
---@return boolean
function M.image_cache_exists(id)
  return vim.fn.filereadable(M.get_image_cache_path(id)) == 1
end

--- 异步下载图片
---@param id string
---@param on_done? fun() 下载完成回调
function M.download_image_async(id, on_done)
  if downloading[id] then
    return
  end

  local cache_path = M.get_image_cache_path(id)

  -- 确保缓存目录存在
  vim.fn.mkdir(image_cache_dir, "p")

  downloading[id] = true

  vim.system({ cmd, "download", id, cache_path }, { text = true }, function(result)
    downloading[id] = nil
    if result.code == 0 and on_done then
      vim.schedule(on_done)
    end
  end)
end

--- 解析 iwiki 图片路径（供 snacks.nvim resolve 配置使用）
---@param file string 当前文件路径
---@param src string 图片 src
---@return string|nil 返回本地缓存路径，或 nil 表示不处理
function M.resolve_image(file, src)
  if not M.is_iwiki_image(src) then
    return nil
  end

  local id = M.extract_attachment_id(src)
  if not id then
    return nil
  end

  local cache_path = M.get_image_cache_path(id)

  if M.image_cache_exists(id) then
    return cache_path
  end

  -- 异步下载，完成后刷新当前 buffer 的图片
  M.download_image_async(id, function()
    -- 触发 snacks image 重新渲染
    local buf = vim.fn.bufnr(file)
    if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("doautocmd FileType")
      end)
    end
  end)

  -- 返回缓存路径（即使还不存在，snacks 会处理文件不存在的情况）
  return cache_path
end

return M
