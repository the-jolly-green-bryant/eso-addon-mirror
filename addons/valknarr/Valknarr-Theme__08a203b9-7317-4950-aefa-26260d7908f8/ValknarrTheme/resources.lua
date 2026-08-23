-- Independent Health / Magicka / Stamina bars on GuiRoot.
-- Console native ZO_PlayerAttribute* ignore restyle; 0.1.1 diag showed our
-- labels "visible" while the vanilla bars stayed on screen. Hide natives and
-- draw our own, same pattern as Azurah / EZOHud Attribute HUD.

ValknarrThemeResources = ValknarrThemeResources or {}

local Resources = ValknarrThemeResources
local Format = ValknarrThemeFormat
local Safe = ValknarrThemeSafe
local Log = ValknarrThemeLog
local Skins = ValknarrThemeSkins

local ADDON_NAME = "ValknarrTheme"
local FONTS = { "ZoFontGamepad34", "ZoFontGamepad27", "ZoFontGameShadow" }

local BARS = {
    {
        id = "health",
        title = "Health",
        global = "ZO_PlayerAttributeHealth",
        power = "COMBAT_MECHANIC_FLAGS_HEALTH",
        x = 0.50,
        y = 0.86,
        width = 320,
        height = 44,
        fill = { 0.78, 0.16, 0.14, 1 },
    },
    {
        id = "magicka",
        title = "Magicka",
        global = "ZO_PlayerAttributeMagicka",
        power = "COMBAT_MECHANIC_FLAGS_MAGICKA",
        x = 0.34,
        y = 0.82,
        width = 320,
        height = 44,
        fill = { 0.22, 0.46, 0.94, 1 },
    },
    {
        id = "stamina",
        title = "Stamina",
        global = "ZO_PlayerAttributeStamina",
        power = "COMBAT_MECHANIC_FLAGS_STAMINA",
        x = 0.66,
        y = 0.82,
        width = 320,
        height = 44,
        fill = { 0.20, 0.70, 0.30, 1 },
    },
}

local function PowerType(flagName)
    local value = _G[flagName]
    if type(value) == "number" then
        return value
    end
    return nil
end

local function FindNative(spec)
    local control = _G[spec.global]
    if control and type(control.SetAnchor) == "function" then
        return control
    end
    return nil
end

local function PositiveNumber(value, fallback)
    value = tonumber(value)
    if value and value > 1 then
        return value
    end
    return fallback
end

local function ScreenSize()
    local width, height = 1920, 1080
    if GuiRoot then
        if type(GuiRoot.GetWidth) == "function" then
            width = PositiveNumber(GuiRoot:GetWidth(), width)
        end
        if type(GuiRoot.GetHeight) == "function" then
            height = PositiveNumber(GuiRoot:GetHeight(), height)
        end
    end
    return width, height
end

function Resources.SetGamepadFont(label, preferred)
    if not label or type(label.SetFont) ~= "function" then
        return false
    end
    local fonts = FONTS
    if preferred then
        fonts = { preferred, "ZoFontGamepad27", "ZoFontGamepad34", "ZoFontGameShadow" }
    end
    for index = 1, #fonts do
        if pcall(label.SetFont, label, fonts[index]) then
            return true
        end
    end
    return false
end

