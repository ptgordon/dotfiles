local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{"rafi/awesome-vim-colorschemes"},
    {"williamboman/mason.nvim"},
    {"williamboman/mason-lspconfig.nvim"},
    {"f-person/git-blame.nvim"},
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {'nvim-tree/nvim-web-devicons'},
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            {"ms-jpq/coq_nvim", branch = "coq"},

            {"ms-jpq/coq.artifacts", branch = "artifacts"},

            {"ms-jpq/coq.thirdparty", branch = "3p"}
        },
        init = function()
            vim.g.coq_settings = {
                auto_start = true,
            }
        end,
        config = function()
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {'nvim-lua/plenary.nvim'}
    },
})

vim.o.number = true         -- Enable line numbers
vim.o.tabstop = 4           -- Number of spaces a tab represents
vim.o.shiftwidth = 4        -- Number of spaces for each indentation
vim.o.expandtab = true      -- Convert tabs to spaces
vim.o.smartindent = true    -- Automatically indent new lines
vim.o.wrap = false          -- Disable line wrapping
vim.o.cursorline = true     -- Highlight the current line
vim.o.termguicolors = true  -- Enable 24-bit RGB colors
vim.cmd.colorscheme('gruvbox')  -- Set colorscheme


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({no_ignore = true}) end, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


-- Syntax highlighting and filetype plugins
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

require('mason').setup({})
require('mason-lspconfig').setup{
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    },
}

local git_blame = require('gitblame')
vim.g.gitblame_display_virtual_text = 0

local lualine = require('lualine')
lualine.setup {
    sections = {
        lualine_c = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } }
    }
}

local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
