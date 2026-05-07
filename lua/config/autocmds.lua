local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("codex_checktime", { clear = true }),
  callback = function()
    vim.cmd.checktime()
  end,
})

autocmd("BufReadPost", {
  group = augroup("codex_restore_cursor", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("FileType", {
  group = augroup("codex_disable_spell_in_code", { clear = true }),
  pattern = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "lua",
    "scss",
    "typescript",
    "typescriptreact",
    "vue",
  },
  callback = function()
    vim.opt_local.spell = false
  end,
})

local function is_frontend_filetype(filetype)
  return vim.tbl_contains({
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  }, filetype)
end

local function max_sample_line_width(limit)
  local max_width = 0
  for lnum = 1, math.min(limit, vim.api.nvim_buf_line_count(0)) do
    local width = vim.fn.strdisplaywidth(vim.fn.getline(lnum))
    if width > max_width then
      max_width = width
    end
  end
  return max_width
end

local function preload_large_file(args)
  local stats = vim.uv.fs_stat(args.file)
  if not stats or stats.type ~= "file" or stats.size < 256 * 1024 then
    return
  end

  vim.b.codex_largefile_bytes = stats.size
  vim.opt_local.undofile = false
  vim.opt_local.swapfile = false
  vim.opt_local.bufhidden = "unload"
  vim.opt_local.cursorline = false
  vim.opt_local.list = false
  vim.opt_local.synmaxcol = 120
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.foldenable = false
  vim.opt_local.redrawtime = 1000

  if stats.size >= 1024 * 1024 then
    vim.opt_local.undolevels = -1
  end
end

local function optimize_large_file()
  if vim.bo.buftype ~= "" or vim.b.codex_largefile_level ~= nil then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local byte_size = vim.b.codex_largefile_bytes or math.max(vim.fn.line2byte(line_count + 1) - 1, 0)
  local max_width = max_sample_line_width(1000)
  local file_name = vim.fn.expand("%:t")
  local filetype = vim.bo.filetype
  local is_frontend = is_frontend_filetype(filetype)
  local is_large = byte_size >= 256 * 1024 or line_count >= 800 or max_width >= 240
  local is_very_large = byte_size >= 1024 * 1024 or line_count >= 2000 or max_width >= 480
  local lockfiles = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "Cargo.lock" }
  local is_lockfile = vim.tbl_contains(lockfiles, file_name)
  local is_minified = max_width >= 800
    or file_name:match("%.min%.js$")
    or file_name:match("%.min%.css$")
    or file_name:match("%.min%.json$")
  local is_generated = file_name:match("%.map$") or file_name:match("%.bundle%.") or file_name:match("%.chunk%.")
  local expensive = vim.tbl_contains({
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "markdown",
    "toml",
    "typescript",
    "typescriptreact",
    "xml",
    "yaml",
  }, filetype)

  if is_frontend then
    is_large = is_large or byte_size >= 160 * 1024 or line_count >= 450 or max_width >= 180
    is_very_large = is_very_large or byte_size >= 320 * 1024 or line_count >= 900 or max_width >= 320
  end

  if not is_large then
    vim.b.codex_largefile_level = 0
    return
  end

  vim.opt_local.undofile = false
  vim.opt_local.swapfile = false
  vim.opt_local.bufhidden = "unload"
  vim.opt_local.cursorline = false
  vim.opt_local.list = false
  vim.opt_local.synmaxcol = 120
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.foldenable = false
  vim.opt_local.redrawtime = 1000
  vim.cmd("silent! syntax sync minlines=20 maxlines=60")

  if is_very_large or is_minified or is_generated or (is_lockfile and byte_size >= 256 * 1024) or (expensive and byte_size >= 384 * 1024) then
    vim.bo.syntax = "OFF"
    vim.opt_local.cursorcolumn = false
    vim.opt_local.undolevels = -1
    vim.opt_local.spell = false
    vim.b.codex_largefile_level = 2
    return
  end

  vim.b.codex_largefile_level = 1
end

autocmd("BufReadPre", {
  group = augroup("codex_largefile_preload", { clear = true }),
  callback = preload_large_file,
})

autocmd({ "BufReadPost", "BufWinEnter" }, {
  group = augroup("codex_largefile_optimize", { clear = true }),
  callback = optimize_large_file,
})

autocmd("FileType", {
  group = augroup("codex_largefile_extras", { clear = true }),
  pattern = { "json", "jsonc", "markdown", "yaml", "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    if vim.b.codex_largefile_level == 2 then
      vim.schedule(function()
        pcall(vim.cmd, "LspStop")
      end)
    end
  end,
})

autocmd("FileType", {
  group = augroup("codex_frontend_tune", { clear = true }),
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.synmaxcol = 160
    vim.opt_local.redrawtime = 1200
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.foldenable = false
    vim.cmd("silent! syntax sync minlines=30 maxlines=80")
    vim.b.codex_largefile_level = nil
    optimize_large_file()
  end,
})
