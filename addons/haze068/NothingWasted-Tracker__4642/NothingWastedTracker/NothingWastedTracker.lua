NothingWastedTracker = {}
local NWT = NothingWastedTracker

NWT.name = "NothingWastedTracker"
NWT.displayName = "Nothing Wasted Tracker"
NWT.version = "1.0.0"

local ABILITY_ID = 263461
local MAX_STACKS = 10

local BUFF_NAMES = {
    ["Nichts verschwendet"] = true,
    ["Nothing Wasted"] = true,
    ["Rien de perdu"] = true,
}

local TIMER_FONT = "EsoUI/Common/Fonts/univers67.otf"
local TIMER_STYLE = "soft-shadow-thin"

-- farben fuer die LAM-header
local CAT_COLORS = {
    display  = "1eeb21",
    stacks   = "1ee8eb",
    timer    = "f5a000",
    position = "c850ff",
}

local function CatHeader(stringId, colorKey)
    return string.format("|c%s%s|r", CAT_COLORS[colorKey], GetString(stringId))
end

-- farben fuer die chat-ausgabe
local CHAT = {
    brand = "f50000",
    ok    = "f50000",
    info  = "ff5555",
    label = "8a8a8a",
    value = "bcbcbc",
}
local PREFIX = "|c" .. CHAT.brand .. "[|r|c8a8a8aNWT|r|c" .. CHAT.brand .. "]|r "

local function Msg(text, color)
    if color then
        d(PREFIX .. "|c" .. color .. text .. "|r")
    else
        d(PREFIX .. text)
    end
end

local defaults = {
    locked = false,
    posX = 0,
    posY = 200,
    hideWhenZero = true,
    scale = 64,
    showBorder = true,
    borderThickness = 5,

    -- rahmenfarbe nach stack-stufe (1-3 / 4-6 / 7-9 / 10)
    colorTier1 = { 0.5, 0.5, 0.5, 1 },
    colorTier2 = { 1, 0.75, 0, 1 },
    colorTier3 = { 1, 1, 0, 1 },
    colorTier4 = { 0, 1, 0, 1 },

    showStacks = true,
    stackColor = { 1, 1, 1, 1 },

    showTimer = true,
    timerColor = { 1, 1, 1, 1 },
    timerSize = 18,
}

local panel, iconCtl, stacksCtl, timerCtl, borderCtl
local fragment
local ApplyBorder
local lastEndTime = 0
local lastStacks = 0

local function ApplyVisibility()
    if not fragment then return end
    if not NWT.sv.locked then
        fragment:SetHiddenForReason("nwtContent", false)
        return
    end
    local hide = (lastStacks <= 0) and NWT.sv.hideWhenZero
    fragment:SetHiddenForReason("nwtContent", hide)
end

local function Matches(abilityId, name)
    if abilityId == ABILITY_ID then return true end
    return name ~= nil and BUFF_NAMES[name] == true
end

local function ScanPlayerBuffs()
    for i = 1, GetNumBuffs("player") do
        local name, _, endTime, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if Matches(abilityId, name) then
            return stackCount or 0, endTime or 0
        end
    end
    return 0, 0
end

local function SetupIcon()
    local tex = GetAbilityIcon(ABILITY_ID)
    if tex and tex ~= "" then
        iconCtl:SetTexture(tex)
    end
end

local function UpdateTimerLabel()
    if not NWT.sv.showTimer or lastEndTime <= 0 then
        timerCtl:SetText("")
        return
    end
    local remain = lastEndTime - GetGameTimeSeconds()
    if remain <= 0 then
        timerCtl:SetText("")
        return
    end
    timerCtl:SetText(string.format("%.1f", remain))
end

-- waehlt die rahmenfarbe anhand des stack-stands
local function TierColor(stacks)
    local sv = NWT.sv
    if stacks >= MAX_STACKS then return sv.colorTier4 end
    if stacks >= 7 then return sv.colorTier3 end
    if stacks >= 4 then return sv.colorTier2 end
    return sv.colorTier1
end

-- puls bei vollen stacks (alpha schwingt per sinus)
local PULSE_NAME = "NWT_BorderPulse"

local function StopPulse()
    EVENT_MANAGER:UnregisterForUpdate(PULSE_NAME)
    if borderCtl then borderCtl:SetAlpha(1) end
end

local function StartPulse()
    EVENT_MANAGER:UnregisterForUpdate(PULSE_NAME)
    EVENT_MANAGER:RegisterForUpdate(PULSE_NAME, 16, function()
        local t = GetGameTimeMilliseconds() / 1000
        borderCtl:SetAlpha(0.675 + 0.325 * math.sin(t * 7.5))
    end)
end

-- farbige center-flaeche zeigt die stack-stufe, bei vollen stacks pulsierend
function ApplyBorder()
    borderCtl:SetHidden(not NWT.sv.showBorder)

    local c = TierColor(lastStacks)
    borderCtl:SetCenterColor(c[1], c[2], c[3], c[4] or 1)

    if lastStacks >= MAX_STACKS and NWT.sv.showBorder then
        StartPulse()
    else
        StopPulse()
    end
