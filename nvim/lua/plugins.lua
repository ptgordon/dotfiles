vim.pack.add({
    "https://github.com/ember-theme/nvim",
    "https://github.com/ellisonleao/gruvbox.nvim",
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/lervag/vimtex" },
    { src = "https://github.com/OXY2DEV/markview.nvim" },
    { src = "https://github.com/mason-org/mason.nvim"  },
})

require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
    ensure_installed = {
        "rust-analyzer",
        "lua-language-server",
        "texlab",
        "clangd",
        "matlab-language-server",
    },
})

require("telescope").setup({
  pickers = {
    find_files = {
      no_ignore = true,
      no_ignore_parent = true,
    },
  },
})
require("telescope").load_extension("fzf")

require("markview").setup()

require("gruvbox").setup()

require("ember").setup({
  variant = "ember-soft", -- "ember", "ember-soft", "ember-light"
  styles = {
    comments  = { italic = true },
    keywords  = { bold = true },
    functions = {},
    types     = { bold = true },
  },
  transparent        = false, -- transparent editor background
  transparent_floats = nil,   -- follows `transparent` by default; set explicitly to override
  on_colors     = nil, -- function(palette) - modify palette before theme builds
  on_highlights = nil, -- function(highlights, theme) - modify highlight groups
})

