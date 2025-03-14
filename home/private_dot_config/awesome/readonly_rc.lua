-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard
local io = { open = io.open }

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
--local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
--require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = gears.filesystem.get_configuration_dir() .. "image/bg.jpg"
beautiful.useless_gap = 3
beautiful.notification_max_height = 128

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default mod_key.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
mod_key = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
my_awesome_menu = {
    { "Hotkeys", function()
        hotkeys_popup.show_help(nil, awful.screen.focused())
    end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit Config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function()
        awesome.quit()
    end },
}

my_main_menu = awful.menu({
    items = {
        { "Awesome", my_awesome_menu, beautiful.awesome_icon },
        { "Open Terminal", terminal }
    }
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
end)
-- }}}

-- {{{ App auto start
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -x '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({
    "polybar",
    "unclutter",
    "nm-applet",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "system76-power profile performance",
    "system76-power charge-thresholds --profile max_lifespan",
	"xset s off -dpms",
})
-- }}}

-- {{{ Low battery notification
local function read_first_line(path)
    local file, first_line = io.open(path, "rb"), ""
    if file then
        first_line = file:read("*l")
        file:close()
    end
    return first_line
end

local lastBrightness = -1
local lowBatteryNotification = { id = -1 }

gears.timer {
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = function()
        local battery_charge = tonumber(read_first_line("/sys/class/power_supply/BAT0/capacity"))
        local battery_status = read_first_line("/sys/class/power_supply/BAT0/status")
        local battery_charging = battery_status == "Charging"

        if battery_charge <= 12 and not battery_charging then
            local notify = naughty.notify({
                text = "Critically low battery " .. battery_charge .. "%",
                timeout = 0,
                height = 24,
                position = "top_right",
                ontop = true,
                fg = "#FFFFFF",
                bg = "#ED2B2A",
                replaces_id = lowBatteryNotification.id > 0 and lowBatteryNotification.id or nil
            })
            lowBatteryNotification = notify

            if lastBrightness <= 0 then
                awful.spawn.easy_async("light -G", function(stdout)
                    lastBrightness = math.floor(tonumber(stdout))
                    if lastBrightness > 20 then
                        awful.spawn("light -S 20")
                    end
                end)
            end
        elseif battery_charge <= 20 and not battery_charging then
            local notify = naughty.notify({
                text = "Low battery " .. battery_charge .. "%",
                timeout = 0,
                height = 24,
                position = "top_right",
                ontop = true,
                replaces_id = lowBatteryNotification.id > 0 and lowBatteryNotification.id or nil
            })
            lowBatteryNotification = notify
        else
            if lowBatteryNotification.id > 0 then
                naughty.destroy(lowBatteryNotification)
                lowBatteryNotification.id = -1
            end

            if lastBrightness > 0 then
                awful.spawn("light -S " .. lastBrightness)
                lastBrightness = -1
            end
        end
    end
}
-- }}}

-- {{{ Mouse bindings on desktop
root.buttons(gears.table.join(
        awful.button({ }, 3, function()
            my_main_menu:toggle()
        end)
))
-- }}}

