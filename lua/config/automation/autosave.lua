-- Auto-save file buffers when Neovim loses focus.
local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
      -- Skip non-file buffers (telescope, neo-tree, help, etc.)
      if vim.bo.buftype ~= "" then
        return
      end
      if vim.bo.modified and not vim.bo.readonly then
        vim.cmd("silent write")
      end
    end,
    desc = "Auto-save on focus lost",
  })
end

return M
