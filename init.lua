-- =============================================================================
-- ÇEKİRDEK AYARLAR
-- =============================================================================

-- DİKKAT: vim.opt.autochdir = true KALDIRILDI.
-- VimTeX ve LSP'lerin proje root'unu doğru bulması için bu ayar kapalı kalmalı.



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
vim.g.mapleader = " "
vim.g.maplocalleader = " "
if not pcall(require, "lazy") then
  print("Hata: lazy.nvim yüklenemedi!")
  return
end

-- Temel Neovim Ayarları
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.textwidth = 0
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:block,r-cr-o:hor20,a:blinkwait300-blinkoff400-blinkon250"
vim.opt.clipboard = "unnamedplus"

-- Ortak on_attach fonksiyonu
local function lsp_on_attach(client, bufnr)
  -- print(client.name .. " başlatıldı!") -- Konsol kirliliğini önlemek için kapattım
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
end

-- =============================================================================
-- EKLENTİ YÖNETİMİ (LAZY.NVIM)
-- =============================================================================
require("lazy").setup({
  -- codecompanion kurulumu
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("codecompanion").setup({
        -- Kısayolu burada garantiye alıyoruz (Control + Enter)
        opts = {
          keymaps = {
            send = {
              modes = { n = "<C-CR>", i = "<C-CR>" },
            },
          },
        },
        strategies = {
          chat = {
            adapter = "ollama",
          },
          inline = {
            adapter = "ollama",
          },
        },
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "http://127.0.0.1:11434",
              },
              schema = {
                model = {
                  default = "qwen2.5-coder:3b",
                },
              },
            })
          end,
        },
      })
    end,
  },

  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-mini/mini.icons' },
    config = function()
      require 'alpha'.setup(require 'alpha.themes.startify'.config)
    end
  },

  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
  },

  -- VIMTEX (LaTeX Derleme ve Görüntüleme)
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'zathura_simple'
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_view_general_viewer = 'zathura'
    end
  },

  -- LaTeX Snippet'ları (LuaSnip ile entegre)
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    ft = "tex",
    config = function()
      require('luasnip-latex-snippets').setup({
        use_treesitter = true,
      })
      local ls = require("luasnip")
      vim.keymap.set({ "i", "s" }, "<Tab>", function() ls.jump(1) end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<S-Tab>", function() ls.jump(-1) end, { silent = true })
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "javascript", "typescript", "tsx", "html", "css",
          "c", "cpp", "python", "java", "zig", "rust",
          "vue", "svelte", "go", "c_sharp", "gdscript", "ocaml",
          "glsl", "godot_resource", "latex", "bibtex", "bash"
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "svelte", "latex" },
        },
        indent = { enable = true },
      })
    end,
  },

  -- Dracula Tema (Haskell Purple mod)
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    config = function()
      require("dracula").setup({
        transparent_bg = true,
        italic_comment = true,
        bold_keywords = true,
        overrides = {
          DraculaFg = { fg = "#f8f8f2" },
          DraculaComment = { fg = "#6272a4", italic = true },
          DraculaPurple = { fg = "#bd93f9" },
          DraculaCyan = { fg = "#8be9fd" },
          DraculaGreen = { fg = "#50fa7b" },
          DraculaOrange = { fg = "#ffb86c" },
          DraculaPink = { fg = "#ff79c6" },
          DraculaRed = { fg = "#ff5555" },
          DraculaYellow = { fg = "#f1fa8c" },
          ["@keyword"] = { fg = "#bd93f9", bold = true },
          ["@type"] = { fg = "#8be9fd" },
          ["@function"] = { fg = "#50fa7b" },
          ["@string"] = { fg = "#f1fa8c" },
          ["@constant"] = { fg = "#ff79c6" },
        },
      })
      vim.cmd.colorscheme "dracula"
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.g.copilot_filetypes = { ["*"] = true }
      vim.cmd("Copilot disable")
    end,
  },

  -- nvim-cmp
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

      local s = luasnip.snippet
      local t = luasnip.text_node
      local i = luasnip.insert_node

      luasnip.add_snippets("spec", {
        s("MAX", { t("MAX") }),
        s("MIN", { t("MIN") }),
        s("SEARCH", { t("SEARCH") }),
        s("SELECT", { t("SELECT") }),
        s("EXISTS", { t("EXISTS") }),
        s("DECISION", { t("DECISION") }),
        s("COPY", { t("COPY") }),
        s("FORALL", { t("FORALL") }),
        s("MIS", { t("MIS") }),
        s("FILTER", { t("FILTER") }),
        s("SUM", { t("SUM") }),
        s("COUNT", { t("COUNT") }),
        s("In:", { t("In: ") }),
        s("Out:", { t("Out: ") }),
        s("Pre:", { t("Pre: ") }),
        s("Post:", { t("Post: ") }),
        s("Fn:", { t("Fn: ") }),
      })

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
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {}
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- LSP Config & Mason
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "html", "cssls", "ts_ls", "htmx", "clangd", "pyright",
          "jdtls", "zls", "rust_analyzer", "vue_ls", "vtsls",
          "svelte", "gopls", "texlab", "bashls", "powershell_es", "hls",
          "ocamllsp", "asm_lsp"
        },
        automatic_installation = true,
        handlers = {
          ["lua_ls"] = function()
            local loveApiPath = "/home/unram/.local/share/lua-language-server/luaSources/love-api"
            local defaultLibs = vim.api.nvim_get_runtime_file("", true)
            require("lspconfig").lua_ls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              settings = {
                Lua = {
                  runtime = { version = 'LuaJIT' },
                  diagnostics = { globals = { 'love', 'vim' } },
                  workspace = {
                    library = vim.list_extend(defaultLibs, { loveApiPath }),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              },
            }
          end,
          function(server_name)
            require("lspconfig")[server_name].setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
            }
          end,
          ["ocamllsp"] = function()
            require("lspconfig").ocamllsp.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              filetypes = { "ocaml", "ocaml_interface", "ocamllex", "menhir" },
              root_dir = require("lspconfig").util.root_pattern(
                "*.opam", "opam", ".ocamlformat", "dune-project", "dune-workspace", ".git"
              ),
              settings = {
                codelens = { enable = true },
                inlayHints = { enable = true },
              },
            }
          end,
          ["vtsls"] = function()
            require("lspconfig").vtsls.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
              root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", ".git"),
              settings = {
                javascript = { format = { enable = false } },
                typescript = { format = { enable = false } },
              },
            }
          end,
          ["texlab"] = function()
            require("lspconfig").texlab.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              settings = {
                texlab = {
                  build = { onSave = true },
                  chktex = { onOpenAndSave = true, onEdit = false },
                }
              }
            }
          end,
          ["powershell_es"] = function()
            require("lspconfig").powershell_es.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              filetypes = { "ps1", "psm1", "psd1" },
              settings = {
                powershell = { scriptAnalysis = { enable = true } },
              },
            }
          end,
        },
      })
    end,
  },

  -- Roslyn (C#)
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csharp" },
    dependencies = { "Hoffs/omnisharp-extended-lsp.nvim" },
    config = function()
      require("roslyn").setup({
        on_attach = lsp_on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup { options = { theme = "dracula" } }
    end,
  },

  -- Conform (Formatter)
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
          cs = { "csharpier" },
          tex = { "latexindent" },
          ocaml = { "ocp_indent" },
        },
        formatters = {
          ocp_indent = {
            command = "ocp-indent",
            args = { "_" },
          },
          prettier = {
            command = vim.fn.stdpath("data") .. "/mason/bin/prettier",
            args = { "--stdin-filepath", "$FILENAME" },
          },
          csharpier = {
            command = "csharpier",
            args = { "--fast", "$FILENAME" },
          },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
    end,
  },

  -- Git Signs
  { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },

  -- Debug Adapter Protocol (DAP)
  {
    "mfussenegger/nvim-dap",
    config = function()
      vim.keymap.set('n', '<leader>db', ':DapToggleBreakpoint<CR>',
        { noremap = true, silent = true, desc = 'Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dc', ':DapContinue<CR>', { noremap = true, silent = true, desc = 'Continue' })
      vim.keymap.set('n', '<leader>dn', ':DapStepOver<CR>', { noremap = true, silent = true, desc = 'Step Over' })
      vim.keymap.set('n', '<leader>di', ':DapStepInto<CR>', { noremap = true, silent = true, desc = 'Step Into' })
      vim.keymap.set('n', '<leader>do', ':DapStepOut<CR>', { noremap = true, silent = true, desc = 'Step Out' })
    end,
  },

  -- Java LSP & DAP (nvim-jdtls)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local jdtls = require('jdtls')

      -- Proje kökünü belirleyen fonksiyon
      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = jdtls.setup.find_root(root_markers)

      local config = {
        cmd = {
          'jdtls', -- Mason kurduysa PATH'tedir
          '-data', vim.fn.stdpath('cache') .. '/jdtls/' .. vim.fn.fnamemodify(root_dir, ':p:h:t'),
        },
        root_dir = root_dir,
        settings = {
          java = {
            signatureHelp = { enabled = true },
            saveActions = { organizeImports = true },
            configuration = {
              runtimes = {
                {
                  -- Burada sistemindeki JDK yolunu belirtmen gerekebilir
                  name = "JavaSE-26",
                  path = "/usr/lib/jvm/java-26-openjdk", -- /bin/java kısmını sildik!
                  default = true,
                },
              }
            }
          }
        },
        init_options = {
          bundles = {} -- Eğer Lombok kullanıyorsan buraya jar yollarını eklemelisin
        }
      }

      -- JDTLS'i başlat
      jdtls.start_or_attach(config)

      -- DAP desteğini aktif et
      jdtls.setup_dap({ hotcodereplace = 'auto' })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      require("telescope").setup {}
      vim.keymap.set("n", "<space>.", builtin.find_files, { desc = "Dosyaları Bul" })
      vim.keymap.set("n", "<space>/", builtin.live_grep, { desc = "Metin Ara" })
      vim.keymap.set("n", "<space>,", builtin.buffers, { desc = "buffer search" })
      vim.keymap.set("n", "<space>th", function() builtin.colorscheme({ enable_preview = true }) end,
        { desc = "Temaları Canlı Önizle" })
    end,
  },

  "rafamadriz/friendly-snippets",

  -- Pano (Clipboard)
  {
    "ojroques/nvim-osc52",
    config = function()
      require('osc52').setup { max_length = 0, silent = true }
      vim.api.nvim_create_autocmd('TextYankPost', {
        callback = function()
          if vim.v.event.operator == 'y' then
            require('osc52').copy_register('+')
          end
        end,
      })
    end,
  },

  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<M-x>]],
        direction = 'float',
        dir = "buffer",
        float_opts = { border = 'curved' }
      })
    end
  },

  -- Indent Blankline
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
}) -- =============================================================================
-- GÖRSEL VE DİĞER AYARLAR
-- =============================================================================

