local g = vim.g

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
