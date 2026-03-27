-- Configure the statusline layout and buffer path display.
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      section_separators = "",
      component_separators = { left = "|", right = "|" },
      extensions = { "neo-tree" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        {
          function()
            local name = vim.fn.expand("%:t")
            local path = vim.fn.expand("%:h")

            if name == "" or name == "No Name" then
              return "[No Name]"
            end

            local suffix = ""
            if vim.bo.modified then
              suffix = suffix .. "●"
            end
            if vim.bo.readonly then
              suffix = suffix .. "🔒"
            end

            if path == "." or path == "" then
              return name .. suffix
            end
            return name .. " › " .. path .. suffix
          end,
        },
      },
      lualine_x = { "filetype" },
      lualine_y = {},
      lualine_z = {
        {
          "location",
          color = { bg = "none", fg = "#888888" },
        },
        {
          function() return "  " .. vim.fn.line("$") end,
          color = { bg = "none", fg = "#888888" },
        },
        { "progress" },
      },
    },
  },
}
