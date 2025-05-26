local M = {}

local zellij = require("util.zellij")
local buffer = require("util.buffer")
local term = require("util.term")
local job = require("util.job")

function M.open_k9s_in_zellij()
  -- 用 fish 包装一下，避免 EDITOR 环境变量经过 zellij 后不被传递给 k9s，导致 e 键使用 vi 而不是 nvim 打开 (fish 启动时会加载环境变量，并传递给脚本里的子进程)
  local script = "EDITOR=nvim "
  local kubeconfig = os.getenv("KUBECONFIG")
  if kubeconfig then
    script = script .. "KUBECONFIG=" .. kubeconfig .. " "
  end
  script = script .. "k9s"
  zellij.run_script(script, { name = "k9s", close_on_exit = true })
end

function M.open_k9s_in_term()
  local env = {
    EDITOR = "nvim",
  }
  local kubeconfig = os.getenv("KUBECONFIG")
  if kubeconfig then
    env.KUBECONFIG = kubeconfig
  end
  Snacks.terminal({ "k9s" }, {
    env = env,
  })
end

function M.kubectl_apply()
  local file = buffer.absolute_path()
  job.run_script("kubectl apply -f " .. file)
end

function M.kubectl_apply_term()
  local file = buffer.absolute_path()
  term.run_script("kubectl apply -f " .. file)
end

function M.kubectl_delete()
  local file = buffer.absolute_path()
  job.run_script("kubectl delete -f " .. file)
end

function M.kubectl_delete_term()
  local file = buffer.absolute_path()
  term.run_script("kubectl delete -f " .. file)
end

function M.kustomize_apply()
  local dir = buffer.current_dir()
  job.run_script(
    "kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone " .. dir .. " | kubectl apply -f -"
  )
end

function M.kustomize_apply_term()
  local dir = buffer.current_dir()
  term.run_script(
    "kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone " .. dir .. " | kubectl apply -f -"
  )
end

function M.kustomize_delete()
  local dir = buffer.current_dir()
  job.run_script(
    "kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone " .. dir .. " | kubectl delete -f -"
  )
end

function M.kustomize_delete_term()
  local dir = buffer.current_dir()
  term.run_script(
    "kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone " .. dir .. " | kubectl delete -f -"
  )
end

return M
