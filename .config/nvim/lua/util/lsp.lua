local M = {}

-- 递归查找最内层的函数/方法符号
local function find_inner_function(symbols, cursor)
  local best_match = nil

  for _, symbol in ipairs(symbols) do
    -- 检查光标是否在符号范围内
    if symbol.range and symbol.range.start and symbol.range["end"] then
      local start_line = symbol.range.start.line
      local start_char = symbol.range.start.character
      local end_line = symbol.range["end"].line
      local end_char = symbol.range["end"].character

      if cursor.line >= start_line and cursor.line <= end_line then
        if cursor.line == start_line then
          if cursor.character < start_char then
            goto continue
          end
        end
        if cursor.line == end_line then
          if cursor.character >= end_char then
            goto continue
          end
        end

        -- 优先匹配更具体的子符号
        local child_match
        if symbol.children then
          child_match = find_inner_function(symbol.children, cursor)
        end

        -- 选择最内层的匹配
        if child_match then
          best_match = child_match
        else
          -- 仅匹配函数/方法 (LSP SymbolKind 6=Method, 12=Function)
          if symbol.kind == 6 or symbol.kind == 12 then
            best_match = symbol
          end
        end
      end
    end
    ::continue::
  end

  return best_match
end

function M.jump_to_method_name()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(win)
  local lsp_pos = { line = cursor_pos[1] - 1, character = cursor_pos[2] }

  -- 获取当前缓冲区的 LSP 客户端
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No active LSP client found", vim.log.levels.WARN)
    return
  end

  -- 处理文档符号
  local function handle_symbols(symbols)
    if not symbols or vim.tbl_isempty(symbols) then
      return
    end

    local target_symbol = find_inner_function(symbols, lsp_pos)
    if not target_symbol then
      return
    end

    -- 优先使用 selectionRange (名称范围)，没有则使用整个范围
    local target_range = target_symbol.selectionRange or target_symbol.range
    if not target_range then
      return
    end

    -- 跳转到函数名起始位置
    vim.api.nvim_win_set_cursor(win, {
      target_range.start.line + 1,
      target_range.start.character,
    })
  end

  -- 请求文档符号
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result)
    if err then
      vim.notify("LSP error: " .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result then
      vim.notify("No symbols found", vim.log.levels.INFO)
      return
    end

    -- 处理两种可能的响应格式
    if vim.islist(result) then
      if result[1] and result[1].location then
        -- SymbolInformation 格式 (扁平列表)
        local symbols = {}
        for _, item in ipairs(result) do
          table.insert(symbols, {
            name = item.name,
            kind = item.kind,
            range = item.location.range,
          })
        end
        handle_symbols(symbols)
      else
        -- DocumentSymbol 格式 (树形结构)
        handle_symbols(result)
      end
    end
  end)
end

return M
