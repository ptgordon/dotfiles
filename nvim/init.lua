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
    {"SmiteshP/nvim-navic"},
    {"lambdalisue/vim-suda"},
    {"nvim-treesitter/nvim-treesitter"},
    {"nvim-tree/nvim-tree.lua"},
    {"neovim/nvim-lspconfig"}, -- Required
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {'nvim-tree/nvim-web-devicons'},
    },
    {'VonHeikemen/lsp-zero.nvim'},
    -- LSP Support
    {
        "hrsh7th/nvim-cmp",
    }, -- Required
    {"hrsh7th/cmp-nvim-lsp"}, -- Required
    {"hrsh7th/cmp-buffer"},
    {"hrsh7th/cmp-path"},
    {"f3fora/cmp-spell"},
    {"saadparwaiz1/cmp_luasnip"},
    {"hrsh7th/cmp-nvim-lua"},

    {"L3MON4D3/LuaSnip"},
    {"Rafamadriz/friendly-snippets"},
    {
        "ibhagwan/fzf-lua",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            -- calling 'setup' is optional for customization
            require("fzf-lua").setup({})
        end
    },
    {
        'martineausimon/nvim-lilypond-suite',
        ft = { "ly"},
        config = function()
            require("nvls").setup({
                lilypond = { options = {} },
            })
        end,
    },
})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>ff", function() require('fzf-lua').files({no_ignore=true}) end, { desc = "Fzf Files" })
vim.keymap.set("n", "<leader>fg", require('fzf-lua').live_grep, { desc = "Fzf Grep" })
vim.keymap.set("n", "<leader>fr", require('fzf-lua').lsp_references, { desc = "Fzf References" })

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
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
vim.o.colorcolumn = "80"    -- Highlight line 80
vim.cmd.colorscheme('gruvbox')  -- Set colorscheme
vim.o.ignorecase = true    -- ignore case in search


vim.api.nvim_set_keymap('t', '<Leader><ESC>', '<C-\\><C-n>', {noremap = true})


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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "markdown", "txt" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end,
})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
	    end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'spell' },
    }),

    mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),

    ["<Down>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<Up>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    },

    formatting = {
        format = function(entry, vim_item)
            -- add label to show where suggestion comes from
            vim_item.menu = ({
                buffer = "[Buffer]",
                spell = "[Spell]",
                nvim_lsp = "[LSP]",
            })[entry.source.name]
            return vim_item
        end,
    },

})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.matlab_ls.setup {
	capabilities = capabilities,
	settings = {
		matlab = {
	    	installPath = {"/usr/local/MATLAB/R2024b"},
		}
	}
}

lspconfig.clangd.setup {
    capabilities = capabilities,
}

lspconfig.pyright.setup{
    capabilities = capabilities,
}

lspconfig.ltex.setup{
    settings = {
        ltex = {
            language = "en-US",
            additionalRules = { enablePickyRules = true },
            checkFrequency = "save",
        },
    },
}

lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_init = function(client)
    local path = client.workspace_folders[1].name

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- Auto-wrap LaTeX files at 80 columns with hard line breaks
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"tex", "txt"},
  callback = function()
    -- vim.opt_local.textwidth = 80        -- insert newlines after 80 chars
    -- vim.opt_local.formatoptions:append("t") -- auto-wrap text as you type
    vim.opt_local.wrap = true           -- visual wrapping (just in case)
    vim.opt_local.linebreak = true      -- wrap at word boundaries
    vim.opt_local.breakindent = true    -- indent wrapped lines
  end,
})

local navic = require("nvim-navic")
navic.setup = {
    lsp = {
        auto_attach = true,
    },
    highlight = false,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = false,
    click = false,
    format_text = function(text)
        return text
    end,
}

local lualine = require('lualine')
lualine.setup {
    sections = {
        lualine_c = { { 'filename', path = 2 } }
    }
}

