vim.pack.add({
    "https://github.com/ember-theme/nvim",
    "https://github.com/ellisonleao/gruvbox.nvim",
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/lervag/vimtex" },
    { src = "https://github.com/OXY2DEV/markview.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    { src = "https://github.com/mason-org/mason.nvim"  },
    { src = "https://github.com/echasnovski/mini.pairs" },
})

require("mini.pairs").setup()

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

-- markview renders LaTeX math, HTML tags and YAML frontmatter through treesitter
-- injections, so those parsers have to be present. Neovim only bundles
-- c/lua/markdown/markdown_inline/query/vim/vimdoc, so fetch the rest once.
--
-- Checked against the runtime path rather than nvim-treesitter's own list so a
-- parser shipped by Neovim or installed from the tree-sitter-grammars packages
-- counts as present and isn't rebuilt.
local ts_parsers = { "latex", "html", "yaml" }

local missing = vim.tbl_filter(function (lang)
  return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
end, ts_parsers)

if #missing > 0 then
  -- nvim-treesitter's main branch shells out to the tree-sitter CLI to build
  -- (and, for latex, to generate) a parser. Say so once instead of letting
  -- every startup fail with an opaque ENOENT.
  if vim.fn.executable("tree-sitter") == 1 then
    require("nvim-treesitter").install(missing)
  else
    -- Deferred and kept to one short line: a message emitted during startup,
    -- or one long enough to wrap, costs a hit-enter prompt on every launch.
    vim.schedule(function ()
      vim.notify(
        "markview: :TSInstall " .. table.concat(missing, " ") .. " (needs tree-sitter-cli)",
        vim.log.levels.WARN
      )
    end)
  end
end

require("markview").setup({
  markdown = {
    -- markview's own wrap handling miscounts columns once it starts inserting
    -- inline virtual text, so a wrapped block quote gets a stray border marker
    -- and a wrapped list item a run of padding, both landing mid-sentence on
    -- the continuation line. Neovim's own linebreak handling is correct, so
    -- leave the wrapping to it.
    --
    -- Only relevant because 'wrap' is on globally; see lua/options.lua.
    block_quotes = { wrap = false },
    list_items = { wrap = false },
  },
})

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

