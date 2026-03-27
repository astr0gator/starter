-- Configure Comment.nvim with custom keybindings that fit this keymap setup.
return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      mappings = { basic = false, extra = false, extended = false },
    }
  end,
  config = function(_, opts)
    require("Comment").setup(opts)

    local comment_api = require("Comment.api")
    local map = vim.keymap.set

    map("n", "<M-/>", comment_api.toggle.linewise.current, { desc = "Comment — toggle line" })
    map("v", "<M-/>", function()
      vim.api.nvim_feedkeys(vim.fn["comment.api"].toggle.linewise(vim.fn.visualmode()), "n", false)
    end, { desc = "Comment — toggle selection" })
  end,
}
