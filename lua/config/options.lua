local opt = vim.opt

local path_sep = vim.uv.os_uname().version:match("Windows") and ";" or ":"
local extra_paths = {}

local function add_path(path)
  if path and path ~= "" and vim.uv.fs_stat(path) then
    table.insert(extra_paths, path)
  end
end

add_path("/opt/homebrew/bin")
add_path("/opt/homebrew/sbin")
add_path(vim.fn.expand("~/.local/bin"))

local nvm_bins = vim.fn.glob(vim.fn.expand("~/.nvm/versions/node/*/bin"), false, true)
table.sort(nvm_bins)
if #nvm_bins > 0 then
  add_path(nvm_bins[#nvm_bins])
end

if #extra_paths > 0 then
  vim.env.PATH = table.concat(extra_paths, path_sep) .. path_sep .. vim.env.PATH
end

opt.encoding = "utf-8"
opt.fileencodings = { "utf-8", "ucs-bom", "gb18030", "gbk", "gb2312", "cp936", "big5", "latin1" }
opt.autoread = true
opt.hidden = true
opt.confirm = true
if vim.fn.exists("+maxmem") == 1 then
  opt.maxmem = 65536
end
if vim.fn.exists("+maxmemtot") == 1 then
  opt.maxmemtot = 262144
end
opt.undolevels = 300
opt.backupdir = vim.fn.expand("~/.local/state/nvim/backup//")
opt.directory = vim.fn.expand("~/.local/state/nvim/swap//")
opt.undodir = vim.fn.expand("~/.local/state/nvim/undo")
opt.viewdir = vim.fn.expand("~/.local/state/nvim/view//")
opt.undofile = true

for _, dir in ipairs({
  vim.fn.expand("~/.local/state/nvim/backup"),
  vim.fn.expand("~/.local/state/nvim/swap"),
  vim.fn.expand("~/.local/state/nvim/undo"),
  vim.fn.expand("~/.local/state/nvim/view"),
}) do
  vim.fn.mkdir(dir, "p")
end

opt.number = true
opt.relativenumber = false
opt.numberwidth = 4
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.termguicolors = true
opt.wrap = false
opt.list = false
opt.listchars = {
  tab = ">-",
  trail = ".",
  extends = ">",
  precedes = "<",
  nbsp = "+",
}
opt.synmaxcol = 200
opt.redrawtime = 1500
opt.lazyredraw = true
opt.laststatus = 3
opt.pumheight = 10
opt.winborder = "rounded"
opt.cursorlineopt = "number"

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.history = 1000
opt.wildignorecase = true
opt.inccommand = "nosplit"
opt.backspace = { "indent", "eol", "start" }
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.shiftround = true
opt.formatoptions:remove({ "c", "r", "o" })
opt.whichwrap:append("<,>,[,],h,l")
opt.clipboard = "unnamed,unnamedplus"
opt.timeoutlen = 400
opt.shortmess:append("I")
opt.switchbuf = { "useopen", "usetab" }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime = 200

opt.wildignore:append({
  "*/node_modules/*",
  "*/dist/*",
  "*/build/*",
  "*/coverage/*",
  "*/.git/*",
  "*/.next/*",
  "*/.turbo/*",
})

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

vim.g.loaded_matchparen = 1

