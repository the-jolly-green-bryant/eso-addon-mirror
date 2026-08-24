-- Form-only werewolf widget. Clean: icon + Ult over Fury.
-- Named skins: one 8-tile inverted-L plate (Ult in the bar, Fury on the head).
-- No cooldown ring (console paints that as a spinning white square).
-- Native ZO_PlayerAttributeWerewolf is hidden while this widget is shown.

ValknarrThemeWerewolf = ValknarrThemeWerewolf or {}

local Werewolf = ValknarrThemeWerewolf
local Format = ValknarrThemeFormat
local Safe = ValknarrThemeSafe
local Log = ValknarrThemeLog
local Skins = ValknarrThemeSkins

local ADDON_NAME = "ValknarrTheme"
local ELEMENT_ID = "werewolf"
local HOST_ADDON = "ValknarrUIE"

local ROOT_W = 340
local ROOT_H = 160
local ORB_SIZE = 96
local BAR_W = 228
local BAR_H = 36
local PLATE_COLS = 4
local PLATE_ROWS = 2
local PLATE_TILE = 80
local PLATE_W = PLATE_COLS * PLATE_TILE
local PLATE_H = PLATE_ROWS * PLATE_TILE
local PLATE_COUNT = PLATE_COLS * PLATE_ROWS
local DEFAULT_X = 0.16
local DEFAULT_Y = 0.72
local BLINK_MS = 400
local FILL_WARN = { 0.78, 0.28, 0.16, 1 }
local SUSTAIN_OK = { 1, 0.92, 0.55, 1 }
local SUSTAIN_WARN = { 1, 0.32, 0.22, 1 }

