vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.signcolumn = "yes"
vim.wo.number = true
vim.opt.termguicolors = true
vim.opt.complete:append('kspell')
vim.o.colorcolumn = "100"    -- Highlight line 80

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

