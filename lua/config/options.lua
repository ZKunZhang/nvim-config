local opt = vim.opt

opt.fileencodings = { "utf-8", "ucs-bom", "gb18030", "gbk", "gb2312", "cp936", "big5", "latin1" }
opt.autoread = true
opt.confirm = true
opt.undolevels = 1000
local state_dir = vim.fn.stdpath("state")
opt.directory = state_dir .. "/swap//"
opt.undodir = state_dir .. "/undo//"
opt.viewdir = state_dir .. "/view//"
opt.undofile = true
-- Keep long-running terminal jobs from retaining an unbounded amount of output.
opt.scrollback = 2000

for _, dir in ipairs({
  state_dir .. "/swap",
  state_dir .. "/undo",
  state_dir .. "/view",
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
opt.lazyredraw = false
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
opt.inccommand = "split"
opt.completeopt = { "menu", "menuone", "noselect", "popup" }
opt.jumpoptions = "view"
opt.backspace = { "indent", "eol", "start" }
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.shiftround = true
opt.formatoptions:remove({ "c", "r", "o" })
opt.clipboard = "unnamed,unnamedplus"
opt.timeoutlen = 400
opt.shortmess:append("I")
opt.switchbuf = { "useopen" }
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
