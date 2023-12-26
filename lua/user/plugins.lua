local fn = vim.fn

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install your plugins here
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  -- mini
  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  { "kyazdani42/nvim-web-devicons", lazy = true },
  { "lewis6991/impatient.nvim" },

  -- undotree
  {
    "mbbill/undotree",
    lazy = true,
    cmd = "UndotreeToggle",
  },

  -- whichkey
  {
    "folke/which-key.nvim",
    cmd = "WhichKey",
    event = "VeryLazy",
    config = function()
      require("user.whichkey")
    end,
  },

  -- Colorschemes
  {
    "luisiacc/gruvbox-baby",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme gruvbox-baby]])
    end,
  },

  -- Copilot
  { "zbirenbaum/copilot.lua" },

  -- Cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("user.none")
      -- Here is where you configure the autocompletion settings.
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require("cmp")
      local cmp_action = lsp_zero.cmp_action()
      local cmp_select = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        sources = {
          { name = "copilot" },
          { name = "nvim_lsp" },
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-f>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        }),
      })

      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
      require("copilot_cmp").setup()
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-nvim-lua",
    },
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = {
      "friendly-snippets",
    },
  },
  { "rafamadriz/friendly-snippets", lazy = true },

  -- LSP
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspInstall", "LspStart" },
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function()
      local lsp_zero_config = {
        call_servers = "global",
      }

      local lsp_zero = require("lsp-zero")
      lsp_zero.set_preferences(lsp_zero_config)
      lsp_zero.extend_lspconfig()

      lsp_zero.configure("lua_ls", {})
      lsp_zero.configure("phpactor", {})
      lsp_zero.configure("rust_analyzer", {})
      lsp_zero.configure("tsserver", {})
      lsp_zero.configure("texlab", {})
      lsp_zero.configure("pylsp", {})

      lsp_zero.on_attach(function(client, bufnr) end)
    end,
  },
  { "nvimtools/none-ls.nvim",        lazy = true },

  -- Telescope
  { "nvim-telescope/telescope.nvim", lazy = true, cmd = "Telescope" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "romgrk/nvim-treesitter-context",
    },
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost BufNewFile BufWritePre",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  -- harpoon
  { "ThePrimeagen/harpoon", lazy = true },

  -- tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
})
