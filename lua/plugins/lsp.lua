local function project_root(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr or 0)
  local start = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()
  local root = vim.fs.find({ "package.json", "tsconfig.json", ".git" }, {
    upward = true,
    path = start,
    stop = vim.env.HOME,
  })[1]

  if root then
    return vim.fs.dirname(root)
  end

  return vim.uv.cwd()
end

local function root_dir(markers)
  return function(bufnr, callback)
    local name = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(name ~= "" and name or vim.uv.cwd(), markers)
    callback(root or project_root(bufnr))
  end
end

local function find_local_bin(bufnr, name)
  local root = project_root(bufnr)
  local path = root .. "/node_modules/.bin/" .. name
  if vim.uv.fs_stat(path) then
    return path
  end
end

local function executable_or_nil(command)
  if command == "" then
    return nil
  end
  return command
end

local function prettier_command(bufnr)
  local command = find_local_bin(bufnr, "prettier")
    or find_local_bin(bufnr, "prettierd")
    or vim.fn.exepath("prettier")
    or vim.fn.exepath("prettierd")

  return executable_or_nil(command)
end

local function eslint_d_command(bufnr)
  local command = find_local_bin(bufnr, "eslint_d")
    or vim.fn.exepath("eslint_d")

  return executable_or_nil(command)
end

local function disable_semantic_tokens(client)
  client.server_capabilities.semanticTokensProvider = nil
end

return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "eslint",
        "cssls",
        "html",
        "jsonls",
        "lua_ls",
      },
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",
        "stylua",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 2000,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.diagnostic.config({
        virtual_text = false,
        severity_sort = true,
        float = { border = "rounded" },
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      local servers = {
        ts_ls = {
          root_dir = root_dir({ "package.json", "tsconfig.json", ".git" }),
          single_file_support = false,
          init_options = {
            preferences = {
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
            },
          },
        },
        eslint = {
          root_dir = root_dir({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            "package.json",
            ".git",
          }),
          settings = {
            workingDirectory = { mode = "auto" },
            format = false,
          },
        },
        cssls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
            },
          },
        },
      }

      for server, server_config in pairs(servers) do
        vim.lsp.config(server, vim.tbl_deep_extend("force", server_config, {
          capabilities = capabilities,
          on_attach = disable_semantic_tokens,
        }))
        vim.lsp.enable(server)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        javascript = { "eslint_local", "prettier_local" },
        javascriptreact = { "eslint_local", "prettier_local" },
        typescript = { "eslint_local", "prettier_local" },
        typescriptreact = { "eslint_local", "prettier_local" },
        css = { "prettier_local" },
        scss = { "prettier_local" },
        html = { "prettier_local" },
        json = { "prettier_local" },
        jsonc = { "prettier_local" },
        markdown = { "prettier_local" },
        yaml = { "prettier_local" },
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        local disabled = vim.tbl_contains({ "bigfile" }, vim.bo[bufnr].filetype)
        if disabled or vim.b[bufnr].codex_largefile_level == 2 then
          return
        end
        return { timeout_ms = 1500, lsp_fallback = true }
      end,
      formatters = {
        eslint_local = {
          command = function(_, ctx)
            return eslint_d_command(ctx.buf)
          end,
          args = {
            "--fix-to-stdout",
            "--stdin",
            "--stdin-filename",
            "$FILENAME",
          },
          cwd = function(_, ctx)
            return project_root(ctx.buf)
          end,
          stdin = true,
          condition = function(_, ctx)
            return eslint_d_command(ctx.buf) ~= nil
          end,
        },
        prettier_local = {
          command = function(_, ctx)
            return prettier_command(ctx.buf)
          end,
          args = { "--stdin-filepath", "$FILENAME" },
          cwd = function(_, ctx)
            return project_root(ctx.buf)
          end,
          stdin = true,
          condition = function(_, ctx)
            return prettier_command(ctx.buf) ~= nil
          end,
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<c-space>"] = cmp.mapping.complete(),
          ["<cr>"] = cmp.mapping.confirm({ select = true }),
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
