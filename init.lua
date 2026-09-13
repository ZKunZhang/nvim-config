-- Only enable when the terminal already uses a Nerd Font. No font is installed here.
vim.g.have_nerd_font = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

vim.cmd.colorscheme("catppuccin")