-- {{{ Key bindings
local lastBottomNotificationID = 0

function volumeUpdate()
    awful.spawn("ogg123 --quiet " .. gears.filesystem.get_configuration_dir() .. "sound/volume-change.oga")
    awful.spawn.easy_async("pamixer --get-volume-human", function(stdout)
        local notify = naughty.notify({
            text = "Volume " .. stdout,
            timeout = 3,
            height = 24,
            position = "bottom_middle",
            replaces_id = lastBottomNotificationID
        })
        lastBottomNotificationID = notify.id
    end)
end

function brightnessUpdate()
    awful.spawn.easy_async("light -G", function(stdout)
        local notify = naughty.notify({
            text = "Brightness " .. tostring(math.floor(tonumber(stdout))) .. "%",
            timeout = 3,
            height = 24,
            position = "bottom_middle",
            replaces_id = lastBottomNotificationID
        })
        lastBottomNotificationID = notify.id
    end)
end

globalkeys = gears.table.join(
        awful.key({ mod_key, }, "s", hotkeys_popup.show_help,
                { description = "show help", group = "awesome" }),
        awful.key({ mod_key, }, "Left", awful.tag.viewprev,
                { description = "view previous", group = "tag" }),
        awful.key({ mod_key, }, "Right", awful.tag.viewnext,
                { description = "view next", group = "tag" }),
        awful.key({ mod_key, }, "Escape", awful.tag.history.restore,
                { description = "go back", group = "tag" }),

        awful.key({ mod_key, }, "j",
                function()
                    awful.client.focus.byidx(1)
                end,
                { description = "focus next by index", group = "client" }
        ),
        awful.key({ mod_key, }, "k",
                function()
                    awful.client.focus.byidx(-1)
                end,
                { description = "focus previous by index", group = "client" }
        ),
        awful.key({ mod_key, }, "w", function()
            my_main_menu:show()
        end,
                { description = "show main menu", group = "awesome" }),

-- Layout manipulation
        awful.key({ mod_key, "Shift" }, "j", function()
            awful.client.swap.byidx(1)
        end,
                { description = "swap with next client by index", group = "client" }),
        awful.key({ mod_key, "Shift" }, "k", function()
            awful.client.swap.byidx(-1)
        end,
                { description = "swap with previous client by index", group = "client" }),
        awful.key({ mod_key, "Control" }, "j", function()
            awful.screen.focus_relative(1)
        end,
                { description = "focus the next screen", group = "screen" }),
        awful.key({ mod_key, "Control" }, "k", function()
            awful.screen.focus_relative(-1)
        end,
                { description = "focus the previous screen", group = "screen" }),
        awful.key({ mod_key, }, "u", awful.client.urgent.jumpto,
                { description = "jump to urgent client", group = "client" }),
        awful.key({ mod_key, }, "Tab",
                function()
                    awful.client.focus.history.previous()
                    if client.focus then
                        client.focus:raise()
                    end
                end,
                { description = "go back", group = "client" }),

-- Standard program
        awful.key({ mod_key, }, "Return", function()
            awful.spawn(terminal)
        end,
                { description = "open a terminal", group = "launcher" }),
        awful.key({ mod_key, "Control" }, "r", awesome.restart,
                { description = "reload awesome", group = "awesome" }),
        awful.key({ mod_key, "Shift" }, "q", awesome.quit,
                { description = "quit awesome", group = "awesome" }),
        awful.key({ }, "Print", function()
            awful.spawn("flameshot gui")
        end,
                { description = "open a terminal", group = "launcher" }),

        awful.key({ mod_key, }, "l", function()
            awful.tag.incmwfact(0.05)
        end,
                { description = "increase master width factor", group = "layout" }),
        awful.key({ mod_key, }, "h", function()
            awful.tag.incmwfact(-0.05)
        end,
                { description = "decrease master width factor", group = "layout" }),
        awful.key({ mod_key, "Shift" }, "h", function()
            awful.tag.incnmaster(1, nil, true)
        end,
                { description = "increase the number of master clients", group = "layout" }),
        awful.key({ mod_key, "Shift" }, "l", function()
            awful.tag.incnmaster(-1, nil, true)
        end,
                { description = "decrease the number of master clients", group = "layout" }),
        awful.key({ mod_key, "Control" }, "h", function()
            awful.tag.incncol(1, nil, true)
        end,
                { description = "increase the number of columns", group = "layout" }),
        awful.key({ mod_key, "Control" }, "l", function()
            awful.tag.incncol(-1, nil, true)
        end,
                { description = "decrease the number of columns", group = "layout" }),
        awful.key({ mod_key, }, "space", function()
            awful.layout.inc(1)
        end,
                { description = "select next", group = "layout" }),
        awful.key({ mod_key, "Shift" }, "space", function()
            awful.layout.inc(-1)
        end,
                { description = "select previous", group = "layout" }),

        awful.key({ mod_key, "Control" }, "n",
                function()
                    local c = awful.client.restore()
                    -- Focus restored client
                    if c then
                        c:emit_signal(
                                "request::activate", "key.unminimize", { raise = true }
                        )
                    end
                end,
                { description = "restore minimized", group = "client" }),

-- Prompt
        awful.key({ mod_key }, "r", function()
            awful.screen.focused().my_prompt_box:run()
        end,
                { description = "run prompt", group = "launcher" }),

        awful.key({ mod_key }, "x",
                function()
                    awful.prompt.run {
                        prompt = "Run Lua code: ",
                        textbox = awful.screen.focused().my_prompt_box.widget,
                        exe_callback = awful.util.eval,
                        history_path = awful.util.get_cache_dir() .. "/history_eval"
                    }
                end,
                { description = "lua execute prompt", group = "awesome" }),
-- Menubar
        awful.key({ mod_key }, "p", function()
            --menubar.show()
            awful.spawn("rofi -show drun")
        end,
                { description = "show the menubar", group = "launcher" }),

-- Lock screen
        awful.key({ mod_key, "Shift" }, "l", function()
            awful.spawn("dm-tool lock")
        end,
                { description = "lock screen", group = "system" }),

-- Volume
        awful.key({ }, "XF86AudioLowerVolume", function()
            awful.spawn("pamixer --decrease 2")
            volumeUpdate()
        end,
                { description = "decrease volume", group = "controls" }),

        awful.key({ }, "XF86AudioRaiseVolume", function()
            awful.spawn("pamixer --increase 2")
            volumeUpdate()
        end,
                { description = "increase volume", group = "controls" }),

        awful.key({ }, "XF86AudioMute", function()
            awful.spawn("pamixer --toggle-mute")
            volumeUpdate()
        end,
                { description = "mute volume", group = "controls" }),

-- Brightness
        awful.key({ }, "XF86MonBrightnessDown", function()
            awful.spawn("light -U 2")
            brightnessUpdate()
        end,
                { description = "decrease brightness", group = "controls" }),

        awful.key({ }, "XF86MonBrightnessUp", function()
            awful.spawn("light -A 2")
            brightnessUpdate()
        end,
                { description = "increase brightness", group = "controls" })
)

clientkeys = gears.table.join(
        awful.key({ mod_key, }, "f",
                function(c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end,
                { description = "toggle fullscreen", group = "client" }),
        awful.key({ mod_key, "Shift" }, "c", function(c)
            c:kill()
        end,
                { description = "close", group = "client" }),
        awful.key({ mod_key, "Control" }, "space", awful.client.floating.toggle,
                { description = "toggle floating", group = "client" }),
        awful.key({ mod_key, "Control" }, "Return", function(c)
            c:swap(awful.client.getmaster())
        end,
                { description = "move to master", group = "client" }),
        awful.key({ mod_key, }, "o", function(c)
            c:move_to_screen()
        end,
                { description = "move to screen", group = "client" }),
        awful.key({ mod_key, }, "t", function(c)
            c.ontop = not c.ontop
        end,
                { description = "toggle keep on top", group = "client" }),
        awful.key({ mod_key, }, "n",
                function(c)
                    -- The client currently has the input focus, so it cannot be
                    -- minimized, since minimized clients can't have the focus.
                    c.minimized = true
                end,
                { description = "minimize", group = "client" }),
        awful.key({ mod_key, }, "m",
                function(c)
                    c.maximized = not c.maximized
                    c:raise()
                end,
                { description = "(un)maximize", group = "client" }),
        awful.key({ mod_key, "Control" }, "m",
                function(c)
                    c.maximized_vertical = not c.maximized_vertical
                    c:raise()
                end,
                { description = "(un)maximize vertically", group = "client" }),
        awful.key({ mod_key, "Shift" }, "m",
                function(c)
                    c.maximized_horizontal = not c.maximized_horizontal
                    c:raise()
                end,
                { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
    globalkeys = gears.table.join(globalkeys,
    -- View tag only.
            awful.key({ mod_key }, "#" .. i + 9,
                    function()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                            tag:view_only()
                        end
                    end,
                    { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
            awful.key({ mod_key, "Control" }, "#" .. i + 9,
                    function()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                            awful.tag.viewtoggle(tag)
                        end
                    end,
                    { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
            awful.key({ mod_key, "Shift" }, "#" .. i + 9,
                    function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then
                                client.focus:move_to_tag(tag)
                            end
                        end
                    end,
                    { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
            awful.key({ mod_key, "Control", "Shift" }, "#" .. i + 9,
                    function()
                        if client.focus then
                            local tag = client.focus.screen.tags[i]
                            if tag then
                                client.focus:toggle_tag(tag)
                            end
                        end
                    end,
                    { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
        awful.button({ }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ mod_key }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ mod_key }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA", -- Firefox addon DownThemAll.
            "copyq", -- Includes session name in class.
            "pinentry",
        },
        class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin", -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer" },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
            "Event Tester", -- xev.
        },
        role = {
            "AlarmWindow", -- Thunderbird's calendar.
            "ConfigManager", -- Thunderbird's about:config.
            "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true } },

    -- Add titlebars to normal clients and dialogs
    { rule_any = { type = { "normal", "dialog" }
    }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}