local function OverlayTier(control, drawLevel)
    Safe.Try(control, "SetMouseEnabled", false)
    Safe.Try(control, "SetMovable", false)
    Safe.Try(control, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(control, "SetDrawTier", DT_HIGH)
    Safe.Try(control, "SetDrawLevel", drawLevel or 100)
    Safe.Try(control, "SetAlpha", 1)
end

local CLEAN_CENTER = { 0.05, 0.05, 0.06, 0.90 }
-- Each tile stays square (uniform scale). Three tiles make the rectangle.
local TILE_COUNT = 3
local TILE_SUFFIX = { "Chrome", "ChromeM", "ChromeR" }

local function PaintBackdrop(control, width, height, center, edge, drawLevel)
    if not control then
        return
    end
    OverlayTier(control, drawLevel)
    if width then
        Safe.Try(control, "SetDimensions", width, height)
    end
    if center then
        Safe.Try(control, "SetCenterColor", center[1], center[2], center[3], center[4])
    end
    if edge then
        Safe.Try(control, "SetEdgeColor", edge[1], edge[2], edge[3], edge[4])
    else
        Safe.Try(control, "SetEdgeColor", 0, 0, 0, 0)
    end
    Safe.Try(control, "SetCenterTexture", "")
    Safe.Try(control, "SetEdgeTexture", "", 1, 1, 0)
    Safe.Try(control, "SetHidden", false)
end

local function RootSize(spec)
    return spec.width, spec.height
end

local function TileSize(spec)
    return math.floor(spec.width / TILE_COUNT)
end

local function HideTiles(tiles, host)
    if host then
        Safe.Try(host, "SetHidden", true)
    end
    if type(tiles) ~= "table" then
        return
    end
    for index = 1, #tiles do
        Safe.Try(tiles[index], "SetHidden", true)
    end
end

local function TilesBound(tiles)
    if type(tiles) ~= "table" or not Skins or type(Skins.IsCustomBound) ~= "function" then
        return false
    end
    if #tiles < 1 then
        return false
    end
    for index = 1, #tiles do
        if not Skins.IsCustomBound(tiles[index]) then
            return false
        end
    end
    return true
end

function Resources:LockNative(spec)
    local native = FindNative(spec)
    if not native or native.ValknarrThemeLocked then
        return native ~= nil
    end
    native.ValknarrThemeLocked = true
    local origHidden = native.SetHidden
    if type(origHidden) == "function" then
        native.SetHidden = function(ctrl, hidden)
            if Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) then
                return origHidden(ctrl, true)
            end
            return origHidden(ctrl, hidden)
        end
    end
    local origAlpha = native.SetAlpha
    if type(origAlpha) == "function" then
        native.SetAlpha = function(ctrl, alpha)
            if Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) then
                return origAlpha(ctrl, 0)
            end
            return origAlpha(ctrl, alpha)
        end
    end
    if type(native.SetHandler) == "function" then
        pcall(native.SetHandler, native, "OnShow", function()
            if Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) then
                Safe.Try(native, "SetHidden", true)
                Safe.Try(native, "SetAlpha", 0)
            end
        end)
    end
    if type(ZO_PreHook) == "function" then
        pcall(ZO_PreHook, native, "SetHidden", function(_ctrl, hidden)
            if Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) and not hidden then
                return true
            end
        end)
        pcall(ZO_PreHook, native, "SetAlpha", function(_ctrl, alpha)
            if Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) and (tonumber(alpha) or 0) > 0 then
                return true
            end
        end)
    end
    return true
end

function Resources:HideNative(spec, hide)
    local native = FindNative(spec)
    if not native then
        return false
    end
    self:LockNative(spec)
    Safe.Try(native, "SetHidden", hide and true or false)
    Safe.Try(native, "SetAlpha", hide and 0 or 1)
    return true
end

