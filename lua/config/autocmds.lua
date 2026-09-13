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

local function max_sample_line_width(limit)
  local max_width = 0
  for lnum = 1, math.min(limit, vim.api.nvim_buf_line_count(0)) do
    local width = vim.fn.strdisplaywidth(vim.fn.getline(lnum))
    max_width = math.max(max_width, width)
    if max_width >= 4000 then break end
  end
  return max_width
end

local function apply_large_file_options()
  vim.opt_local.undofile = false
  vim.opt_local.cursorline = false
  vim.opt_local.list = false
  vim.opt_local.synmaxcol = 120
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.foldenable = false
end

local function preload_large_file(args)
  local stats = vim.uv.fs_stat(args.file)
  if not stats or stats.type ~= "file" or stats.size < 1024 * 1024 then
    return
  end

  vim.b.codex_largefile_bytes = stats.size
  apply_large_file_options()
end

local function optimize_large_file()
  if vim.bo.buftype ~= "" or vim.b.codex_largefile_level ~= nil then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(0)
  local byte_size = vim.b.codex_largefile_bytes or math.max(vim.fn.line2byte(line_count + 1) - 1, 0)
  -- Size and line count already decide the strongest reduction; skip sampling then.
  local is_very_large = byte_size >= 5 * 1024 * 1024 or line_count >= 50000
  local max_width = is_very_large and 0 or max_sample_line_width(1000)
  local file_name = vim.fn.expand("%:t")
  local is_large = byte_size >= 1024 * 1024 or line_count >= 10000 or max_width >= 1000
  is_very_large = is_very_large or max_width >= 4000
  local lockfiles = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "Cargo.lock" }
  local is_lockfile = vim.tbl_contains(lockfiles, file_name)
  local is_minified = max_width >= 800
    or file_name:match("%.min%.js$")
    or file_name:match("%.min%.css$")
    or file_name:match("%.min%.json$")
  local is_generated = file_name:match("%.map$") or file_name:match("%.bundle%.") or file_name:match("%.chunk%.")
  if not is_large then
    vim.b.codex_largefile_level = 0
    return
  end

  apply_large_file_options()
  vim.cmd("silent! syntax sync minlines=20 maxlines=60")

  if is_very_large or is_minified or is_generated or is_lockfile then
    vim.bo.syntax = "OFF"
    vim.opt_local.cursorcolumn = false
    vim.opt_local.spell = false
    vim.b.codex_largefile_level = 2
    -- FileType/syntax autocommands may run after BufReadPost during startup.
    local bufnr = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].codex_largefile_level == 2 then
        vim.bo[bufnr].syntax = "OFF"
      end
    end)
    return
  end

  vim.b.codex_largefile_level = 1
end

autocmd("BufReadPre", {
  group = augroup("codex_largefile_preload", { clear = true }),
  callback = preload_large_file,
})

autocmd("BufReadPost", {
  group = augroup("codex_largefile_optimize", { clear = true }),
  callback = optimize_large_file,
})

autocmd("TextYankPost", {
  group = augroup("codex_yank_highlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

autocmd("FileType", {
  group = augroup("codex_formatoptions", { clear = true }),
  callback = function(args)
    vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions:gsub("[cro]", "")
  end,
})
