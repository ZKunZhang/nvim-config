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
            find_command = { "git", "ls-files", "--cached", "--others", "--exclude-standard" },
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

      local function git_grep(pathspec)
        vim.ui.input({ prompt = "搜索代码: " }, function(query)
          if not query or query == "" then
            return
          end

          local root = project_root()
          local command = { "git", "-C", root, "grep", "-n", "--column", "--full-name", "-e", query, "--" }
          if pathspec then
            table.insert(command, pathspec)
          end

          local results = vim.fn.systemlist(command)
          if vim.v.shell_error > 1 then
            vim.notify(table.concat(results, "\n"), vim.log.levels.ERROR)
            return
          end
          if #results == 0 then
            vim.notify("没有找到匹配代码", vim.log.levels.INFO)
            return
          end

          vim.fn.setqflist({}, " ", {
            title = "git grep: " .. query,
            lines = results,
            efm = "%f:%l:%c:%m",
          })
          telescope().quickfix({ cwd = root })
        end)
      end

      local function search_all()
        git_grep()
      end

      local function search_current_file()
        telescope().current_buffer_fuzzy_find()
      end

      local function search_current_dir()
        local file = vim.api.nvim_buf_get_name(0)
        local root = project_root()
        local directory = file ~= "" and vim.fs.dirname(file) or root
        local relative = directory:sub(1, #root) == root and directory:sub(#root + 2) or nil
        git_grep(relative and relative ~= "" and relative or ".")
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
