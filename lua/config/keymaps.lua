-- Preserve native search direction and counts, then center the result.
vim.keymap.set("n", "n", "nzz", { desc = "下一个搜索结果并居中" })
vim.keymap.set("n", "N", "Nzz", { desc = "反向搜索结果并居中" })
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- File tabs are listed buffers; Tab keeps its usual meaning in insert mode.
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "下一个文件" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "上一个文件" })
vim.keymap.set("n", "<leader>bd", "<cmd>confirm bdelete<cr>", { desc = "关闭文件（未保存时确认）" })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "保存当前文件" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "打开或关闭文件树" })
