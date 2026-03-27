-- Configure tree-sitter parsers, highlighting, and indentation support.
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  opts = function()
    return {
      parser_install_dir = vim.fn.stdpath("cache") .. "/treesitter",
      ensure_installed = {
        "bash",
        "css",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
  config = function(_, opts)
    if not vim.tbl_contains(vim.opt.runtimepath:get(), opts.parser_install_dir) then
      vim.opt.runtimepath:prepend(opts.parser_install_dir)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
}
