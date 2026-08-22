OverloadTracker = OverloadTracker or {}
OverloadTracker.name = "OverloadTracker"

OverloadTracker.defaults = {
    x = 0,
    y = -150,
    point = CENTER,
    relPoint = CENTER,
}

local mainFrame = nil
local controlLabel = nil

local function IsOverloadActive()
    if GetActiveHotbarCategory() == HOTBAR_CATEGORY_OVERLOAD then
        return true
    end

    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == 29868 or string.find(string.lower(buffName or ""), "overload") then
            return true
        end
    end

    return false
end

local function UpdateOverloadStatus()
    if not controlLabel then return end

    if IsOverloadActive() then
        controlLabel:SetText("OVERLOAD: ON")
        controlLabel:SetColor(0, 1, 0, 1)
    else
        controlLabel:SetText("OVERLOAD: OFF")
        controlLabel:SetColor(0.5, 0.5, 0.5, 0.8)
    end
end

-- Save coordinates natively when dragging stops
local function OnWindowMoveStop(control)
    local isValid, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(0)
    
    if isValid then
        OverloadTracker.savedVars.point = point
        OverloadTracker.savedVars.relPoint = relativePoint
        OverloadTracker.savedVars.x = offsetX
        OverloadTracker.savedVars.y = offsetY
    end
end

local function CreateUI()
    local wm = WINDOW_MANAGER
    
    mainFrame = wm:CreateTopLevelWindow("OverloadTrackerUI")
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetDimensions(200, 40)
    
    -- Load saved anchors safely with defaults fallback
    local point = OverloadTracker.savedVars.point or CENTER
    local relPoint = OverloadTracker.savedVars.relPoint or CENTER
    local x = OverloadTracker.savedVars.x or 0
    local y = OverloadTracker.savedVars.y or -150

    mainFrame:ClearAnchors()
    mainFrame:SetAnchor(point, GuiRoot, relPoint, x, y)
    
    mainFrame:SetMovable(true)
    mainFrame:SetMouseEnabled(true)
    mainFrame:SetHandler("OnMoveStop", OnWindowMoveStop)

    -- Background
    local bg = wm:CreateControl("OverloadTrackerBG", mainFrame, CT_BACKDROP)
    bg:SetAnchorFill(mainFrame)
    bg:SetCenterColor(0, 0, 0, 0.4)
    bg:SetEdgeColor(0.2, 0.2, 0.2, 0.6)
    bg:SetEdgeTexture("", 8, 1, 0)

    -- Text Label
    controlLabel = wm:CreateControl("OverloadTrackerLabel", mainFrame, CT_LABEL)
    controlLabel:SetFont("$(MEDIUM_FONT)|22|outline")
    controlLabel:SetAnchor(CENTER, mainFrame, CENTER, 0, 0)

    UpdateOverloadStatus()
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= OverloadTracker.name then return end
    EVENT_MANAGER:UnregisterForEvent(OverloadTracker.name, EVENT_ADD_ON_LOADED)

    -- Initialize saved variables object
    OverloadTracker.savedVars = ZO_SavedVars:NewAccountWide(
        "OverloadTrackerSV", 
        1, 
        nil, 
        OverloadTracker.defaults
    )

    -- Create UI ONLY after saved variables are initialized
    CreateUI()

    EVENT_MANAGER:RegisterForEvent(OverloadTracker.name, EVENT_ACTION_SLOTS_FULL_UPDATE, UpdateOverloadStatus)
    EVENT_MANAGER:RegisterForEvent(OverloadTracker.name, EVENT_ACTION_SLOT_STATE_CHANGE, UpdateOverloadStatus)
    EVENT_MANAGER:RegisterForEvent(OverloadTracker.name, EVENT_PLAYER_ACTIVATED, UpdateOverloadStatus)
    
    EVENT_MANAGER:RegisterForEvent(OverloadTracker.name, EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, buffName, unitTag)
        if unitTag == "player" then
            UpdateOverloadStatus()
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(OverloadTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)