return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        icons_enabled = false,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      tabline = {
        lualine_a = {
          {
            "buffers",
            mode = 0,
            show_filename_only = false,
            show_modified_status = true,
            max_length = function()
              return vim.o.columns
            end,
            symbols = { modified = " [+]", alternate_file = "", directory = "Dir" },
          },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = {},
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
