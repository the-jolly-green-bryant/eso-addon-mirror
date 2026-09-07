local ADDON_NAME = "NirnsteelUI"
local NS = ADDON_NAME .. "_Minimap"
Nirnsteel_UI = Nirnsteel_UI or {}
local Minimap = {}
Nirnsteel_UI.Minimap = Minimap
ZO_CreateStringId("SI_BINDING_NAME_NIRNSTEEL_MINIMAP_WAYPOINT", "Minimap: Place Waypoint at Cursor")
ZO_CreateStringId("SI_BINDING_CATEGORY_NIRNSTEEL_UI", "Nirnsteel UI")

local PI, TAU = math.pi, math.pi * 2
local UPDATE_MS, MAP_CHECK_MS = 33, 1000
local INSET, HEADER, FOOTER = 14, 30, 28
local ICONS = {
    player = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip_white.dds",
    group = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds",
    leader = "EsoUI/Art/Compass/groupLeader.dds",
    waypoint = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination_white.dds",
    quest = "EsoUI/Art/Compass/quest_icon.dds",
    wayshrine = "EsoUI/Art/ZoneStories/completiontypeicon_wayshrine.dds",
}
local RECT = { {0, 0}, {1, 0}, {1, 1}, {0, 1} }
local ARROW = { {0.5, 0}, {1, 1}, {0, 1} }
local CIRCLE = {}
for i = 0, 95 do
    local a = i * TAU / 96
    CIRCLE[#CIRCLE + 1] = { 0.5 + math.cos(a) * 0.5, 0.5 + math.sin(a) * 0.5 }
end

local function Settings() return Nirnsteel_UI.Settings:GetMinimap() end
local function Finite(n) return type(n) == "number" and n == n and n > -math.huge and n < math.huge end
local function Clamp(n, low, high, fallback)
    n = tonumber(n)
    if not Finite(n) then n = fallback or low end
    return math.max(low, math.min(high, n))
end
local function ValidPoint(x, y)
    return Finite(x) and Finite(y) and x >= 0 and x <= 1 and y >= 0 and y <= 1
end
local function Color(c, a) return c.r, c.g, c.b, a or 1 end
local function CleanName(name) return zo_strformat("<<1>>", name or "") end

-- Screen-space angles are clockwise; ESO camera/texture headings are counterclockwise.
-- Keep these pure transforms shared by tiles, pins and the inverse click projection.
function Minimap:Project(x, y)
    local dx, dy = (x - self.playerX) * self.span, (y - self.playerY) * self.span
    return dx * self.cosAngle - dy * self.sinAngle, dx * self.sinAngle + dy * self.cosAngle
end

function Minimap:Unproject(x, y)
    return self.playerX + (x * self.cosAngle + y * self.sinAngle) / self.span,
        self.playerY + (-x * self.sinAngle + y * self.cosAngle) / self.span
end

function Minimap:Contains(x, y, inset)
    local w, h = self.width / 2 - (inset or 0), self.height / 2 - (inset or 0)
    if Settings().shape == "circle" then return x * x + y * y <= math.min(w, h) ^ 2 end
    return math.abs(x) <= w and math.abs(y) <= h
end

function Minimap:EdgePoint(x, y, inset)
    local w, h = self.width / 2 - inset, self.height / 2 - inset
    local divisor
    if Settings().shape == "circle" then
        divisor = math.sqrt(x * x + y * y) / math.min(w, h)
    else
        divisor = math.max(math.abs(x) / w, math.abs(y) / h)
    end
    if divisor == 0 then return 0, 0 end
    return x / divisor, y / divisor
end

function Minimap:UpdateTransform(x, y, heading, elapsed)
    self.playerX, self.playerY = x, y
    heading = Finite(heading) and heading or 0
    local target = Settings().orientation == "rotating" and heading or 0
    if self.angle == nil or Settings().orientation == "north" then self.angle = target end
    local delta = (target - self.angle + PI) % TAU - PI
    self.angle = (self.angle + delta * (1 - math.exp(-12 * (elapsed or 1)))) % TAU
    self.cosAngle, self.sinAngle = math.cos(self.angle), math.sin(self.angle)
    self.span = math.min(self.width, self.height) * Settings().zoom
    self.heading = heading
end

local function Control(parent, kind, level)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, kind or CT_CONTROL)
    c:SetMouseEnabled(false)
    -- Texture and polygon defaults must not decide which one covers the other.
    -- Draw levels only order controls after their tier and layer agree.
    c:SetDrawTier(DT_MEDIUM)
    c:SetDrawLayer(DL_CONTROLS)
    c:SetDrawLevel(level or 0)
    return c
end
local function Place(c, parent, w, h, x, y)
    c:SetDimensions(w, h)
    c:ClearAnchors()
    c:SetAnchor(CENTER, parent, CENTER, x or 0, y or 0)
end
local function Polygon(parent, points, level)
    local c = Control(parent, CT_POLYGON, level)
    c:SetPointLayout(POLYGON_POINT_LAYOUT_CLOCKWISE)
    -- ESO smoothing reshapes the contour; it is not just edge antialiasing.
    -- Keep rectangle corners, compass ticks and arrow tips exact. Only the
    -- densely sampled circular contours should use native smoothing.
    c:SetSmoothingEnabled(points == CIRCLE)
    for _, p in ipairs(points) do c:AddPoint(p[1], p[2]) end
    c:SetBorderDirection(POLYGON_BORDER_DIRECTION_IN)
    c:SetBorderThickness(0, 0, 1)
    c:SetCenterColor(0, 0, 0, 0)
    return c
