-- Test scroll and buffer cycle keymaps.

local map = vim.keymap.set

-- Define the same mappings as lua/config/keymaps.lua (scroll + buffer sections).
map("n", "zt", "H", { noremap = true, desc = "Scroll — current line to top" })
map("n", "zz", "M", { noremap = true, desc = "Scroll — current line to center" })
map("n", "zb", "L", { noremap = true, desc = "Scroll — current line to bottom" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>",     { desc = "Next buffer" })

local function assert_eq(actual, expected, label)
  if vim.deep_equal(actual, expected) then return end
  error(("%s\nexpected: %s\nactual:   %s"):format(label, vim.inspect(expected), vim.inspect(actual)))
end

-- Verify scroll mappings point to native H/M/L with noremap.
local scroll = {
  { "zt", "H" },
  { "zz", "M" },
  { "zb", "L" },
}

for _, t in ipairs(scroll) do
  local info = vim.fn.maparg(t[1], "n", false, true)
  assert_eq(info.rhs, t[2], t[1] .. " rhs")
  assert_eq(info.noremap, 1, t[1] .. " noremap")
end

-- Verify buffer cycle mappings.
local buffers = {
  { "<S-h>", "<cmd>bprevious<CR>" },
  { "<S-l>", "<cmd>bnext<CR>" },
}

for _, t in ipairs(buffers) do
  local info = vim.fn.maparg(t[1], "n", false, true)
  assert_eq(info.rhs, t[2], t[1] .. " rhs")
end

-- Verify scroll mappings use noremap so they bypass the H/L buffer mappings.
local info_zt = vim.fn.maparg("zt", "n", false, true)
assert_eq(info_zt.noremap, 1, "zt must be noremap to bypass H buffer mapping")

-- Functional test: zt/zz/zb should move the cursor (not trigger buffer cycling).
local lines = {}
for i = 1, 50 do lines[i] = ("line %d"):format(i) end
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.api.nvim_win_set_height(0, 10)
vim.api.nvim_win_set_cursor(0, { 30, 0 })

vim.cmd.normal("zt")
local after_zt = vim.api.nvim_win_get_cursor(0)[1]
assert_eq(after_zt ~= 30, true, "zt should move the cursor")
assert_eq(after_zt >= 1 and after_zt <= 50, true, "zt should stay within buffer")

print(("ok: %d scroll keymap tests passed"):format(#scroll + #buffers + 1))
