-- Register core autocmds and wire up local automation modules.
local autocmd = vim.api.nvim_create_autocmd

require("config.automation.autosave").setup()
require("config.automation.task_ids").setup()

autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd("FileType", {
  pattern = "markdown",
  desc = "Use visual wrapping for Markdown content, including wide tables",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Set cursor color after colorscheme changes
autocmd("ColorScheme", {
  desc = "Apply custom cursor color",
  callback = function()
    local theme = require("config.theme")
    theme.set_cursor()
  end,
})

-- Reload config command
vim.api.nvim_create_user_command("Rel", function()
  package.loaded['config.keymaps'] = nil
  package.loaded['config.autocmds'] = nil
  require("config.keymaps")
  require("config.autocmds")
  vim.notify("Config reloaded!", vim.log.levels.INFO)
end, { desc = "Reload config" })