end
local function PlaceRotatedPolygon(c, parent, points, w, h, x, y, angle)
    -- Rotate vertices inside an axis-aligned control. Control-space transforms
    -- also move ESO's screen-space clip, displacing arrows and the map mask.
    local cosine, sine = math.cos(angle), math.sin(angle)
    local boundsW = math.abs(w * cosine) + math.abs(h * sine)
    local boundsH = math.abs(w * sine) + math.abs(h * cosine)
    Place(c, parent, boundsW, boundsH, x, y)
    for i, p in ipairs(points) do
        local dx, dy = (p[1] - 0.5) * w, (p[2] - 0.5) * h
        c:SetPoint(i, 0.5 + (dx * cosine - dy * sine) / boundsW,
            0.5 + (dx * sine + dy * cosine) / boundsH)
    end
end
local function Label(parent, text, size, level)
    local c = Control(parent, CT_LABEL, level or 40)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetFont("$(BOLD_FONT)|" .. (size or 14) .. "|soft-shadow-thick")
    c:SetText(text)
    c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c:SetColor(0.85, 0.89, 0.91, 1)
    return c
end

function Minimap:CreateView()
    if self.root then return end
    local root = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_Minimap")
    self.root = root
    root:SetHidden(true)
    root:SetClampedToScreen(true)
    root:SetDrawTier(DT_MEDIUM)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    self.viewport = Control(root)
    self.terrain = Control(self.viewport)
    self.pins = Control(self.viewport)
    self.frame = Control(root)
    self.tilePool, self.pinPool, self.staticPins = {}, {}, {}
    self.frames = {}
    for _, shape in ipairs({ "circle", "rectangle" }) do
        local points = shape == "circle" and CIRCLE or RECT
        local f = {
            shadow = Polygon(self.frame, points, 1),
            backing = Polygon(self.viewport, points, 0),
            outer = Polygon(self.frame, points, 30),
            bevel = Polygon(self.frame, points, 31),
            inner = Polygon(self.frame, points, 32),
        }
        f.shadow:SetDrawLayer(DL_BACKGROUND)
        f.shadow:SetDrawLevel(0)
        f.backing:SetDrawLayer(DL_BACKGROUND)
        f.backing:SetDrawLevel(1)
        for _, border in ipairs({ f.outer, f.bevel, f.inner }) do border:SetDrawLayer(DL_OVERLAY) end
        self.frames[shape] = f
    end
    self.ticks = {}
    for i = 1, 24 do
        self.ticks[i] = Polygon(self.frame, RECT, 33)
        self.ticks[i]:SetDrawLayer(DL_OVERLAY)
    end
    self.cardinals = {}
    for i, name in ipairs({ "N", "E", "S", "W" }) do self.cardinals[i] = Label(self.frame, name, i == 1 and 14 or 11) end
    self.north = Polygon(self.frame, ARROW, 41)
    self.north:SetDrawLayer(DL_OVERLAY)
    self.title = Label(root, "", 14)
    self.coordinates = Label(root, "", 12)
    self.status = Label(self.viewport, "Map unavailable", 14, 45)
    self.player = Control(self.pins, CT_TEXTURE, 25)
    self.player:SetTexture(ICONS.player)
    self.player:SetColor(0.96, 0.98, 1, 1)
    self.waypointArrow = Polygon(self.pins, ARROW, 23)
    self.waypointArrow:SetHidden(true)
    self.toolbar = Control(root, CT_CONTROL, 50)
    self.buttons = {}
    for index, spec in ipairs({ { "−", -1 }, { "+", 1 }, { "M", 0 } }) do
        local button = Label(self.toolbar, spec[1], 16, 52)
        local background = Polygon(self.toolbar, RECT, 51)
        background:SetCenterColor(0.025, 0.04, 0.05, 0.94)
        background:SetBorderColor(0.40, 0.49, 0.54, 0.8)
        background:SetBorderThickness(1, 1, 1)
        Place(button, self.toolbar, 26, 22, (index - 2) * 30, 0)
        Place(background, self.toolbar, 26, 22, (index - 2) * 30, 0)
        local direction = spec[2]
        button:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
            if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT and self.interactive then
                if direction == 0 then
                    if not self.preview then ZO_WorldMap_ShowWorldMap() end
                else self:ChangeZoom(direction) end
            end
        end)
        self.buttons[index] = button
    end
    self.input = Control(self.viewport, CT_CONTROL, 60)
    self.input:SetAnchorFill(self.viewport)
    self.input:SetHandler("OnMouseWheel", function(_, delta)
        local x, y = self:MousePoint()
        if self.interactive and Settings().wheelZoom and self:Contains(x, y) then self:ChangeZoom(delta) end
    end)
    self.input:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside then self:HandleClick(button) end
    end)
    -- The artwork and interaction control cover the root window. Give unlock
    -- mode its own hit surface above all of them, including the location header.
    self.mover = Control(root, CT_CONTROL, 100)
    self.mover:SetDrawTier(DT_HIGH)
    self.mover:SetDrawLayer(DL_OVERLAY)
    self.mover:SetAnchorFill(root)
    self.mover:SetHidden(true)
    self.mover:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self.canDrag then
            root:SetMovable(true)
            self.dragging = root:StartMoving()
        end
    end)
    self.mover:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then self:StopDragging() end
    end)
    root:SetHandler("OnMoveStop", function()
        self.dragging = false
        root:SetMovable(false)
        local position = Nirnsteel_UI.Settings:GetMinimapPosition()
        position.x, position.y = root:GetRight() - GuiRoot:GetRight(), root:GetBottom() - GuiRoot:GetBottom()
        self:Layout()
    end)
    root:SetHandler("OnRectChanged", function() if self.width then self:RefreshClip() end end)
end

