-- Configure smooth scrolling behavior with neoscroll.nvim.
return {
  "karb94/neoscroll.nvim",
  lazy = false,
  opts = {
    easing = "quadratic",
    mappings = {},
  },
  config = function(_, opts)
    local scroll = require("neoscroll")
    scroll.setup(opts)

    local map = vim.keymap.set
    local scroll_modes = { "n", "v", "x" }

    map(scroll_modes, "<C-d>", function()
      scroll.ctrl_d({ duration = 200 })
    end, { desc = "Scroll — half page down" })

    map(scroll_modes, "<C-u>", function()
      scroll.ctrl_u({ duration = 200 })
    end, { desc = "Scroll — half page up" })

  end,
}
