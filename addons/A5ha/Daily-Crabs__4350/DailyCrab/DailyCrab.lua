local ADDON_NAME = "DailyCrab"
local DailyCrab = { name = ADDON_NAME }

local defaultSavedVariables = {
    crabToday = 0,
    windowOffsetX = 20,
    windowOffsetY = 20,
    isHidden = false,
    dailyResetEnabled = true,
    userOverride = false,
}

local clientLang = GetCVar("language.2")
local crabNames = {
    ["en"] = { ["Mudcrab"] = 1, ["Coral Crab"] = 1, ["Hermit Crab"] = 1, ["Swarming Mudcrab"] = 1,
        ["Clatterclaw"] = 10, ["Queen of the Reef"] = 10, ["Colossal Coral Crab"] = 5, ["Tidespite"] = 10 },
    ["ru"] = { ["Грязевой краб"] = 1, ["Коралловый краб"] = 1, ["Краб-отшельник"] = 1, ["Щелкун"] = 10,
        ["Королева Рифа"] = 10, ["Огромный коралловый краб"] = 5, ["Злоба Прилива"] = 10 },
}
local crabsOfClientLang = crabNames[clientLang] or crabNames["en"]
if not crabsOfClientLang then return end

DailyCrab.Settings = {}
DailyCrab.ui = nil

local function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function FormatNumberWithCommas(number)
    local formatted = tostring(number)
    local k = formatted:len() % 3
    if k == 0 then k = 3 end
    return formatted:sub(1, k) .. formatted:sub(k+1):gsub("(%d%d%d)", ",%1")
end

local function CreateTrackerWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("DailyCrabWindow")
    local baseWidth = 40
    window:SetDimensions(baseWidth, 30)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)

    local x = clamp(tonumber(DailyCrab.Settings.windowOffsetX) or 20, 0, GuiRoot:GetWidth() - 60)
    local y = clamp(tonumber(DailyCrab.Settings.windowOffsetY) or 20, 0, GuiRoot:GetHeight() - 24)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

    window:SetHandler("OnMoveStop", function(self)
        DailyCrab.Settings.windowOffsetX = clamp(self:GetLeft(), 0, GuiRoot:GetWidth() - 60)
        DailyCrab.Settings.windowOffsetY = clamp(self:GetTop(), 0, GuiRoot:GetHeight() - 24)
    end)

    -- Background
    local background = WINDOW_MANAGER:CreateControl("DailyCrabBackground", window, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetEdgeTexture("DailyCrab/Textures/centerscreen_floating_edge.dds", 256, 256, 8)
    background:SetCenterTexture("DailyCrab/Textures/centerscreen_floating_center.dds")
    background:SetInsets(8, 8, -8, -8)
    background:SetAlpha(0.5)
    local bgColor = ZO_ColorDef:New(0, 0, 0, 1)
    background:SetCenterColor(bgColor:UnpackRGBA())
    background:SetEdgeColor(bgColor:UnpackRGBA())

    -- Icon
    local icon = WINDOW_MANAGER:CreateControl("DailyCrabIcon", window, CT_TEXTURE)
    icon:SetDimensions(32, 32)
    icon:SetAnchor(LEFT, window, LEFT, 6, 0)
    icon:SetTexture("/esoui/art/armory/buildicons/buildicon_69.dds")

    -- Count label
    local crabCount = WINDOW_MANAGER:CreateControl("DailyCrabCount", window, CT_LABEL)
    crabCount:SetDimensions(80, 20)
    crabCount:SetAnchor(LEFT, icon, RIGHT, 2, 0)
    crabCount:SetFont("ZoFontWinH4")
    crabCount:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    return { window = window, crabCount = crabCount, icon = icon, background = background }
end

function DailyCrab.UpdateVisibility()
    if not DailyCrab.ui or not DailyCrab.ui.window then return end
    if DailyCrab.Settings.userOverride then
        DailyCrab.ui.window:SetHidden(DailyCrab.Settings.isHidden)
        return
    end
    local inHud = SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
    DailyCrab.ui.window:SetHidden(not inHud)
end

function DailyCrab.RegisterSceneWatcher()
    local function OnSceneChange(_, newState)
        DailyCrab.UpdateVisibility()
    end
    for _, sceneName in ipairs({"hud", "hudui"}) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then scene:RegisterCallback("StateChange", OnSceneChange) end
    end
end

local function UpdateDisplay()
    if not DailyCrab.ui then return end
    local ui = DailyCrab.ui
    local crabToday = DailyCrab.Settings.crabToday or 0
    local text = FormatNumberWithCommas(crabToday)
    ui.crabCount:SetText(text)

    -- Window width extension logic
    local digitCount = string.len(tostring(crabToday))
    local commaCount = math.max(0, math.floor((digitCount - 1) / 3))
    local effectiveCharacterCount = digitCount + (commaCount * 0.5)
    local baseWidth = 70
    local extension = (effectiveCharacterCount - 1) * 8
    ui.window:SetDimensions(baseWidth + extension, 30)

    -- Always white text
    ui.crabCount:SetColor(1, 0.84, 0, 1) 
end

function DailyCrab.ResetDailyCrab()
    if not DailyCrab.Settings.dailyResetEnabled then return end
    DailyCrab.Settings.crabToday = 0
    UpdateDisplay()
end

function DailyCrab.ForceReset()
    DailyCrab.Settings.crabToday = 0
    UpdateDisplay()
    d("Daily Crab: Force Reset!")
end

local function onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                            sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
                            sourceUnitId, targetUnitId, abilityId, overflow)
    if not targetName or targetName == "" then return end
    
    local trimmedTargetName = zo_strformat("<<C:1>>", targetName)
    local score = crabsOfClientLang[trimmedTargetName]
    if score then
        DailyCrab.Settings.crabToday = (DailyCrab.Settings.crabToday or 0) + score
        UpdateDisplay()
    end
