BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.UI = BGMeter.UI or {}

local U = BGMeter.UI._win
local K = BGMeter.Constants
local P = BGMeter.Plot.primitives
local Drawer = BGMeter.UI.Drawer
local set_text = U.set_text
local hexc = Drawer.hexc

local function lean_color(e)
    local lean = BGMeter.Faces.lean(e)
    if lean == "with" then return K.COLOR.face_with end
    if lean == "against" then return K.COLOR.face_vs end
    return K.COLOR.face_mixed
end

local D = Drawer.new({
    key = "faces",
    index = 3,
    title = "Familiar faces",
    icon = "EsoUI/Art/Help/help_tabIcon_emotes_up.dds",
    icon_down = "EsoUI/Art/Help/help_tabIcon_emotes_down.dds",
    icon_over = "EsoUI/Art/Help/help_tabIcon_emotes_over.dds",
    drag_name = "BGMeterFacesDrag",
    search = true,
    search_hint = "search a name",
    credit = "Feature credit goes to unit220",
    cache_key = function(self) return self:query() .. "|" .. tostring(BGMeter.Faces.count()) end,
    fetch = function(self) return BGMeter.Faces.list(self:query(), 400) end,
    row_make = function(self, r)
        r.pipW = P.rect(r.container, K.COLOR.face_with)
        r.pipW:SetWidth(3)
        r.pipW:SetAnchor(TOPLEFT, r.container, TOPLEFT, 3, 5)
        r.pipA = P.rect(r.container, K.COLOR.face_vs)
        r.pipA:SetWidth(3)
        r.pipA:SetAnchor(BOTTOMLEFT, r.container, BOTTOMLEFT, 3, -5)
    end,
    row_fill = function(self, r, e)
        local c = lean_color(e)
        local span = Drawer.row_h() - 10
        local wh = math.floor(span * e.w / math.max(1, e.w + e.a) + 0.5)
        r.pipW:SetHeight(wh)
        r.pipW:SetHidden(wh <= 0)
        r.pipA:SetHeight(span - wh)
        r.pipA:SetHidden(span - wh <= 0)
        local nm = e.name
        if e.chr and e.chr ~= "" and e.chr ~= e.name then nm = nm .. "  |c" .. hexc(K.COLOR.text_dim) .. e.chr .. "|r" end
        set_text(r.name, nm)
        set_text(r.count, string.format("|c%s×%d|r", hexc(c), e.w + e.a))
    end,
    describe = function(self, e) return BGMeter.Faces.describe(e) end,
    foot = function(self, list)
        local known = BGMeter.Faces.count()
        if #list == 0 then return known == 0 and "no one yet  ·  faces fill in as you play" or "no match" end
        return string.format("%d known  ·  green with you, red against", known)
    end,
})

local M = {}
function M.invalidate() D:invalidate() end
function M.refresh() D:refresh() end
function M.scroll(delta) D:scroll(delta) end
function M.scroll_to(want) D:scroll_to(want) end
function M.on_track_click() D:on_track_click() end
function M.on_thumb_down() D:on_thumb_down() end
function M.on_thumb_up() D:on_thumb_up() end
function M.drag_active() return D:drag_active() end
function M.on_host_resized() D:on_host_resized() end
function M.is_open() return D:is_open() end
function M.toggle() D:toggle() end
function M.set_query(text) D:set_query(text) end
function M.query() return D:query() end
function M.on_menu_shown() D:on_menu_shown() end
function M.init(pw) D:init(pw) end
function M.controls() return D:controls() end
M.drawer = D

BGMeter.UI.faces = M