function Minimap:NormalizeSettings()
    local s = Settings()
    local ranges = {
        diameter = {180, 500, 280}, width = {220, 600, 340}, height = {160, 500, 240}, questTrackerOffset = {0, 600, 0},
        mapOpacity = {0, 100, 95}, frameOpacity = {0, 100, 100}, borderThickness = {1, 6, 2},
        zoom = {1, 8, 2.5}, markerScale = {75, 150, 100}, playerScale = {75, 175, 110}, combatOpacity = {0, 100, 40},
    }
    for key, range in pairs(ranges) do s[key] = Clamp(s[key], range[1], range[2], range[3]) end
    if s.shape ~= "rectangle" then s.shape = "circle" end
    if s.orientation ~= "rotating" then s.orientation = "north" end
    if s.questMode ~= "all" then s.questMode = "tracked" end
    if s.combatBehavior ~= "hide" and s.combatBehavior ~= "dim" then s.combatBehavior = "show" end
    for _, key in ipairs({ "borderColor", "accentColor" }) do
        if type(s[key]) ~= "table" then s[key] = { r = 0.8, g = 0.8, b = 0.8 } end
        for _, channel in ipairs({ "r", "g", "b" }) do s[key][channel] = Clamp(s[key][channel], 0, 1, 0.8) end
    end
end

function Minimap:StopDragging()
    if not self.root then return end
    self.root:StopMovingOrResizing()
    self.root:SetMovable(false)
    self.dragging = false
end

local function ReadAnchors(control)
    local anchors = {}
    for i = 0, control:GetNumAnchors() - 1 do
        local valid, point, relativeTo, relativePoint, x, y, constraints = control:GetAnchor(i)
        if valid then anchors[#anchors + 1] = { point, relativeTo, relativePoint, x, y, constraints } end
    end
    return anchors
end

local function SameAnchors(a, b)
    if not b or #a ~= #b then return false end
    for i, anchor in ipairs(a) do
        for j = 1, 6 do if anchor[j] ~= b[i][j] then return false end end
    end
    return true
end

function Minimap:ApplyQuestTrackerOffset()
    local panel = ZO_FocusedQuestTrackerPanel
    if not panel then return end
    local offset = Settings().enabled and Settings().questTrackerOffset or 0
    local current = ReadAnchors(panel)
    if #current == 0 then return end
    -- Preserve ESO's relative anchors, so dynamic events, timers and gamepad
    -- layout still flow normally. Never accumulate our offset on refresh.
    if self.questTrackerPanel ~= panel or not SameAnchors(current, self.questTrackerApplied) then
        self.questTrackerBase, self.questTrackerApplied = nil, nil
    end
    if offset == 0 and not self.questTrackerBase then return end
    self.questTrackerPanel = panel
    self.questTrackerBase = self.questTrackerBase or current
    panel:ClearAnchors()
    for _, anchor in ipairs(self.questTrackerBase) do
        panel:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] + offset, anchor[6])
    end
    self.questTrackerApplied = ReadAnchors(panel)
    if offset == 0 then self.questTrackerBase, self.questTrackerApplied = nil, nil end
end

function Minimap:Layout()
    local s = Settings()
    self.width = s.shape == "circle" and s.diameter or s.width
    self.height = s.shape == "circle" and s.diameter or s.height
    local w, h = self.width, self.height
    self.root:SetDimensions(w + INSET * 2, h + INSET * 2 + HEADER + FOOTER)
    self.root:ClearAnchors()
    local p = Nirnsteel_UI.Settings:GetMinimapPosition()
    local maxX = math.max(0, GuiRoot:GetWidth() - self.root:GetWidth())
    local maxY = math.max(0, GuiRoot:GetHeight() - self.root:GetHeight())
    p.x, p.y = Clamp(p.x, -maxX, 0, -32), Clamp(p.y, -maxY, 0, -48)
    self.root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, p.x, p.y)
    self.viewport:ClearAnchors()
    self.viewport:SetDimensions(w, h)
    self.viewport:SetAnchor(TOPLEFT, self.root, TOPLEFT, INSET, HEADER + INSET)
    self.terrain:SetAnchorFill(self.viewport)
    self.pins:SetAnchorFill(self.viewport)
    self.frame:SetAnchorFill(self.viewport)
    self.terrain:SetAlpha(s.mapOpacity / 100)
    self.frame:SetAlpha(s.frameOpacity / 100)
    for shape, f in pairs(self.frames) do
        for _, c in pairs(f) do c:SetHidden(shape ~= s.shape) end
        Place(f.shadow, self.viewport, w + 19, h + 19, 0, 3)
        -- A hollow shadow cannot veil terrain or markers, even during relayout.
        f.shadow:SetCenterColor(0, 0, 0, 0)
        f.shadow:SetBorderColor(0, 0, 0, 0.34)
        f.shadow:SetBorderThickness(9.5, 9.5, 1)
        f.shadow:SetHidden(shape ~= s.shape or not s.shadow)
        Place(f.backing, self.viewport, w, h)
        f.backing:SetCenterColor(0.025, 0.037, 0.046, 0.80 * s.mapOpacity / 100)
        for _, entry in ipairs({ { f.outer, 10, 4 }, { f.bevel, 5, s.borderThickness }, { f.inner, 1, 1 } }) do
            Place(entry[1], self.viewport, w + entry[2], h + entry[2])
            entry[1]:SetBorderThickness(entry[3], entry[3], 1)
        end
        f.outer:SetBorderColor(0.045, 0.067, 0.079, 1)
        f.bevel:SetBorderColor(Color(s.borderColor))
        f.inner:SetBorderColor(0.13, 0.19, 0.22, 1)
    end
    Place(self.title, self.viewport, w + 16, 24, 0, -h / 2 - 22)
    Place(self.coordinates, self.viewport, w, 20, 0, h / 2 + 20)
    Place(self.status, self.viewport, w - 30, 40)
    Place(self.toolbar, self.viewport, 88, 24, 0, h / 2 + 20)
    self.title:SetHidden(not s.showLocation and not self.preview and not s.unlocked)
    self.coordinates:SetHidden(not s.showCoordinates)
    Place(self.player, self.viewport, 22 * s.playerScale / 100, 22 * s.playerScale / 100)
    self.north:SetCenterColor(Color(s.accentColor))
    self.waypointArrow:SetCenterColor(Color(s.accentColor))
    self:RefreshClip()
