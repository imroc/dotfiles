-- Pandoc Lua filter: 将表格列格式从无竖线改为有竖线
-- 例如 @{}lll@{} -> |l|l|l|

-- 转义 LaTeX 特殊字符，避免表格内容中的 _、#、%、$、{、}、~、^ 等导致编译失败
local function escape_latex(s)
  -- 注意：\ 不转义，因为内容可能包含已有的 LaTeX 命令
  s = s:gsub("([#$%%_{}&])", "\\%1")
  s = s:gsub("~", "\\textasciitilde{}")
  s = s:gsub("%^", "\\textasciicircum{}")
  return s
end

function Table(el)
  if FORMAT:match("latex") then
    -- 构建带竖线的列格式
    local aligns = {}
    for i, colspec in ipairs(el.colspecs) do
      local align = colspec[1]
      if align == pandoc.AlignLeft then
        aligns[i] = "l"
      elseif align == pandoc.AlignRight then
        aligns[i] = "r"
      elseif align == pandoc.AlignCenter then
        aligns[i] = "c"
      else
        aligns[i] = "l"
      end
    end
    local colformat = "|" .. table.concat(aligns, "|") .. "|"

    -- 用 RawBlock 手动输出 longtable
    local result = {}

    table.insert(result, pandoc.RawBlock("latex", "\\begin{longtable}[]{" .. colformat .. "}"))
    table.insert(result, pandoc.RawBlock("latex", "\\hline"))

    -- 表头
    if el.head and el.head.rows and #el.head.rows > 0 then
      for _, row in ipairs(el.head.rows) do
        local cells = {}
        for _, cell in ipairs(row.cells) do
          table.insert(cells, escape_latex(pandoc.utils.stringify(cell.contents)))
        end
        table.insert(result, pandoc.RawBlock("latex", table.concat(cells, " & ") .. " \\\\"))
      end
      table.insert(result, pandoc.RawBlock("latex", "\\hline"))
      table.insert(result, pandoc.RawBlock("latex", "\\endhead"))
    end

    -- 表体
    for _, body in ipairs(el.bodies) do
      for _, row in ipairs(body.body) do
        local cells = {}
        for _, cell in ipairs(row.cells) do
          table.insert(cells, escape_latex(pandoc.utils.stringify(cell.contents)))
        end
        table.insert(result, pandoc.RawBlock("latex", table.concat(cells, " & ") .. " \\\\"))
        table.insert(result, pandoc.RawBlock("latex", "\\hline"))
      end
    end

    table.insert(result, pandoc.RawBlock("latex", "\\end{longtable}"))

    return result
  end
end
