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

  -- VIMTEX (LaTeX Derleme ve Görüntüleme)
  {
    "lervag/vimtex",
    lazy = false, -- VimTeX lazy-load edilmemeli, dosya türü algılaması için şart.
    init = function()
      -- VimTeX ayarları buraya taşındı (Modülerlik için)
      vim.g.vimtex_view_method = 'zathura' -- Linux/WSL için en iyisi
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_quickfix_mode = 0       -- Hata penceresini otomatik açma, rahatsız edici olabilir

      -- PDF görüntüleyici ile ters arama (Ctrl+Click) için ayarlar
      -- Zathura kullanıyorsan xdotool gerekebilir: sudo apt install xdotool
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
          "vue", "svelte", "go", "c_sharp", "gdscript",
          "glsl", "godot_resource", "latex", "bibtex", "bash" -- LaTeX parserları eklendi
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "svelte", "latex" }, -- LaTeX için regex gerekli olabilir
        },
        indent = { enable = true },
      })
    end,
  },

  -- Catppuccin Tema
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        transparent_background = true, -- Opak arka plan daha iyi kontrast sağlar
        show_end_of_buffer = false,
        compile = {
          enable = false,
        },
        term_colors = true,
        styles = {
          comments = { "italic" },
          keywords = { "bold" },
        },
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
      vim.cmd.colorscheme "catppuccin"
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
        -- Basic Keywords
        s("MAX", { t("MAX") }),
        s("MIN", { t("MIN") }),
        s("SEARCH", { t("SEARCH") }),

        -- Smart Keywords with Tab-stops (the "LSP" feel)
        -- After expanding, hit Tab to jump to the cursor positions
        s("In:", { t("In: "), i(1, "input_variables") }),
        s("Out:", { t("Out: "), i(1, "output_variables") }),
        s("Pre:", { t("Pre: "), i(1, "condition") }),
        s("Post:", { t("Post: "), i(1, "condition") }),
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
          "svelte", "gopls", "texlab", "bashls",
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
                  runtime = {
                    version = 'LuaJIT',
                  },
                  diagnostics = {
                    globals = { 'love', 'vim' },
                  },
                  workspace = {
                    library = vim.list_extend(defaultLibs, { loveApiPath }),
                    checkThirdParty = false,
                  },
                  telemetry = {
                    enable = false,
                  },
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
          -- Özel Handlerlar (Aynı kaldı)
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
          ["texlab"] = function() -- LaTeX özel ayarı
            require("lspconfig").texlab.setup {
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
              on_attach = lsp_on_attach,
              settings = {
                texlab = {
                  build = {
                    onSave = true, -- Kaydederken build (VimTeX zaten yapıyor, burası opsiyonel)
                  },
                  chktex = {
                    onOpenAndSave = true, -- Linter
                    onEdit = false,
                  },
                }
              }
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
      require("lualine").setup { options = { theme = "catppuccin" } }
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
          tex = { "latexindent" }, -- LaTeX formatlayıcı eklendi (Perl gerektirir)
        },
        formatters = {
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

  -- Java DAP
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "java" },
    config = function()
      require('jdtls').setup_dap({ hotcodereplace = 'auto' })
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
      vim.keymap.set("n", "<space>th", function()
        builtin.colorscheme({ enable_preview = true })
      end, { desc = "Temaları Canlı Önizle" })
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
})

-- =============================================================================
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
    vim.fn.matchadd("myyellow", "N")
    vim.fn.matchadd("myyellow", "Z")
    vim.fn.matchadd("myyellow", "L")
    vim.fn.matchadd("myyellow", "R")
    vim.fn.matchadd("mygreen", "and")
    vim.fn.matchadd("myblue", "COUNT")
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



-- Renk highlight'ları
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "myred", { fg = "#ff2b00", bold = true })
    vim.api.nvim_set_hl(0, "myyellow", { fg = "#FFBB00", bold = true })
    vim.api.nvim_set_hl(0, "mygreen", { fg = "#00FF6F", bold = true })
    vim.api.nvim_set_hl(0, "myblue", { fg = "#00EAFF", bold = true })
    vim.api.nvim_set_hl(0, "mypink", { fg = "#FF69B4", bold = true })
    vim.api.nvim_set_hl(0, "myotherblue", { fg = "#00FFFF", bold = true })
  end,
})

vim.api.nvim_set_hl(0, "myotherblue", { fg = "#00FFFF", bold = true })
vim.api.nvim_set_hl(0, "mypink", { fg = "#FF69B4", bold = true })
vim.api.nvim_set_hl(0, "myblue", { fg = "#00EAFF", bold = true })
vim.api.nvim_set_hl(0, "myred", { fg = "#ff2b00", bold = true })
vim.api.nvim_set_hl(0, "myyellow", { fg = "#FFBB00", bold = true })
vim.api.nvim_set_hl(0, "mygreen", { fg = "#00FF6F", bold = true })
vim.filetype.add({
  extension = { myext = "spec" },
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "spec",
  callback = function()
    vim.cmd([[
      syntax match myred /\<\(In\|Out\|Post\|Pre\):/
      syntax match myyellow /\<\(N\|Z\|L\|R\|S\)\>/
      syntax match mygreen /\<\(and\|or\)\>/
      syntax match myblue /\<COUNT\|MAX\|MIN\>/
      syntax match mypink /[()]/
      syntax match myotherblue /=/
    ]])
  end,
})

-- Matematik Sembolleri
vim.keymap.set('i', '<M-i>', '∈', { desc = 'Insert Element Of (∈)' })
vim.keymap.set('i', '<M-V>', '∀', { desc = 'Insert For All (∀)' })
vim.keymap.set('i', '<M-H>', '∃', { desc = 'Insert not For All (∃)' })
