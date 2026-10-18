-- Reload a buffer when its file changes on disk, e.g. when Claude Code edits it.
--
-- 'autoread' only acts when :checktime runs, which Neovim does on focus and a
-- few other events -- never while the editor sits idle in another terminal. So
-- watch the directory of each open file and run :checktime for that buffer as
-- soon as the file changes.
--
-- The directory rather than the file itself: tools that save by writing a temp
-- file and renaming it over the original replace the inode, and an inotify
-- watch on the old inode silently stops firing.
--
-- A buffer with unsaved changes is never overwritten; :checktime raises the
-- usual W12 "changed since editing started" prompt instead.

vim.o.autoread = true

local uv = vim.uv

-- dir -> { handle = fs_event, files = { [basename] = bufnr } }
local watchers = {}

-- A single save can arrive as several events (truncate, write, close), so
-- collapse each burst into one reload.
local pending = {}

local function reload(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  -- The W12 prompt can't open from the command line or the cmdline window.
  if vim.fn.getcmdwintype() ~= "" or vim.api.nvim_get_mode().mode:sub(1, 1) == "c" then
    return
  end
  pcall(vim.cmd.checktime, buf)
end

local function on_change(buf)
  if pending[buf] then return end
  pending[buf] = true
  vim.defer_fn(function()
    pending[buf] = nil
    reload(buf)
  end, 100)
end

local function split(buf)
  if vim.bo[buf].buftype ~= "" then return end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then return end
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  return vim.fs.dirname(path), vim.fs.basename(path)
end

local function watch(buf)
  local dir, name = split(buf)
  if not dir or vim.fn.isdirectory(dir) == 0 then return end

  local w = watchers[dir]
  if not w then
    local handle = uv.new_fs_event()
    if not handle then return end
    local ok = handle:start(dir, {}, vim.schedule_wrap(function(err, fname)
      local cur = watchers[dir]
      if err or not fname or not cur then return end
      local target = cur.files[fname]
      if target then on_change(target) end
    end))
    if not ok then
      handle:close()
      return
    end
    w = { handle = handle, files = {} }
    watchers[dir] = w
  end
  w.files[name] = buf
end

local function unwatch(buf)
  local dir, name = split(buf)
  local w = dir and watchers[dir]
  if not w or w.files[name] ~= buf then return end
  w.files[name] = nil
  if next(w.files) == nil then
    w.handle:stop()
    w.handle:close()
    watchers[dir] = nil
  end
end

local group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  group = group,
  callback = function(args) watch(args.buf) end,
})

-- :saveas / :file rename the buffer; drop the old name before it changes.
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufFilePre" }, {
  group = group,
  callback = function(args) unwatch(args.buf) end,
})

vim.api.nvim_create_autocmd("BufFilePost", {
  group = group,
  callback = function(args) watch(args.buf) end,
})

-- Fallback for anything the watcher misses, such as a file on a network mount.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.api.nvim_get_mode().mode:sub(1, 1) ~= "c" then
      pcall(vim.cmd.checktime)
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function(args)
    -- Also fires when the W12 prompt kept the buffer's own edits instead.
    if vim.bo[args.buf].modified then return end
    vim.notify("Reloaded " .. vim.fn.fnamemodify(args.file, ":~:."), vim.log.levels.INFO)
  end,
})