-- Full-screen host only. Do not re-stretch on refresh; children keep their own GuiRoot anchors.
function Resources:EnsureLayer()
    if self.layer then
        return self.layer
    end
    if not WINDOW_MANAGER or not GuiRoot then
        return nil
    end
    local layer
    if type(WINDOW_MANAGER.CreateTopLevelWindow) == "function" then
        local ok, created = pcall(WINDOW_MANAGER.CreateTopLevelWindow, WINDOW_MANAGER, ADDON_NAME .. "Layer")
        if ok then
            layer = created
        end
    end
    if not layer then
        layer = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Layer", GuiRoot, CT_CONTROL)
    end
    if not layer then
        return nil
    end
    OverlayTier(layer, 50)
    Safe.Try(layer, "SetClampedToScreen", false)
    Safe.Try(layer, "ClearAnchors")
    Safe.Try(layer, "SetAnchor", TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    Safe.Try(layer, "SetAnchor", BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    Safe.Try(layer, "SetHidden", false)
    self.layer = layer
    return layer
end

function Resources:Place(spec, root)
    if not root then
        return
    end
    local totalW, totalH = RootSize(spec)
    local screenW, screenH = ScreenSize()
    local left = spec.x * screenW - (totalW * 0.5)
    local top = spec.y * screenH - (totalH * 0.5)
    OverlayTier(root, 100)
    Safe.Try(root, "SetClampedToScreen", false)
    Safe.Try(root, "SetDimensions", totalW, totalH)
    Safe.Try(root, "ClearAnchors")
    Safe.Try(root, "SetAnchor", TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Guest roots are placed once. Refresh / power / ApplyStyle must not
-- ClearAnchors — that fights ValknarrUIE saved positions.
function Resources.IsUnanchored(control)
    if not control or type(control.GetNumAnchors) ~= "function" then
        return false
    end
    local ok, count = pcall(control.GetNumAnchors, control)
    if not ok then
        return false
    end
    return (tonumber(count) or 0) < 1
end

function Resources:PlaceIfUnanchored(spec, root)
    if Resources.IsUnanchored(root) then
        self:Place(spec, root)
    end
end

function Resources:Ensure(spec)
    self.frames = self.frames or {}
    local frame = self.frames[spec.id]
    if frame and frame.root then
        return frame.root
    end
    local parent = self:EnsureLayer() or GuiRoot
    if not WINDOW_MANAGER or not parent then
        return nil
    end

    local root = WINDOW_MANAGER:CreateControl(ADDON_NAME .. spec.title .. "Root", parent, CT_CONTROL)
    if not root then
        return nil
    end
    Safe.Try(root, "SetHidden", true)
    self:Place(spec, root)

    local bg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. spec.title .. "Bg", root, CT_BACKDROP)
    Safe.Try(bg, "SetAnchor", TOPLEFT, root, TOPLEFT, 0, 0)
    PaintBackdrop(bg, spec.width, spec.height, CLEAN_CENTER, nil, 100)

    local fill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. spec.title .. "Fill", root, CT_BACKDROP)
    Safe.Try(fill, "SetAnchor", LEFT, bg, LEFT, 6, 0)
    PaintBackdrop(fill, spec.width - 12, spec.height - 8, spec.fill, nil, 101)

    local host = WINDOW_MANAGER:CreateControl(ADDON_NAME .. spec.title .. "ChromeHost", root, CT_CONTROL)
    OverlayTier(host, 102)
    Safe.Try(host, "SetHidden", true)

    local tiles = {}
    for index = 1, TILE_COUNT do
        local name = ADDON_NAME .. spec.title .. TILE_SUFFIX[index]
        local tile
        if WINDOW_MANAGER and CT_TEXTURE then
            tile = WINDOW_MANAGER:CreateControl(name, host, CT_TEXTURE)
        end
        if tile then
            OverlayTier(tile, 103)
            Safe.Try(tile, "SetColor", 1, 1, 1, 1)
            Safe.Try(tile, "SetHidden", true)
            tiles[index] = tile
        end
    end

    local label = WINDOW_MANAGER:CreateControl(ADDON_NAME .. spec.title .. "Label", root, CT_LABEL)
    OverlayTier(label, 104)
    Safe.Try(label, "SetAnchor", CENTER, bg, CENTER, 0, 0)
    Safe.Try(label, "SetDimensions", spec.width, spec.height)
    Safe.Try(label, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
    Safe.Try(label, "SetColor", 1, 1, 1, 1)
    Resources.SetGamepadFont(label)

    self.frames[spec.id] = {
        root = root,
        bg = bg,
        fill = fill,
        chrome = tiles[1],
        chromeHost = host,
        tiles = tiles,
        label = label,
        spec = spec,
    }
    if Log then
        Log:Debug("created " .. spec.id .. " replacement bar")
    end
    return root
end

function Resources:ReadPower(spec)
    local powerType = PowerType(spec.power)
    if not powerType or type(GetUnitPower) ~= "function" then
        return 0, 0
    end
    local ok, current, maximum = pcall(GetUnitPower, "player", powerType)
    if not ok then
        return 0, 0
    end
    return tonumber(current) or 0, tonumber(maximum) or 0
end

function Resources:RefreshBar(spec)
    local themed = Format.ResourcesThemed(ValknarrThemeStore:ThemeId())
    self:HideNative(spec, themed)

    local root = self:Ensure(spec)
    local frame = self.frames and self.frames[spec.id]
    if not root or not frame then
        return
    end

    self:PlaceIfUnanchored(spec, root)
    Safe.Try(root, "SetHidden", not themed)
    if not themed then
        return
    end
    Safe.Try(root, "SetAlpha", 1)
    Safe.Try(frame.fill, "SetHidden", false)
    Safe.Try(frame.label, "SetHidden", false)

    local current, maximum = self:ReadPower(spec)
    local pct = Format.Percent(current, maximum)
    local metal = Format.ResourcesMetal(ValknarrThemeStore:ThemeId())
    local pack = Skins and Skins.BarFrame and Skins.BarFrame(spec.id)
    local framed = false
    if metal and pack and frame.tiles and Skins.BindBarTiles then
        if not frame.metalArmed or frame.metalRebind then
            if not frame.metalArmed then
                for index = 1, #frame.tiles do
                    if Skins.ClearBind then
                        Skins.ClearBind(frame.tiles[index])
                    end
                end
                frame.metalArmed = true
            end
            frame.metalRebind = nil
            framed = Skins.BindBarTiles(frame.tiles, pack, spec.id .. "/tile")
        else
            framed = TilesBound(frame.tiles)
        end
    else
        frame.metalArmed = nil
        frame.metalRebind = nil
    end
    frame.framed = framed
    if metal and not framed then
        if Log and not frame.metalMissLogged then
            frame.metalMissLogged = true
            Log:Always("metal tiles missed; " .. spec.id .. " using clean layout; retrying")
        end
        self:StartMetalRetry()
    else
        frame.metalMissLogged = nil
        if metal and framed and not self:AnyMetalMissing() then
            self:StopMetalRetry()
        end
    end

    if framed then
        local tile = TileSize(spec)
        local stripW, stripH = tile * TILE_COUNT, tile
        local hole = pack.hole
        local x = hole[1] * stripW + 2
        local y = hole[2] * stripH + 2
        local wellW = (hole[3] - hole[1]) * stripW - 4
        local wellH = (hole[4] - hole[2]) * stripH - 4
        Safe.Try(frame.chromeHost, "SetHidden", false)
        Safe.Try(frame.chromeHost, "ClearAnchors")
        Safe.Try(frame.chromeHost, "SetAnchor", CENTER, root, CENTER, 0, 0)
        Safe.Try(frame.chromeHost, "SetDimensions", stripW, stripH)
        for index = 1, #frame.tiles do
            local piece = frame.tiles[index]
            Safe.Try(piece, "SetHidden", false)
            Safe.Try(piece, "ClearAnchors")
            Safe.Try(piece, "SetAnchor", TOPLEFT, frame.chromeHost, TOPLEFT, (index - 1) * tile, 0)
            Safe.Try(piece, "SetDimensions", tile, tile)
        end
        Safe.Try(frame.bg, "ClearAnchors")
        Safe.Try(frame.bg, "SetAnchor", TOPLEFT, frame.chromeHost, TOPLEFT, x, y)
        PaintBackdrop(frame.bg, wellW, wellH, CLEAN_CENTER, nil, 100)
        Safe.Try(frame.fill, "ClearAnchors")
        Safe.Try(frame.fill, "SetAnchor", LEFT, frame.bg, LEFT, 0, 0)
        PaintBackdrop(frame.fill, math.max(8, math.floor((wellW * pct) / 100)), wellH, spec.fill, nil, 101)
        if frame.label then
            Safe.Try(frame.label, "ClearAnchors")
            Safe.Try(frame.label, "SetAnchor", CENTER, frame.bg, CENTER, 0, 0)
            Safe.Try(frame.label, "SetDimensions", wellW, wellH)
        end
    else
        HideTiles(frame.tiles, frame.chromeHost)
        Safe.Try(frame.bg, "ClearAnchors")
        Safe.Try(frame.bg, "SetAnchor", TOPLEFT, root, TOPLEFT, 0, 0)
        PaintBackdrop(frame.bg, spec.width, spec.height, CLEAN_CENTER, nil, 100)
        Safe.Try(frame.fill, "ClearAnchors")
        Safe.Try(frame.fill, "SetAnchor", LEFT, frame.bg, LEFT, 6, 0)
        PaintBackdrop(frame.fill, math.max(8, math.floor(((spec.width - 12) * pct) / 100)), spec.height - 8, spec.fill, nil, 101)
        if frame.label then
            Safe.Try(frame.label, "ClearAnchors")
            Safe.Try(frame.label, "SetAnchor", CENTER, frame.bg, CENTER, 0, 0)
            Safe.Try(frame.label, "SetDimensions", spec.width, spec.height)
        end
    end
    if frame.label then
        Safe.Try(frame.label, "SetText", Format.ResourceLine(current, maximum))
        Resources.SetGamepadFont(frame.label)
    end
end

function Resources:AnyMetalMissing()
    if not Format.ResourcesMetal(ValknarrThemeStore:ThemeId()) then
        return false
    end
    for index = 1, #BARS do
        local frame = self.frames and self.frames[BARS[index].id]
        if not (frame and frame.framed) then
            return true
        end
    end
    return false
end

function Resources:StopMetalRetry()
    local ticks = self.metalRetryTick or 0
    local wasRetrying = self.metalRetrying
    if self.metalRetrying and EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, ADDON_NAME .. "MetalRetry")
    end
    self.metalRetrying = false
    if wasRetrying and ticks >= 8 and Format.ResourcesMetal(ValknarrThemeStore:ThemeId())
        and self:AnyMetalMissing() and Log then
        Log:Always("metal tiles still missed after retry")
    end
end

function Resources:StartMetalRetry()
    if self.metalRetrying then
        return
    end
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    self.metalRetrying = true
    self.metalRetryTick = 0
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "MetalRetry", 400, function()
        Resources.metalRetryTick = (Resources.metalRetryTick or 0) + 1
        if Resources.frames then
            for index = 1, #BARS do
                local frame = Resources.frames[BARS[index].id]
                if frame then
                    frame.metalRebind = true
                end
            end
        end
        Resources:Apply()
        if Resources.metalRetryTick >= 8 or not Resources:AnyMetalMissing() then
            Resources:StopMetalRetry()
        end
    end)
