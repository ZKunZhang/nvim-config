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
          "> `<Leader>` 是空格键；先按 `Esc` 回到普通模式，再执行快捷键。",
          "",
          "## 项目与文件",
          "",
          "- `Space f f`：按名称查找项目文件",
          "- `:Search 关键词`：全文搜索项目代码",
          "- `:NvimTreeToggle`：打开或关闭文件树",
          "- `:e 路径`：打开文件",
          "- `:edit .`：浏览当前目录",
          "",
          "## 文件内查找、复制与粘贴",
          "",
          "- `/关键词`：在当前文件向下查找  ·  `?关键词`：向上查找",
          "- `n` / `N`：跳到下一个 / 上一个匹配项",
          "- `*` / `#`：向下 / 向上查找光标所在单词",
          "- `v` 选择内容后按 `y`：复制选中内容",
          "- `yy`：复制当前行  ·  `3yy`：复制三行",
          "- `p` / `P`：粘贴到光标后 / 前",
          "- `\"+y` / `\"+p`：明确使用系统剪贴板复制 / 粘贴",
          "- 当前配置已启用系统剪贴板，通常直接 `y` 和 `p` 即可跨应用使用",
          "",
          "## 复制文件地址",
          "",
          "- 文件树中按 `y`：复制文件名",
          "- 文件树中按 `Y`：复制项目相对路径",
          "- 文件树中按 `gy`：复制文件绝对路径",
          "- 编辑文件时执行 `:let @+ = expand('%')`：复制相对路径",
          "- 编辑文件时执行 `:let @+ = expand('%:p')`：复制绝对路径",
          "",
          "## NvimTree 文件树",
          "",
          "- `Enter` / `o`：打开文件或展开目录",
          "- `a`：新建文件或目录（名称以 `/` 结尾）",
          "- `r`：重命名  ·  `d`：删除",
          "- `x`：剪切  ·  `c`：复制  ·  `p`：粘贴",
          "- `R`：刷新  ·  `H`：显示或隐藏点文件",
          "- `?`：查看文件树全部快捷键  ·  `q`：关闭文件树",
          "",
          "## 模式与输入",
          "",
          "- `i` / `a`：在光标前 / 后进入插入模式",
          "- `I` / `A`：在行首 / 行尾进入插入模式",
          "- `o` / `O`：在下方 / 上方新建一行",
          "- `Esc`：返回普通模式",
          "- `v` / `V` / `Ctrl-v`：字符 / 行 / 块选择模式",
          "",
          "## 移动",
          "",
          "- `h j k l`：左、下、上、右",
          "- `w` / `b`：下一个 / 上一个单词",
          "- `0` / `^` / `$`：行首 / 首个非空字符 / 行尾",
          "- `gg` / `G`：文件开头 / 文件末尾",
          "- `{` / `}`：上一个 / 下一个段落",
          "- `Ctrl-u` / `Ctrl-d`：向上 / 向下滚半页",
          "- `Ctrl-b` / `Ctrl-f`：向上 / 向下翻整页",
          "- `数字G`：跳到指定行，例如 `120G`",
          "",
          "## 编辑",
          "",
          "- `x`：删除字符  ·  `dd`：删除整行",
          "- `dw`：删除单词  ·  `d$`：删除到行尾",
          "- `cc`：修改整行  ·  `cw`：修改单词",
          "- `yy`：复制整行  ·  `p` / `P`：向后 / 向前粘贴",
          "- `u` / `Ctrl-r`：撤销 / 重做",
          "- `.`：重复上一次修改",
          "- `>` / `<`：选择模式下增加 / 减少缩进",
          "- `==`：格式化当前行  ·  `gg=G`：格式化全文缩进",
          "",
          "## 查找与替换",
          "",
          "- `/关键词` / `?关键词`：向下 / 向上查找",
          "- `n` / `N`：下一个 / 上一个匹配项",
          "- `*` / `#`：向下 / 向上查找光标所在单词",
          "- `:%s/旧/新/g`：全文替换",
          "- `:%s/旧/新/gc`：逐项确认全文替换",
          "- `:nohlsearch`：清除搜索高亮",
          "",
          "## 窗口与缓冲区",
          "",
          "- `:split` / `:vsplit`：水平 / 垂直分屏",
          "- `Ctrl-w h/j/k/l`：切换到左 / 下 / 上 / 右窗口",
          "- `Ctrl-w =`：平均窗口大小  ·  `Ctrl-w q`：关闭窗口",
          "- `:ls`：列出缓冲区  ·  `:b 数字`：切换缓冲区",
          "- `:bnext` / `:bprevious`：下一个 / 上一个缓冲区",
          "- `:bdelete`：关闭当前缓冲区",
          "",
          "## 保存与退出",
          "",
          "- `:w`：保存  ·  `:wa`：保存全部",
          "- `:q`：退出当前窗口  ·  `:qa`：退出全部",
          "- `:wq` / `ZZ`：保存并退出",
          "- `:q!` / `ZQ`：放弃修改并退出",
          "",
          "提示：在普通模式按 `:Tutor` 可打开 Neovim 官方交互教程。",
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
