-- Configure Flexoki as the primary theme with automatic variant selection.
return {
  "nuvic/flexoki-nvim",
  name = "flexoki",
  lazy = false,
  priority = 1000,
  opts = {
    variant = "auto",
  },
  config = function(_, opts)
    require("flexoki").setup(opts)
  end,
}