-- Renk highlight'ları
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "myred", { fg = "#ff2b00", bold = true })
    vim.api.nvim_set_hl(0, "myyellow", { fg = "#FFBB00", bold = true })
    vim.api.nvim_set_hl(0, "mygreen", { fg = "#00FF6F", bold = true })
    vim.api.nvim_set_hl(0, "myblue", { fg = "#00EAFF", bold = true })
  end,
})

-- Özel dosya tipi renklendirmesi (spec files)
vim.filetype.add({ extension = { myext = "spec" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "spec",
  callback = function()
    vim.fn.matchadd("myred", "In:")
    vim.fn.matchadd("myred", "Out:")
    vim.fn.matchadd("myred", "Post:")
    vim.fn.matchadd("myred", "Pre:")
    vim.fn.matchadd("myred", "Fn:")
    vim.fn.matchadd("myyellow", "N")
    vim.fn.matchadd("myyellow", "Z")
    vim.fn.matchadd("myyellow", "L")
    vim.fn.matchadd("myyellow", "R")
    vim.fn.matchadd("mygreen", "and")
    vim.fn.matchadd("mygreen", "or")
    vim.fn.matchadd("myblue", "COUNT")
    vim.fn.matchadd("myblue", "MIS")
    vim.fn.matchadd("myblue", "SEARCH")
    vim.fn.matchadd("myblue", "EVERY")
    vim.fn.matchadd("myblue", "SELECT")
    vim.fn.matchadd("myblue", "SUM")
    vim.fn.matchadd("myblue", "COPY")
    vim.fn.matchadd("myblue", "DECISION")
    vim.fn.matchadd("myblue", "FORALL")
    vim.fn.matchadd("myblue", "FILTER")
    vim.fn.matchadd("myblue", "EXISTS")
    vim.fn.matchadd("myblue", "MAX")
    vim.fn.matchadd("myblue", "MIN")
  end,
})

-- LaTeX için özel ayarlar (Conceal Level)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.conceallevel = 2    -- Sembollerin görünmesi için (örn: \alpha -> α)
    vim.opt_local.spell = true        -- Yazım denetimini aç
    vim.opt_local.spelllang = "en_us" -- İngilizce ve Türkçe sözlük
  end,
})