end

local playerActivatedFired = false
function DailyCrab.OnPlayerActivated()
    if playerActivatedFired then return end
    playerActivatedFired = true
    UpdateDisplay()
    DailyCrab.UpdateVisibility()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

function DailyCrab.OnAddOnLoaded(event, addonName)
    if addonName ~= DailyCrab.name then return end
    
    local worldName = GetWorldName() or "Default"
    DailyCrab.Settings = ZO_SavedVars:NewAccountWide("DailyCrab_SavedVariables", 1, worldName, defaultSavedVariables)
    
    DailyCrab.ui = CreateTrackerWindow()
    DailyCrab.RegisterSceneWatcher()
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, onCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, DailyCrab.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_NEW_DAILY_LOGIN_REWARD_AVAILABLE, DailyCrab.ResetDailyCrab)
    
    SLASH_COMMANDS["/dailycrab"] = function()
        if not DailyCrab.ui or not DailyCrab.ui.window then return end
        local hidden = DailyCrab.ui.window:IsHidden()
        DailyCrab.ui.window:SetHidden(not hidden)
        DailyCrab.Settings.isHidden = not hidden
        DailyCrab.Settings.userOverride = not hidden
        d(hidden and "Daily Crab: Show" or "Daily Crab: Hide")
    end

    SLASH_COMMANDS["/dailycrab_reset"] = function()
        DailyCrab.Settings.crabToday = 0
        UpdateDisplay()
        d("Daily Crab: Reset!")
    end

    SLASH_COMMANDS["/dailycrab_nodailyreset"] = function()
        DailyCrab.Settings.dailyResetEnabled = not DailyCrab.Settings.dailyResetEnabled
        d(DailyCrab.Settings.dailyResetEnabled and "Daily Crab: Autoreset ON" or "Daily Crab: Autoreset OFF")
    end
    
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, DailyCrab.OnAddOnLoaded)