vim.opt.completeopt = { "menuone", "noinsert", "popup", "fuzzy" }

-- Render the full multi-line diagnostic below the cursor's line. Limited to the
-- current line so unrelated errors elsewhere in the buffer don't shift the text
-- around while editing.
vim.diagnostic.config({
  virtual_lines = { current_line = true },
})

vim.lsp.config('rust_analyzer', {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", ".git" },
})

vim.lsp.enable('rust_analyzer')

vim.lsp.config('lua_ls', {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  -- Specific settings to send to the server. The schema is server-defined.
  -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- `vim` is injected by the editor, so it has no definition in the
      -- workspace for lua_ls to find.
      diagnostics = {
        globals = { 'vim' },
      },
    }
  }
})

vim.lsp.enable('lua_ls')

vim.lsp.config('texlab', {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'plaintex', 'bib' },
  root_markers = { '.latexmkrc', '.texlabroot', 'texlabroot', 'Tectonic.toml', '.git' },
})

vim.lsp.enable('texlab')

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--completion-style=detailed',
    '--fallback-style=llvm',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { '.clangd', '.clang-format', 'CMakeLists.txt', 'compile_commands.json', '.git' },
  capabilities = {
    offsetEncoding = { 'utf-16' },
  },
})

vim.lsp.enable('clangd')

-- *.m detection is a content heuristic that can land on octave/objc/mma, so pin it.
vim.g.filetype_m = 'matlab'

vim.lsp.config('matlab_ls', {
  cmd = { 'matlab-language-server', '--stdio' },
  filetypes = { 'matlab' },
  root_markers = { '.git' },
  settings = {
    MATLAB = {
      installPath = '/usr/local/MATLAB/R2026a',
      matlabConnectionTiming = 'onStart',
      indexWorkspace = true,
      telemetry = false,
    },
  },
})

vim.lsp.enable('matlab_ls')

-- Format on save, handled by whichever language server is attached: rust-analyzer
-- shells out to rustfmt, clangd uses its built-in clang-format, lua_ls uses
-- EmmyLuaCodeStyle. Each picks up the project's own config file if there is one
-- (rustfmt.toml, .clang-format, .editorconfig).
--
-- Opt-in per filetype rather than "any client that can format", so enabling a
-- new language server doesn't silently start rewriting those files on save.
local format_on_save = {
  rust = true,
  lua = true,
  c = true,
  cpp = true,
}

local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local chars = {}
    for i = string.byte("a"), string.byte("z") do
        table.insert(chars, string.char(i))
    end

    client.server_capabilities.completionProvider.triggerCharacters = chars

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })
    end

    if format_on_save[vim.bo[args.buf].filetype]
      and client:supports_method("textDocument/formatting") then
      -- Buffer-local, and cleared first so a second attaching client doesn't
      -- register a duplicate BufWritePre that formats the buffer twice.
      vim.api.nvim_clear_autocmds({ group = format_group, buffer = args.buf })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
        end,
      })
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
  end,
})