end

function Resources:Apply()
    if not Format.ResourcesMetal(ValknarrThemeStore:ThemeId()) then
        self:StopMetalRetry()
        if self.frames then
            for index = 1, #BARS do
                local frame = self.frames[BARS[index].id]
                if frame then
                    frame.metalArmed = nil
                    frame.metalRebind = nil
                    frame.framed = nil
                    frame.metalMissLogged = nil
                end
            end
        end
    end
    for index = 1, #BARS do
        self:RefreshBar(BARS[index])
    end
end

function Resources:DescribeBar(spec)
    local native = FindNative(spec)
    local frame = self.frames and self.frames[spec.id]
    local ours = frame and frame.root
    local label = frame and frame.label
    local current, maximum = self:ReadPower(spec)
    local nativeBits = Log and Log.ControlBits and Log:ControlBits(native) or { present = native ~= nil }
    local oursBits = Log and Log.ControlBits and Log:ControlBits(ours) or { present = ours ~= nil }
    local text
    if label and type(label.GetText) == "function" then
        local ok, value = pcall(label.GetText, label)
        if ok then
            text = value
        end
    end
    local width, height, left, top
    if ours then
        if type(ours.GetWidth) == "function" then
            local ok, value = pcall(ours.GetWidth, ours)
            if ok then
                width = value
            end
        end
        if type(ours.GetHeight) == "function" then
            local ok, value = pcall(ours.GetHeight, ours)
            if ok then
                height = value
            end
        end
        if type(ours.GetLeft) == "function" then
            local ok, value = pcall(ours.GetLeft, ours)
            if ok then
                left = math.floor(value + 0.5)
            end
        end
        if type(ours.GetTop) == "function" then
            local ok, value = pcall(ours.GetTop, ours)
            if ok then
                top = math.floor(value + 0.5)
            end
        end
    end
    return {
        id = spec.id,
        native = nativeBits.name or (nativeBits.present and "yes" or "missing"),
        nativeHidden = nativeBits.hidden,
        ours = oursBits.name or (oursBits.present and "yes" or "missing"),
        oursHidden = oursBits.hidden,
        text = text,
        w = width,
        h = height,
        left = left,
        top = top,
        current = current,
        max = maximum,
        powerFlag = PowerType(spec.power),
        skin = ValknarrThemeStore:ThemeId(),
        chrome = frame and frame.chrome and frame.chrome.ValknarrBoundTex or nil,
        metal = Format.ResourcesMetal(ValknarrThemeStore:ThemeId()) and true or false,
    }
