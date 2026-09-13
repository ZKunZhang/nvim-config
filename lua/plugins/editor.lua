local project = require("config.project")

return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeFindFileToggle", "NvimTreeFocus" },
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("config_start_page", { clear = true }),
        once = true,
        callback = function()
          local count = vim.fn.argc()
          local directory = count == 1 and vim.fn.argv(0) or nil
          if not directory or vim.fn.isdirectory(directory) == 0 then return end
          vim.schedule(function()
            vim.cmd.cd(vim.fn.fnameescape(vim.fn.fnamemodify(directory, ":p")))
            require("lazy").load({ plugins = { "nvim-tree.lua" } })
            require("nvim-tree.api").tree.open({ path = vim.fn.getcwd(), focus = true })
          end)
        end,
        desc = "目录启动时打开文件树",
      })
    end,
    opts = function()
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
            web_devicons = { file = { enable = false }, folder = { enable = false } },
            git_placement = "after",
            modified_placement = "after",
            show = {
              file = true, folder = true, folder_arrow = true, git = true,
              modified = true, hidden = false, diagnostics = false, bookmarks = false,
            },
            glyphs = {
              modified = "*",
              git = { unstaged = "M", staged = "S", unmerged = "U", renamed = "R", untracked = "?", deleted = "D", ignored = "I" },
              default = "[]", symlink = "@",
              folder = {
                default = "[+]", open = "[-]", empty = "[ ]", empty_open = "[ ]",
                symlink = "[@]", symlink_open = "[@]", arrow_closed = ">", arrow_open = "v",
              },
            },
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
      vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained", "ShellCmdPost", "TermClose" }, {
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
        desc = "保存或返回终端后刷新文件树，无需文件系统监听",
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      return {
        defaults = {
          path_display = { "truncate" },
          disable_devicons = true,
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