local function OverlayTier(control, drawLevel)
    Safe.Try(control, "SetMouseEnabled", false)
    Safe.Try(control, "SetMovable", false)
    Safe.Try(control, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(control, "SetDrawTier", DT_HIGH)
    Safe.Try(control, "SetDrawLevel", drawLevel or 100)
    Safe.Try(control, "SetAlpha", 1)
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

local function MakePlate(parent)
    local host = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfPlateHost", parent, CT_CONTROL)
    OverlayTier(host, 102)
    Safe.Try(host, "SetHidden", true)
    local tiles = {}
    for index = 1, PLATE_COUNT do
        local tile
        if WINDOW_MANAGER and CT_TEXTURE then
            tile = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfPlate" .. index, host, CT_TEXTURE)
        end
        if tile then
            OverlayTier(tile, 109)
            Safe.Try(tile, "SetColor", 1, 1, 1, 1)
            Safe.Try(tile, "SetHidden", true)
            tiles[index] = tile
        end
    end
    return host, tiles
end

local function SizeOrb(holder, icon, ring, segs, size)
    Safe.Try(holder, "SetDimensions", size, size)
    Safe.Try(icon, "SetDimensions", size, size)
    Safe.Try(ring, "SetDimensions", size, size)
    if type(segs) ~= "table" then
        return
    end
    for index = 1, #segs do
        Safe.Try(segs[index], "SetDimensions", size, size)
    end
end

-- Vanilla werewolf ability art. Not LycanMeter's files.
local ICON_TEXTURE = "/esoui/art/icons/ability_werewolf_001.dds"

local function PowerType(flagName)
    local value = _G[flagName]
    if type(value) == "number" then
        return value
    end
    return nil
end

local function NativeWerewolf()
    local control = _G.ZO_PlayerAttributeWerewolf
    if control and type(control.SetHidden) == "function" then
        return control
    end
    return nil
end

local function InForm()
    local value = Safe.Global("IsPlayerInWerewolfForm")
    return value and true or false
end

local function InCombat()
    if type(IsUnitInCombat) ~= "function" then
        return false
    end
    local ok, result = pcall(IsUnitInCombat, "player")
    if ok then
        return result and true or false
    end
    return false
end

function Werewolf:ShouldShow(wolfId, inForm)
    if wolfId == nil then
        wolfId = ValknarrThemeStore:WolfId()
    end
    if inForm == nil then
        inForm = InForm()
    end
    return Format.WidgetVisible(wolfId, inForm, Format.IsEditorScene())
end

-- Default layout only. Refresh / power / form events must not re-anchor
-- after ValknarrUIE has saved a position.
function Werewolf:Place(root)
    root = root or self.root
    if not root then
        return
    end
    Safe.Try(root, "SetDimensions", ROOT_W, ROOT_H)
    local screenW, screenH = 1920, 1080
    if GuiRoot then
        if type(GuiRoot.GetWidth) == "function" then
            local width = tonumber(GuiRoot:GetWidth())
            if width and width > 1 then
                screenW = width
            end
        end
        if type(GuiRoot.GetHeight) == "function" then
            local height = tonumber(GuiRoot:GetHeight())
            if height and height > 1 then
                screenH = height
            end
        end
    end
    Safe.Try(root, "ClearAnchors")
    Safe.Try(root, "SetAnchor", TOPLEFT, GuiRoot, TOPLEFT, DEFAULT_X * screenW, DEFAULT_Y * screenH)
end

function Werewolf:PlaceIfUnanchored(root)
    root = root or self.root
    local unanchored = ValknarrThemeResources and ValknarrThemeResources.IsUnanchored
    if unanchored and unanchored(root) then
        self:Place(root)
    end
end

function Werewolf:Ensure()
    if self.root then
        return self.root
    end
    local parent = GuiRoot
    if ValknarrThemeResources and ValknarrThemeResources.EnsureLayer then
        parent = ValknarrThemeResources:EnsureLayer() or GuiRoot
    end
    if not WINDOW_MANAGER or not parent then
        return nil
    end

    local root = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfRoot", parent, CT_CONTROL)
    if not root then
        return nil
    end
    Safe.Try(root, "SetMouseEnabled", false)
    Safe.Try(root, "SetMovable", false)
    Safe.Try(root, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(root, "SetDrawTier", DT_HIGH)
    Safe.Try(root, "SetDrawLevel", 100)
    Safe.Try(root, "SetAlpha", 1)
    self:Place(root)
    Safe.Try(root, "SetHidden", true)

    local iconHolder = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfOrb", root, CT_CONTROL)
    Safe.Try(iconHolder, "SetDimensions", ORB_SIZE, ORB_SIZE)
    Safe.Try(iconHolder, "SetAnchor", RIGHT, root, RIGHT, 0, 0)
    Safe.Try(iconHolder, "SetMouseEnabled", false)
    self.orb = iconHolder
    self.ring = nil

    local icon
    if Skins and Skins.CreateTexture then
        icon = Skins.CreateTexture(ADDON_NAME .. "WolfIcon", iconHolder, Skins.TEMPLATE.icon)
    else
        icon = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfIcon", iconHolder, CT_TEXTURE)
    end
    Safe.Try(icon, "SetAnchor", CENTER, iconHolder, CENTER, 0, 0)
    Safe.Try(icon, "SetDimensions", ORB_SIZE, ORB_SIZE)
    Safe.Try(icon, "SetTexture", ICON_TEXTURE)
    Safe.Try(icon, "SetColor", 1, 1, 1, 1)
    Safe.Try(icon, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(icon, "SetDrawTier", DT_HIGH)
    Safe.Try(icon, "SetDrawLevel", 106)
    self.icon = icon

    local ringFrame
    if Skins and Skins.CreateTexture then
        ringFrame = Skins.CreateTexture(ADDON_NAME .. "WolfRing", iconHolder, Skins.TEMPLATE.ring)
    else
        ringFrame = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfRing", iconHolder, CT_TEXTURE)
    end
    Safe.Try(ringFrame, "SetAnchor", CENTER, iconHolder, CENTER, 0, 0)
    Safe.Try(ringFrame, "SetDimensions", ORB_SIZE, ORB_SIZE)
    Safe.Try(ringFrame, "SetColor", 1, 1, 1, 1)
    Safe.Try(ringFrame, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(ringFrame, "SetDrawTier", DT_HIGH)
    Safe.Try(ringFrame, "SetDrawLevel", 108)
    Safe.Try(ringFrame, "SetHidden", true)
    self.ringFrame = ringFrame

    self.segments = {}
    for index = 1, Format.RING_SEGMENTS do
        local seg
        if Skins and Skins.CreateTexture then
            seg = Skins.CreateTexture(ADDON_NAME .. "WolfSeg" .. index, iconHolder, Skins.TEMPLATE.seg)
        else
            seg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfSeg" .. index, iconHolder, CT_TEXTURE)
        end
        Safe.Try(seg, "SetAnchor", CENTER, iconHolder, CENTER, 0, 0)
        Safe.Try(seg, "SetDimensions", ORB_SIZE, ORB_SIZE)
        Safe.Try(seg, "SetColor", 1, 1, 1, 1)
        Safe.Try(seg, "SetDrawLayer", DL_OVERLAY)
        Safe.Try(seg, "SetDrawTier", DT_HIGH)
        Safe.Try(seg, "SetDrawLevel", 107)
        Safe.Try(seg, "SetHidden", true)
        self.segments[index] = seg
    end

    local liquid = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfLiquid", iconHolder, CT_TEXTURE)
    OverlayTier(liquid, 110)
    Safe.Try(liquid, "SetColor", 1, 1, 1, 1)
    Safe.Try(liquid, "SetHidden", true)
    self.liquid = liquid

    local rim = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfLiquidRim", iconHolder, CT_BACKDROP)
    OverlayTier(rim, 111)
    Safe.Try(rim, "SetCenterColor", 1.0, 0.62, 0.32, 0.95)
    Safe.Try(rim, "SetEdgeColor", 0, 0, 0, 0)
    Safe.Try(rim, "SetEdgeTexture", nil, 1, 1, 1, 0)
    Safe.Try(rim, "SetHidden", true)
    self.liquidRim = rim

    local cleanUlt = Format.Fill("clean", "ult")
    local cleanFury = Format.Fill("clean", "fury")

    local ultBg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfUltBg", root, CT_BACKDROP)
    Safe.Try(ultBg, "SetAnchor", TOPRIGHT, iconHolder, TOPLEFT, -6, -12)
    Safe.Try(ultBg, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(ultBg, "SetCenterColor", 0.08, 0.06, 0.02, 0.82)
    Safe.Try(ultBg, "SetEdgeColor", 0.48, 0.38, 0.16, 0.9)
    Safe.Try(ultBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
    self.ultBg = ultBg

    local ultFill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfUltFill", root, CT_BACKDROP)
    Safe.Try(ultFill, "SetAnchor", LEFT, ultBg, LEFT, 2, 0)
    Safe.Try(ultFill, "SetDimensions", 8, BAR_H - 4)
    Safe.Try(ultFill, "SetCenterColor", cleanUlt[1], cleanUlt[2], cleanUlt[3], cleanUlt[4])
    Safe.Try(ultFill, "SetEdgeColor", 0, 0, 0, 0)
    Safe.Try(ultFill, "SetEdgeTexture", nil, 1, 1, 1, 0)
    OverlayTier(ultFill, 101)
    self.ultFill = ultFill

    local sustain = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfSustain", root, CT_LABEL)
    Safe.Try(sustain, "SetAnchor", CENTER, ultBg, CENTER, 0, 0)
    Safe.Try(sustain, "SetDimensions", BAR_W, BAR_H)
    if ValknarrThemeResources and ValknarrThemeResources.AlignBarLabel then
        ValknarrThemeResources.AlignBarLabel(sustain)
    else
        Safe.Try(sustain, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
        Safe.Try(sustain, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    end
    OverlayTier(sustain, 110)
    Safe.Try(sustain, "SetColor", SUSTAIN_OK[1], SUSTAIN_OK[2], SUSTAIN_OK[3], SUSTAIN_OK[4])
    if ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(sustain, Format.HudFonts("clean", BAR_H))
    elseif sustain and type(sustain.SetFont) == "function" then
        pcall(sustain.SetFont, sustain, "ZoFontGamepad22")
    end
    self.sustainLabel = sustain

    local barBg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfBarBg", root, CT_BACKDROP)
    Safe.Try(barBg, "SetAnchor", BOTTOMRIGHT, iconHolder, BOTTOMLEFT, -6, 12)
    Safe.Try(barBg, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(barBg, "SetCenterColor", 0.08, 0.02, 0.02, 0.82)
    Safe.Try(barBg, "SetEdgeColor", 0.32, 0.12, 0.10, 0.9)
    Safe.Try(barBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
    self.barBg = barBg

    local fill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfFill", root, CT_BACKDROP)
    Safe.Try(fill, "SetAnchor", LEFT, barBg, LEFT, 2, 0)
    Safe.Try(fill, "SetDimensions", 8, BAR_H - 4)
    Safe.Try(fill, "SetCenterColor", cleanFury[1], cleanFury[2], cleanFury[3], cleanFury[4])
    Safe.Try(fill, "SetEdgeColor", 0, 0, 0, 0)
    Safe.Try(fill, "SetEdgeTexture", nil, 1, 1, 1, 0)
    OverlayTier(fill, 101)
    self.fill = fill

    local fury = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfFury", root, CT_LABEL)
    Safe.Try(fury, "SetAnchor", CENTER, barBg, CENTER, 0, 0)
    Safe.Try(fury, "SetDimensions", BAR_W, BAR_H)
    if ValknarrThemeResources and ValknarrThemeResources.AlignBarLabel then
        ValknarrThemeResources.AlignBarLabel(fury)
    else
        Safe.Try(fury, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
        Safe.Try(fury, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    end
    OverlayTier(fury, 110)
    Safe.Try(fury, "SetColor", 0.92, 0.86, 0.82, 1)
    if ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(fury, Format.HudFonts("clean", BAR_H))
    elseif fury and type(fury.SetFont) == "function" then
        pcall(fury.SetFont, fury, "ZoFontGamepad22")
    end
    self.furyLabel = fury

    self.plateHost, self.plateTiles = MakePlate(root)

    self.root = root
    if Log then
        Log:Debug("werewolf widget created")
    end
    return root
end

function Werewolf:ReadFury()
    local powerType = PowerType("COMBAT_MECHANIC_FLAGS_WEREWOLF")
    if not powerType or type(GetUnitPower) ~= "function" then
        return 0, 1000
    end
    local ok, current, maximum = pcall(GetUnitPower, "player", powerType)
    if not ok then
        return 0, 1000
    end
    return tonumber(current) or 0, tonumber(maximum) or 1000
end

function Werewolf:ReadUltimate()
    local powerType = PowerType("COMBAT_MECHANIC_FLAGS_ULTIMATE")
    if not powerType or type(GetUnitPower) ~= "function" then
        return 0, 0
    end
    local ok, current, maximum = pcall(GetUnitPower, "player", powerType)
    if not ok then
        return 0, 0
    end
    return tonumber(current) or 0, tonumber(maximum) or 0
end

function Werewolf:LockNative(native)
    if not native or native.ValknarrThemeLocked then
        return
    end
    native.ValknarrThemeLocked = true
    local origHidden = native.SetHidden
    if type(origHidden) == "function" then
        native.SetHidden = function(ctrl, hidden)
            if Werewolf:ShouldShow() then
                return origHidden(ctrl, true)
            end
            return origHidden(ctrl, hidden)
        end
    end
    local origAlpha = native.SetAlpha
    if type(origAlpha) == "function" then
        native.SetAlpha = function(ctrl, alpha)
            if Werewolf:ShouldShow() then
                return origAlpha(ctrl, 0)
            end
            return origAlpha(ctrl, alpha)
        end
    end
    if type(ZO_PreHook) == "function" then
        pcall(ZO_PreHook, native, "SetHidden", function(_ctrl, hidden)
            if Werewolf:ShouldShow() and not hidden then
                return true
            end
        end)
        pcall(ZO_PreHook, native, "SetAlpha", function(_ctrl, alpha)
            if Werewolf:ShouldShow() and (tonumber(alpha) or 0) > 0 then
                return true
            end
        end)
    end
end

function Werewolf:SyncNativeBar(showOurs)
    local native = NativeWerewolf()
    if not native then
        self.hidNative = false
        return
    end
    self:LockNative(native)
    if showOurs then
        Safe.Try(native, "SetHidden", true)
        Safe.Try(native, "SetAlpha", 0)
        self.hidNative = true
        return
    end
    if self.hidNative then
        Safe.Try(native, "SetAlpha", 1)
        if InForm() then
            Safe.Try(native, "SetHidden", false)
        end
        self.hidNative = false
    end
end

function Werewolf:StopBlink()
    if self.blinkRegistered and EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, ADDON_NAME .. "WolfBlink")
    end
    self.blinkRegistered = false
    self.blinkOn = false
end

local function LayoutCleanBar(bg, fill, label, pct, color, bgCenter, bgEdge)
    Safe.Try(bg, "SetHidden", false)
    if bgCenter then
        Safe.Try(bg, "SetCenterColor", bgCenter[1], bgCenter[2], bgCenter[3], bgCenter[4])
    end
    if bgEdge then
        Safe.Try(bg, "SetEdgeColor", bgEdge[1], bgEdge[2], bgEdge[3], bgEdge[4])
        Safe.Try(bg, "SetEdgeTexture", nil, 1, 1, 1, 0)
    end
    Safe.Try(fill, "ClearAnchors")
    Safe.Try(fill, "SetAnchor", LEFT, bg, LEFT, 2, 0)
    Safe.Try(fill, "SetDimensions", math.max(8, math.floor(((BAR_W - 4) * pct) / 100)), BAR_H - 4)
    if color then
        Safe.Try(fill, "SetCenterColor", color[1], color[2], color[3], color[4])
    end
    Safe.Try(fill, "SetHidden", false)
    if label then
        Safe.Try(label, "ClearAnchors")
        Safe.Try(label, "SetAnchor", CENTER, bg, CENTER, 0, 0)
        Safe.Try(label, "SetDimensions", BAR_W, BAR_H)
    end
end

function Werewolf:ClearFrameBinds()
    local tiles = self.plateTiles
    if type(tiles) == "table" then
        for index = 1, #tiles do
            if Skins and Skins.ClearBind then
                Skins.ClearBind(tiles[index])
            end
        end
    end
    self.frameArmed = nil
    self.frameRebind = nil
    self.frameSkin = nil
    self.framed = false
end

function Werewolf:AnyFrameMissing()
    if not Format.WolfMetal(ValknarrThemeStore:WolfId()) then
        return false
    end
    return not self.framed
end

function Werewolf:StopFrameRetry()
    local ticks = self.frameRetryTick or 0
    local wasRetrying = self.frameRetrying
    if self.frameRetrying and EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, ADDON_NAME .. "WolfRetry")
    end
    self.frameRetrying = false
    if wasRetrying and ticks >= 8 and self:AnyFrameMissing() and Log then
        Log:Warn("wolf frame tiles still missed after retry")
    end
end

function Werewolf:StartFrameRetry()
    if self.frameRetrying then
        return
    end
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    self.frameRetrying = true
    self.frameRetryTick = 0
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "WolfRetry", 400, function()
        Werewolf.frameRetryTick = (Werewolf.frameRetryTick or 0) + 1
        Werewolf.frameRebind = true
        Werewolf:Refresh()
        if Werewolf.frameRetryTick >= 8 or not Werewolf:AnyFrameMissing() then
            Werewolf:StopFrameRetry()
        end
    end)
end

function Werewolf:BindPlate(wolfId)
    local pack = Skins and Skins.WolfPlate and Skins.WolfPlate(wolfId)
    local want = Format.WolfMetal(wolfId)
    if not (want and pack and self.plateTiles and Skins.BindBarTiles) then
        if self.frameArmed or self.framed or self.frameSkin then
            self:StopFrameRetry()
            self:ClearFrameBinds()
        end
        return false, nil
    end
    if self.frameSkin ~= wolfId then
        self:ClearFrameBinds()
        self.frameSkin = wolfId
    end
    local framed
    if not self.frameArmed or self.frameRebind then
        self.frameArmed = true
        self.frameRebind = nil
        framed = Skins.BindBarTiles(self.plateTiles, pack, "wolf/plate")
    else
        framed = TilesBound(self.plateTiles)
    end
    self.framed = framed
    if want and not framed then
        if Log and not self.frameMissLogged then
            self.frameMissLogged = true
            Log:Debug("wolf plate tiles missed; using clean layout; retrying")
        end
        self:StartFrameRetry()
    else
        self.frameMissLogged = nil
        if framed then
            self:StopFrameRetry()
        end
    end
    return framed, pack
end

function Werewolf:PaintWarning(on)
    local wolfId = ValknarrThemeStore:WolfId()
    local fill = on and FILL_WARN or Format.Fill(wolfId, "ult")
    local text = on and SUSTAIN_WARN or SUSTAIN_OK
    if self.ultFill then
        Safe.Try(self.ultFill, "SetCenterColor", fill[1], fill[2], fill[3], fill[4])
    end
    if self.ultBg and not self.framed then
        if on then
            Safe.Try(self.ultBg, "SetEdgeColor", 0.72, 0.32, 0.18, 1)
        else
            Safe.Try(self.ultBg, "SetEdgeColor", fill[1] * 0.8, fill[2] * 0.8, fill[3] * 0.8, 0.9)
        end
    end
    if self.sustainLabel then
        Safe.Try(self.sustainLabel, "SetColor", text[1], text[2], text[3], text[4])
    end
end

function Werewolf:PulseWarning()
    if not self.warning or not self:ShouldShow() then
        self:StopBlink()
        self:PaintWarning(false)
        return
    end
    self.blinkOn = not self.blinkOn
    self:PaintWarning(self.blinkOn)
end

function Werewolf:SetWarning(on)
    on = on and true or false
    if on then
        self.warning = true
        if not self.blinkRegistered and EVENT_MANAGER and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "WolfBlink", BLINK_MS, function()
                Werewolf:PulseWarning()
            end)
            self.blinkRegistered = true
        end
        self:PaintWarning(true)
        return
    end
    self.warning = false
    self:StopBlink()
    self:PaintWarning(false)
end

function Werewolf:PaintRing(furyPct, wedgePath, show, count)
    count = tonumber(count) or Format.RING_SEGMENTS
    local filled = 0
    if show then
        filled = Format.RingFilled(furyPct, count)
    end
    local twoPi = 2 * math.pi
    local segs = self.segments or {}
    for index = 1, Format.RING_SEGMENTS do
        local seg = segs[index]
        if seg then
            local showSeg = show and index <= filled and index <= count
            Safe.Try(seg, "SetHidden", not showSeg)
            if showSeg and Skins and wedgePath then
                local bind = Skins.Rebind or Skins.Bind
                bind(seg, wedgePath, "wolf/wedge")
                Safe.Try(seg, "SetTextureRotation", (index - 1) * (twoPi / count))
            end
        end
    end
    return filled
end

function Werewolf:HideLiquid()
    Safe.Try(self.liquid, "SetHidden", true)
    Safe.Try(self.liquidRim, "SetHidden", true)
end

function Werewolf:PaintPortrait(wolfId)
    local icon = self.icon
    if not icon then
        return
    end
    local pack = Skins and Skins.WolfPack and Skins.WolfPack(wolfId)
    local path = pack and pack.portrait
    if not path then
        Safe.Try(icon, "SetHidden", true)
        return
    end
    local size = 0
    if self.orb and type(self.orb.GetWidth) == "function" then
        size = tonumber(self.orb:GetWidth()) or 0
    end
    if size < 8 then
        size = ORB_SIZE
    end
    local inner = math.max(8, math.floor(size * Format.WolfLiquidScale(wolfId)))
    OverlayTier(icon, 112)
    local bind = (Skins and (Skins.Rebind or Skins.Bind)) or nil
    if bind then
        bind(icon, path, "wolf/portrait")
    end
    Safe.Try(icon, "ClearAnchors")
    Safe.Try(icon, "SetAnchor", CENTER, self.orb, CENTER, 0, 0)
    Safe.Try(icon, "SetDimensions", inner, inner)
    Safe.Try(icon, "SetHidden", false)
end

function Werewolf:PaintLiquid(furyPct, wolfId)
    local liquid = self.liquid
    if not liquid then
        return 0
    end
    local pct = (tonumber(furyPct) or 0) / 100
    if pct < 0 then
        pct = 0
    end
    if pct > 1 then
        pct = 1
    end
    if pct < 0.02 then
        self:HideLiquid()
        return 0
    end
    local size = 0
    if self.orb and type(self.orb.GetWidth) == "function" then
        size = tonumber(self.orb:GetWidth()) or 0
    end
    if size < 8 then
        size = ORB_SIZE
    end
    local inner = math.max(8, math.floor(size * Format.WolfLiquidScale(wolfId)))
    local height = math.max(2, math.floor(inner * pct))
    local inset = math.floor((size - inner) * 0.5)
    local path = "/ValknarrTheme/texture/liq.dds"
    local pack = Skins and Skins.WolfPack and Skins.WolfPack(wolfId)
    if pack and pack.liquid then
        path = pack.liquid
    end
    local bind = (Skins and (Skins.Rebind or Skins.Bind)) or nil
    if bind then
        bind(liquid, path, "wolf/liquid")
    end
    OverlayTier(liquid, 110)
    Safe.Try(liquid, "ClearAnchors")
    Safe.Try(liquid, "SetAnchor", BOTTOM, self.orb, BOTTOM, 0, -inset)
    Safe.Try(liquid, "SetDimensions", inner, height)
    Safe.Try(liquid, "SetTextureCoords", 0, 1, 1 - pct, 1)
    Safe.Try(liquid, "SetHidden", false)

    local rim = self.liquidRim
    if rim then
        local radius = inner * 0.5
        local fromCenter = height - radius
        local under = radius * radius - fromCenter * fromCenter
        local chord = 0
        if under > 0 then
            chord = math.floor(math.sqrt(under) * 2 * 0.92)
        end
        if chord >= 10 and pct < 0.98 then
            OverlayTier(rim, 111)
            Safe.Try(rim, "ClearAnchors")
            Safe.Try(rim, "SetAnchor", TOP, liquid, TOP, 0, 0)
            Safe.Try(rim, "SetDimensions", chord, 3)
            Safe.Try(rim, "SetHidden", false)
        else
            Safe.Try(rim, "SetHidden", true)
        end
    end
    return math.floor(pct * 100)
end

function Werewolf:LayoutPlate(pack, furyPct, ultPct, wolfId)
    Safe.Try(self.ultBg, "SetHidden", true)
    Safe.Try(self.barBg, "SetHidden", true)
    Safe.Try(self.fill, "SetHidden", true)
    Safe.Try(self.furyLabel, "SetHidden", true)
    Safe.Try(self.icon, "SetHidden", true)
    Safe.Try(self.ringFrame, "SetHidden", true)

    local host = self.plateHost
    local tiles = self.plateTiles
    Safe.Try(host, "SetHidden", false)
    Safe.Try(host, "ClearAnchors")
    Safe.Try(host, "SetAnchor", CENTER, self.root, CENTER, 0, 0)
    Safe.Try(host, "SetDimensions", PLATE_W, PLATE_H)
    for index = 1, #tiles do
        local piece = tiles[index]
        local col = (index - 1) % PLATE_COLS
        local row = math.floor((index - 1) / PLATE_COLS)
        Safe.Try(piece, "SetHidden", false)
        Safe.Try(piece, "ClearAnchors")
        Safe.Try(piece, "SetAnchor", TOPLEFT, host, TOPLEFT, col * PLATE_TILE, row * PLATE_TILE)
        Safe.Try(piece, "SetDimensions", PLATE_TILE, PLATE_TILE)
    end

    local hole = pack.hole
    local x = hole[1] * PLATE_W + 2
    local y = hole[2] * PLATE_H + 2
    local wellW = (hole[3] - hole[1]) * PLATE_W - 4
    local wellH = (hole[4] - hole[2]) * PLATE_H - 4
    local ultColor = Format.Fill(wolfId, "ult")
    Safe.Try(self.ultFill, "ClearAnchors")
    Safe.Try(self.ultFill, "SetAnchor", TOPLEFT, host, TOPLEFT, x, y)
    Safe.Try(self.ultFill, "SetDimensions", math.max(8, math.floor((wellW * ultPct) / 100)), wellH)
    Safe.Try(self.ultFill, "SetCenterColor", ultColor[1], ultColor[2], ultColor[3], ultColor[4])
    Safe.Try(self.ultFill, "SetHidden", false)
    if self.sustainLabel then
        local ox = math.floor(x + wellW * 0.5 - PLATE_W * 0.5)
        local oy = math.floor(y + wellH * 0.5 - PLATE_H * 0.5)
        Safe.Try(self.sustainLabel, "ClearAnchors")
        Safe.Try(self.sustainLabel, "SetAnchor", CENTER, host, CENTER, ox, oy)
        Safe.Try(self.sustainLabel, "SetDimensions", wellW, wellH)
        if ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
            ValknarrThemeResources.SetGamepadFont(self.sustainLabel, Format.HudFonts(wolfId, wellH))
        end
    end

    local circle = pack.circle or { 0.75, 0.50, 0.24 }
    local cx = circle[1] * PLATE_W
    local cy = circle[2] * PLATE_H
    local radius = circle[3] * PLATE_W
    local orb = math.max(48, math.floor(radius * 2))
    Safe.Try(self.orb, "ClearAnchors")
    Safe.Try(self.orb, "SetAnchor", TOPLEFT, host, TOPLEFT, math.floor(cx - orb * 0.5), math.floor(cy - orb * 0.5))
    SizeOrb(self.orb, self.icon, self.ringFrame, self.segments, orb)
    if Format.WolfLiquid(wolfId) then
        self:PaintRing(furyPct, nil, false)
        self:PaintPortrait(wolfId)
        return self:PaintLiquid(furyPct, wolfId)
    end
    self:HideLiquid()
    OverlayTier(self.icon, 106)
    Safe.Try(self.icon, "SetHidden", true)
    local wolf = Skins and Skins.WolfPack and Skins.WolfPack(wolfId)
    if Format.WolfRunes(wolfId) then
        return self:PaintRing(furyPct, wolf and wolf.wedge, true, Format.RUNE_SEGMENTS)
    end
    return self:PaintRing(furyPct, wolf and wolf.wedge, true)
end

function Werewolf:LayoutClean(furyPct, ultPct, wolfId)
    HideTiles(self.plateTiles, self.plateHost)
    self:HideLiquid()
    OverlayTier(self.icon, 106)
    Safe.Try(self.icon, "SetHidden", false)
    Safe.Try(self.ringFrame, "SetHidden", true)
    Safe.Try(self.orb, "ClearAnchors")
    Safe.Try(self.orb, "SetAnchor", RIGHT, self.root, RIGHT, 0, 0)
    SizeOrb(self.orb, self.icon, self.ringFrame, self.segments, ORB_SIZE)
    if Skins and self.icon then
        local bind = Skins.Rebind or Skins.Bind
        bind(self.icon, ICON_TEXTURE, "wolf/icon")
    end
    local ultColor = Format.Fill(wolfId, "ult")
    local furyColor = Format.Fill(wolfId, "fury")
    LayoutCleanBar(
        self.ultBg, self.ultFill, self.sustainLabel, ultPct, ultColor,
        { 0.08, 0.06, 0.02, 0.82 },
        { ultColor[1] * 0.7, ultColor[2] * 0.7, ultColor[3] * 0.7, 0.9 }
    )
    LayoutCleanBar(
        self.barBg, self.fill, self.furyLabel, furyPct, furyColor,
        { 0.08, 0.02, 0.02, 0.82 },
        { furyColor[1] * 0.7, furyColor[2] * 0.7, furyColor[3] * 0.7, 0.9 }
    )
    if self.sustainLabel and ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(self.sustainLabel, Format.HudFonts("clean", BAR_H))
    end
    if self.furyLabel and ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(self.furyLabel, Format.HudFonts("clean", BAR_H))
    end
    return self:PaintRing(furyPct, nil, false)
end

function Werewolf:ApplySkin(furyPct, ultPct)
    local wolfId = ValknarrThemeStore:WolfId()
    furyPct = furyPct or 0
    ultPct = ultPct or 0
    local framed, pack = self:BindPlate(wolfId)
    local filled
    if framed and pack then
        filled = self:LayoutPlate(pack, furyPct, ultPct, wolfId)
    else
        filled = self:LayoutClean(furyPct, ultPct, wolfId)
    end

    if self.lastWolfId ~= wolfId then
        if Log then
            local meter
            if Format.WolfLiquid(wolfId) then
                meter = "liquid=" .. tostring(furyPct) .. "%"
            else
                meter = "filled=" .. tostring(filled) .. "/" .. tostring(Format.RING_SEGMENTS)
            end
            Log:Debug(
                "wolf plate skin=" .. wolfId
                .. " " .. meter
                .. " fury=" .. tostring(furyPct) .. "%"
                .. " plated=" .. tostring(framed)
            )
        end
        self.lastWolfId = wolfId
    elseif Log and Log.Debug then
        Log:Debug("wolf plate filled=" .. tostring(filled) .. " fury=" .. tostring(furyPct))
    end
    self:ApplyLabels()
end

function Werewolf:ApplyLabels()
    local showText = Format.ShowBarText()
    if self.sustainLabel then
        Safe.Try(self.sustainLabel, "SetHidden", not showText)
    end
    if self.furyLabel then
        Safe.Try(self.furyLabel, "SetHidden", self.framed or not showText)
    end
end

function Werewolf:SyncHudVisibility(hud)
    if Format.IsEditorScene() then
        self:Refresh()
        return
    end
    if hud == nil then
        hud = Format.HudSceneVisible()
    end
    if self.root then
        Safe.Try(self.root, "SetHidden", not (self:ShouldShow() and hud))
    end
end

function Werewolf:Refresh()
    local show = self:ShouldShow()
    local root = self:Ensure()
    if root then
        self:PlaceIfUnanchored(root)
        Safe.Try(root, "SetHidden", not (show and Format.HudSceneVisible()))
    end
    self:SyncNativeBar(show)
    if not show then
        self:SetWarning(false)
        self:StopFrameRetry()
        return
    end

    local furyCurrent, furyMax = self:ReadFury()
    local pct = Format.Percent(furyCurrent, furyMax)
    local ultimate, ultMax = self:ReadUltimate()
    local ultPct = Format.Percent(ultimate, ultMax)
    local inCombat = InCombat()
    if self.furyLabel then
        Safe.Try(self.furyLabel, "SetText", Format.FuryLine(furyCurrent, furyMax))
    end
    if self.sustainLabel then
        Safe.Try(self.sustainLabel, "SetText", Format.SustainLine(ultimate, inCombat))
    end
    self:ApplySkin(pct, ultPct)
    self:SetWarning(Format.SustainIsLow(ultimate, inCombat))
end

function Werewolf:OnPowerUpdate(_event, unitTag, _powerIndex, powerType)
    if unitTag and unitTag ~= "player" then
        return
    end
    if not self:ShouldShow() then
        return
    end
    local fury = PowerType("COMBAT_MECHANIC_FLAGS_WEREWOLF")
    local ult = PowerType("COMBAT_MECHANIC_FLAGS_ULTIMATE")
    if powerType == fury or powerType == ult then
        self:Refresh()
    end
end

function Werewolf:Describe()
    local native = NativeWerewolf()
    local root = self.root
    local furyCurrent, furyMax = self:ReadFury()
    local ultimate, ultMax = self:ReadUltimate()
    local nativeBits = Log and Log.ControlBits and Log:ControlBits(native) or { present = native ~= nil }
    local rootBits = Log and Log.ControlBits and Log:ControlBits(root) or { present = root ~= nil }
    return {
        shouldShow = self:ShouldShow() and true or false,
        inForm = InForm() and true or false,
        inCombat = InCombat() and true or false,
        hidNative = self.hidNative and true or false,
        native = nativeBits.name or (nativeBits.present and "yes" or "missing"),
        nativeHidden = nativeBits.hidden,
        widget = rootBits.name or (rootBits.present and "yes" or "missing"),
        widgetHidden = rootBits.hidden,
        fury = furyCurrent,
        furyMax = furyMax,
        ultimate = ultimate,
        ultMax = ultMax,
        warning = self.warning and true or false,
        hostRegistered = self.hostRegistered and true or false,
        skin = ValknarrThemeStore:WolfId(),
        ringFilled = Format.RingFilled(Format.Percent(furyCurrent, furyMax)),
        framed = self.framed and true or false,
        hudVisible = Format.HudSceneVisible() and true or false,
        barText = Format.ShowBarText() and true or false,
        iconTex = self.icon and self.icon.ValknarrBoundTex or nil,
        ringTex = self.ringFrame and self.ringFrame.ValknarrBoundTex or nil,
        plateTile = self.plateTiles and self.plateTiles[1] and self.plateTiles[1].ValknarrBoundTex or nil,
    }
end

function Werewolf:RegisterHost()
    local lib = _G.LibValknarrUIE
    if not lib or type(lib.RegisterElement) ~= "function" then
        return false
    end
    if self.hostRegistered then
        return true
    end
    lib:RegisterAddon(ADDON_NAME, "Valknarr Theme")
    lib:RegisterElement(ADDON_NAME, ELEMENT_ID, {
        name = "Werewolf meter",
        resizable = false,
        replaces = "werewolf",
        active = function()
            return Format.NormalizeWolfId(ValknarrThemeStore:WolfId()) ~= Format.WOLF_VANILLA
        end,
        locate = function()
            return Werewolf:Ensure()
        end,
        default = { x = DEFAULT_X, y = DEFAULT_Y },
    })
    self.hostRegistered = true
    if Log then
        Log:Info("registered " .. HOST_ADDON .. " guest " .. ADDON_NAME .. ":" .. ELEMENT_ID)
    end
    return true
end

function Werewolf:RegisterEvents()
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return
    end
    if self.eventsRegistered then
        return
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WolfPower", EVENT_POWER_UPDATE, function(...)
        Werewolf:OnPowerUpdate(...)
    end)
    if type(EVENT_MANAGER.AddFilterForEvent) == "function" and REGISTER_FILTER_UNIT_TAG then
        pcall(EVENT_MANAGER.AddFilterForEvent, EVENT_MANAGER, ADDON_NAME .. "WolfPower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    end
    if EVENT_WEREWOLF_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WolfForm", EVENT_WEREWOLF_STATE_CHANGED, function()
            Werewolf:Refresh()
        end)
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WolfCombat", EVENT_PLAYER_COMBAT_STATE, function()
            Werewolf:Refresh()
        end)
    end
    self.eventsRegistered = true
end

return Werewolf
