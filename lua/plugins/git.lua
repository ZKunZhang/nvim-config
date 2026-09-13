return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" }, change = { text = "~" }, delete = { text = "_" },
        topdelete = { text = "-" }, changedelete = { text = "~" }, untracked = { text = "?" },
      },
      signs_staged = {
        add = { text = "+" }, change = { text = "~" }, delete = { text = "_" },
        topdelete = { text = "-" }, changedelete = { text = "~" }, untracked = { text = "?" },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 700, virt_text_pos = "eol" },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    },
  },
}