end

function Minimap:ClipControl(c)
    c:ClearCircularClip()
    c:ClearRectangularClip()
    if Settings().shape == "circle" then
        local x, y = self.viewport:GetCenter()
        c:SetCircularClip(x, y, (self.viewport:GetRight() - self.viewport:GetLeft()) / 2)
    else
        c:SetRectangularClip(self.viewport:GetLeft(), self.viewport:GetTop(), self.viewport:GetRight(), self.viewport:GetBottom())
    end
end

function Minimap:RefreshClip()
    if not self.viewport then return end
    -- Apply to the actual drawables as well as parents, keeping every clip in
    -- screen space while texture rotation and polygon vertices rotate the art.
    self:ClipControl(self.terrain)
    self:ClipControl(self.pins)
    for _, c in ipairs(self.tilePool) do self:ClipControl(c) end
    for _, pin in ipairs(self.pinPool) do self:ClipControl(pin.icon); self:ClipControl(pin.area) end
    self:ClipControl(self.player)
    self:ClipControl(self.waypointArrow)
end

function Minimap:LayoutCompass()
    local s = Settings()
    for i, tick in ipairs(self.ticks) do
        local a = (i - 1) * TAU / 24 + self.angle
        local x, y = self:EdgePoint(math.sin(a), -math.cos(a), -5)
        local tickAngle = a
        if s.shape == "rectangle" then tickAngle = math.abs(x) > self.width / 2 and PI / 2 or 0 end
        PlaceRotatedPolygon(tick, self.viewport, RECT, i % 6 == 1 and 2 or 1,
            i % 6 == 1 and 6 or 3, x, y, tickAngle)
        tick:SetCenterColor(Color(s.borderColor, 0.65))
        tick:SetHidden(not s.showCardinals)
    end
    for i, label in ipairs(self.cardinals) do
        local a = (i - 1) * PI / 2 + self.angle
        local x, y = self:EdgePoint(math.sin(a), -math.cos(a), 13)
        Place(label, self.viewport, 20, 18, x, y)
        label:SetColor(Color(i == 1 and s.accentColor or s.borderColor))
        label:SetHidden(not s.showCardinals)
    end
    local nx, ny = self:EdgePoint(self.sinAngle, -self.cosAngle, -5)
    PlaceRotatedPolygon(self.north, self.viewport, ARROW, 10, 8, nx, ny, self.angle)
    self.north:SetHidden(not s.showCardinals)
end

function Minimap:GetMapKey()
    return tostring(GetCurrentMapId()) .. ":" .. tostring(GetMapFloorInfo())
end

function Minimap:InvalidateMap()
    self.mapReady, self.mapKey, self.angle = false, nil, nil
    self.available = false
    self.staticPins = {}
    self.staticDirty, self.nextMapCheck = true, 0
    if self.root then
        self.terrain:SetHidden(true)
        self.pins:SetHidden(true)
        self:ClearHover()
    end
end

function Minimap:LoadTiles(mapId)
    local columns, rows = GetMapNumTilesForMapId(mapId)
    if not Finite(columns) or not Finite(rows) or columns < 1 or rows < 1 or columns * rows > 256 then return false end
    local textures = {}
    for i = 1, columns * rows do
        local texture = GetMapTileTextureForMapId(mapId, i)
        if type(texture) ~= "string" or texture == "" then return false end
        textures[i] = texture
    end
    self.columns, self.rows, self.tileCount = columns, rows, #textures
    for i, texture in ipairs(textures) do
        local tile = self.tilePool[i]
        if not tile then
            tile = Control(self.terrain, CT_TEXTURE, 5)
            tile:SetPixelRoundingEnabled(false)
            self.tilePool[i] = tile
        end
        tile:SetTexture(texture)
        tile:SetColor(1, 1, 1, 1)
        tile:SetHidden(false)
        self:ClipControl(tile)
    end
    for i = #textures + 1, #self.tilePool do self.tilePool[i]:SetHidden(true) end
    return true
end

function Minimap:CanUseLiveMap()
    if not Settings().enabled or not self.playerActive or self.preview or self.travelActive then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or scene:GetState() ~= SCENE_SHOWN then return false end
    local name = scene:GetName()
    if name ~= "hud" and name ~= "hudui" then return false end
    return not ZO_WorldMap_IsWorldMapShowing() and WORLD_MAP_MANAGER:IsMapChangingAllowed()
        and not IsInteracting() and not HasAutoMapNavigationTarget()
end

function Minimap:RefreshMap()
    if not self:CanUseLiveMap() then return false end
    -- The API shares map selection with the world map and other addons. Only
    -- select the player's map while a fully shown gameplay scene owns the HUD.
    if not DoesCurrentMapMatchMapForPlayerLocation() then
        local result = SetMapToPlayerLocation()
        if result == SET_MAP_RESULT_MAP_CHANGED then CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged") end
    end
    if not self:CanUseLiveMap() or not DoesCurrentMapMatchMapForPlayerLocation() then
        self:InvalidateMap()
        return false
    end
    local key = self:GetMapKey()
    if key ~= self.mapKey or not self.mapReady then
        self:InvalidateMap()
        if not self:LoadTiles(GetCurrentMapId()) then return false end
        self.mapKey, self.mapReady, self.staticDirty = key, true, true
        self.mapName = CleanName(GetMapName())
    end
    return true
end

