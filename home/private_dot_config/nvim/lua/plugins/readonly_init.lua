-- Plugins
require("packer").startup(function(use)
	-- Packer can manage itself
	use "wbthomason/packer.nvim"

	-- Telescope and related plugins
	use {
		"nvim-telescope/telescope.nvim", tag = "0.1.8",
		requires = { { "nvim-lua/plenary.nvim" } }
	}
	use "nvim-telescope/telescope-file-browser.nvim"

	-- Smooth scroll
	use "karb94/neoscroll.nvim"

	-- Dev icons
	use "kyazdani42/nvim-web-devicons"

	-- Dashboard
	use "glepnir/dashboard-nvim"

	-- Treesitter
	use "nvim-treesitter/nvim-treesitter"

	-- Auto pairs
	use "windwp/nvim-autopairs"

	-- Status line
	use {
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true }
	}

	-- Catppuccin theme
	use { "catppuccin/nvim", as = "catppuccin" }

	-- LSP
	use "neovim/nvim-lspconfig"

	-- Go
	use "ray-x/go.nvim"
	use "ray-x/guihua.lua"

	-- Autocompletion
	use "hrsh7th/nvim-cmp"
	use "hrsh7th/cmp-nvim-lsp"

	-- Snippets
	use "saadparwaiz1/cmp_luasnip"
	use "L3MON4D3/LuaSnip"

	-- Comments
	use "numToStr/Comment.nvim"

	-- Tabs
	use {
		"romgrk/barbar.nvim",
		requires = { "kyazdani42/nvim-web-devicons" }
	}

	-- LSP navigation
	use "ray-x/navigator.lua"
end)

require("plugins.dashboard")

require("telescope").load_extension "file_browser"
require("telescope").setup({
	defaults = {
		prompt_prefix = "  ",
		selection_caret = "❯ ",
		path_display = { "truncate" },
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		layout_config = {
			prompt_position = "top",
		},
	},
})

require("neoscroll").setup()

require("nvim-web-devicons").setup({
	default = true,
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "go", "gomod", "bash", "fish", "nix", "markdown", "python" },

	highlight = {
		enable = true,
	},
})

require("nvim-autopairs").setup({
	check_ts = true,
	disable_filetype = { "TelescopePrompt", "guihua" },
})

require("lualine").setup({
	options = {
		-- theme = "onedark",
		theme = "catppuccin",
	},
})

require("catppuccin").setup({
	integrations = {
		telescope = true,
		treesitter = true,
		dashboard = true,
	},
})
vim.cmd [[colorscheme catppuccin]]

require("Comment").setup()

-- Setup is automatic
-- require("barbar").setup()

-- Add additional capabilities supported by nvim-cmp
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Setup nvim-lspconfig
-- local lspconfig = require("lspconfig")

-- local servers = { "gopls", "clangd", "pyright" }
-- for _, lsp in ipairs(servers) do
-- 	lspconfig[lsp].setup {
-- 		capabilities = capabilities,
-- 	}
-- end

require("go").setup()
require("go.format").goimport()

-- lspconfig["sumneko_lua"].setup {
-- 	capabilities = capabilities,
-- 	settings = {
-- 		Lua = {
-- 			runtime = {
-- 				version = "LuaJIT",
-- 			},
-- 			diagnostics = {
-- 				globals = { "vim" },
-- 			},
-- 			workspace = {
-- 				library = vim.api.nvim_get_runtime_file("", true),
-- 			},
-- 			telemetry = {
-- 				enable = false,
-- 			},
-- 		},
-- 	},
-- }

-- Setup luasnip
local luasnip = require "luasnip"

-- Setup nvim-cmp
local cmp = require("cmp")
cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
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
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
}

-- LSP navigation
require("navigator").setup()

