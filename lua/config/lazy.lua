local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.notify("未找到已有 lazy.nvim；当前配置不会自动安装插件。", vim.log.levels.WARN)
  return
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.editor" },
    { import = "plugins.git" },
  },
  install = {
    missing = false,
    colorscheme = { "habamax" },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
})
