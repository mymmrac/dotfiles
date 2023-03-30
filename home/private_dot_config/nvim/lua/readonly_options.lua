local g = vim.g
local o = vim.o
local A = vim.api

-- Leave N lines on top and bottom when scrolling
o.scrolloff = 8

-- Enable numbers & relative numbers
o.number = true
o.numberwidth = 2
o.relativenumber = true

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

-- Spell check
o.spell = true
o.spelllang = "en_us,uk"

-- Set theme flavor
g.catppuccin_flavour = "mocha"

-- Highlight the region on yank
A.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 120 })
	end,
})

-- Set spellchecker theme
A.nvim_set_hl(0, "SpellBad", { underdashed = true, sp = "#f38ba8" })
