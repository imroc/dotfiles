local have_dap, dap = pcall(require, "dap")

if not have_dap then
  return
end

---
---Returns a kubectl prefix. e.g. `kubectl --context <context> --namespace <namespace>`
---
---@param config table
---@return string
local get_kubectl_prefix = function(config)
  local kubectl_prefix = config.kubectl_path or "kubectl"
  if config.context then
    kubectl_prefix = kubectl_prefix .. " --context " .. config.context
  end
  if config.namespace then
    kubectl_prefix = kubectl_prefix .. " --namespace " .. config.namespace
  end
  return kubectl_prefix
end

---
---Returns a kubectl common args as table. e.g. `--context <context> --namespace <namespace>`
---
---@param config table
---@return table
local get_kubectl_common_args = function(config)
  local kubectl_prefix = {}
  if config.context then
    vim.list_extend(kubectl_prefix, { "--context", config.text })
  end
  if config.namespace then
    vim.list_extend(kubectl_prefix, { "--namespace", config.namespace })
  end
  return kubectl_prefix
end

local enrich_kube_go_config = function(config, on_config)
  local final_config = vim.deepcopy(config)
  final_config.mode = "local"
  -- 一般要调试的是容器主进程，pid 默认为 1
  final_config.processId = final_config.processId or 1
  -- 只支持 attach
  final_config.request = "attach"
  on_config(final_config)
end

-- launch.json 配置示例:
-- {
--   "version": "0.2.0",
--   "configurations": [
--     {
--       "type": "kubernetes-go",
--       "name": "debug app in k8s",
--       "context": "tke",
--       "namespace": "bookinfo",
--       "target": "deployment/productpage",
--       "startDlv": {
--         "container": "productpage",
--         "dlvPath": "/bin/dlv"
--       }
--     }
--   ]
-- }
dap.adapters["kubernetes-go"] = function(callback, config)
  ---@diagnostic disable-next-line: undefined-field
  local target = config.target
  assert(target, "`target` is required for a k8s `attach` configuration")

  ---@diagnostic disable-next-line: undefined-field
  local startDlv = config.startDlv
  if startDlv then
    local kubectl_prefix = get_kubectl_prefix(config)
    local exec_script = kubectl_prefix .. " exec "
    ---@diagnostic disable-next-line: undefined-field
    if startDlv.container then
      ---@diagnostic disable-next-line: undefined-field
      exec_script = exec_script .. " -c " .. startDlv.container
    end
    ---@diagnostic disable-next-line: undefined-field
    local dlv_path = startDlv.dlvPath or "dlv"
    ---@diagnostic disable-next-line: undefined-field
    local bash_path = startDlv.bashPath or "bash"
    ---@diagnostic disable-next-line: undefined-field
    local listen_port = startDlv.listenPort or "${port}"
    exec_script = exec_script
      .. " "
      .. target
      .. " -- "
      .. dlv_path
      .. " dap -l 0.0.0.0:"
      .. listen_port
      .. ' &\npid_exec="$!"\n'

    local pf_script = kubectl_prefix
      .. " port-forward "
      .. target
      .. " ${port}"
      .. ":"
      .. listen_port
      .. ' &\npid_pf="$!"\n'

    local script = "set -ex\n"
      .. exec_script
      .. pf_script
      .. [[
shutdown() {
  kill -SIGTERM $pid_pf $pid_exec
  wait $pid_pf $pid_exec
}
trap shutdown SIGTERM SIGHUP
wait
    ]]

    callback({
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      enrich_config = enrich_kube_go_config,
      executable = {
        command = bash_path,
        args = { "-c", script },
        detached = false,
      },
    })
  else
    ---@diagnostic disable-next-line: undefined-field
    local target_port = config.targetPort
    assert(target_port, "`targetPort` is required for a kube_go configuration if startDlv is not set")

    local args = get_kubectl_common_args(config)
    vim.list_extend(args, { "port-forward", target, "${port}", target_port })

    callback({
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      enrich_config = enrich_kube_go_config,
      executable = {
        ---@diagnostic disable-next-line: undefined-field
        command = config.kubectl_path or "kubectl",
        args = args,
        detached = false,
      },
    })
  end
end

-- launch.json 配置示例:
-- {
--   "version": "0.2.0",
--   "configurations": [
--     {
--       "type": "dap-server",
--       "name": "debug app with dap server",
--       "host": "127.0.0.1",
--       "port": 40000
--     }
--   ]
-- }
dap.adapters["dap-server"] = function(callback, config)
  ---@diagnostic disable-next-line: undefined-field
  local host = config.host or "127.0.0.1"
  ---@diagnostic disable-next-line: undefined-field
  local port = config.port
  assert(port, "`port` is required for a dap-server configuration")
  callback({
    type = "server",
    host = host,
    port = port,
  })
end

local resolved_path = vim.fn.getcwd() .. "/debug-roc/launch.json"
if not vim.loop.fs_stat(resolved_path) then
  return
end
require("dap.ext.vscode").load_launchjs(resolved_path, {
  ["dap-server"] = { "go", "rust" },
  ["kubernetes-go"] = { "go" },
})
