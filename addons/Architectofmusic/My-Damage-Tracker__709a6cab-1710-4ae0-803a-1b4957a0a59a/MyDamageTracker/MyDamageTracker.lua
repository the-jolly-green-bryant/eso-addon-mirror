-- MyDamageTracker.lua

-- Initialize saved variables
if MyDamageTrackerSavedVariables == nil then
    MyDamageTrackerSavedVariables = {
        enabled = true,
        trackTime = 10
    }
end

-- Table to track recent damage
local recentDamage = {}

-- Create top-level window
local damageWindow = WINDOW_MANAGER:CreateTopLevelWindow("MyDamageReportWindow")
damageWindow:SetDimensions(400, 200)
damageWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
damageWindow:SetHidden(true)
damageWindow:SetMouseEnabled(true)
damageWindow:SetMovable(true)
damageWindow:SetClampedToScreen(true)

-- Background
local bg = WINDOW_MANAGER:CreateControl(nil, damageWindow, CT_BACKDROP)
bg:SetAnchorFill(damageWindow)
bg:SetCenterColor(0,0,0,0.7)
bg:SetEdgeColor(0,0,0,1)

-- Scroll for listing hits
local scroll = WINDOW_MANAGER:CreateControl("MyDamageScroll", damageWindow, CT_SCROLL)
scroll:SetAnchor(TOPLEFT, damageWindow, TOPLEFT, 10, 10)
scroll:SetDimensions(380, 180)
scroll:SetMouseEnabled(true)
scroll:SetClampedToScreen(true)

-- Function to track combat events
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                             sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
    if not MyDamageTrackerSavedVariables.enabled then return end
    if targetName ~= GetUnitName("player") then return end

    table.insert(recentDamage, {
        timestamp = GetFrameTimeSeconds(),
        source = sourceName or "Unknown",
        ability = abilityName or "Unknown",
        damage = hitValue or 0
    })

    -- Clean old entries
    local now = GetFrameTimeSeconds()
    for i = #recentDamage, 1, -1 do
        if now - recentDamage[i].timestamp > MyDamageTrackerSavedVariables.trackTime then
            table.remove(recentDamage, i)
        end
    end
end

-- Function to display death report
local function OnPlayerDeath(eventCode, unitTag, isDead)
    if not MyDamageTrackerSavedVariables.enabled then return end
    if unitTag ~= "player" then return end

    -- Clear old scroll children
    local children = {scroll:GetChildren()}
    for _, child in ipairs(children) do
        child:SetHidden(true)
        child:Destroy()
    end

    -- Add new labels
    for i, dmg in ipairs(recentDamage) do
        local label = WINDOW_MANAGER:CreateControl(nil, scroll, CT_LABEL)
        label:SetText(string.format("%s hit you with %s for %d", dmg.source, dmg.ability, dmg.damage))
        label:SetDimensions(360, 20)
        label:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, (i-1)*20)
    end

    damageWindow:SetHidden(false)
end

-- Close window with Circle button
local function OnKeyDown(keyCode)
    if keyCode == KEY_GAMEPAD_CIRCLE and not damageWindow:IsHidden() then
        damageWindow:SetHidden(true)
    end
end

-- Register events
EVENT_MANAGER:RegisterForEvent("MyDamageTracker", EVENT_COMBAT_EVENT, OnCombatEvent)
EVENT_MANAGER:RegisterForEvent("MyDamageTracker", EVENT_UNIT_DEATH, OnPlayerDeath)
EVENT_MANAGER:RegisterForEvent("MyDamageTracker", EVENT_KEY_DOWN, OnKeyDown)

-- === LibAddonMenu2 Integration ===
local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type = "panel",
    name = "Damage Tracker",
    displayName = "Damage Tracker",
    author = "YourName",
    version = "1.0",
    registerForRefresh = true,
    registerForDefaults = true
}

local optionsTable = {
    {
        type = "checkbox",
        name = "Enable Tracker",
        tooltip = "Turn the damage tracker on or off",
        getFunc = function() return MyDamageTrackerSavedVariables.enabled end,
        setFunc = function(value) MyDamageTrackerSavedVariables.enabled = value end,
        width = "full",
    },
    {
        type = "slider",
        name = "Seconds to track",
        tooltip = "How many seconds of damage to store before death",
        min = 5,
        max = 30,
        step = 1,
        getFunc = function() return MyDamageTrackerSavedVariables.trackTime end,
        setFunc = function(value) MyDamageTrackerSavedVariables.trackTime = value end,
    }
}

LAM:RegisterAddonPanel("MyDamageTrackerPanel", panelData)
LAM:RegisterOptionControls("MyDamageTrackerPanel", optionsTable)