-- Sync active Neovim keymaps into the external Navi cheat file.
-- Usage: :lua require('tools.navi_sync').sync()

local M = {}
local navi_cheat_path = "/Users/art/Dropbox/06 - Infrastructure/Syncing Databases (Manual)/Navi/nvim.cheat.md"
local keymaps_path = vim.fn.stdpath("config") .. "/lua/config/keymaps.lua"

local function format_keys(keys)
  local result = keys
    :gsub('<leader>', 'space ')
    :gsub('<Leader>', 'space ')
    :gsub('<localleader>', 'space space ')
    :gsub('<CR>', '')
    :gsub('<Esc>', 'esc')
    :gsub('<cmd>', '')
    :gsub('</', '')
    :gsub('%"%"', '%%')
    :gsub('<C%-(.)>', function(c) return 'ctrl ' .. c:lower() .. ' ' end)
    :gsub('<c%-(.)>', function(c) return 'ctrl ' .. c:lower() .. ' ' end)
    :gsub('<M%-(.)>', function(c) return 'opt ' .. c:lower() .. ' ' end)
    :gsub('<m%-(.)>', function(c) return 'opt ' .. c:lower() .. ' ' end)
    :gsub('<A%-(.)>', function(c) return 'alt ' .. c:lower() .. ' ' end)
    :gsub('<a%-(.)>', function(c) return 'alt ' .. c:lower() .. ' ' end)
    :gsub('<S%-', 'shift ')
    :gsub('<C%-M%-(.)>', function(c) return 'ctrl opt ' .. c:lower() .. ' ' end)
    :gsub('<c%-m%-(.)>', function(c) return 'ctrl opt ' .. c:lower() .. ' ' end)
    :gsub('<M%-C%-(.)>', function(c) return 'ctrl opt ' .. c:lower() .. ' ' end)
    :gsub('<lt>', '<')
    :gsub('<(.-)>', function(s) return s:lower() end)
    -- Clean up trailing spaces
    :gsub('%s+$', '')

  return result
end

local function add_section(output, name, items)
  if items and #items > 0 then
    table.insert(output, "\n; ── " .. name .. " ──\n")
    for _, item in ipairs(items) do
      local formatted_keys = format_keys(item.keys)
      table.insert(output, "# " .. item.desc .. "\n")
      table.insert(output, formatted_keys .. "\n\n")
    end
  end
end

local function extract_quoted_value(value)
  return value:match('^"(.*)"$') or value:match("^'(.*)'$")
end

local function ensure_section(sections, order, name)
  if not sections[name] then
    sections[name] = {}
    table.insert(order, name)
  end
end

local function parse_keymaps()
  if vim.fn.filereadable(keymaps_path) == 0 then
    return {}, {}
  end

  local lines = vim.fn.readfile(keymaps_path)
  local sections = {}
  local order = {}
  local current_section
  local seen = {}
  local index = 1

  while index <= #lines do
    local line = lines[index]
    local section = line:match("^%-%-%s*──%s*(.-)%s*──")
    if section then
      current_section = vim.trim(section)
      ensure_section(sections, order, current_section)
    elseif current_section and not line:match("^%s*%-%-") and line:match("^map%(") then
      local statement = line
      local paren_balance = select(2, line:gsub("%(", "")) - select(2, line:gsub("%)", ""))

      while paren_balance > 0 and index < #lines do
        index = index + 1
        local next_line = lines[index]
        statement = statement .. "\n" .. next_line
        paren_balance = paren_balance
          + select(2, next_line:gsub("%(", ""))
          - select(2, next_line:gsub("%)", ""))
      end

      local normalized = statement:gsub("%s+", " ")
      local mode_arg, remainder

      if normalized:match("^map%(%s*%{") then
        mode_arg, remainder = normalized:match("^map%(%s*(%b{}),%s*(.+)$")
      else
        mode_arg, remainder = normalized:match("^map%(%s*(%b\"\"),%s*(.+)$")
      end

      if mode_arg and remainder then
        local keys_arg = remainder:match("^(%b\"\")")
        local keys = keys_arg and extract_quoted_value(keys_arg)
        local desc = normalized:match('desc%s*=%s*"([^"]+)"') or normalized:match("desc%s*=%s*'([^']+)'")

        if keys and desc then
          local signature = table.concat({ current_section, keys, desc }, "\0")
          if not seen[signature] then
            seen[signature] = true
            table.insert(sections[current_section], {
              keys = keys,
              desc = desc,
            })
          end
        end
      end
    end

    index = index + 1
  end

  return sections, order
