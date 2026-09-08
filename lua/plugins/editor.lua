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
    init = function()
      local function open_start_page()
        local buffer = vim.api.nvim_get_current_buf()
        vim.bo[buffer].buftype = "nofile"
        vim.bo[buffer].bufhidden = "wipe"
        vim.bo[buffer].swapfile = false
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
          "# 欢迎使用 Neovim",
          "",
          "先按 Esc，再使用下面的空格快捷键（依次按，不用同时按）。",
          "",
          "- Space e：开关文件树，选中文件后按 Enter 打开",
          "- Space f f：按文件名查找并打开文件",
          "- 鼠标点击顶部标签：切换文件；[+] 表示尚未保存",
          "- Space w：保存当前文件",
          "- Space b d：关闭当前文件，未保存时会询问",
          "",
          "编辑：按 i 开始输入，按 Esc 结束输入。",
          "退出：按 Esc，输入 :qa，再按 Enter；未保存时会询问。",
          "",
          "其他操作需要时再查 ~/.config/nvim/README.md。",
        })
        vim.bo[buffer].filetype = "markdown"
        vim.bo[buffer].modifiable = false
        vim.api.nvim_buf_set_name(buffer, "欢迎")
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local argument_count = vim.fn.argc()
          local directory = argument_count == 1 and vim.fn.argv(0) or nil
          if argument_count > 1 or (argument_count == 1 and vim.fn.isdirectory(directory) == 0) then
            return
          end

          vim.schedule(function()
            if directory then
              vim.cmd.cd(vim.fn.fnameescape(vim.fn.fnamemodify(directory, ":p")))
            end
            open_start_page()
          end)
        end,
        desc = "空启动时显示操作欢迎页",
      })
    end,
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