local function AddPin(list, kind, x, y, icon, name, radius)
    if ValidPoint(x, y) and type(icon) == "string" and icon ~= "" then
        list[#list + 1] = { kind = kind, x = x, y = y, icon = icon, name = CleanName(name), radius = radius or 0 }
    end
end

function Minimap:BuildStaticPins()
    if not self.mapReady or self.preview or self.mapKey ~= self:GetMapKey() then return end
    local s, pins, wayshrinePOIs, seen = Settings(), {}, {}, {}
    for i = 1, GetNumFastTravelNodes() do
        local known, name, x, y, icon, _, poiType, shown, locked = GetFastTravelNodeInfo(i)
        if poiType == POI_TYPE_WAYSHRINE then
            local zone, poi = GetFastTravelNodePOIIndicies(i)
            wayshrinePOIs[tostring(zone) .. ":" .. tostring(poi)] = true
            if s.showWayshrines and known and shown and not locked then AddPin(pins, "wayshrine", x, y, icon, name) end
        end
    end
    if s.showLocations then
        local zone = GetCurrentMapZoneIndex()
        for i = 1, GetNumPOIs(zone) do
            local x, y, _, icon, shown, locked, discovered, nearby = GetPOIMapInfo(zone, i)
            if shown and not locked and (discovered or nearby) and GetPOIType(zone, i) ~= POI_TYPE_WAYSHRINE
                and not wayshrinePOIs[tostring(zone) .. ":" .. tostring(i)] then
                local name = GetPOIInfo(zone, i)
                AddPin(pins, "location", x, y, icon, name)
            end
        end
        for i = 1, GetNumMapLocations() do
            if IsMapLocationVisible(i) then
                local icon, x, y = GetMapLocationIcon(i)
                AddPin(pins, "location", x, y, icon, GetMapLocationTooltipHeader(i))
            end
        end
    end
    if s.showQuests and WORLD_MAP_QUEST_BREADCRUMBS then
        for quest = 1, MAX_JOURNAL_QUESTS do
            if IsValidQuestIndex(quest) and (s.questMode == "all" or FOCUSED_QUEST_TRACKER:IsOnTracker(TRACK_TYPE_QUEST, quest)) then
                local steps = WORLD_MAP_QUEST_BREADCRUMBS:GetSteps(quest)
                for _, conditions in pairs(steps or {}) do
                    for _, data in pairs(conditions) do
                        -- Use the native icon lookup with its tiny read-only input contract.
                        local proxy = { m_PinTag = { isBreadcrumb = data.isBreadcrumb }, GetPinType = function() return data.pinType end }
                        local icon = ZO_MapPin.GetQuestIcon(proxy) or ICONS.quest
                        local name = GetJournalQuestName(quest)
                        if data.insideCurrentMapWorld then
                            AddPin(pins, "quest", data.xLoc, data.yLoc, icon, name, data.areaRadius)
                        end
                        if data.symbolicState == QUEST_PIN_STATE_HAS_ADDITIONAL_SYMBOLIC_POSITION then
                            AddPin(pins, "quest", data.additionalSymbolicLocX, data.additionalSymbolicLocY, icon, name)
                        end
                    end
                end
            end
        end
    end
    -- Several native providers can describe the same location or quest target.
    self.staticPins = {}
    for _, pin in ipairs(pins) do
        local key = string.format("%s:%.6f:%.6f:%s", pin.kind, pin.x, pin.y, pin.name)
        if not seen[key] then self.staticPins[#self.staticPins + 1] = pin; seen[key] = true end
    end
    self.staticDirty = false
end

function Minimap:GroupPosition(tag)
    if not DoesUnitExist(tag) or AreUnitsEqual("player", tag) or not IsUnitOnline(tag) then return end
    local x, y, _, shown = GetMapPlayerPosition(tag)
    if not shown or not ValidPoint(x, y) then return end
    local instanceMap = GetMapContentType() == MAP_CONTENT_DUNGEON or GetCurrentZoneHouseId() ~= 0
    if instanceMap and IsGroupMemberInSameWorldAsPlayer(tag) then
        if not IsGroupMemberInSameInstanceAsPlayer(tag) then return end
        if not IsGroupMemberInSameLayerAsPlayer(tag) and not IsUnitWorldMapPositionBreadcrumbed(tag) then return end
    end
    return x, y
end

function Minimap:AcquirePin(index)
    local pin = self.pinPool[index]
    if not pin then
        pin = { icon = Control(self.pins, CT_TEXTURE, 20), area = Polygon(self.pins, CIRCLE, 10) }
        pin.area:SetCenterColor(0.90, 0.74, 0.40, 0.10)
        pin.area:SetBorderColor(0.90, 0.74, 0.40, 0.38)
        pin.area:SetBorderThickness(1, 1, 1)
        self:ClipControl(pin.icon)
        self:ClipControl(pin.area)
        self.pinPool[index] = pin
    end
    return pin
end

function Minimap:DrawPin(data, index)
    local x, y = self:Project(data.x, data.y)
    local size = 22 * Settings().markerScale / 100
    local pin = self:AcquirePin(index)
    pin.data, pin.x, pin.y, pin.size, pin.visible, pin.edge = data, x, y, size, false, false
    pin.icon:SetHidden(true)
    pin.area:SetHidden(true)
    local radius = Finite(data.radius) and math.max(0, data.radius) * self.span or 0
    if radius > 0 and self:Contains(x, y, -radius) then
        Place(pin.area, self.viewport, radius * 2, radius * 2, x, y)
        pin.area:SetCenterColor(Color(Settings().accentColor, 0.10))
        pin.area:SetBorderColor(Color(Settings().accentColor, 0.38))
        pin.area:SetHidden(false)
    end
    if self:Contains(x, y) then
        Place(pin.icon, self.viewport, size, size, x, y)
        pin.icon:SetTexture(data.icon)
        if data.kind == "quest" or data.kind == "waypoint" then pin.icon:SetColor(Color(Settings().accentColor))
        elseif data.kind == "group" then pin.icon:SetColor(0.54, 0.83, 0.95, 1)
        else pin.icon:SetColor(0.94, 0.96, 0.95, 1) end
        pin.icon:SetDrawLevel(data.kind == "waypoint" and 23 or data.kind == "group" and 22 or data.kind == "quest" and 21 or 20)
        pin.icon:SetHidden(false)
        pin.visible = true
    elseif data.kind == "waypoint" and Settings().waypointEdge then
        x, y = self:EdgePoint(x, y, size / 2 + 3)
        PlaceRotatedPolygon(self.waypointArrow, self.viewport, ARROW, size * 0.7, size * 0.85,
            x, y, math.atan2(y, x) + PI / 2)
        self.waypointArrow:SetHidden(false)
        pin.x, pin.y, pin.visible, pin.edge = x, y, true, true
    end
    return index + 1
end

function Minimap:DrawPins()
    local index = 1
    self.waypointArrow:SetHidden(true)
    for _, data in ipairs(self.staticPins) do index = self:DrawPin(data, index) end
    if not self.preview then
        self.groupRecords = self.groupRecords or {}
        if Settings().showGroup then
            for i = 1, GetGroupSize() do
                local tag = GetGroupUnitTagByIndex(i)
                local x, y = self:GroupPosition(tag)
                if x then
                    local record = self.groupRecords[i] or { kind = "group" }
                    self.groupRecords[i] = record
                    record.x, record.y, record.name = x, y, CleanName(GetUnitName(tag))
                    record.icon = IsUnitGroupLeader(tag) and ICONS.leader or ICONS.group
                    index = self:DrawPin(record, index)
                end
            end
        end
        if Settings().showWaypoint then
            local x, y = GetMapPlayerWaypoint()
            if ValidPoint(x, y) and (x ~= 0 or y ~= 0) then
                self.waypointRecord = self.waypointRecord or { kind = "waypoint", icon = ICONS.waypoint, name = "Personal waypoint" }
                self.waypointRecord.x, self.waypointRecord.y = x, y
                index = self:DrawPin(self.waypointRecord, index)
            end
        end
    end
    self.activePinCount = index - 1
    for i = index, #self.pinPool do
        local pin = self.pinPool[i]
        pin.icon:SetHidden(true); pin.area:SetHidden(true); pin.visible = false; pin.data = nil
    end
end

function Minimap:Render(elapsed)
    local x, y, heading, shown, symbolic, ignoredHeading
    if self.preview then x, y, heading, shown = 0.5, 0.5, (GetFrameTimeMilliseconds() % 16000) / 16000 * TAU, true
    else
        x, y, ignoredHeading, shown, symbolic = GetMapPlayerPosition("player")
        heading = GetPlayerCameraHeading()
    end
    local available = self.mapReady and shown and not symbolic and ValidPoint(x, y)
    self.available = available == true
    self.terrain:SetHidden(not available)
    self.pins:SetHidden(not available)
    self.status:SetHidden(available)
    self.status:SetText("Map unavailable")
    self.title:SetText(self.preview and "MINIMAP PREVIEW" or Settings().unlocked and "MINIMAP · DRAG TO MOVE" or (available and self.mapName or "MINIMAP"))
    if not available then self.coordinates:SetText("") end
    if not available then self:ClearHover(); return end
    self:UpdateTransform(x, y, heading, elapsed)
    for i = 1, self.tileCount do
        local tile = self.tilePool[i]
        local tx = ((i - 1) % self.columns + 0.5) / self.columns
        local ty = (math.floor((i - 1) / self.columns) + 0.5) / self.rows
        local px, py = self:Project(tx, ty)
        -- Half-pixel overlap prevents filtered tile edges opening hairline seams.
        Place(tile, self.viewport, self.span / self.columns + 0.5, self.span / self.rows + 0.5, px, py)
        -- Rotate only the drawable quad about its center. A control transform
        -- rotates the native clipping coordinates too, shifting terrain outside
        -- the frame. ESO texture angles have the opposite sign to Project().
        tile:SetTextureRotation(-self.angle, 0.5, 0.5)
    end
    self.player:SetTextureRotation(heading - self.angle, 0.5, 0.5)
    self:DrawPins()
    self:LayoutCompass()
    self.coordinates:SetText(string.format("%.1f, %.1f", x * 100, y * 100))
end

function Minimap:MousePoint()
    local x, y = GetUIMousePosition()
    local cx, cy = self.viewport:GetCenter()
    local scaleX = (self.viewport:GetRight() - self.viewport:GetLeft()) / self.width
    local scaleY = (self.viewport:GetBottom() - self.viewport:GetTop()) / self.height
    return (x - cx) / math.max(0.001, scaleX), (y - cy) / math.max(0.001, scaleY)
end

function Minimap:HitPin(x, y)
    if not self.available or not self:Contains(x, y) then return end
    local best, bestPriority, bestDistance
    for i = 1, self.activePinCount or 0 do
        local pin = self.pinPool[i]
        if pin.visible then
            local distance = (x - pin.x) ^ 2 + (y - pin.y) ^ 2
            local priority = pin.data.kind == "waypoint" and 4 or pin.data.kind == "group" and 3 or pin.data.kind == "quest" and 2 or 1
            if distance <= (pin.size / 2) ^ 2 and (not best or priority > bestPriority or (priority == bestPriority and distance < bestDistance)) then
                best, bestPriority, bestDistance = pin.data, priority, distance
            end
        end
    end
    return best
end

function Minimap:NavigationMousePoint()
    local s = Settings()
    if not s.enabled or s.unlocked or s.clickThrough or not IsGameCameraUIModeActive()
        or not self.root or self.root:IsHidden() or self.preview or not self.available or not self:CanUseLiveMap()
        or self.mapKey ~= self:GetMapKey() or not DoesCurrentMapMatchMapForPlayerLocation() then return end
    local x, y = self:MousePoint()
    if not self:Contains(x, y) then return end
    return x, y
end

function Minimap:PlaceWaypointAtCursor()
    local x, y = self:NavigationMousePoint()
    if x == nil then return end
    local mx, my = self:Unproject(x, y)
    if ValidPoint(mx, my) then PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, mx, my) end
end

function Minimap:HandleClick(button)
    if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
    local x, y = self:NavigationMousePoint()
    if x == nil then return end
    local pin = self:HitPin(x, y)
    if pin and pin.kind == "waypoint" then RemovePlayerWaypoint() end
end

function Minimap:ChangeZoom(delta)
    Nirnsteel_UI.Settings:SetMinimapValue("zoom", Clamp(Settings().zoom + (delta > 0 and 0.25 or -0.25), 1, 8))
end

function Minimap:ClearHover()
    if self.tooltipOwned then ClearTooltip(InformationTooltip); self.tooltipOwned = false end
    self.hoverPin = nil
end

function Minimap:UpdateInteraction()
    local s = Settings()
    local cursor = IsGameCameraUIModeActive() or self.settingsVisible == true
    local shown = not self.root:IsHidden()
    self.interactive = shown and cursor and not s.clickThrough and not s.unlocked
    local canDrag = shown and cursor and s.unlocked
    if self.canDrag ~= canDrag then
        if not canDrag then self:StopDragging() end
        self.canDrag = canDrag
        self.root:SetMouseEnabled(canDrag)
        self.mover:SetHidden(not canDrag)
        self.mover:SetMouseEnabled(canDrag)
    end
    if self.dragging then self:RefreshClip() end
    self.input:SetMouseEnabled(self.interactive)
    local hovered = self.interactive and MouseIsOver(self.root)
    self.toolbar:SetHidden(not hovered)
    self.coordinates:SetHidden(not s.showCoordinates or hovered)
    for _, button in ipairs(self.buttons) do button:SetMouseEnabled(hovered) end
    if not self.interactive or not s.tooltips or not self.available then self:ClearHover(); return end
    local x, y = self:MousePoint()
    local pin = self:HitPin(x, y)
    if pin ~= self.hoverPin then
        self:ClearHover()
        self.hoverPin = pin
        if pin then
            InitializeTooltip(InformationTooltip, self.root, TOPRIGHT, -8, 0, TOPLEFT)
            InformationTooltip:AddLine(pin.name)
            self.tooltipOwned = true
        end
    end
end

function Minimap:RefreshVisibility()
    if not self.root then return end
    local s = Settings()
    local scene = SCENE_MANAGER:GetCurrentScene()
    local hud = scene and scene:GetState() == SCENE_SHOWN and (scene:GetName() == "hud" or scene:GetName() == "hudui")
    local previewVisible = self.preview and (self.settingsVisible or hud)
    local live = self:CanUseLiveMap()
    local visible = s.enabled and (previewVisible or (live and not (self.inCombat and s.combatBehavior == "hide")))
    self.root:SetHidden(not visible)
    self.root:SetAlpha(not self.preview and self.inCombat and s.combatBehavior == "dim" and s.combatOpacity / 100 or 1)
    if visible and not self.updating then
        self.updating = true
        self.lastFrame, self.nextMapCheck = nil, 0
        EVENT_MANAGER:RegisterForUpdate(NS, UPDATE_MS, function() self:Tick() end)
    elseif not visible then
        EVENT_MANAGER:UnregisterForUpdate(NS)
        self.updating = false
        self.lastFrame = nil
        self:ClearHover()
        if not self.preview then self:InvalidateMap() end
    end
    self:UpdateInteraction()
end

function Minimap:ScheduleVisibility()
    if not Settings().enabled then return end
    -- Let native event handlers finish changing scenes/map modes before resuming.
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_Visibility")
    EVENT_MANAGER:RegisterForUpdate(NS .. "_Visibility", 1, function()
        EVENT_MANAGER:UnregisterForUpdate(NS .. "_Visibility")
        if Settings().enabled then self:RefreshVisibility() end
    end)
end

function Minimap:Tick()
    local now = GetFrameTimeMilliseconds()
    if self.preview and now >= self.previewUntil then self:StopPreview(); return end
    self:RefreshVisibility()
    if not self.updating then return end
    local elapsed = self.lastFrame and Clamp((now - self.lastFrame) / 1000, 0, 0.25) or 1
    self.lastFrame = now
    if not self.preview then
        -- Map IDs/floors may change between one-second location checks (another
        -- addon or a floor transition). Never project old pins onto new tiles.
        if self.mapKey and self.mapKey ~= self:GetMapKey() then self:InvalidateMap() end
        if now >= (self.nextMapCheck or 0) then
            self:RefreshMap()
            self.nextMapCheck = now + MAP_CHECK_MS
        end
        if self.staticDirty then self:BuildStaticPins() end
    end
    self:Render(elapsed)
    self:UpdateInteraction()
end

function Minimap:BuildPreviewPins()
    self.staticPins = {}
    local s, pins = Settings(), self.staticPins
    if s.showQuests then AddPin(pins, "quest", 0.57, 0.41, ICONS.quest, "Sample quest objective", 0.035) end
    if s.showWayshrines then AddPin(pins, "wayshrine", 0.38, 0.45, ICONS.wayshrine, "Sample wayshrine") end
    if s.showLocations then AddPin(pins, "location", 0.59, 0.59, ICONS.wayshrine, "Sample location") end
    if s.showGroup then AddPin(pins, "group", 0.44, 0.57, ICONS.leader, "Sample group leader") end
    if s.showWaypoint then AddPin(pins, "waypoint", 0.86, 0.37, ICONS.waypoint, "Sample waypoint") end
end

function Minimap:Preview()
    if not Settings().enabled then return end
    self:CreateView()
    self:InvalidateMap()
    self.preview = true
    self.previewUntil = Settings().unlocked and self.settingsVisible and math.huge or GetFrameTimeMilliseconds() + 12000
    -- Reads by map ID do not select a map or create requests/pings. Samples are
    -- kept in our own pool, completely separate from the native pin managers.
    self.mapReady = self:LoadTiles(GetCurrentMapId())
    self:BuildPreviewPins()
    self:Layout()
    self:RefreshVisibility()
    self:Tick()
end

function Minimap:StopPreview()
    self.preview, self.previewUntil = false, nil
    self:InvalidateMap()
    if self.root then self:Layout(); self:RefreshVisibility() end
end

function Minimap:SetSettingsPanelVisible(visible)
    self.settingsVisible = visible
    if not visible and self.preview then self:StopPreview() end
    if visible and Settings().enabled and Settings().unlocked then self:Preview() end
    if self.root then self:RefreshVisibility() end
end

function Minimap:ResetPosition()
    local p = Nirnsteel_UI.Settings:GetMinimapPosition()
    p.x, p.y = -32, -48
    if self.root then self:Layout() end
end

function Minimap:RegisterEvents()
    if self.eventsRegistered then return end
    self.eventsRegistered = true
    self.runtimeEvents = {}
    local function Event(name, callback, runtime)
        local event = _G[name]
        if event then
            local namespace = NS .. "_" .. name
            if runtime then self.runtimeEvents[#self.runtimeEvents + 1] = { namespace, event, callback }
            else EVENT_MANAGER:RegisterForEvent(namespace, event, callback) end
        end
    end
    Event("EVENT_PLAYER_ACTIVATED", function()
        self.playerActive, self.travelActive = true, false
        self.inCombat = IsUnitInCombat("player")
        self:ApplyQuestTrackerOffset()
        self:InvalidateMap()
        self:ScheduleVisibility()
    end)
    Event("EVENT_PLAYER_DEACTIVATED", function()
        self.playerActive = false
        if self.preview then self:StopPreview() end
        self:InvalidateMap()
        self:RefreshVisibility()
    end)
    Event("EVENT_PLAYER_COMBAT_STATE", function(_, inCombat)
        self.inCombat = inCombat
        if Settings().enabled then self:RefreshVisibility() end
    end)
    for _, name in ipairs({ "EVENT_SCREEN_RESIZED", "EVENT_GAMEPAD_PREFERRED_MODE_CHANGED" }) do
        Event(name, function()
            self:ApplyQuestTrackerOffset()
            if self.root then self:StopDragging(); self:Layout(); self:ScheduleVisibility() end
        end)
    end
    for _, name in ipairs({ "EVENT_ZONE_CHANGED", "EVENT_POIS_INITIALIZED" }) do
        Event(name, function() if not self.preview then self:InvalidateMap() end; self:ScheduleVisibility() end, true)
    end
    for _, name in ipairs({ "EVENT_POI_DISCOVERED", "EVENT_POI_UPDATED", "EVENT_FAST_TRAVEL_NETWORK_UPDATED",
        "EVENT_QUEST_ADDED", "EVENT_QUEST_REMOVED", "EVENT_QUEST_LIST_UPDATED", "EVENT_QUEST_ADVANCED",
        "EVENT_QUEST_CONDITION_COUNTER_CHANGED", "EVENT_QUEST_POSITION_REQUEST_COMPLETE" }) do
        Event(name, function() self.staticDirty = true end, true)
    end
    for _, name in ipairs({ "EVENT_START_FAST_TRAVEL_INTERACTION", "EVENT_START_FAST_TRAVEL_KEEP_INTERACTION" }) do
        Event(name, function() self.travelActive = true; self:RefreshVisibility() end, true)
    end
    for _, name in ipairs({ "EVENT_END_FAST_TRAVEL_INTERACTION", "EVENT_END_FAST_TRAVEL_KEEP_INTERACTION" }) do
        Event(name, function() self.travelActive = false; self:ScheduleVisibility() end, true)
    end
    for _, name in ipairs({ "EVENT_INTERACTION_ENDED", "EVENT_CLIENT_INTERACT_RESULT", "EVENT_AUTO_MAP_NAVIGATION_TARGET_SET" }) do
        Event(name, function() self:ScheduleVisibility() end, true)
    end
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        if Settings().enabled then self:RefreshVisibility(); self:ScheduleVisibility() end
    end)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        if Settings().enabled and not self.preview then self:InvalidateMap(); self:ScheduleVisibility() end
    end)
    if WORLD_MAP_QUEST_BREADCRUMBS then
        for _, name in ipairs({ "QuestAvailable", "QuestRemoved" }) do
            WORLD_MAP_QUEST_BREADCRUMBS:RegisterCallback(name, function() self.staticDirty = true end)
        end
    end
    if FOCUSED_QUEST_TRACKER then
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", function() self.staticDirty = true end)
    end
