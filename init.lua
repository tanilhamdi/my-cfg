-- Lazy.nvim yükleyicisi
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("lazy.nvim bulunamadı, indiriliyor...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Lazy'nin yüklendiğini kontrol et
if not pcall(require, "lazy") then
  print("lazy.nvim yüklenemedi!")
  return
end

-- Temel ayarlar
vim.opt.number = true          -- Satır numaralarını göster
vim.opt.relativenumber = true  -- Göreceli satır numaraları
vim.opt.tabstop = 2            -- Tab genişliği
vim.opt.shiftwidth = 2         -- Girinti genişliği
vim.opt.expandtab = true       -- Tab yerine boşluk kullan
vim.opt.smartindent = true     -- Akıllı girinti

-- Eski BufWritePre autocommand'lerini temizle
vim.api.nvim_clear_autocmds({ event = "BufWritePre", group = vim.api.nvim_create_augroup("LspFormatting", {}) })

require("lazy").setup({
  -- Mevcut cmp eklentisi
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        completion = {
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  -- Otomatik parantez kapatma
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {}
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  -- LSP eklentileri
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "html", "cssls", "ts_ls" },
      })
    end,
  },
  -- Dosya gezgini
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {}
    end,
  },
  -- Tema
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  -- Statü çubuğu
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup {
        options = { theme = "tokyonight" },
      }
    end,
  },
  -- Kod formatlama ve lint
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            prefer_local = "node_modules/.bin",
          }),
          null_ls.builtins.diagnostics.eslint_d.with({
            prefer_local = "node_modules/.bin",
          }),
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },
  -- Git entegrasyonu
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  -- Arama ve bulma
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {}
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
    end,
  },
  -- Kod parçalama
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "javascript", "typescript", "tsx", "html", "css" },
        highlight = { enable = true },
      }
    end,
  },
  -- Snippet desteği
  "rafamadriz/friendly-snippets",
})

-- LSP ayarları
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- HTML LSP ile snippet desteği
lspconfig.html.setup {
  capabilities = require("cmp_nvim_lsp").default_capabilities({
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  }),
  cmd = { "vscode-html-language-server", "--stdio" },
}

-- CSS LSP
lspconfig.cssls.setup {
  capabilities = capabilities,
  cmd = { "vscode-css-language-server", "--stdio" },
}

-- JavaScript/TypeScript LSP
lspconfig.ts_ls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    print("ts_ls başlatıldı!")
  end,
  cmd = { "typescript-language-server", "--stdio" },
  init_options = {
    hostInfo = "neovim",
  },
}

-- Transparanlık için ek highlight ayarları
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