end

function Resources:Describe()
    local list = {}
    for index = 1, #BARS do
        list[index] = self:DescribeBar(BARS[index])
    end
    return list
end

function Resources:OnPowerUpdate(_event, unitTag, _powerIndex, powerType)
    if unitTag and unitTag ~= "player" then
        return
    end
    if not Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) then
        return
    end
    for index = 1, #BARS do
        local spec = BARS[index]
        if PowerType(spec.power) == powerType then
            self:RefreshBar(spec)
            return
        end
    end
end

function Resources:RegisterHost()
    local lib = _G.LibValknarrUIE
    if not lib or type(lib.RegisterElement) ~= "function" then
        return false
    end
    if self.hostRegistered then
        return true
    end
    lib:RegisterAddon(ADDON_NAME, "Valknarr Theme")
    for index = 1, #BARS do
        local spec = BARS[index]
        lib:RegisterElement(ADDON_NAME, spec.id, {
            name = "Theme " .. spec.title,
            resizable = false,
            replaces = spec.id,
            active = function()
                return Format.ResourcesThemed(ValknarrThemeStore:ThemeId())
            end,
            locate = function()
                return Resources:Ensure(spec)
            end,
            default = { x = spec.x, y = spec.y },
        })
    end
    self.hostRegistered = true
    if Log then
        Log:Info("registered theme H/M/S with LibValknarrUIE")
    end
    return true
