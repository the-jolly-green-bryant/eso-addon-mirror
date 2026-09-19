BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.UI = BGMeter.UI or {}

local U = BGMeter.UI._win
local K = BGMeter.Constants
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Drawer = BGMeter.UI.Drawer
local TX = U.TX
local set_text = U.set_text
local hexc = F.hexc

local D = Drawer.new({
    key = "saved",
    index = 2,
    bottom = true,
    title = "Saved matches",
    icon = TX.saved.n,
    icon_down = TX.saved.p,
    icon_over = TX.saved.o,
    drag_name = "BGMeterSavedDrag",
    cache_key = function(self)
        local first = BGMeter.History.get(1)
        return tostring(BGMeter.History.count()) .. "|" .. tostring(BGMeter.History.pinned_count()) .. "|" .. tostring(first and first.capturedAt or 0)
    end,
    fetch = function(self) return BGMeter.History.pinned() end,
    row_make = function(self, r)
        r.pip = P.rect(r.container, K.COLOR.text_dim)
        r.pip:SetDimensions(3, Drawer.row_h() - 10)
        r.pip:SetAnchor(LEFT, r.container, LEFT, 3, 0)
        r.name:ClearAnchors()
        r.name:SetAnchor(LEFT, r.container, LEFT, 12, 0)
        r.name:SetAnchor(RIGHT, r.container, RIGHT, -78, 0)
        r.count:SetDimensions(72, Drawer.row_h())
        if r.count.SetFont then r.count:SetFont(S.FONT.small) end
    end,
    row_fill = function(self, r, e)
        local m = e.m
        P.set_rect_color(r.pip, U.result_color(m.result))
        set_text(r.name, m.name or "Battleground")
        set_text(r.count, string.format("|c%s%s|r", hexc(K.COLOR.text_dim), U.mode_tag(m)))
    end,
    describe = function(self, e)
        local m = e.m
        local lr = BGMeter.Match.local_row(m)
        local lines = { string.format("%s  ·  |c%s%s|r", m.name or "Battleground", hexc(U.result_color(m.result)), m.result or "") }
        if m.teams and #m.teams >= 2 then
            lines[#lines + 1] = string.format("%d - %d  ·  %s", m.teams[1].score or 0, m.teams[2].score or 0, U.mode_tag(m))
        end
        if lr then
            lines[#lines + 1] = string.format("you  %d/%d/%d  ·  %s dmg  ·  %s heal",
                lr.kills or 0, lr.deaths or 0, lr.assists or 0, F.abbrev(lr.damage or 0), F.abbrev(lr.healing or 0))
        end
        local when = F.ago(m.capturedAt)
        lines[#lines + 1] = (BGMeter.History.has_detail(m) and "charts kept" or "scoreboard only") .. (when and ("  ·  " .. when) or "")
        lines[#lines + 1] = "click to open  ·  unlock it in the Registry to release"
        return table.concat(lines, "\n")
    end,
    on_click = function(self, e)
        local idx = BGMeter.History.index_of(e.m)
        if idx and BGMeter.UI.window then
            BGMeter.UI.window.show_match(idx)
            BGMeter.Sound.play("page")
        end
    end,
    foot = function(self, list)
        local cap = BGMeter.History.PIN_CAP
        if #list == 0 then return string.format("nothing saved yet  ·  lock a match in the Registry (up to %d)", cap) end
        return string.format("%d of %d saved  ·  never pruned", #list, cap)
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

BGMeter.UI.saved = M
