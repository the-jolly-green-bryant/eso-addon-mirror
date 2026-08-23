-- Form-only werewolf widget: Fury bar + Ultimate bar, plus the werewolf icon.
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
local ROOT_H = 104
local ORB_SIZE = 96
local BAR_W = 228
local BAR_H = 36
local DEFAULT_X = 0.16
local DEFAULT_Y = 0.72
local BLINK_MS = 400
local FURY_FILL = { 0.78, 0.12, 0.12, 0.95 }
local ULT_FILL = { 0.90, 0.72, 0.16, 0.95 }
local FILL_WARN = { 1, 0.28, 0.12, 1 }
local SUSTAIN_OK = { 1, 0.92, 0.55, 1 }
local SUSTAIN_WARN = { 1, 0.32, 0.22, 1 }

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
    return Format.WidgetVisible(wolfId, inForm)
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

    local ultBg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfUltBg", root, CT_BACKDROP)
    Safe.Try(ultBg, "SetAnchor", TOPRIGHT, iconHolder, TOPLEFT, -6, 4)
    Safe.Try(ultBg, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(ultBg, "SetCenterColor", 0.08, 0.06, 0.02, 0.82)
    Safe.Try(ultBg, "SetEdgeColor", 0.55, 0.42, 0.12, 0.9)
    Safe.Try(ultBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
    self.ultBg = ultBg

    local ultFill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfUltFill", root, CT_BACKDROP)
    Safe.Try(ultFill, "SetAnchor", LEFT, ultBg, LEFT, 2, 0)
    Safe.Try(ultFill, "SetDimensions", 8, BAR_H - 4)
    Safe.Try(ultFill, "SetCenterColor", ULT_FILL[1], ULT_FILL[2], ULT_FILL[3], ULT_FILL[4])
    Safe.Try(ultFill, "SetEdgeColor", 0, 0, 0, 0)
    Safe.Try(ultFill, "SetEdgeTexture", nil, 1, 1, 1, 0)
    Safe.Try(ultFill, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(ultFill, "SetDrawTier", DT_HIGH)
    self.ultFill = ultFill

    local sustain = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfSustain", ultBg, CT_LABEL)
    Safe.Try(sustain, "SetAnchor", CENTER, ultBg, CENTER, 0, 0)
    Safe.Try(sustain, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(sustain, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
    Safe.Try(sustain, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(sustain, "SetDrawTier", DT_HIGH)
    Safe.Try(sustain, "SetDrawLevel", 110)
    Safe.Try(sustain, "SetColor", SUSTAIN_OK[1], SUSTAIN_OK[2], SUSTAIN_OK[3], SUSTAIN_OK[4])
    if ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(sustain, "ZoFontGamepad27")
    elseif sustain and type(sustain.SetFont) == "function" then
        pcall(sustain.SetFont, sustain, "ZoFontGamepad27")
    end
    self.sustainLabel = sustain

    local barBg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfBarBg", root, CT_BACKDROP)
    Safe.Try(barBg, "SetAnchor", BOTTOMRIGHT, iconHolder, BOTTOMLEFT, -6, -4)
    Safe.Try(barBg, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(barBg, "SetCenterColor", 0.08, 0.02, 0.02, 0.82)
    Safe.Try(barBg, "SetEdgeColor", 0.35, 0.1, 0.1, 0.9)
    Safe.Try(barBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
    self.barBg = barBg

    local fill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfFill", root, CT_BACKDROP)
    Safe.Try(fill, "SetAnchor", LEFT, barBg, LEFT, 2, 0)
    Safe.Try(fill, "SetDimensions", 8, BAR_H - 4)
    Safe.Try(fill, "SetCenterColor", FURY_FILL[1], FURY_FILL[2], FURY_FILL[3], FURY_FILL[4])
    Safe.Try(fill, "SetEdgeColor", 0, 0, 0, 0)
    Safe.Try(fill, "SetEdgeTexture", nil, 1, 1, 1, 0)
    Safe.Try(fill, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(fill, "SetDrawTier", DT_HIGH)
    self.fill = fill

    local fury = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "WolfFury", barBg, CT_LABEL)
    Safe.Try(fury, "SetAnchor", CENTER, barBg, CENTER, 0, 0)
    Safe.Try(fury, "SetDimensions", BAR_W, BAR_H)
    Safe.Try(fury, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
    Safe.Try(fury, "SetDrawLayer", DL_OVERLAY)
    Safe.Try(fury, "SetDrawTier", DT_HIGH)
    Safe.Try(fury, "SetDrawLevel", 110)
    Safe.Try(fury, "SetColor", 1, 0.92, 0.92, 1)
    if ValknarrThemeResources and ValknarrThemeResources.SetGamepadFont then
        ValknarrThemeResources.SetGamepadFont(fury, "ZoFontGamepad27")
    elseif fury and type(fury.SetFont) == "function" then
        pcall(fury.SetFont, fury, "ZoFontGamepad27")
    end
    self.furyLabel = fury

    local function MakeChrome(name, parent)
        local chrome
        if Skins and Skins.CreateTexture then
            chrome = Skins.CreateTexture(name, parent, Skins.TEMPLATE.hudRim)
        else
            chrome = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
        end
        Safe.Try(chrome, "SetDimensions", BAR_W + 28, BAR_H + 16)
        Safe.Try(chrome, "SetColor", 1, 1, 1, 1)
        Safe.Try(chrome, "SetAnchor", TOPLEFT, parent, TOPLEFT, -14, -8)
        Safe.Try(chrome, "SetAnchor", BOTTOMRIGHT, parent, BOTTOMRIGHT, 14, 8)
        Safe.Try(chrome, "SetDrawLayer", DL_OVERLAY)
        Safe.Try(chrome, "SetDrawTier", DT_HIGH)
        Safe.Try(chrome, "SetDrawLevel", 109)
        Safe.Try(chrome, "SetHidden", true)
        return chrome
    end
    self.ultChrome = MakeChrome(ADDON_NAME .. "WolfUltChrome", ultBg)
    self.furyChrome = MakeChrome(ADDON_NAME .. "WolfFuryChrome", barBg)

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

function Werewolf:PaintWarning(on)
    local fill = on and FILL_WARN or ULT_FILL
    local text = on and SUSTAIN_WARN or SUSTAIN_OK
    if self.ultFill then
        Safe.Try(self.ultFill, "SetCenterColor", fill[1], fill[2], fill[3], fill[4])
    end
    if self.ultBg then
        if on then
            Safe.Try(self.ultBg, "SetEdgeColor", 1, 0.35, 0.18, 1)
        else
            Safe.Try(self.ultBg, "SetEdgeColor", 0.55, 0.42, 0.12, 0.9)
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

function Werewolf:ApplySkin(pct)
    local wolfId = ValknarrThemeStore:WolfId()
    local pack = Skins and Skins.WolfPack(wolfId)
    local metal = pack ~= nil
    local iconPath = ICON_TEXTURE
    if pack and pack.icon then
        iconPath = pack.icon
    end
    if Skins and self.icon then
        local bind = Skins.Rebind or Skins.Bind
        bind(self.icon, iconPath, "wolf/icon")
    end
    if self.ringFrame then
        Safe.Try(self.ringFrame, "SetHidden", not metal)
        if metal and Skins then
            local bind = Skins.Rebind or Skins.Bind
            bind(self.ringFrame, pack.ring, "wolf/ring")
        end
    end
    local filled = 0
    if metal then
        filled = Format.RingFilled(pct)
    end
    local twoPi = 2 * math.pi
    local segs = self.segments or {}
    for index = 1, Format.RING_SEGMENTS do
        local seg = segs[index]
        if seg then
            local showSeg = metal and index <= filled
            Safe.Try(seg, "SetHidden", not showSeg)
            if showSeg and Skins then
                local bind = Skins.Rebind or Skins.Bind
                bind(seg, pack.wedge, "wolf/wedge")
                Safe.Try(seg, "SetTextureRotation", (index - 1) * (twoPi / Format.RING_SEGMENTS))
            end
        end
    end
    -- HUD chrome looks wrong stretched over these short bars. Keep a thin
    -- bronze edge only; the painted wolf + ring is the metal look.
    if self.ultChrome then
        Safe.Try(self.ultChrome, "SetHidden", true)
    end
    if self.furyChrome then
        Safe.Try(self.furyChrome, "SetHidden", true)
    end
    if self.ultBg then
        if metal then
            Safe.Try(self.ultBg, "SetCenterColor", 0.08, 0.06, 0.03, 0.90)
            Safe.Try(self.ultBg, "SetEdgeColor", 0.72, 0.58, 0.32, 0.95)
            Safe.Try(self.ultBg, "SetEdgeTexture", nil, 1, 1, 2, 0)
        else
            Safe.Try(self.ultBg, "SetCenterColor", 0.08, 0.06, 0.02, 0.82)
            Safe.Try(self.ultBg, "SetEdgeColor", 0.55, 0.42, 0.12, 0.9)
            Safe.Try(self.ultBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
        end
    end
    if self.barBg then
        if metal then
            Safe.Try(self.barBg, "SetCenterColor", 0.10, 0.03, 0.03, 0.90)
            Safe.Try(self.barBg, "SetEdgeColor", 0.62, 0.28, 0.16, 0.95)
            Safe.Try(self.barBg, "SetEdgeTexture", nil, 1, 1, 2, 0)
        else
            Safe.Try(self.barBg, "SetCenterColor", 0.08, 0.02, 0.02, 0.82)
            Safe.Try(self.barBg, "SetEdgeColor", 0.35, 0.1, 0.1, 0.9)
            Safe.Try(self.barBg, "SetEdgeTexture", nil, 1, 1, 1, 0)
        end
    end
    if self.lastWolfId ~= wolfId then
        if Log then
            Log:Always(
                "wolf ring skin=" .. wolfId
                .. " filled=" .. tostring(filled) .. "/" .. tostring(Format.RING_SEGMENTS)
                .. " fury=" .. tostring(pct) .. "%"
                .. " metal=" .. tostring(metal)
            )
        end
        self.lastWolfId = wolfId
    elseif Log and Log.Debug then
        Log:Debug("wolf ring filled=" .. tostring(filled) .. " fury=" .. tostring(pct))
    end
end

function Werewolf:Refresh()
    local show = self:ShouldShow()
    local root = self:Ensure()
    if root then
        self:PlaceIfUnanchored(root)
        Safe.Try(root, "SetHidden", not show)
    end
    self:SyncNativeBar(show)
    if not show then
        self:SetWarning(false)
        return
    end

    local furyCurrent, furyMax = self:ReadFury()
    local pct = Format.Percent(furyCurrent, furyMax)
    local ultimate, ultMax = self:ReadUltimate()
    local ultPct = Format.Percent(ultimate, ultMax)
    local inCombat = InCombat()
    local inner = BAR_W - 4
    if self.fill then
        local width = math.max(8, math.floor((pct / 100) * inner))
        Safe.Try(self.fill, "SetDimensions", width, BAR_H - 4)
        Safe.Try(self.fill, "SetHidden", false)
    end
    if self.ultFill then
        local width = math.max(8, math.floor((ultPct / 100) * inner))
        Safe.Try(self.ultFill, "SetDimensions", width, BAR_H - 4)
        Safe.Try(self.ultFill, "SetHidden", false)
    end
    if self.furyLabel then
        Safe.Try(self.furyLabel, "SetText", Format.FuryLine(furyCurrent, furyMax))
    end
    if self.sustainLabel then
        Safe.Try(self.sustainLabel, "SetText", Format.SustainLine(ultimate, inCombat))
    end
    self:ApplySkin(pct)
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
        iconTex = self.icon and self.icon.ValknarrBoundTex or nil,
        ringTex = self.ringFrame and self.ringFrame.ValknarrBoundTex or nil,
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