-- Genel Tuş Eşlemeleri
vim.api.nvim_set_keymap('n', '<space>r', ':!make && make run<CR>',
  { noremap = true, silent = false, desc = "Make ve Çalıştır" })
vim.api.nvim_set_keymap('n', '<C-d>', '<C-d>zz',
  { noremap = true, silent = true, desc = "Yarı Sayfa Aşağı Kaydır ve Ortala" })
vim.api.nvim_set_keymap('n', '<C-u>', '<C-u>zz',
  { noremap = true, silent = true, desc = "Yarı Sayfa Yukarı Kaydır ve Ortala" })
vim.keymap.set('n', '<space>g', ':belowright split term://go run .<CR>',
  { noremap = true, silent = true, desc = 'Run Go program in split' })

-- Copilot Kontrolleri
vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', { noremap = true, silent = true, desc = 'Enable Copilot' })
vim.keymap.set('n', '<leader>cd', ':Copilot disable<CR>', { noremap = true, silent = true, desc = 'Disable Copilot' })
vim.keymap.set('n', '<leader>cs', ':Copilot status<CR>', { noremap = true, silent = true, desc = 'Copilot Status' })



-- =============================================================================
-- ÖZEL DOSYA TİPİ VE SYNTAX AYARLARI (TEMİZLENMİŞ VERSİYON)
-- =============================================================================

