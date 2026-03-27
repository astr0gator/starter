-- Configure custom file icons via nvim-web-devicons.
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    default = true,
    strict = true,
    override_by_filename = {
      ["next.config.ts"] = {
        icon = "▲",
        color = "#ffffff",
        name = "NextConfigTs",
      },
      ["next.config.js"] = {
        icon = "▲",
        color = "#ffffff",
        name = "NextConfigJs",
      },
      ["next.config.mjs"] = {
        icon = "▲",
        color = "#ffffff",
        name = "NextConfigMjs",
      },
      ["next.config.cjs"] = {
        icon = "▲",
        color = "#ffffff",
        name = "NextConfigCjs",
      },
      ["pnpm-lock.yaml"] = {
        icon = "󰏖",
        color = "#f9ad00",
        name = "PnpmLock",
      },
      ["vercel.json"] = {
        icon = "▲",
        color = "#ffffff",
        name = "VercelJson",
      },
      ["vitest.config.ts"] = {
        icon = "󰙨",
        color = "#6E9F18",
        name = "VitestConfigTs",
      },
    },
  },
}
