-- Configure which-key hints and the global key hint entrypoint.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 150,
    notify = false,
    -- Use automatic triggers everywhere except operator-pending mode,
    -- which interferes with flash.nvim's remote motions.
    triggers = {
      { "<auto>", mode = "nixstc" },
    },
    spec = {
      { "<leader>x", desc = "Close buffer" },
      { "<C-j>", desc = "Scroll — half page down" },
      { "<C-k>", desc = "Scroll — half page up" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Show key hints",
    },
  },
}
