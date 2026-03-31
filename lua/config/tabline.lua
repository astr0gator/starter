-- Custom tabline: single-letter path suffix (filename/a instead of a/filename)
local function tabline()
  local line = ""

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    local filename = vim.fn.fnamemodify(name, ":t")
    local path = vim.fn.fnamemodify(name, ":h")

    if filename == "" then
      filename = "[No Name]"
    end

    local label
    if path == "." or path == "" then
      label = filename
    else
      -- Get first letter of last directory name
      local last_dir = path:match("[^/]+$") or path:match("[^/]+[^/]*/?$") or path
      local path_letter = last_dir:sub(1, 1)
      label = filename .. "/" .. path_letter
    end

    if vim.bo[buf].modified then
      label = label .. "+"
    end

    local is_current = tab == vim.api.nvim_get_current_tabpage()
    if is_current then
      line = line .. "%#TabLineSel#"
    else
      line = line .. "%#TabLine#"
    end

    line = line .. " " .. label .. " "
  end

  line = line .. "%T%#TabLineFill#"
  return line
end

vim.opt.tabline = "%!v:lua.require'config.tabline'.tabline()"
vim.opt.showtabline = 2

return { tabline = tabline }
