-- Bootstrap lazy.nvim and import plugin specs from scoped plugin folders.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.editor" },
    { import = "plugins.ui" },
    { import = "plugins.themes" },
    { import = "plugins.lsp" },
  },
  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = { "flexoki", "miasma" },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    notify = false,
  },
})
