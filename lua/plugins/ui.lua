return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>c", group = "代码" },
        { "<leader>f", group = "查找" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "块级改动" },
        { "<leader>s", group = "搜索" },
        { "<leader>x", group = "诊断" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        icons_enabled = false,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      local ok, lualine = pcall(require, "lualine")
      if not ok then
        vim.notify("lualine.nvim is not installed correctly yet; run :Lazy sync", vim.log.levels.WARN)
        return
      end
      lualine.setup(opts)
    end,
  },
}
