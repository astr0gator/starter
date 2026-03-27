-- Sync Neovim background changes with the current theme auto-mode.
return {
  "f-person/auto-dark-mode.nvim",
  lazy = false,
  priority = 800,
  config = function()
    local theme = require "config.theme"

    theme.register_commands()

    require("auto-dark-mode").setup({
      update_interval = 1500,
      set_dark_mode = function()
        if not theme.is_auto_mode() then
          return
        end

        vim.api.nvim_set_option_value("background", "dark", {})
        theme.apply_auto_colorscheme()
        vim.schedule(function()
          theme.set_dark_background()
        end)
      end,
      set_light_mode = function()
        if not theme.is_auto_mode() then
          return
        end

        vim.api.nvim_set_option_value("background", "light", {})
        theme.apply_auto_colorscheme()
      end,
    })
  end,
}
