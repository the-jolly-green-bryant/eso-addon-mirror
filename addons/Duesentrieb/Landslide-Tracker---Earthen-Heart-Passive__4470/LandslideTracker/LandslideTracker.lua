---------------------------------------------------------------------------
-- SETTINGS, GLOBALS AND DEFAULTS
---------------------------------------------------------------------------
LandslideTracker = {
    name = "LandslideTracker",
    author = "@Duesentrieb",
    version = "20260320-0002",
    chat = "|cFF7F00[LT]|r",

    -- ADJUSTABLE SETTINGS
    fontColor = {1, 1, 1, 1}, -- r, g, b, a (0.0 .. 1.0)
    fontSize = 54,
    updateTime = 250, -- Milliseconds
    buffId = 29465, -- Landslide

    -- INTERNAL VARIABLES
    SVVersion = 1,
    SVName = "LandslideTrackerVariables",
    default = { offsetX = 50, offsetY = 50 },
    SV = {}
}

local LT = LandslideTracker

---------------------------------------------------------------------------
-- CREATE UI ELEMENTS DYNAMICALLY (NO XML NEEDED)
---------------------------------------------------------------------------
function LT.CreateUI()
    LT.control = WINDOW_MANAGER:CreateTopLevelWindow("LTControl")
    LT.control:SetDimensions(100, 100)
    LT.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LT.SV.offsetX, LT.SV.offsetY)
    LT.control:SetClampedToScreen(true)
    LT.control:SetMouseEnabled(true)
    LT.control:SetMovable(true)
    LT.control:SetHidden(true)
    LT.control:SetDrawTier(DT_HIGH)

    LT.control:SetHandler("OnMoveStop", LT.SavePosition)

    LT.label = WINDOW_MANAGER:CreateControl("LTLabel", LT.control, CT_LABEL)
    LT.label:SetAnchorFill()
    LT.label:SetFont("$(BOLD_FONT)|" .. LT.fontSize .. "|thick-outline")
    LT.label:SetColor(unpack(LT.fontColor))
    LT.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    LT.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    LT.label:SetText("0")
end

---------------------------------------------------------------------------
-- SAVE POSITION TO SAVED VARIABLES
---------------------------------------------------------------------------
function LT.SavePosition()
    LT.SV.offsetX = LT.control:GetLeft()
    LT.SV.offsetY = LT.control:GetTop()

    LT.control:ClearAnchors()
    LT.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LT.SV.offsetX, LT.SV.offsetY)
end

---------------------------------------------------------------------------
-- GET CURRENT STACKS OF THE BUFF ON PLAYER
---------------------------------------------------------------------------
function LT.GetStacks()
    local maxStacks = 0
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == LT.buffId then
            if stackCount and stackCount > maxStacks then
                maxStacks = stackCount
            end
        end
    end
    return maxStacks
end

---------------------------------------------------------------------------
-- UPDATE LOOP (RUNS EVERY 250MS)
---------------------------------------------------------------------------
function LT.UpdateLoop()
    local stacks = LT.GetStacks()
    LT.label:SetText(tostring(stacks))

    if stacks > 0 or IsUnitInCombat("player") then
        LT.control:SetHidden(false)
    else
        LT.control:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(LT.name .. "UpdateLoop")
    end
end

---------------------------------------------------------------------------
-- COMBAT STATE TRIGGER
---------------------------------------------------------------------------
function LT.OnCombatState(_, inCombat)
    if inCombat then
        LT.control:SetHidden(false)
        LT.label:SetText(tostring(LT.GetStacks()))
        EVENT_MANAGER:RegisterForUpdate(LT.name .. "UpdateLoop", LT.updateTime, LT.UpdateLoop)
    else
        if LT.GetStacks() == 0 then
            LT.control:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate(LT.name .. "UpdateLoop")
        end
    end
end

---------------------------------------------------------------------------
-- SCENE CHANGE (HIDE ADDON WHEN IN MENU ETC)
---------------------------------------------------------------------------
function LT.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        if LT.GetStacks() > 0 or IsUnitInCombat("player") then
            LT.control:SetHidden(false)
        end
    elseif newState == SCENE_HIDING then
        LT.control:SetHidden(true)
    end
end

---------------------------------------------------------------------------
-- INITIALIZATION
---------------------------------------------------------------------------
function LT.Initialize()
    LT.SV = ZO_SavedVars:NewAccountWide(LT.SVName, LT.SVVersion, GetWorldName(), LT.default)
    LT.CreateUI()

    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", LT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", LT.OnStateChange)
    EVENT_MANAGER:RegisterForEvent(LT.name .. "EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, LT.OnCombatState)
end

---------------------------------------------------------------------------
-- ADDON LOADED
---------------------------------------------------------------------------
function LT.OnAddOnLoaded(_, addonName)
    if addonName == LT.name then
        EVENT_MANAGER:UnregisterForEvent(LT.name, EVENT_ADD_ON_LOADED)
        LT.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(LT.name, EVENT_ADD_ON_LOADED, LT.OnAddOnLoaded)