end

local function Refresh(stacks, endTime)
    lastEndTime = endTime or 0
    lastStacks = stacks or 0

    if NWT.sv.showStacks then
        stacksCtl:SetHidden(false)
        stacksCtl:SetText(tostring(stacks))
    else
        stacksCtl:SetHidden(true)
    end

    if stacks > 0 then
        EVENT_MANAGER:RegisterForUpdate(NWT.name .. "Timer", 100, UpdateTimerLabel)
        UpdateTimerLabel()
    else
        EVENT_MANAGER:UnregisterForUpdate(NWT.name .. "Timer")
        timerCtl:SetText("")
    end

    ApplyVisibility()
    ApplyBorder()
end

local function OnEffectChanged(_, changeType, _, effectName, unitTag, _, endTime, stackCount, _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then return end
    if not Matches(abilityId, effectName) then return end

    if changeType == EFFECT_RESULT_FADED then
        Refresh(0, 0)
    else
        Refresh(stackCount or 0, endTime or 0)
    end
end

local function ApplyAppearance()
    local sv = NWT.sv
    panel:SetDimensions(sv.scale, sv.scale)

    -- backdrop fuellt das panel, das icon liegt mit rand-inset darueber.
    -- die rahmenstaerke wird begrenzt, damit das icon nicht verschwindet.
    borderCtl:SetDimensions(sv.scale, sv.scale)
    borderCtl:SetEdgeTexture("", 1, 1, 1, 0)
    local maxThick = math.floor((sv.scale - 8) / 2)
    local thick = math.max(0, math.min(sv.borderThickness, maxThick))
    iconCtl:ClearAnchors()
    iconCtl:SetAnchor(TOPLEFT, panel, TOPLEFT, thick, thick)
    iconCtl:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -thick, -thick)
    iconCtl:SetHidden(false)

    local sc = sv.stackColor
    stacksCtl:SetColor(sc[1], sc[2], sc[3], sc[4] or 1)

    local tc = sv.timerColor
    timerCtl:SetColor(tc[1], tc[2], tc[3], tc[4] or 1)
    timerCtl:SetFont(TIMER_FONT .. "|" .. sv.timerSize .. "|" .. TIMER_STYLE)
end

function NWT.OnMoveStop()
    NWT.sv.posX = panel:GetLeft()
    NWT.sv.posY = panel:GetTop()
end

local function RestorePosition()
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NWT.sv.posX, NWT.sv.posY)
end

local function ApplyLock()
    panel:SetMovable(not NWT.sv.locked)
    panel:SetMouseEnabled(not NWT.sv.locked)
end

local function ForceRefresh()
    local s, e = ScanPlayerBuffs()
    Refresh(s, e)
end

