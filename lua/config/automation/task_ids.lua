-- Assign incrementing task IDs to backlog.md checkboxes before save.
local M = {}

local config = {
  prefix = "K",
}

local function parse_existing_id(line)
  local prefix, num = line:match("|%s*(%w+)%-(%d+)%s*$")
  if prefix and num then
    return prefix, tonumber(num)
  end
  return nil, nil
end

local function has_id(line)
  return parse_existing_id(line) ~= nil
end

local function is_task_line(line)
  local content = line:match("^%s*[-*+]?%s*%[[ xX]%]%s*(.*)$")
  if not content then
    return false
  end
  return not content:match("^%s*$")
end

local function assign_task_ids(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local max_id = 0
  local lines_to_process = {}

  for i, line in ipairs(lines) do
    if is_task_line(line) then
      local prefix, num = parse_existing_id(line)
      if prefix and num then
        if num > max_id then
          max_id = num
        end
      elseif not has_id(line) then
        table.insert(lines_to_process, i)
      end
    end
  end

  if #lines_to_process == 0 then
    return
  end

  for _, line_idx in ipairs(lines_to_process) do
    max_id = max_id + 1
    local line = lines[line_idx]
    lines[line_idx] = line:gsub("%s+$", "") .. " | " .. config.prefix .. "-" .. max_id
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  print(("✓ Assigned IDs up to %s-%d"):format(config.prefix, max_id))
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*/backlog.md",
    callback = function(opts)
      if vim.fn.fnamemodify(opts.file, ":t") == "backlog.md" then
        assign_task_ids(opts.buf)
      end
    end,
    desc = "Assign incrementing task IDs to backlog.md ONLY",
  })
end

return M
