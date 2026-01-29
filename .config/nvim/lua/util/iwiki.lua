---@diagnostic disable: undefined-global
-- Used for sync markdown file to tencent iwiki (tencent internal wiki platform)
local M = {}

local buffer = require("util.buffer")
local job = require("util.job")

-- 图片下载相关
local image_cache_dir = vim.fn.stdpath("cache") .. "/iwiki/images"
local downloading = {} -- 正在下载的 attachment id 集合

function M.save_iwiki()
  local file_path = buffer.absolute_path()
  job.run_script('iwiki.sh save "' .. file_path .. '"', {
    on_exit = function(job, code, signal)
      if code == 0 then
        vim.notify("Successfully synced to iwiki")
      else
        local result = job:stderr_result()
        if next(result) == nil then
          result = job:result()
        end
        if next(result) ~= nil then
          local msg = table.concat(result, "\n")
          vim.notify(msg)
        end
      end
    end,
  })
end

function M.open_iwiki()
  local file_path = buffer.absolute_path()
  job.run_script('iwiki.sh open "' .. file_path .. '"')
end

-- function insert_at_cursor(text)
--   local cursor = vim.api.nvim_win_get_cursor(0)
--   vim.api.nvim_buf_set_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2], { text })
--   vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + #text })
-- end

function M.insert_image()
  local file_path = buffer.absolute_path()
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = "iwiki.sh",
    args = { "upload", file_path },
  }):sync()

  local msg = ""
  if next(result) ~= nil then
    msg = table.concat(result, "\n")
  end

  if code == 0 then
    if next(result) ~= nil then
      vim.notify("successfully upload image to iwiki")
      vim.fn.setreg(vim.v.register, msg)
    else
      vim.notify("empty result", vim.log.levels.WARN)
    end
  else
    vim.notify("failed to upload image to iwiki:" .. msg, vim.log.levels.ERROR)
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

  vim.system({ "iwiki.sh", "download", id, cache_path }, { text = true }, function(result)
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
