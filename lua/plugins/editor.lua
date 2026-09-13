local project = require("config.project")

return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = { default = true },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeFindFileToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("config_start_page", { clear = true }),
        once = true,
        callback = function()
          local count = vim.fn.argc()
          local directory = count == 1 and vim.fn.argv(0) or nil
          if count > 1 or (directory and vim.fn.isdirectory(directory) == 0) then return end
          if count == 0 and (vim.bo.modified or vim.api.nvim_buf_get_name(0) ~= ""
            or vim.api.nvim_buf_line_count(0) > 1 or vim.fn.getline(1) ~= "") then return end
          vim.schedule(function()
            if directory then vim.cmd.cd(vim.fn.fnameescape(vim.fn.fnamemodify(directory, ":p"))) end
            local buffer = vim.api.nvim_get_current_buf()
            vim.bo[buffer].buftype = "nofile"
            vim.bo[buffer].bufhidden = "wipe"
            vim.bo[buffer].swapfile = false
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
              "# Neovim 默认操作入门",
              "",
              "先用 :Tutor 跟着练；冒号命令输入后按 Enter。",
              "",
              "i / Esc             开始输入 / 回到普通模式",
              "h j k l / w b       左下上右 / 按单词移动",
              "dd / yy / p         删除行 / 复制行 / 粘贴",
              "u / Ctrl-r / .      撤销 / 重做 / 重复上次修改",
              "/关键词 / n / N     搜索 / 下一个 / 反向匹配",
              ":w / :q / :wq       保存 / 退出窗口 / 保存并退出",
              ":e 路径 / :ls       打开文件 / 列出已打开文件",
              ":bn / :bp / :bd     下个文件 / 上个文件 / 关闭文件",
              "Ctrl-w 后按 h/j/k/l 在分屏或文件树与代码之间移动",
              "",
              "已有插件（使用各自默认操作）：",
              ":NvimTreeToggle     开关文件树；树内 Enter 打开、Backspace 收起",
              ":Telescope find_files  查找文件；Ctrl-n/p 选择、Enter 打开、Ctrl-c 关闭",
              ":Search             本配置提供的项目搜索命令",
              "",
              "帮助：:help；文件树内：g?；详细练习：~/.config/nvim/README.md。",
            })
            vim.bo[buffer].filetype = "markdown"
            vim.bo[buffer].modifiable = false
            vim.api.nvim_buf_set_name(buffer, "欢迎")
            if directory then
              require("lazy").load({ plugins = { "nvim-tree.lua" } })
              require("nvim-tree.api").tree.open({ path = vim.fn.getcwd(), focus = true })
            end
          end)
        end,
        desc = "显示操作欢迎页，目录启动时打开文件树",
      })
    end,
    opts = function()
      local nerd = vim.g.have_nerd_font == true
      return {
        hijack_cursor = false,
        sync_root_with_cwd = true,
        respect_buf_cwd = false,
        update_focused_file = { enable = true, update_root = false },
        view = { width = { min = 30, max = 46, padding = 1 } },
        actions = {
          change_dir = { enable = false, restrict_above_cwd = true },
          open_file = { quit_on_open = false, resize_window = true },
        },
        renderer = {
          root_folder_label = ":~:t",
          highlight_git = "name",
          highlight_opened_files = "name",
          add_trailing = true,
          group_empty = true,
          indent_markers = { enable = true },
          icons = {
            web_devicons = { file = { enable = nerd }, folder = { enable = false } },
            git_placement = "after",
            modified_placement = "after",
            show = {
              file = true, folder = true, folder_arrow = true, git = true,
              modified = true, hidden = false, diagnostics = false, bookmarks = false,
            },
            glyphs = vim.tbl_deep_extend("force", {
              modified = "*",
              git = { unstaged = "M", staged = "S", unmerged = "U", renamed = "R", untracked = "?", deleted = "D", ignored = "I" },
            }, nerd and {} or {
              default = "[]", symlink = "@",
              folder = {
                default = "[+]", open = "[-]", empty = "[ ]", empty_open = "[ ]",
                symlink = "[@]", symlink_open = "[@]", arrow_closed = ">", arrow_open = "v",
              },
            }),
          },
        },
        filters = { dotfiles = false, git_ignored = true, custom = { "^[.]git$" } },
        git = { enable = true, show_on_dirs = true, show_on_open_dirs = true },
        modified = { enable = true, show_on_dirs = true, show_on_open_dirs = true },
        filesystem_watchers = { enable = false },
      }
    end,
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      local pending = false
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "FocusGained", "ShellCmdPost", "TermClose" }, {
        group = vim.api.nvim_create_augroup("config_tree_refresh", { clear = true }),
        callback = function()
          local api = require("nvim-tree.api")
          if pending or not api.tree.is_visible() then return end
          pending = true
          vim.defer_fn(function()
            pending = false
            if api.tree.is_visible() then api.tree.reload() end
          end, 150)
        end,
        desc = "保存或返回文件时刷新文件树，无需文件系统监听",
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    opts = function()
      return {
        defaults = {
          path_display = { "truncate" },
          disable_devicons = not vim.g.have_nerd_font,
          prompt_prefix = "> ", selection_caret = "> ",
          sorting_strategy = "ascending", layout_strategy = "flex",
          layout_config = {
            width = 0.92, height = 0.85, flip_columns = 120,
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical = { prompt_position = "top", preview_cutoff = 20 },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = function(opts)
              opts.cwd = opts.cwd or project.root()
              return project.find_command(opts.cwd)
            end,
          },
          oldfiles = { cwd_only = true },
        },
      }
    end,
    init = function()
      vim.api.nvim_create_user_command("Search", function(opts)
        project.search({ default_text = opts.args ~= "" and opts.args or nil, literal = opts.bang })
      end, { nargs = "*", bang = true, desc = "搜索项目；Search! 使用普通文本" })
    end,
  },
}
