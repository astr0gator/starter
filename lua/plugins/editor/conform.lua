-- Configure conform.nvim formatters for supported filetypes.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
