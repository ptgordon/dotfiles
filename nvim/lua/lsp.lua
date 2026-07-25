vim.opt.completeopt = { "menuone", "noinsert", "popup", "fuzzy" }

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

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
  end,
})

