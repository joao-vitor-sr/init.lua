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

require("lazy").setup({
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		event = "VeryLazy",
	},
	{
		"karb94/neoscroll.nvim",
		lazy = false,
		config = function()
			require("neoscroll").setup()
		end,
		event = "VeryLazy",
	},
	{
		"luisiacc/gruvbox-baby",
	},
    {
      'mbbill/undotree',
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
		},
      event = "VeryLazy",
    },
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
        cmd = "Neotree",
        init = function()
          vim.g.neo_tree_remove_legacy_commands = 1
          if vim.fn.argc() == 1 then
            local stat =  vim.loop.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
              require("neo-tree")
            end
          end
        end,
		keys = {
			{ "<leader>pv", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
	},
	{
		"nvim-treesitter/playground",
	},
	{
		"theprimeagen/harpoon",
		event = "BufEnter",
	},
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},
	{
		"tpope/vim-surround",
		event = "VeryLazy",
	},
	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		lazy = false,
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",

			-- Snippets
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",

			-- Formatter and lint
			"jose-elias-alvarez/null-ls.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
	},
})
