ProximityAlert = { name = "ProximityAlert" }
local A = ProximityAlert
local timeLeft, isLooping, isBooming, hasPlayedWarning, isTestMode = 0, false, false, false, false

local FIXED_ICON = "esoui/art/icons/ability_ava_proximity_detonation.dds"

A.defaults = {
    addonEnabled = true, showIcon = true, hideInactive = true,
    offsetX = 0, offsetY = 0, 
    textOffsetX = 0, 
    textOffsetY = 50, -- Changed from 5 to 50 so it starts BELOW the icon
    iconSize = 48, 
    fontSize = 32,
    startR = 1, startG = 1, startB = 0,
    warnR = 1, warnG = 0, warnB = 0,
    warnThreshold = 1.0, useSound = true, soundOffset = 0.0,
}

local function EnsureTimersEnabled()
    local main = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ABILITY_BAR_TIMERS)
    local back = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ABILITY_BAR_BACK_ROW)
    if main == "0" or back == "0" then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ABILITY_BAR_TIMERS, "1")
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ABILITY_BAR_BACK_ROW, "1")
        d("|cFFFF00[ProximityAlert]|r |c00FF00Notice:|r Timers forced ON.")
    end
end

local function UpdateUI()
    local s = A.settings
    if not s or not ProximityAlertControl then return end
    
    ProximityAlertControl:ClearAnchors()
    ProximityAlertControl:SetAnchor(CENTER, GuiRoot, CENTER, s.offsetX, s.offsetY)
    
    ProximityAlertControlIcon:SetHidden(not s.showIcon)
    ProximityAlertControlIcon:SetDimensions(s.iconSize, s.iconSize)
    
    ProximityAlertControlTimer:ClearAnchors()
    if s.showIcon then
        -- Anchor to BOTTOM of icon so the offset moves it further down/up from the edge
        ProximityAlertControlTimer:SetAnchor(TOP, ProximityAlertControlIcon, BOTTOM, s.textOffsetX, s.textOffsetY)
    else
        -- If icon is hidden, center the text on the global position
        ProximityAlertControlTimer:SetAnchor(CENTER, ProximityAlertControl, CENTER, s.textOffsetX, s.textOffsetY)
    end
    
    local font = string.format("EsoUI/Common/Fonts/FTN87.otf|%d|soft-shadow-thick", s.fontSize)
    ProximityAlertControlTimer:SetFont(font)
    
    if not isLooping and not isBooming then
        ProximityAlertControlTimer:SetColor(s.startR, s.startG, s.startB, 1)
        ProximityAlertControlTimer:SetText("--")
    end

    local isHidden = not s.addonEnabled or (s.hideInactive and not isLooping and not isBooming)
    ProximityAlertControl:SetHidden(isHidden)
end

local function GetTime()
    if isTestMode then return nil end 
    for _, bar in ipairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        for slot = 3, 8 do
            local name = GetSlotName(slot, bar)
            if name and string.find(name, "Detonation") then
                local remain = GetActionSlotEffectTimeRemaining(slot, bar)
                if remain > 0 then return remain / 1000 end
            end
        end
    end
    return nil
end

local function EndCycle()
    isBooming, isLooping, hasPlayedWarning = false, false, false
    UpdateUI()
    if isTestMode then 
        zo_callLater(function() if isTestMode then A.Trigger(true) end end, 200) 
    end
end

local function OnUpdate()
    if not isLooping or not A.settings.addonEnabled then return end
    
    local barTime = GetTime()
    timeLeft = barTime and (math.floor(barTime * 10 + 0.5) / 10) or (timeLeft - 0.05)

    if timeLeft <= 0 then
        isLooping, isBooming = false, true
        ProximityAlertControlTimer:SetText("0.0")
        ProximityAlertControlTimer:SetColor(A.settings.warnR, A.settings.warnG, A.settings.warnB, 1)
        EVENT_MANAGER:UnregisterForUpdate("ProxUpdate")
        zo_callLater(function() 
            ProximityAlertControlTimer:SetText("BOOM!") 
            zo_callLater(EndCycle, 500) 
        end, 100)
        return
    end

    ProximityAlertControlTimer:SetText(string.format("%.1f", timeLeft))
    
    local s = A.settings
    local isWarning = timeLeft <= s.warnThreshold
    local r, g, b = isWarning and s.warnR or s.startR, isWarning and s.warnG or s.startG, isWarning and s.warnB or s.startB
    ProximityAlertControlTimer:SetColor(r, g, b, 1)

    if s.useSound and not hasPlayedWarning and timeLeft <= (s.warnThreshold + s.soundOffset) then
        PlaySound(SOUNDS.DUEL_START)
        hasPlayedWarning = true
    end
end