-- 1. .spec uzantısını Neovim'e düzgünce tanıt
vim.filetype.add({
  extension = {
    spec = "spec",
  },
})

-- 2. Renk Gruplarını Tanımla (Hangi renk ne olacak?)
local function set_spec_highlights()
  vim.api.nvim_set_hl(0, "myred", { fg = "#ff2b00", bold = true })
  vim.api.nvim_set_hl(0, "myyellow", { fg = "#FFBB00", bold = true })
  vim.api.nvim_set_hl(0, "mygreen", { fg = "#00FF6F", bold = true })
  vim.api.nvim_set_hl(0, "myblue", { fg = "#00EAFF", bold = true })
  vim.api.nvim_set_hl(0, "mypink", { fg = "#FF69B4", bold = true })
  vim.api.nvim_set_hl(0, "myotherblue", { fg = "#00FFFF", bold = true })
end

vim.api.nvim_create_autocmd({ "FileType", "ColorScheme" }, {
  pattern = "spec",
  callback = function()
    set_spec_highlights()

    vim.cmd([[syntax clear]])
    vim.cmd([[syntax case match]])

    -- Keywords (Mavi olanlar)
    vim.cmd([[syntax keyword myblue COUNT MAX MIN SELECT MIS FORALL SEARCH EXISTS SUM COPY DECISION EVERY FILTER]])

    -- Match Tanımları (Regex)
    vim.cmd([[
      " 'In:', 'Out:', 'Pre:', 'Post:' ve 'Fn:' kelimelerini (ve hemen ardından gelen : işaretini) boyar
      syntax match myred /\<\(In\|Out\|Pre\|Post\|Fn\)\s*:/

      " Kümeler/Tipler (N, Z, L, R)
      syntax match myyellow /\<\(N\|Z\|L\|R\|S\)\>/

      " Mantıksal operatörler
      syntax match mygreen /\<\(and\|or\)\>/

      " Parantezler
      syntax match mypink /[()]/

      " Eşittir işareti
      syntax match myotherblue /=/
    ]])
  end,
})