end

function Resources:RegisterEvents()
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return
    end
    if self.eventsRegistered then
        return
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ResPower", EVENT_POWER_UPDATE, function(...)
        Resources:OnPowerUpdate(...)
    end)
    if type(EVENT_MANAGER.AddFilterForEvent) == "function" and REGISTER_FILTER_UNIT_TAG then
        pcall(EVENT_MANAGER.AddFilterForEvent, EVENT_MANAGER, ADDON_NAME .. "ResPower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    end
    local bars = _G.PLAYER_ATTRIBUTE_BARS
    if bars and type(bars.ApplyStyle) == "function" and not bars.ValknarrThemeNumbersHooked then
        local original = bars.ApplyStyle
        bars.ApplyStyle = function(this, ...)
            local a, b, c, d, e = original(this, ...)
            Resources:Apply()
            return a, b, c, d, e
        end
        bars.ValknarrThemeNumbersHooked = true
    end
    if type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "ResKeepHidden", 250, function()
            if not Format.ResourcesThemed(ValknarrThemeStore:ThemeId()) then
                return
            end
            for index = 1, #BARS do
                Resources:HideNative(BARS[index], true)
            end
        end)
    end
    self.eventsRegistered = true
    if Log then
        Log:Debug("resource replacement events registered")
    end
end

return Resources