function A.Trigger(fromTest)
    if not A.settings.addonEnabled then return end
    if not fromTest then isTestMode = false end 
    
    timeLeft = 8.0 
    isLooping, isBooming, hasPlayedWarning = true, false, false
    UpdateUI()
    EVENT_MANAGER:RegisterForUpdate("ProxUpdate", 50, OnUpdate)
end

function A.ToggleTest()
    isTestMode = not isTestMode
    if isTestMode then
        d("|cFFFF00[ProximityAlert]|r Test Loop: |c00FF00Started|r")
        A.Trigger(true)
    else
        d("|cFFFF00[ProximityAlert]|r Test Loop: |cFF0000Stopped|r")
        isLooping = false
        EVENT_MANAGER:UnregisterForUpdate("ProxUpdate")
        EndCycle()
    end
end

function A.CreateMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    local s = A.settings
    local options = {
        { type = "checkbox", name = "Addon Enabled", getFunc = function() return s.addonEnabled end, setFunc = function(v) s.addonEnabled = v UpdateUI() end },
        { type = "checkbox", name = "Hide When Inactive", getFunc = function() return s.hideInactive end, setFunc = function(v) s.hideInactive = v UpdateUI() end },
        { type = "header", name = "Visuals" },
        { type = "checkbox", name = "Show Icon", getFunc = function() return s.showIcon end, setFunc = function(v) s.showIcon = v UpdateUI() end },
        { type = "slider", name = "Icon Size", min = 16, max = 256, step = 1, getFunc = function() return s.iconSize end, setFunc = function(v) s.iconSize = v UpdateUI() end },
        { type = "slider", name = "Font Size", min = 14, max = 100, step = 1, getFunc = function() return s.fontSize end, setFunc = function(v) s.fontSize = v UpdateUI() end },
        { type = "header", name = "Alerts" },
        { type = "checkbox", name = "Use Sound", getFunc = function() return s.useSound end, setFunc = function(v) s.useSound = v end },
        { type = "colorpicker", name = "Normal Color", getFunc = function() return s.startR, s.startG, s.startB end, setFunc = function(r,g,b) s.startR, s.startG, s.startB = r,g,b UpdateUI() end },
        { type = "colorpicker", name = "Warning Color", getFunc = function() return s.warnR, s.warnG, s.warnB end, setFunc = function(r,g,b) s.warnR, s.warnG, s.warnB = r,g,b end },
        { type = "slider", name = "Warning Threshold", min = 0.25, max = 3.0, step = 0.25, getFunc = function() return s.warnThreshold end, setFunc = function(v) s.warnThreshold = v end },
        { type = "slider", name = "Sound Offset", min = -1.0, max = 1.0, step = 0.1, getFunc = function() return s.soundOffset end, setFunc = function(v) s.soundOffset = v end },
        { type = "header", name = "Global Position (Fast Placement)" },
        { type = "slider", name = "Overall Horizontal", min = -2000, max = 2000, step = 5, getFunc = function() return s.offsetX end, setFunc = function(v) s.offsetX = v UpdateUI() end },
        { type = "slider", name = "Overall Vertical", min = -2000, max = 2000, step = 5, getFunc = function() return s.offsetY end, setFunc = function(v) s.offsetY = v UpdateUI() end },
        { type = "header", name = "Text Position (Precise Alignment)" },
        { type = "slider", name = "Text Horizontal", min = -300, max = 300, step = 1, getFunc = function() return s.textOffsetX end, setFunc = function(v) s.textOffsetX = v UpdateUI() end },
        { type = "slider", name = "Text Vertical", min = -300, max = 300, step = 1, getFunc = function() return s.textOffsetY end, setFunc = function(v) s.textOffsetY = v UpdateUI() end },
        { type = "button", name = "Toggle Test Loop", func = A.ToggleTest, width = "half" },
        { type = "button", name = "Reset", func = function() for k, v in pairs(A.defaults) do s[k] = v end UpdateUI() end, width = "half" },
    }
    LAM:RegisterAddonPanel("ProxAlertMenu", {type = "panel", name = "Proximity Alert", registerForRefresh = true})
    LAM:RegisterOptionControls("ProxAlertMenu", options)
end

EVENT_MANAGER:RegisterForEvent("ProxAlert", EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= A.name then return end
    A.settings = ZO_SavedVars:NewAccountWide("ProximityAlertVars", 1, nil, A.defaults)
    ProximityAlertControlIcon:SetTexture(FIXED_ICON)
    A.CreateMenu()
    UpdateUI()
    EnsureTimersEnabled()
    EVENT_MANAGER:RegisterForEvent("ProxAlertAura", EVENT_EFFECT_CHANGED, function(_, change, _, abilityName, unit)
        if unit == "player" and abilityName and string.find(abilityName, "Detonation") and (change == 1 or change == 3) then A.Trigger() end
    end)
end)