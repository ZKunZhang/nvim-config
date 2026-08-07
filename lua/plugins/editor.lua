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
            cwd = project_root(),
            find_command = { "git", "ls-files", "--cached", "--others", "--exclude-standard" },
          },
          oldfiles = {
            cwd_only = true,
          },
        },
      }
    end,
    init = function()
      local function search_project(opts)
        require("lazy").load({ plugins = { "telescope.nvim" } })

        local finders = require("telescope.finders")
        local make_entry = require("telescope.make_entry")
        local pickers = require("telescope.pickers")
        local conf = require("telescope.config").values
        local root = project_root()
        local picker_opts = {
          cwd = root,
          default_text = opts.args ~= "" and opts.args or nil,
        }

        pickers
          .new(picker_opts, {
            prompt_title = "搜索项目代码",
            finder = finders.new_job(function(query)
              if not query or query == "" then
                return nil
              end

              return { "git", "-C", root, "grep", "-n", "--column", "--full-name", "-e", query, "--" }
            end, make_entry.gen_from_vimgrep(picker_opts), nil, root),
            previewer = conf.grep_previewer(picker_opts),
            sorter = conf.generic_sorter(picker_opts),
          })
          :find()
      end

      vim.api.nvim_create_user_command("Search", search_project, { nargs = "*", desc = "Search project" })
    end,
  },
}
