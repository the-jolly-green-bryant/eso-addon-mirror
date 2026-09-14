BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.UI = BGMeter.UI or {}

local U = BGMeter.UI._win
local K = BGMeter.Constants
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Drawer = BGMeter.UI.Drawer
local set_text = U.set_text
local hexc = Drawer.hexc

local MODE_LABEL = {
    deathmatch = "Deathmatch", domination = "Domination", crazy_king = "Crazy King",
    capture_the_flag = "Capture the Relic", murderball = "Chaosball", king_of_the_hill = "King of the Hill",
    none = "Unknown", unknown = "Unknown",
}

local function pretty(e, mode)
    if mode == "modes" then return MODE_LABEL[e.name] or e.name end
    return e.name
end

local function win_color(win)
    if win >= 0.5 then return K.COLOR.face_with end
    if win > 0 then return K.COLOR.face_vs end
    return K.COLOR.text_dim
end

local function ago(ts)
    local A = BGMeter.zenimax.api
    local now = (type(A.get_timestamp) == "function") and A.get_timestamp() or nil
    if not ts or ts <= 0 or not now or now <= ts then return nil end
    local s = now - ts
    if s < 3600 then return math.floor(s / 60) .. " min ago" end
    if s < 86400 then return math.floor(s / 3600) .. " h ago" end
    return math.floor(s / 86400) .. " d ago"
end

local D = Drawer.new({
    key = "arenas",
    index = 2,
    title = "Arenas",
    icon = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds",
    icon_down = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_down.dds",
    icon_over = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_over.dds",
    drag_name = "BGMeterArenasDrag",
    modes = { { key = "maps", label = "MAPS" }, { key = "modes", label = "MODES" } },
    fetch = function(self)
        if self.mode == "modes" then return BGMeter.Ledger.modes() end
        return BGMeter.Ledger.arenas()
    end,
    row_make = function(self, r)
        r.name:ClearAnchors()
        r.name:SetAnchor(LEFT, r.container, LEFT, 10, 0)
        r.name:SetAnchor(RIGHT, r.container, RIGHT, -96, 0)
        r.win = P.label(r.container, S.FONT.small, K.COLOR.text)
        r.win:SetAnchor(RIGHT, r.container, RIGHT, -52, 0)
        r.win:SetDimensions(42, Drawer.row_h())
        r.win:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end,
    row_fill = function(self, r, e)
        set_text(r.name, pretty(e, self.mode))
        local wc = win_color(e.win)
        set_text(r.win, string.format("|c%s%d%%|r", hexc(wc), math.floor(e.win * 100 + 0.5)))
        set_text(r.count, string.format("|c%s×%d|r", hexc(K.COLOR.text_dim), e.n))
    end,
    describe = function(self, e)
        local g, b, gold = hexc(K.COLOR.face_with), hexc(K.COLOR.face_vs), hexc(K.COLOR.gold)
        local lines = {
            string.format("%s  ·  %d %s", pretty(e, self.mode), e.n, (e.n == 1) and "match" or "matches"),
            string.format("|c%s%d won|r  ·  |c%s%d lost|r%s", g, e.w, b, e.l, (e.t > 0) and string.format("  ·  %d tied", e.t) or ""),
            string.format("avg  %s dmg  ·  %s heal  ·  |c%s%.1f K|r / |c%s%.1f D|r", F.abbrev(e.avg_dmg), F.abbrev(e.avg_heal), g, e.avg_kills, b, e.avg_deaths),
        }
        if e.best > 0 then
            local when = ago(e.bestAt)
            lines[#lines + 1] = string.format("best  |c%s%s dmg|r%s", gold, F.abbrev(e.best), when and ("  ·  " .. when) or "")
            lines[#lines + 1] = BGMeter.Ledger.find_match(e.bestAt) and "click to open that match" or "that match has left the registry"
        end
        return table.concat(lines, "\n")
    end,
    on_click = function(self, e)
        local idx = BGMeter.Ledger.find_match(e.bestAt)
        if idx and BGMeter.UI.window then
            BGMeter.UI.window.show_match(idx)
            BGMeter.Sound.play("page")
        else
            BGMeter.Sound.play("deny")
        end
    end,
    foot = function(self, list)
        if #list == 0 then return "nothing yet  ·  arenas fill in as you play" end
        return (self.mode == "modes") and "win rate per game mode  ·  click for the best match" or "win rate per map  ·  click for the best match"
    end,
})

local M = {}
function M.invalidate() D:invalidate() end
function M.refresh() D:refresh() end
function M.scroll(delta) D:scroll(delta) end
function M.scroll_to(want) D:scroll_to(want) end
function M.is_open() return D:is_open() end
function M.toggle() D:toggle() end
function M.set_mode(mode) D:set_mode(mode) end
function M.mode() return D.mode end
function M.on_host_resized() D:on_host_resized() end
function M.on_menu_shown() D:on_menu_shown() end
function M.init(pw) D:init(pw) end
function M.controls() return D:controls() end
M.drawer = D

BGMeter.UI.arenas = M
