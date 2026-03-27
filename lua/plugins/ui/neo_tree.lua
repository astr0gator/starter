-- Configure neo-tree as the file explorer with custom window mappings.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle filesystem reveal left<CR>", desc = "Toggle file tree" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
      window = {
        fuzzy_finder_mappings = {
          ["<Esc>"] = "close",
          ["<C-c>"] = "close",
          n = {
            ["q"] = "close",
            ["<esc>"] = "close",
          },
        },
      },
    },
    window = {
      width = 32,
      mappings = {
        ["<esc>"] = "close_window",
        ["l"] = "open",
        ["h"] = "close_all_nodes",
      },
    },
  },
}