require("oil").setup({

  -- Open Oil for the current file's directory using the '-' key
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
  -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
  default_file_explorer = true,
  -- Id is automatically added at the beginning, and name at the end
  -- See :help oil-columns
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  -- Buffer-local options to use for oil buffers
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },
  -- Window-local options to use for oil buffers
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },
  -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
  delete_to_trash = false,
  -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
  skip_confirm_for_simple_edits = false,
  -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
  -- (:help prompt_save_on_select_new_entry)
  prompt_save_on_select_new_entry = true,
  -- Oil will automatically delete hidden buffers after this delay
  -- You can set the delay to false to disable cleanup entirely
  -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
  cleanup_delay_ms = 2000,
  lsp_file_methods = {
    -- Enable or disable LSP file operations
    enabled = true,
    -- Time to wait for LSP file operations to complete before skipping
    timeout_ms = 1000,
    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    autosave_changes = false,
  },
  -- Constrain the cursor to the editable parts of the oil buffer
  -- Set to `false` to disable, or "name" to keep it on the file names
  constrain_cursor = "editable",
  -- Set to true to watch the filesystem for changes and reload oil
  watch_for_changes = false,
  -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("oil.actions").<name>
  -- Set to `false` to remove a keymap
  -- See :help oil-actions for a list of all available actions
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = false,
    -- This function defines what is considered a "hidden" file
    is_hidden_file = function(name, bufnr)
      local m = name:match("^%.")
      return m ~= nil
    end,
    -- This function defines what will never be shown, even when `show_hidden` is set
    is_always_hidden = function(name, bufnr)
      return false
    end,
    -- Sort file names with numbers in a more intuitive order for humans.
    -- Can be "fast", true, or false. "fast" will turn it off for large directories.
    natural_order = "fast",
    -- Sort file and directory names case insensitive
    case_insensitive = false,
    sort = {
      -- sort order can be "asc" or "desc"
      -- see :help oil-columns to see which columns are sortable
      { "type", "asc" },
      { "name", "asc" },
    },
    -- Customize the highlight group for the file name
    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
      return nil
    end,
  },
  -- Extra arguments to pass to SCP when moving/copying files over SSH
  extra_scp_args = {},
  -- Extra arguments to pass to aws s3 when creating/deleting/moving/copying files using aws s3
  extra_s3_args = {},
  -- EXPERIMENTAL support for performing file operations with git
  git = {
    -- Return true to automatically git add/mv/rm files
    add = function(path)
      return false
    end,
    mv = function(src_path, dest_path)
      return false
    end,
    rm = function(path)
      return false
    end,
  },
  -- Configuration for the floating window in oil.open_float
  float = {
    -- Padding around the floating window
    padding = 2,
    -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    max_width = 0,
    max_height = 0,
    border = nil,
    win_options = {
      winblend = 0,
    },
    -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
    get_win_title = nil,
    -- preview_split: Split direction: "auto", "left", "right", "above", "below".
    preview_split = "auto",
    -- This is the config that will be passed to nvim_open_win.
    -- Change values here to customize the layout
    override = function(conf)
      return conf
    end,
  },
  -- Configuration for the file preview window
  preview_win = {
    -- Whether the preview window is automatically updated when the cursor is moved
    update_on_cursor_moved = true,
    -- How to open the preview window "load"|"scratch"|"fast_scratch"
    preview_method = "fast_scratch",
    -- A function that returns true to disable preview on a file e.g. to avoid lag
    disable_preview = function(filename)
      return false
    end,
    -- Window-local options to use for preview window buffers
    win_options = {},
  },
  -- Configuration for the floating action confirmation window
  confirmation = {
    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
    max_width = 0.9,
    -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
    min_width = { 40, 0.4 },
    -- optionally define an integer/float for the exact width of the preview window
    width = nil,
    -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a single value or a list of mixed integer/float types.
    -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
    max_height = 0.9,
    -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
    min_height = { 5, 0.1 },
    -- optionally define an integer/float for the exact height of the preview window
    height = nil,
    border = nil,
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating progress window
  progress = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = { 10, 0.9 },
    min_height = { 5, 0.1 },
    height = nil,
    border = nil,
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating SSH window
  ssh = {
    border = nil,
  },
  -- Configuration for the floating keymaps help window
  keymaps_help = {
    border = nil,
  },
})

vim.keymap.set("n", "m", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })

-- Matematik Sembolleri
vim.keymap.set('i', '<M-i>', '∈', { desc = 'Insert Element Of (∈)' })
vim.keymap.set('i', '<M-V>', '∀', { desc = 'Insert For All (∀)' })
vim.keymap.set('i', '<M-H>', '∃', { desc = 'Insert not For All (∃)' })