end

local function append_items(sections, order, section_name, items)
  ensure_section(sections, order, section_name)
  for _, item in ipairs(items) do
    table.insert(sections[section_name], item)
  end
end

local function add_manual_custom_sections(sections, order)
  append_items(sections, order, "Search", {
    { keys = "<C-s>", desc = "Flash — toggle overlay in command-mode search" },
  })

  append_items(sections, order, "Navigation", {
    { keys = "s", desc = "Flash — jump by character (labels appear, type label to zip there)" },
    { keys = "S", desc = "Flash — jump by treesitter node (functions, params, etc.)" },
  })

  append_items(sections, order, "Edit: Delete (void register)", {
    { keys = "r", desc = "Flash — remote flash motion (dr + char = delete to any char on screen)" },
  })

  append_items(sections, order, "Edit: Change (void register)", {
    { keys = "R", desc = "Flash — treesitter search motion (cR = change until function definition)" },
  })
end

local function to_cheat_format()
  local output = {}
  table.insert(output, "% nvim\n")

  -- ===== Custom keymaps =====
  local sections, order = parse_keymaps()
  add_manual_custom_sections(sections, order)
  for _, section_name in ipairs(order) do
    add_section(output, section_name, sections[section_name])
  end

  -- ===== Plugin-specific keymaps =====
  table.insert(output, "\n; ── Telescope ────────────────────────────────────────────────────────────\n")
  table.insert(output, "# Telescope — command palette\n<leader>p\n\n")
  table.insert(output, "# Telescope — find files\n<leader>f\n\n")
  table.insert(output, "# Telescope — grep in files\n<leader>/\n\n")
  table.insert(output, "# Telescope — open buffers\n<leader>b\n\n")
  table.insert(output, "# Telescope — help pages\n<leader>h\n\n")
  table.insert(output, "# Telescope — keymaps\n<leader>k\n\n")

  table.insert(output, "\n; ── Comment (Comment.nvim) ───────────────────────────────────────────────\n")
  table.insert(output, "# Comment — toggle line\nopt /\n\n")
  table.insert(output, "# Comment — toggle selection (visual)\nopt /\n\n")

  table.insert(output, "\n; ── Markdown: Bullets ──────────────────────────────────────────────────────\n")
  table.insert(output, "# Markdown — toggle checkbox\ntd\n\n")
  table.insert(output, "# Markdown — new checkbox on current line\nta\n\n")
  table.insert(output, "# Markdown — new checkbox below\nto\n\n")
  table.insert(output, "# Markdown — new checkbox above\ntO\n\n")
  table.insert(output, "# Markdown — toggle table mode\n<leader>tb\n\n")
  table.insert(output, "# Markdown — realign table\n<leader>tr\n\n")

  table.insert(output, "\n; ── Insert Snippets ───────────────────────────────────────────────────────\n")
  table.insert(output, "# Insert — empty checkbox [ ]\n[[\n\n")

  -- ===== Standard Vim shortcuts =====
  table.insert(output, "\n; ── Delete (standard Vim) ───────────────────────────────────────────────────\n")
  table.insert(output, "# Delete line — Normal — Remove line\ndd\n\n")
  table.insert(output, "# Delete line — Insert — Clear line\ncc/S\n\n")
  table.insert(output, "# Delete line — Normal — Clear line\n0D\n\n")
  table.insert(output, "# Delete motion — Normal — Partial\nd<motion>\n\n")
  table.insert(output, "# Delete char — Normal — Forward (now void register in config)\nx\n\n")
  table.insert(output, "# Delete char — Normal — Backward (now void register in config)\nX\n\n")

  table.insert(output, "\n; ── Yank (standard Vim) ─────────────────────────────────────────────────────\n")
  table.insert(output, "# Yank line — to register\nyy\n\n")
  table.insert(output, "# Yank — with motion, to register\ny<motion>\n\n")

  table.insert(output, "\n; ── Paste (standard Vim) ────────────────────────────────────────────────────\n")
  table.insert(output, "# Paste — after cursor, from register\np\n\n")
  table.insert(output, "# Paste — before cursor, from register\nP\n\n")

  table.insert(output, "\n; ── Insert (standard Vim) ───────────────────────────────────────────────────\n")
  table.insert(output, "# Insert — at cursor\ni\n\n")
  table.insert(output, "# Insert — before line (BOL)\nI\n\n")
  table.insert(output, "# Insert — append after cursor\na\n\n")
  table.insert(output, "# Insert — append after line (EOL)\nA\n\n")
  table.insert(output, "# Insert — new line below, enter insert\no\n\n")
  table.insert(output, "# Insert — new line above, enter insert\nO\n\n")
  table.insert(output, "# Insert — run one normal command, return to insert\nctrl o\n\n")

  table.insert(output, "\n; ── Comment (standard Vim) ────────────────────────────────────────────────\n")
  table.insert(output, "# Comment — toggle with motion\ngc<motion>\n\n")
  table.insert(output, "# Comment — toggle from cursor to EOF\ngcG\n\n")

  table.insert(output, "\n; ── Indent (standard Vim) ───────────────────────────────────────────────────\n")
  table.insert(output, "# Indent — auto-format line\n==\n\n")
  table.insert(output, "# Indent — auto-format selection (visual)\n=\n\n")

  table.insert(output, "\n; ── Navigate: Cursor (standard Vim) ───────────────────────────────────────────\n")
  table.insert(output, "# Navigate — word forward (start)\nw\n\n")
  table.insert(output, "# Navigate — word backward (start)\nb\n\n")
  table.insert(output, "# Navigate — word forward (end)\ne\n\n")
  table.insert(output, "# Navigate — WORD forward (whitespace-delimited)\nW\n\n")
  table.insert(output, "# Navigate — WORD backward (whitespace-delimited)\nB\n\n")
  table.insert(output, "# Navigate — to first line\ngg\n\n")
  table.insert(output, "# Navigate — to last line\nG\n\n")
  table.insert(output, "# Navigate — to line N\n<N>G\n\n")
  table.insert(output, "# Navigate — to matching bracket / paren / brace\n%\n\n")
  table.insert(output, "# Navigate — char forward (jump to)\nf<char>\n\n")
  table.insert(output, "# Navigate — char backward (jump to)\nF<char>\n\n")
  table.insert(output, "# Navigate — char forward (jump before)\nt<char>\n\n")
  table.insert(output, "# Navigate — char backward (jump before)\nT<char>\n\n")
  table.insert(output, "# Navigate — word backward (end)\nge\n\n")
  table.insert(output, "# Navigate — WORD forward (end)\nE\n\n")
  table.insert(output, "# Navigate — WORD backward (end)\ngE\n\n")

  table.insert(output, "\n; ── Navigate: Jump List (standard Vim) ──────────────────────────────────────\n")
  table.insert(output, "# Navigate — jump list, back\nctrl o\n\n")
  table.insert(output, "# Navigate — jump list, forward\nctrl i\n\n")
  table.insert(output, "# Navigate — jump to previous position (last edit)\n``\n\n")

  table.insert(output, "\n; ── Navigate: Screen (standard Vim) ───────────────────────────────────────────\n")
  table.insert(output, "# Navigate — screen position, top\nH\n\n")
  table.insert(output, "# Navigate — screen position, middle\nM\n\n")
  table.insert(output, "# Navigate — screen position, bottom\nL\n\n")

  table.insert(output, "\n; ── Focus (standard Vim) ─────────────────────────────────────────────────────\n")
  table.insert(output, "# Focus — center current line on screen\nzz\n\n")
  table.insert(output, "# Focus — bring current line to top of screen\nzt\n\n")
  table.insert(output, "# Focus — bring current line to bottom of screen\nzb\n\n")

  table.insert(output, "\n; ── Search (standard Vim) ────────────────────────────────────────────────────\n")
  table.insert(output, "# Search — forward\n/<pattern>\n\n")
  table.insert(output, "# Search — backward\n?<pattern>\n\n")
  table.insert(output, "# Search — word under cursor, forward\n*\n\n")
  table.insert(output, "# Search — word under cursor, backward\n#\n\n")
  table.insert(output, "# Search — next match\nn\n\n")
  table.insert(output, "# Search — previous match\nN\n\n")
  table.insert(output, "# Search and replace — all occurrences in file\n:%s/old/new/g\n\n")
  table.insert(output, "# Search and replace — with confirmation\n:%s/old/new/gc\n\n")

  table.insert(output, "\n; ── Select (standard Vim) ────────────────────────────────────────────────────\n")
  table.insert(output, "# Select — character mode (visual)\nv\n\n")
  table.insert(output, "# Select — line mode (visual)\nV\n\n")
  table.insert(output, "# Select — block mode (visual)\nctrl v\n\n")
  table.insert(output, "# Select — inside word\niw\n\n")
  table.insert(output, "# Select — inside quotes\ni\"\n\n")
  table.insert(output, "# Select — inside parens\ni(\n\n")
  table.insert(output, "# Select — around brackets (includes brackets)\na[\n\n")

  table.insert(output, "\n; ── Window (standard Vim) ────────────────────────────────────────────────────\n")
  table.insert(output, "# Window — split horizontal\n:split\n\n")
  table.insert(output, "# Window — split vertical\n:vsplit\n\n")
  table.insert(output, "# Window — focus left\nctrl w h\n\n")
  table.insert(output, "# Window — focus right\nctrl w l\n\n")
  table.insert(output, "# Window — focus up\nctrl w k\n\n")
  table.insert(output, "# Window — focus down\nctrl w j\n\n")
  table.insert(output, "# Window — close current\nctrl w q\n\n")
  table.insert(output, "# Window — equalize all sizes\nctrl w =\n\n")

  table.insert(output, "\n; ── File (standard Vim) ─────────────────────────────────────────────────────\n")
  table.insert(output, "# File — save\n:w\n\n")
  table.insert(output, "# File — quit all\n:qa\n\n")

  table.insert(output, "\n; ── Mark (standard Vim) ─────────────────────────────────────────────────────\n")
  table.insert(output, "# Mark — set with letter\nm<letter>\n\n")
  table.insert(output, "# Mark — jump to (BOL)\n'<letter>\n\n")
  table.insert(output, "# Mark — jump to exact position\n`<letter>\n\n")

  table.insert(output, "\n; ── Macro (standard Vim) ────────────────────────────────────────────────────\n")
  table.insert(output, "# Macro — record to register\nq<letter>\n\n")
  table.insert(output, "# Macro — stop recording\nq\n\n")
  table.insert(output, "# Macro — play from register\n@<letter>\n\n")
  table.insert(output, "# Macro — repeat last played\n@@\n\n")

  table.insert(output, "\n; ── LSP (standard) ───────────────────────────────────────────────────────────\n")
  table.insert(output, "# LSP — jump to definition\ngd\n\n")
  table.insert(output, "# LSP — jump to declaration\ngD\n\n")
  table.insert(output, "# LSP — show references\ngr\n\n")
  table.insert(output, "# LSP — hover documentation\nK\n\n")

  return table.concat(output)
end

function M.render()
  return to_cheat_format()
end

function M.sync()
  local content = M.render()
  local ok, err = pcall(vim.fn.writefile, vim.split(content, "\n", { trimempty = false }), navi_cheat_path)
  if not ok then
    vim.notify("Failed to sync Navi key file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.notify("Synced Neovim keys to Navi", vim.log.levels.INFO)
end

function M.setup()
  -- Auto-sync when keymaps.lua is written
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*/lua/config/keymaps.lua",
    callback = function()
      M.sync()
    end,
    desc = "Auto-sync Neovim keys to Navi",
  })

  -- User command to sync manually
  vim.api.nvim_create_user_command("SyncNaviKeys", function()
    M.sync()
  end, { desc = "Sync Neovim keys to Navi" })

  vim.api.nvim_create_user_command("SyncCheatsheet", function()
    M.sync()
  end, { desc = "Alias for SyncNaviKeys" })
end

return M
