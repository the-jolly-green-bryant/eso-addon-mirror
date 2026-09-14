BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.UI = BGMeter.UI or {}

local U = BGMeter.UI._win
local K = BGMeter.Constants
local F = BGMeter.Format
local Drawer = BGMeter.UI.Drawer
local set_text = U.set_text
local hexc = Drawer.hexc

local LABEL = {
    damage = "Most damage", healing = "Most healing", kills = "Most kills",
    assists = "Most assists", ap = "Most AP in a match", streak = "Longest win streak",
}
local MODE_LABEL = {
    deathmatch = "Deathmatch", domination = "Domination", crazy_king = "Crazy King",
    capture_the_flag = "Capture the Relic", murderball = "Chaosball", king_of_the_hill = "King of the Hill",
}

local function fmt(e)
    if e.key == "streak" then return string.format("%d in a row", e.v) end
    if e.key == "kills" or e.key == "assists" then return tostring(e.v) end
    return F.abbrev(e.v)
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
    key = "marks",
    index = 1,
    title = "Marks",
    icon = "EsoUI/Art/Journal/journal_tabIcon_achievements_up.dds",
    icon_down = "EsoUI/Art/Journal/journal_tabIcon_achievements_down.dds",
    icon_over = "EsoUI/Art/Journal/journal_tabIcon_achievements_over.dds",
    drag_name = "BGMeterMarksDrag",
    cache_key = function(self) return tostring(BGMeter.History.count()) .. "|" .. tostring(BGMeter.Ledger.streak()) end,
    fetch = function(self) return BGMeter.Ledger.marks() end,
    row_make = function(self, r)
        r.name:ClearAnchors()
        r.name:SetAnchor(LEFT, r.container, LEFT, 10, 0)
        r.name:SetAnchor(RIGHT, r.container, RIGHT, -80, 0)
        r.count:SetDimensions(72, Drawer.row_h())
    end,
    row_fill = function(self, r, e)
        set_text(r.name, LABEL[e.key] or e.key)
        set_text(r.count, string.format("|c%s%s|r", hexc(K.COLOR.gold), fmt(e)))
    end,
    describe = function(self, e)
        local lines = { string.format("%s  ·  |c%s%s|r", LABEL[e.key] or e.key, hexc(K.COLOR.gold), fmt(e)) }
        local where = {}
        if e.arena and e.arena ~= "" then where[#where + 1] = e.arena end
        if e.mode and MODE_LABEL[e.mode] then where[#where + 1] = MODE_LABEL[e.mode] end
        local when = ago(e.at)
        if when then where[#where + 1] = when end
        if #where > 0 then lines[#lines + 1] = table.concat(where, "  ·  ") end
        lines[#lines + 1] = BGMeter.Ledger.find_match(e.at) and "click to open that match" or "that match has left the registry"
        return table.concat(lines, "\n")
    end,
    on_click = function(self, e)
        local idx = BGMeter.Ledger.find_match(e.at)
        if idx and BGMeter.UI.window then
            BGMeter.UI.window.show_match(idx)
            BGMeter.Sound.play("page")
        else
            BGMeter.Sound.play("deny")
        end
    end,
    foot = function(self, list)
        if #list == 0 then return "no marks yet  ·  play a battleground" end
        local streak = BGMeter.Ledger.streak()
        return (streak > 0) and string.format("current streak  %d", streak) or "click a mark to open its match"
    end,
})

local M = {}
function M.invalidate() D:invalidate() end
function M.refresh() D:refresh() end
function M.is_open() return D:is_open() end
function M.toggle() D:toggle() end
function M.on_host_resized() D:on_host_resized() end
function M.on_menu_shown() D:on_menu_shown() end
function M.init(pw) D:init(pw) end
function M.controls() return D:controls() end
M.drawer = D

BGMeter.UI.marks = M