local function BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        Msg("LibAddonMenu-2.0 missing - settings disabled.", CHAT.info)
        return
    end

    -- farbiger addon-name im panel-titel
    local titleColored = "|c0d0d0dNothingWasted|r |ce90101Tracker|r"

    LAM:RegisterAddonPanel("NWT_Options", {
        type = "panel", name = titleColored, displayName = titleColored,
        author = "|cf50000haze068|r", version = NWT.version,
        registerForRefresh = true, registerForDefaults = true,
    })

    local options = {
        {
            type = "submenu", name = CatHeader(SI_NWT_CAT_DISPLAY, "display"),
            controls = {
                {
                    type = "slider", name = GetString(SI_NWT_SIZE), min = 32, max = 160, step = 2,
                    getFunc = function() return NWT.sv.scale end,
                    setFunc = function(v) NWT.sv.scale = v; ApplyAppearance() end,
                },
                {
                    type = "checkbox", name = GetString(SI_NWT_HIDE_ZERO),
                    getFunc = function() return NWT.sv.hideWhenZero end,
                    setFunc = function(v) NWT.sv.hideWhenZero = v; ForceRefresh() end,
                },
                {
                    type = "checkbox", name = GetString(SI_NWT_BORDER),
                    getFunc = function() return NWT.sv.showBorder end,
                    setFunc = function(v) NWT.sv.showBorder = v; ApplyBorder() end,
                },
                {
                    type = "slider", name = GetString(SI_NWT_BORDER_SIZE), min = 1, max = 16, step = 1,
                    getFunc = function() return NWT.sv.borderThickness end,
                    setFunc = function(v) NWT.sv.borderThickness = v; ApplyAppearance() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_COLOR_T1),
                    getFunc = function() local c=NWT.sv.colorTier1; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.colorTier1={r,g,b,a}; ApplyBorder() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_COLOR_T2),
                    getFunc = function() local c=NWT.sv.colorTier2; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.colorTier2={r,g,b,a}; ApplyBorder() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_COLOR_T3),
                    getFunc = function() local c=NWT.sv.colorTier3; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.colorTier3={r,g,b,a}; ApplyBorder() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_COLOR_T4),
                    getFunc = function() local c=NWT.sv.colorTier4; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.colorTier4={r,g,b,a}; ApplyBorder() end,
                },
                {
                    type = "checkbox", name = GetString(SI_NWT_LOCK),
                    getFunc = function() return NWT.sv.locked end,
                    setFunc = function(v) NWT.sv.locked = v; ApplyLock() end,
                },
            },
        },

        {
            type = "submenu", name = CatHeader(SI_NWT_CAT_STACKS, "stacks"),
            controls = {
                {
                    type = "checkbox", name = GetString(SI_NWT_SHOW_STACKS),
                    getFunc = function() return NWT.sv.showStacks end,
                    setFunc = function(v) NWT.sv.showStacks = v; ForceRefresh() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_STACK_COLOR),
                    getFunc = function() local c=NWT.sv.stackColor; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.stackColor={r,g,b,a}; ApplyAppearance() end,
                },
            },
        },

        {
            type = "submenu", name = CatHeader(SI_NWT_CAT_TIMER, "timer"),
            controls = {
                {
                    type = "checkbox", name = GetString(SI_NWT_SHOW_TIMER),
                    getFunc = function() return NWT.sv.showTimer end,
                    setFunc = function(v) NWT.sv.showTimer = v; UpdateTimerLabel() end,
                },
                {
                    type = "slider", name = GetString(SI_NWT_TIMER_SIZE), min = 10, max = 48, step = 1,
                    getFunc = function() return NWT.sv.timerSize end,
                    setFunc = function(v) NWT.sv.timerSize = v; ApplyAppearance() end,
                },
                {
                    type = "colorpicker", name = GetString(SI_NWT_TIMER_COLOR),
                    getFunc = function() local c=NWT.sv.timerColor; return c[1],c[2],c[3],c[4] end,
                    setFunc = function(r,g,b,a) NWT.sv.timerColor={r,g,b,a}; ApplyAppearance() end,
                },
            },
        },

        {
            type = "submenu", name = CatHeader(SI_NWT_CAT_POSITION, "position"),
            controls = {
                {
                    type = "button", name = GetString(SI_NWT_UNLOCK_MOVE),
                    func = function() NWT.sv.locked=false; ApplyLock(); ApplyVisibility(); d("[NWT] "..GetString(SI_NWT_UNLOCK_HINT)) end,
                },
            },
        },
    }
    LAM:RegisterOptionControls("NWT_Options", options)
end

local function PrintHelp()
    Msg("|c" .. CHAT.brand .. GetString(SI_NWT_CMD_HELP_TITLE) .. "|r")
    local function cmd(usage, desc)
        d(string.format("   |c%s%s|r  |c%s-|r  |c%s%s|r",
            CHAT.ok, usage, CHAT.label, CHAT.value, desc))
    end
    cmd("/nwt lock",   GetString(SI_NWT_CMD_HELP_LOCK))
    cmd("/nwt unlock", GetString(SI_NWT_CMD_HELP_UNLOCK))
end

SLASH_COMMANDS["/nwt"] = function(arg)
    arg = (arg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if arg == "lock" then
        NWT.sv.locked = true; ApplyLock(); ApplyVisibility()
        Msg(GetString(SI_NWT_CMD_LOCKED), CHAT.ok)
    elseif arg == "unlock" then
        NWT.sv.locked = false; ApplyLock(); ApplyVisibility()
        Msg(GetString(SI_NWT_CMD_UNLOCKED), CHAT.info)
    else
        PrintHelp()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= NWT.name then return end
    EVENT_MANAGER:UnregisterForEvent(NWT.name, EVENT_ADD_ON_LOADED)

    -- pro server getrennt speichern (EU / NA / PTS)
    NWT.sv = ZO_SavedVars:NewAccountWide("NothingWastedTrackerSV", 1, GetWorldName(), defaults)

    panel      = NWT_Panel
    iconCtl    = NWT_PanelIcon
    stacksCtl  = NWT_PanelStacks
    timerCtl   = NWT_PanelTimer
    borderCtl  = NWT_PanelBorder

    SetupIcon()
    RestorePosition()
    ApplyLock()
    ApplyAppearance()
    ApplyBorder()
    BuildMenu()

    fragment = ZO_HUDFadeSceneFragment:New(panel)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    -- panel nur im HUD zeigen, bei jeder anderen szene ausblenden
    local function OnSceneChange()
        if not fragment then return end
        local s = SCENE_MANAGER:GetCurrentScene()
        local name = s and s:GetName()
        local onHud = (name == "hud") or (name == "hudui")
        fragment:SetHiddenForReason("nwtScene", not onHud)
    end
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneChange)

    EVENT_MANAGER:RegisterForEvent(NWT.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(NWT.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    ForceRefresh()
    OnSceneChange()
end

EVENT_MANAGER:RegisterForEvent(NWT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
