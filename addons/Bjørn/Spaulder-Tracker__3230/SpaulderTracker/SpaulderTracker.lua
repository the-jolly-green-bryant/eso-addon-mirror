local namespace = 'SpaulderTracker'
local isUIUnlocked = false
local uiFragment, sv
local initialLogin = false

local defaults = {
    x = 300,
    y = 300,
    isSpaulderActive = false,
    currentZoneId = nil,
    isSpaulderEquipped = false,
}

local EM = EVENT_MANAGER

local function FragmentCondition()
    local colour = sv.isSpaulderActive and {0.49, 0.72, 0.34, 0.8} or {0.39, 0, 0, 0.8}
    SpaulderTracker_UI_Backdrop:SetCenterColor(unpack(colour))

    return sv.isSpaulderEquipped
end

-- Register Spaulder active state
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_EFFECT_GAINED then
        sv.isSpaulderActive = true
        uiFragment:Refresh()
    elseif result == ACTION_RESULT_EFFECT_FADED then
        sv.isSpaulderActive = false
        uiFragment:Refresh()
    end
end

local function OnGearUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage)
    local hasSet, setName, numBonuses, numNormalEquipped = GetItemLinkSetInfo('|H1:item:181695:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:5200:0|h|h', true)
    if numNormalEquipped == 1 then sv.isSpaulderEquipped = true
    else sv.isSpaulderEquipped = false end

    uiFragment:Refresh()
end

-- If player entered new zone or just logged in spaulder is deactivated, therefore ui should do the same
local function OnPlayerActivated(eventCode, initial)
    local zoneId = GetUnitWorldPosition('player')
    if (initialLogin and initial) or zoneId ~= sv.currentZoneId then
        initialLogin = false
        sv.currentZoneId = zoneId
        sv.isSpaulderActive = false
    end

    OnGearUpdate()
end

-- Save ui location after moving
function SpaulderTrackerOnMoveStop()
    sv.x, sv.y = SpaulderTracker_UI:GetCenter()
end

-- Get saved variables, reposition ui and register events
local function OnAddonLoaded(eventCode, addonName)
    if addonName == namespace then
        EM:UnregisterForEvent(namespace, eventCode)

        initialLogin = true

        sv = ZO_SavedVars:NewAccountWide('SpaulderTrackerSV', 1, nil, defaults)

        SpaulderTracker_UI:ClearAnchors()
        SpaulderTracker_UI:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.x, sv.y)

        uiFragment = ZO_SimpleSceneFragment:New(SpaulderTracker_UI)
        uiFragment:SetConditional(FragmentCondition)
        HUD_SCENE:AddFragment(uiFragment)
        HUD_UI_SCENE:AddFragment(uiFragment)

        EM:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OnCombatEvent)
        EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163359, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        EM:RegisterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnGearUpdate)
        EM:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

        EM:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

EM:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- Chat command to (un-)lock ui
SLASH_COMMANDS['/spaulder'] = function()
    isUIUnlocked = not isUIUnlocked

    SpaulderTracker_UI:SetMouseEnabled(isUIUnlocked)
    SpaulderTracker_UI:SetMovable(isUIUnlocked)
end