end

function Minimap:RefreshSettings()
    self:StopDragging()
    self:NormalizeSettings()
    self:ApplyQuestTrackerOffset()
    self:RegisterEvents()
    local enabled = Settings().enabled
    if enabled ~= self.runtimeRegistered then
        for _, event in ipairs(self.runtimeEvents) do
            if enabled then EVENT_MANAGER:RegisterForEvent(event[1], event[2], event[3])
            else EVENT_MANAGER:UnregisterForEvent(event[1], event[2]) end
        end
        self.runtimeRegistered = enabled
    end
    if not enabled then
        self.preview = false
        EVENT_MANAGER:UnregisterForUpdate(NS)
        EVENT_MANAGER:UnregisterForUpdate(NS .. "_Visibility")
        self.updating = false
        self:InvalidateMap()
    else
        self:CreateView()
        if Settings().unlocked and self.settingsVisible and not self.preview then self:Preview() end
        if self.preview then self:BuildPreviewPins() else self.staticDirty = true end
        if self.preview then
            self.previewUntil = Settings().unlocked and self.settingsVisible and math.huge or GetFrameTimeMilliseconds() + 12000
        end
        self:Layout()
    end
    self:RefreshVisibility()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NS .. "_Loaded", EVENT_ADD_ON_LOADED)
    Minimap:RefreshSettings()
end
EVENT_MANAGER:RegisterForEvent(NS .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
