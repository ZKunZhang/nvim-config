local opt = vim.opt

opt.fileencodings = { "utf-8", "ucs-bom", "gb18030", "gbk", "gb2312", "cp936", "big5", "latin1" }
opt.autoread = true
opt.confirm = true
opt.undolevels = 1000
opt.directory = vim.fn.expand("~/.local/state/nvim/swap//")
opt.undodir = vim.fn.expand("~/.local/state/nvim/undo")
opt.viewdir = vim.fn.expand("~/.local/state/nvim/view//")
opt.undofile = true
-- Keep long-running terminal jobs from retaining an unbounded amount of output.
opt.scrollback = 2000

for _, dir in ipairs({
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
opt.background = "light"
opt.termguicolors = false
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
opt.winborder = "rounded"
opt.cursorlineopt = "number"
opt.showmode = false

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.history = 500
opt.shada = { "!", "'100", "<50", "s10", "h" }
opt.wildignorecase = true
opt.inccommand = "nosplit"
opt.completeopt = { "menu", "menuone", "noselect" }
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

-- Keep opened files available when switching, including unsaved edits.
opt.hidden = true
opt.showtabline = 2
