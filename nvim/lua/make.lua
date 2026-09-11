-- Run the project's Makefile on save.
--
-- vimtex's `\ll` only knows how to run latexmk, which cannot see the
-- output/*.txt and figures/*.pdf prerequisites -- those come from octave and
-- drawio. The Makefile builds all three, so hang it off :w instead. Use one or
-- the other: `\ll` and this together put two latexmk processes on the same
-- document, racing over the aux files.
--
-- Only fires when a Makefile exists at or above the saved file, which scopes it
-- to projects that actually have one.

local enabled = true

-- One `make` per directory at a time. latexmk and octave both write into the
-- source tree, so overlapping runs clobber each other's intermediates. A save
-- landing mid-build sets `pending` rather than starting a second run, which
-- collapses a burst of saves into one rebuild afterwards.
local running, pending = {}, {}

-- The trailing catch-all keeps unmatched lines visible; without it a failure
-- whose output doesn't parse would open an empty list. Note that octave's
-- errors land in output/*.txt -- the recipe redirects them -- so make usually
-- names the failing file rather than printing the error itself.
local efm = table.concat({
  [[%-Gmake%.%#]], -- "make: *** [Makefile:20: main.pdf] Error 1"
  [[%f:%l:%c: %m]],
  [[%f:%l: %m]],
  [[! %m]], -- latex's own error lines
  [[%m]],
}, ",")

-- Tracked so a list this module opened can be cleared once the build is green,
-- without disturbing a quickfix list that came from somewhere else.
local owns_qf = false

local function close_qf()
  if not owns_qf then return end
  vim.cmd("cclose")
  vim.fn.setqflist({}, "r")
  owns_qf = false
end

local function run(dir)
  running[dir] = true
  vim.system({ "make" }, { cwd = dir, text = true }, function(res)
    vim.schedule(function()
      running[dir] = nil

      if res.code == 0 then
        close_qf()
      else
        local out = (res.stdout or "") .. (res.stderr or "")
        vim.fn.setqflist({}, " ", {
          title = "make " .. dir,
          lines = vim.split(out, "\n", { trimempty = true }),
          efm = efm,
        })
        owns_qf = true
        vim.cmd("copen")
        vim.cmd("wincmd p") -- copen steals the cursor; give it back
        vim.notify("make failed (exit " .. res.code .. ")", vim.log.levels.ERROR)
      end

      if pending[dir] then
        pending[dir] = nil
        run(dir)
      end
    end)
  end)
end

local function make_for(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then return end

  local makefile = vim.fs.find("Makefile", { upward = true, path = vim.fs.dirname(file) })[1]
  if not makefile then return end

  local dir = vim.fs.dirname(makefile)
  if running[dir] then
    pending[dir] = true
  else
    run(dir)
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.tex", "*.m" },
  callback = function(args)
    if enabled then make_for(args.buf) end
  end,
})

vim.api.nvim_create_user_command("Make", function()
  make_for(0)
end, { desc = "Run the project Makefile now" })

vim.api.nvim_create_user_command("MakeOnSave", function()
  enabled = not enabled
  vim.notify("make on save: " .. (enabled and "on" or "off"))
end, { desc = "Toggle running make after :w" })
