local function project_root()
  local current = vim.api.nvim_buf_get_name(0)
  local start = current ~= "" and vim.fs.dirname(current) or vim.uv.cwd()
  local root = vim.fs.find({ "package.json", "tsconfig.json", ".git" }, {
    upward = true,
    path = start,
    stop = vim.env.HOME,
  })[1]
  return root and vim.fs.dirname(root) or vim.uv.cwd()
end

local ignore_patterns = {
  "node_modules/",
  "dist/",
  "build/",
  "coverage/",
  ".git/",
  ".next/",
  ".turbo/",
  ".yarn/",
  "tmp/",
  "temp/",
  "%.min%.js",
  "%.min%.css",
  "yarn%.lock",
}

return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
      default = true,
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "浏览项目目录" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      view = {
        width = 36,
      },
      actions = {
        change_dir = {
          enable = false,
          restrict_above_cwd = true,
        },
        open_file = {
          quit_on_open = false,
        },
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        add_trailing = true,
        group_empty = true,
        indent_markers = {
          enable = true,
        },
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = false,
            git = true,
            modified = false,
            hidden = false,
            diagnostics = false,
            bookmarks = false,
          },
        },
      },
      filters = {
        custom = { "^%.git$" },
      },
      git = {
        enable = true,
      },
      filesystem_watchers = {
        enable = false,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "查找文件" },
      { "<leader>fg", "<cmd>SearchAll<cr>", desc = "搜索项目代码" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "查找已打开文件" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "查找最近文件" },
    },
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          path_display = { "smart" },
          prompt_prefix = "  ",
          selection_caret = "  ",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = ignore_patterns,
        },
        pickers = {
          find_files = {
            hidden = true,
            cwd = project_root(),
            no_ignore = false,
            find_command = vim.fn.executable("fd") == 1
                and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
              or nil,
          },
          live_grep = {
            cwd = project_root(),
            additional_args = function()
              return {
                "--hidden",
                "--glob",
                "!**/.git/**",
                "--glob",
                "!**/node_modules/**",
                "--glob",
                "!**/dist/**",
                "--glob",
                "!**/build/**",
                "--glob",
                "!**/coverage/**",
              }
            end,
          },
          oldfiles = {
            cwd_only = true,
          },
        },
      }
    end,
    init = function()
      local function telescope()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        return require("telescope.builtin")
      end

      local function search_all()
        telescope().live_grep({ cwd = project_root() })
      end

      local function search_current_file()
        telescope().current_buffer_fuzzy_find()
      end

      local function search_current_dir()
        local file = vim.api.nvim_buf_get_name(0)
        local cwd = file ~= "" and vim.fs.dirname(file) or project_root()
        telescope().live_grep({ cwd = cwd })
      end

      vim.api.nvim_create_user_command("SearchAll", search_all, { desc = "Search project" })
      vim.api.nvim_create_user_command("Sa", search_all, { desc = "Search project" })
      vim.api.nvim_create_user_command("SA", search_all, { desc = "Search project" })
      vim.api.nvim_create_user_command("Search", search_current_file, { desc = "Search current file" })
      vim.api.nvim_create_user_command("SearchDir", search_current_dir, { desc = "Search current file directory" })
      vim.api.nvim_create_user_command("Sd", search_current_dir, { desc = "Search current file directory" })
    end,
  },
}
