# Neovim 代码浏览配置操作文档

## 1. 配置用途

这套配置用于快速浏览项目、查找文件、全文搜索代码和查看 Git 改动，不包含 LSP、代码补全、自动格式化等开发工具链。

保留的核心能力：

- Telescope：查找文件、搜索代码、切换已打开文件
- nvim-tree：浏览项目目录
- Git：列出项目文件并全文搜索代码
- gitsigns：显示 Git 行级改动
- lualine：显示编辑器状态栏
- lazy.nvim：管理 Neovim 插件

配置仓库：`git@github.com:ZKunZhang/nvim-config.git`

### 终端与配色

配置针对 macOS Terminal 的 `Basic` 浅色 Profile，使用 Neovim 内置 `default` 配色和 256 色模式，不需要安装额外主题插件。

## 2. 环境安装

macOS 使用 Homebrew 安装：

```bash
brew install neovim
```

确认安装结果：

```bash
nvim --version
git --version
```

## 3. 安装配置

首次安装：

```bash
git clone git@github.com:ZKunZhang/nvim-config.git ~/.config/nvim
nvim
```

第一次启动时，lazy.nvim 会自动下载所需插件。等待安装完成后重启 Neovim 即可。

如果 `~/.config/nvim` 已存在，请先备份原配置，再执行克隆：

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone git@github.com:ZKunZhang/nvim-config.git ~/.config/nvim
```

## 4. 打开项目

在项目根目录执行：

```bash
cd /path/to/project
nvim .
```

也可以直接打开某个文件：

```bash
nvim src/pages/index.tsx
```

## 5. 常用快捷键

`<leader>` 为 `Space` 空格键。

| 快捷键 | 功能 |
| --- | --- |
| `Space f f` | 按文件名查找文件 |
| `Space f g` | 全文搜索项目代码 |

按键需要依次输入。例如 `Space f g` 表示依次按空格、`f`、`g`。

除以上两项外，不覆盖 Neovim 原生快捷键。文件树使用下方命令打开。

## 6. 文件树命令

在 Neovim 命令模式下可使用：

```vim
:NvimTreeToggle
```

打开或关闭文件树。

```vim
:NvimTreeFindFileToggle
```

打开文件树并定位当前文件。

## 7. 搜索命令

除快捷键外，还支持以下命令：

```vim
:SearchAll
:Sa
```

搜索整个项目。

```vim
:Search
```

搜索当前文件。

```vim
:SearchDir
:Sd
```

搜索当前文件所在目录。

## 8. 基础操作

| 操作 | 按键或命令 |
| --- | --- |
| 进入插入模式 | `i` |
| 返回普通模式 | `Esc` |
| 保存文件 | `:w` |
| 退出 | `:q` |
| 保存并退出 | `:wq` |
| 强制退出且不保存 | `:q!` |
| 向下翻页 | `Ctrl-f` |
| 向上翻页 | `Ctrl-b` |

## 9. 更新配置

拉取远端配置：

```bash
git -C ~/.config/nvim pull --ff-only
```

启动 Neovim 后同步插件：

```vim
:Lazy sync
```

也可以在终端执行：

```bash
nvim --headless "+Lazy! sync" +qa
```

## 10. 修改并提交配置

```bash
cd ~/.config/nvim
git status
git add -A
git commit -m "中文提交说明"
git push origin main
```

提交前建议验证 Neovim 可以正常启动：

```bash
nvim --headless "+lua print('配置加载成功')" +qa
```

## 11. 故障处理

### 插件未安装完整

在 Neovim 中执行：

```vim
:Lazy sync
```

如果 GitHub 网络临时失败，稍后重试即可。

### 文件或全文搜索不可用

当前配置使用 Git 搜索，不需要安装 ripgrep、fd 或 npm 工具。请确认打开的目录属于 Git 仓库：

```bash
git rev-parse --show-toplevel
git ls-files | head
```

### 完全重装插件

先退出所有 Neovim 实例，再将插件目录移走作为备份：

```bash
mv ~/.local/share/nvim ~/.local/share/nvim.backup
nvim
```

确认新环境正常后，再自行删除备份目录。
