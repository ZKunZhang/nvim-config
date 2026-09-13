local M = {}

M.ignored_dirs = { ".git", "node_modules", "dist", "build", "coverage", ".next", ".turbo", ".yarn", ".cache" }

function M.root()
  local name = vim.api.nvim_buf_get_name(0)
  local start = vim.bo.buftype == "" and name ~= "" and name or vim.fn.getcwd()
  if vim.fn.isdirectory(start) == 0 then
    start = vim.fs.dirname(start)
  end
  return vim.fs.root(start, ".git")
    or vim.fs.root(start, { "package.json", "pyproject.toml", "Cargo.toml", "go.mod", "Makefile" })
    or start
end

local function exclusions()
  local paths = { "." }
  for _, dir in ipairs(M.ignored_dirs) do
    paths[#paths + 1] = ":(exclude,glob)**/" .. dir .. "/**"
  end
  return paths
end

function M.find_command(cwd)
  if vim.fs.root(cwd, ".git") then
    local cmd = { "git", "-C", cwd, "-c", "core.quotepath=false", "ls-files", "--cached", "--others", "--exclude-standard", "--deduplicate", "--" }
    return vim.list_extend(cmd, exclusions())
  end
  local cmd = { "find", ".", "-type", "d", "(" }
  for i, dir in ipairs(M.ignored_dirs) do
    if i > 1 then cmd[#cmd + 1] = "-o" end
    vim.list_extend(cmd, { "-name", dir })
  end
  return vim.list_extend(cmd, { ")", "-prune", "-o", "-type", "f", "-print" })
end

function M.grep_command(cwd, query, literal)
  if not query or query == "" then return nil end
  local cmd = { "git", "-C", cwd, "-c", "core.quotepath=false", "grep",
    vim.fs.root(cwd, ".git") and "--untracked" or "--no-index",
    "--exclude-standard", "-I", "-n", "--column", "-H", "--no-color",
    "--no-heading", "--no-break", "--no-full-name", literal and "-F" or "-G" }
  if not query:find("%u") then cmd[#cmd + 1] = "-i" end
  vim.list_extend(cmd, { "-e", query, "--" })
  return vim.list_extend(cmd, exclusions())
end

function M.find_files(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or M.root()
  opts.find_command = M.find_command(opts.cwd)
  opts.hidden = true
  require("telescope.builtin").find_files(opts)
end

function M.search(opts)
  opts = opts or {}
  require("lazy").load({ plugins = { "telescope.nvim" } })
  local root = opts.cwd or M.root()
  local picker_opts = { cwd = root, default_text = opts.default_text }
  local conf = require("telescope.config").values
  require("telescope.pickers").new(picker_opts, {
    prompt_title = opts.literal and "搜索项目代码（文本）" or "搜索项目代码（正则）",
    results_title = root,
    preview_title = "代码预览",
    finder = require("telescope.finders").new_job(function(query)
      return M.grep_command(root, query, opts.literal)
    end, require("telescope.make_entry").gen_from_vimgrep(picker_opts), nil, root),
    previewer = conf.grep_previewer(picker_opts),
    sorter = require("telescope.sorters").highlighter_only(picker_opts),
  }):find()
end

return M
