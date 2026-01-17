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

-- Lazy'nin başarıyla yüklendiğini kontrol et
if not pcall(require, "lazy") then
  print("Hata: lazy.nvim yüklenemedi!")
  return
end

-- Temel Neovim Ayarları
vim.opt.number = true             -- Satır numaralarını göster
vim.opt.relativenumber = true     -- Göreceli satır numaralarını göster
vim.opt.tabstop = 2               -- Tab genişliğini 2 boşluk olarak ayarla
vim.opt.shiftwidth = 2            -- Otomatik girintilemede kullanılan boşluk sayısını ayarla
vim.opt.expandtab = true          -- Tabları boşluklara dönüştür
vim.opt.smartindent = true        -- Akıllı otomatik girintilemeyi etkinleştir
vim.opt.termguicolors = true      -- Terminalde tam renk desteğini etkinleştir
vim.opt.textwidth = 0             -- Otomatik satır kaydırmayı kapat
vim.opt.wrap = false              -- Satırları otomatik sarma
vim.opt.linebreak = false         -- Satırları kelime sınırlarında bölme
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:hor20" -- İmleç şeklini ayarla

-- Panoya Kopyalama Ayarı (sistem panosu ile entegrasyon)
vim.opt.clipboard = "unnamedplus"

-- Lazy.nvim ile Eklenti Kurulumu ve Yapılandırması
require("lazy").setup({
  -- Catppuccin Tema
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Koyu tema, Helix benzeri sonbahar tonları için
        transparent_background = true, -- Şeffaf arka planı kapat, opak arka plan kullan
        term_colors = true, -- Terminal renkleriyle uyumluluk
        styles = {
          comments = { "italic" }, -- Yorumları italik yap
          keywords = { "bold" }, -- Anahtar kelimeleri kalın yap (Helix tarzı)
          strings = {}, -- Dizeler için varsayılan stil
          functions = {}, -- Fonksiyonlar için varsayılan stil
        },
        custom_highlights = function(colors)
          return {
            -- Helix benzeri sonbahar tonları: turuncu, sarı, kırmızımsı renkler
            Keyword = { fg = colors.peach, style = { "bold" } }, -- Anahtar kelimeler için turuncu
            String = { fg = colors.yellow }, -- Dizeler için sarı
            Comment = { fg = colors.green, style = { "italic" } }, -- Yorumlar için yeşil
            Function = { fg = colors.red }, -- Fonksiyonlar için kırmızımsı ton
            Type = { fg = colors.mauve }, -- Tipler için morumsu ton
            Constant = { fg = colors.flamingo }, -- Sabitler için pembemsi kırmızı
            Identifier = { fg = colors.text }, -- Tanımlayıcılar için varsayılan metin rengi
            LineNr = { fg = colors.overlay0 }, -- Satır numaraları için nötr gri
            CursorLineNr = { fg = colors.peach, style = { "bold" } }, -- Aktif satır numarası için turuncu
          }
        end,
        integrations = {
          cmp = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          mason = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
        },
      })
      vim.cmd([[colorscheme catppuccin]]) -- Catppuccin temasını etkinleştir
    end,
  },

  -- GitHub Copilot Entegrasyonu
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.g.copilot_filetypes = { ["*"] = true }
    end,
  },

  -- nvim-cmp: Neovim için Tamamlama Çerçevesi
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
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
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
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },

  -- nvim-autopairs: Otomatik Parantez/Ayraç Kapatma
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
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup({
        ensure_installed = {
          "html-lsp",
          "css-lsp",
          "typescript-language-server",
          "htmx-lsp",
          "clangd",
          "pyright",
          "jdtls",
          "google-java-format",
          "zls",
          "rust-analyzer",
          "prettier",
          "vue-language-server",
          "vtsls",
          "svelte-language-server",
          "gopls",
          "csharp-ls",
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html",
          "cssls",
          "ts_ls",
          "htmx",
          "clangd",
          "pyright",
          "jdtls",
          "zls",
          "rust_analyzer",
          "vue_ls",
          "vtsls",
          "svelte",
          "gopls",
          "csharp_ls",
        },
        automatic_installation = true,
        handlers = {
          -- Default handler for all LSP servers not explicitly listed
          function(server_name)
            require("lspconfig")[server_name].setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
              end,
            }
          end,

          -- Specific handler for csharp_ls
          ["csharp_ls"] = function()
            require("lspconfig").csharp_ls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
              end,
              filetypes = { "cs" },
              root_dir = require("lspconfig").util.root_pattern("*.sln", "*.csproj", ".git"),
              settings = {
                ["csharp.godot.enable"] = true
              }
            }
          end,

          -- Specific handler for vtsls
          ["vtsls"] = function()
            require("lspconfig").vtsls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
              end,
              filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
              root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", ".git"),
              settings = {
                javascript = { format = { enable = false } },
                typescript = { format = { enable = false } },
              },
              init_options = {
                tsdk = "/home/unram/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib",
              },
            }
          end,
          -- Specific handler for vue_ls
          ["vue_ls"] = function()
            require("lspconfig").volar.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
              end,
              filetypes = { "vue" },
              root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", "vue.config.js", ".git"),
              settings = {
                vue = {
                  updateImportsOnFileMove = { enabled = true },
                },
                typescript = {
                  tsdk = "/home/unram/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib",
                },
              },
              init_options = {
                typescript = {
                  tsdk = "/home/unram/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib",
                },
              },
            }
          end,
          -- Specific handler for svelte
          ["svelte"] = function()
            require("lspconfig").svelte.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
              end,
              filetypes = { "svelte" },
              root_dir = require("lspconfig").util.root_pattern("package.json", "svelte.config.js", "tsconfig.json", ".git"),
              settings = {
                svelte = {
                  plugin = {
                    typescript = {},
                  },
                },
              },
            }
          end,
          -- Specific handler for gopls
          ["gopls"] = function()
            require("lspconfig").gopls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = function(client, bufnr)
                print(client.name .. " başlatıldı!")
                local buf_set_keymap = vim.api.nvim_buf_set_keymap
                local opts = { noremap = true, silent = true }
                buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_set_keymap(bufnr, 'n', 'gl', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
              end,
              filetypes = { "go", "gomod", "gowork", "gotmpl" },
              root_dir = require("lspconfig").util.root_pattern("go.work", "go.mod", ".git"),
              settings = {
                gopls = {
                  analyses = {
                    unusedparams = true,
                  },
                  staticcheck = true,
                },
              },
            }
          end,
        },
      })
    end,
  },

  -- nvim-lualine/lualine.nvim: Durum Çubuğu
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup { options = { theme = "catppuccin" } } -- Catppuccin temasıyla uyumlu
    end,
  },

  -- stevearc/conform.nvim: Kod Formatlama
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          vue = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          python = { "black" },
          java = { "google-java-format" },
          rust = { "rustfmt" },
          svelte = { "prettier" },
          go = { "gofmt" },
        },
        formatters = {
          prettier = {
            command = vim.fn.stdpath("data") .. "/mason/bin/prettier",
            args = { "--stdin-filepath", "$FILENAME" },
          },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
    end,
  },

  -- lewis6991/gitsigns.nvim: Git Entegrasyonu (Değişiklikleri Göster)
  { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },

  -- nvim-telescope/telescope.nvim: Gelişmiş Arama ve Bulma
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {}
      vim.keymap.set("n", "<space>ff", require("telescope.builtin").find_files, { desc = "Dosyaları Bul" })
      vim.keymap.set("n", "<space>fg", require("telescope.builtin").live_grep, { desc = "Metin Ara" })
    end,
  },

  -- nvim-treesitter/nvim-treesitter: Kod Ayrıştırma ve Vurgulama
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "tsx", "html", "css", "c", "cpp", "python", "java", "zig", "rust", "vue", "svelte", "go" },
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })
    end,
  },

  -- rafamadriz/friendly-snippets: Snippet Desteği
  "rafamadriz/friendly-snippets",

  -- lukas-reineke/indent-blankline.nvim: Girinti Kılavuz Çizgileri
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup {
        indent = { char = "▏" },
        scope = { enabled = true, show_start = true, show_end = true }
      }
    end,
  },
})

-- Diagnostiklerin (hata/uyarı) nasıl görüntüleneceğini ayarla
vim.diagnostic.config({
  virtual_text = {
    enable = true,
  },
  signs = true,
  update_in_insert = false,
  float = {
    source = true,
    header = "Diagnostics",
    border = "rounded",
  },
})

-- Genel Tuş Eşlemeleri
vim.api.nvim_set_keymap('n', '<space>r', ':!make && make run<CR>', { noremap = true, silent = false, desc = "Make ve Çalıştır" })
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true, desc = "Yarı Sayfa Aşağı Kaydır ve Ortala" })
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true, desc = "Yarı Sayfa Yukarı Kaydır ve Ortala" })
vim.keymap.set('n', '<space>g', ':belowright split term://go run .<CR>', { noremap = true, silent = true, desc = 'Run Go program in split' })

