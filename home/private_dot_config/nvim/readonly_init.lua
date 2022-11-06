local g = vim.g
local o = vim.o
local A = vim.api

-- Leave N lines on top and bottom when scrolling
o.scrolloff = 8

-- Enable numbers & relative numbers
o.number = true
o.numberwidth = 2
o.relativenumber = true

-- Show sign column always
-- o.signcolumn = "yes"

-- Highlihgt current line
-- o.cursorline = true

-- Make all tabs be a spaces
o.expandtab = false
o.smarttab = true
o.cindent = true
o.autoindent = true
o.wrap = true
o.textwidth = 120
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = -1

-- Add special chars for invisible symbols
o.list = true
o.listchars = "tab:  ,trail:·,nbsp:◇,extends:▸,precedes:◂"

-- Sync nvim & OS clipboards
o.clipboard = "unnamedplus"

-- Case insensitive search unless capital used
o.ignorecase = true
o.smartcase = true

-- Backup only on write & enable undo & swap file
o.backup = false
o.writebackup = true
o.undofile = true
o.swapfile = true

-- History size
o.history = 128

-- Split buffers to right and bottom
o.splitright = true
o.splitbelow = true

-- Disable mode change message
o.showmode = false

-- Highlight the region on yank
A.nvim_create_autocmd("TextYankPost", {
	-- group = num_au,
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 120 })
	end,
})

-- Spell check
o.spell = true
o.spelllang = "en_us,uk"
A.nvim_set_hl(0, "SpellBad", { underdashed = true, sp = "#f38ba8" })

-- Map <leader> to space
g.mapleader = " "
g.maplocalleader = " "

-- Set keybinding `k` for mode `m` and do `v`
local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

-- Keybindings for telescope
map("n", "<leader>fr", "<CMD>Telescope oldfiles<CR>")
map("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
map("n", "<leader>fb", "<CMD>Telescope file_browser<CR>")
map("n", "<leader>fw", "<CMD>Telescope live_grep<CR>")

-- Clear highlighting
map("n", "<leader>h", "<CMD>nohlsearch<CR>")

-- New file
map("n", "<leader>fn", "<CMD>DashboardNewFile<CR>")

-- Move to previous/next buffer
map("n", "<A-,>", "<Cmd>BufferPrevious<CR>")
map("n", "<A-.>", "<Cmd>BufferNext<CR>")

-- Goto buffer in position...
for i = 1, 9 do
	map("n", "<A-" .. i .. ">", "<Cmd>BufferGoto " .. i .. "<CR>")
end

-- Close buffer
map("n", "<A-c>", "<Cmd>BufferClose<CR>")

-- Plugins
require("packer").startup(function(use)
	-- Packer can manage itself
	use "wbthomason/packer.nvim"

	-- Telescope and related plugins
	use {
		"nvim-telescope/telescope.nvim", tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } }
	}
	use "nvim-telescope/telescope-file-browser.nvim"

	-- Smoth scroll
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

	-- One Dark theme
	-- use "navarasu/onedark.nvim"
	-- require("onedark").setup {
	-- 	style = "darker"
	-- }
	-- require("onedark").load()

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
	-- TODO: Remove manual configs & plugins (follow https://github.com/ray-x/navigator.lua#install)
	use "ray-x/navigator.lua"
end)


require("telescope").load_extension "file_browser"
require("telescope").setup({
	defaults = {
		prompt_prefix = " ",
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
g.catppuccin_flavour = "mocha"
vim.cmd [[colorscheme catppuccin]]

require("Comment").setup()

require("bufferline").setup()

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Setup nvim-lspconfig
local lspconfig = require("lspconfig")

local servers = { "gopls", "clangd", "pyright" }
for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup {
		capabilities = capabilities,
	}
end

require("go").setup()
require("go.format").goimport()

lspconfig["sumneko_lua"].setup {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

-- Setup luasnip
local luasnip = require "luasnip"

-- Setup nvim-cmp
local cmp = require "cmp"
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

-- Dashboard config
local db = require("dashboard")

db.hide_statusline = true
db.hide_tabline = true

db.custom_header = {
	"",
	"",
	" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
	" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
	" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
	" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
	" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
	" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
	"",
	" [ TIP: To exit Neovim, just power off your computer. ] ",
	"",
}

db.custom_center = {
	{
		icon = "  ",
		desc = "New file                                ",
		action = "DashboardNewFile",
		shortcut = "spc f n",
	},
	{
		icon = "  ",
		desc = "Find recent files                       ",
		action = "Telescope oldfiles",
		shortcut = "spc f r",
	},
	{
		icon = "  ",
		desc = "Find files                              ",
		action = "Telescope find_files find_command=rg,--hidden,--files",
		shortcut = "spc f f",
	},
	{
		icon = "  ",
		desc = "File browser                            ",
		action = "Telescope file_browser",
		shortcut = "spc f b",
	},
	{
		icon = "﬍  ",
		desc = "Find word                               ",
		action = "Telescope live_grep",
		shortcut = "spc f w",
	},
}

db.custom_footer = {
	"",
	"Hmmm, something goes here...",
	"",
}
