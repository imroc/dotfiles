-- mac-bridge: 远程 SSH 会话到本地 Mac 的通用回调桥接
--
-- 通过 SSH 反向隧道（RemoteForward 17395），远程 nvim 可发送 JSON 请求
-- 到本地 Mac 的 mac-bridge 服务，触发本地命令执行。
--
-- 用法：
--   require('util.mac_bridge').send("jb", { path = "/root/dev/tke/enp" })
--   require('util.mac_bridge').send("url", { url = "https://google.com" })
--   require('util.mac_bridge').send_sync("iwiki_image", { doc_id = "12345" })
--   require('util.mac_bridge').available()  -- 检查隧道是否可用

local M = {}

local TUNNEL_PORT = 17395

local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil

-- 启动时检测隧道可用性（与 im-select.lua 的检测逻辑一致）
local tunnel_available = false
if is_ssh then
  vim.fn.system({ "nc", "-z", "-w1", "127.0.0.1", tostring(TUNNEL_PORT) })
  tunnel_available = vim.v.shell_error == 0
end

--- 隧道是否可用（SSH 环境 + 反向隧道端口可达）
function M.available()
  return tunnel_available
end

--- 异步发送请求到 mac-bridge 服务（fire-and-forget）
--- @param handler string handler 名称（如 "jb"、"url"、"im_switch"）
--- @param payload table? 请求参数
--- @return boolean 是否成功发送
function M.send(handler, payload)
  if not tunnel_available then
    return false
  end
  payload = vim.tbl_extend("force", { handler = handler }, payload or {})
  local json = vim.fn.json_encode(payload)
  vim.fn.system({ "nc", "-w1", "127.0.0.1", tostring(TUNNEL_PORT) }, json)
  return true
end

--- 同步发送请求并等待响应（用于需要回传结果的 handler）
--- @param handler string handler 名称（如 "iwiki_image"）
--- @param payload table? 请求参数
--- @return table|nil 响应 JSON（解析后的 dict），nil 表示失败
function M.send_sync(handler, payload)
  if not tunnel_available then
    return nil
  end
  payload = vim.tbl_extend("force", { handler = handler }, payload or {})
  local json = vim.fn.json_encode(payload)
  local resp = vim.fn.system({ "nc", "-w30", "127.0.0.1", tostring(TUNNEL_PORT) }, json)
  if vim.v.shell_error ~= 0 or resp == "" then
    return nil
  end
  local ok, result = pcall(vim.json.decode, resp)
  if ok then
    return result
  end
  return nil
end

return M
