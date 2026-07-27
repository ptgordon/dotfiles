vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.signcolumn = "yes"
vim.wo.number = true
vim.opt.termguicolors = true
vim.opt.complete:append('kspell')
vim.o.colorcolumn = "100"
vim.opt.textwidth = 100

-- Soft wrap: break long lines visually, never in the file itself
vim.opt.wrap = true
vim.opt.linebreak = true   -- break at word boundaries, not mid-word
vim.opt.breakindent = true -- continuation lines keep the original indent
vim.opt.showbreak = "↳ "

-- 'textwidth' is kept for `gq` and 'colorcolumn', but strip the flags that make
-- it insert real line breaks while typing. Runs after ftplugins, which reset
-- 'formatoptions' per filetype.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "t", "c" })
  end,
})

vim.cmd.colorscheme("ember-soft")
-- vim.cmd.colorscheme("gruvbox")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "markdown", "txt" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end,
})

-- Keymaps

-- Treat each wrapped screen line as its own line for movement.
-- A count still moves by real lines, so relative-number jumps like 12j work.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "0", "g0", { silent = true })
vim.keymap.set({ "n", "x" }, "^", "g^", { silent = true })
vim.keymap.set({ "n", "x" }, "$", "g$", { silent = true })
-- In insert mode the arrows step through the completion menu while it is open,
-- and move by screen line otherwise. <Tab> confirms the selected item
-- ('noinsert' means nothing is committed until then) and is a plain tab when no
-- menu is open.
vim.keymap.set("i", "<Down>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-o>gj"
end, { expr = true, silent = true })
vim.keymap.set("i", "<Up>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-o>gk"
end, { expr = true, silent = true })
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<Tab>"
end, { expr = true, silent = true })
vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, silent = true })

-- <CR> also confirms, but must fall through to mini.pairs' own <CR> handler
-- otherwise (it opens a new indented line between freshly typed brackets).
-- MiniPairs.cr() returns pre-escaped termcodes, hence replace_keycodes = false.
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then return vim.keycode("<C-y>") end
  return require("mini.pairs").cr()
end, { expr = true, replace_keycodes = false, silent = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set("n", "<leader>fe", function()
  vim.diagnostic.open_float(nil, {
    scope = "buffer",
    severity = { min = vim.diagnostic.severity.WARN },
  })
end, { desc = "Diagnostics: errors & warnings in float" })

