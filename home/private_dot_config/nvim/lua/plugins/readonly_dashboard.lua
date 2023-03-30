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
	"  [ TIP: To exit Neovim, just power off your computer. ] ",
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
