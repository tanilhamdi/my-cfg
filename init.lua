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
vim.opt.termguicolors = true   -- True color desteği
vim.opt.textwidth = 0          -- Satır uzunluğu limitini kaldır
vim.opt.wrap = false           -- Görsel satır kaydırmayı kapat
vim.opt.linebreak = false      -- Kelime sınırlarında kesmeyi kapat

-- İmleç şeklini tüm modlarda block olarak sabitle
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:hor20"

-- Escape kodlarıyla imleç rengini değiştirme fonksiyonu
local function set_cursor_color(color)
  vim.fn.system('printf "\\033]12;' .. color .. '\\007"')
end

-- Mod değiştiğinde imleç rengini değiştir
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = function()
    if vim.fn.mode() == "n" then
      set_cursor_color("white") -- Normal mod: Beyaz
    elseif vim.fn.mode() == "i" then
      set_cursor_color("green") -- Insert mod: Yeşil
    elseif vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "" then
      set_cursor_color("red") -- Visual mod: Kırmızı
    end
  end,
})

-- Neovim'den çıkarken imleç rengini varsayılana sıfırla (opsiyonel)
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    set_cursor_color("white") -- Varsayılan rengi beyaz yap
  end,
})

require("lazy").setup({
  -- GitHub Copilot eklentisi
  {
    "github/copilot.vim",
    config = function()
      -- Copilot ayarları
      vim.g.copilot_no_tab_map = true -- Varsayılan <Tab> eşleştirmesini devre dışı bırak
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.g.copilot_filetypes = {
        ["*"] = true, -- Tüm dosya türlerinde Copilot'u etkinleştir
      }
    end,
  },
  -- Mevcut cmp eklentisi
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
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
        ensure_installed = { "html", "cssls", "ts_ls", "htmx", "clangd", "pyright" },
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
  -- Miikanissi Modus Themes (Renk Şeması)
  {
    "miikanissi/modus-themes.nvim",
    config = function()
      require("modus-themes").setup({
        style = "modus_vivendi",
        variant = "default",
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },
        on_colors = function(colors)
          colors.bg_main = "NONE" -- Ana arka plan transparan
          colors.bg_dim = "NONE"  -- Loş arka plan transparan
          colors.bg_alt = "NONE"  -- Alternatif arka plan transparan
        end,
        on_highlights = function(highlights, colors)
          highlights.Normal = { bg = "NONE" } -- Normal metin arka planı transparan
          highlights.NonText = { bg = "NONE" } -- Boşluklar transparan
          highlights.LineNr = { bg = "NONE" }  -- Satır numaraları transparan
          highlights.SignColumn = { bg = "NONE" } -- İşaret sütunu transparan
        end,
      })
      vim.cmd([[colorscheme modus]])
    end,
  },
  -- Statü çubuğu
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup {
        options = { theme = "modus-vivendi" },
      }
    end,
  },
  -- Kod formatlama (conform.nvim ile)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          python = { "black" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
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
      vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files, {})
      vim.keymap.set("n", "<space>fg", require("telescope.builtin").live_grep, {})
    end,
  },
  -- Kod parçalama
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "javascript", "typescript", "tsx", "html", "css", "c", "cpp", "python" },
        highlight = { enable = true },
      }
    end,
  },
  -- Snippet desteği
  "rafamadriz/friendly-snippets",
  -- indent-blankline.nvim
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup {
        indent = {
          char = "▏", -- Dikey çizgi karakteri
        },
        scope = {
          enabled = true, -- Kod bloklarının kapsamını göster
          show_start = true, -- Bloğun başlangıcını vurgula
          show_end = true, -- Bloğun sonunu vurgula
        },
      }
    end,
  },
})

-- LSP ayarları
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- HTML LSP ile snippet desteği
lspconfig.html.setup {
  capabilities = capabilities,
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

-- HTMX LSP
lspconfig.htmx.setup {
  capabilities = capabilities,
  cmd = { "htmx-lsp", "--stdio" },
}

-- Clangd (C/C++) LSP
lspconfig.clangd.setup {
  capabilities = capabilities,
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  on_attach = function(client, bufnr)
    print("clangd başlatıldı!")
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
  end,
}

-- Python LSP (pyright)
lspconfig.pyright.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    print("pyright başlatıldı!")
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}

-- Arka planı transparan yap
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" }) -- İmlecin olduğu satır numarası

-- Derleme ve çalıştırma kısayolu (Makefile ile)
vim.api.nvim_set_keymap('n', '<space>r', ':!make && make run<CR>', { noremap = true, silent = false })
