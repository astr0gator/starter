-- Configure markdown table editing helpers via vim-table-mode.
return {
  "dhruvasagar/vim-table-mode",
  ft = "markdown",
  config = function()
    vim.g.table_mode_corner = "|"
    vim.g.table_mode_align_char = ":"

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.keymap.set("n", "<Leader>tb", ":TableModeToggle<CR>", { buffer = true, desc = "Toggle table mode" })
        vim.keymap.set("n", "<Leader>tr", ":TableModeRealign<CR>", { buffer = true, desc = "Realign table" })
      end,
    })
  end,
}
