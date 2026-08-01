LABz = {}
LABz = {
    appName = "Luminous_ActionBars",
}

local function moveActionBarSetup()
        ActionButton3ButtonText:ClearAnchors()
        ActionButton3ButtonText:SetAnchorFill(ActionButton3)
        ActionButton3ButtonText:SetMouseEnabled(false)
        ActionButton3ButtonText:SetMovable(false)

        ActionButton4ButtonText:ClearAnchors()
        ActionButton4ButtonText:SetAnchorFill(ActionButton4)
        ActionButton4ButtonText:SetMouseEnabled(false)
        ActionButton4ButtonText:SetMovable(false)

        ActionButton5ButtonText:ClearAnchors()
        ActionButton5ButtonText:SetAnchorFill(ActionButton5)
        ActionButton5ButtonText:SetMouseEnabled(false)
        ActionButton5ButtonText:SetMovable(false)

        ActionButton6ButtonText:ClearAnchors()
        ActionButton6ButtonText:SetAnchorFill(ActionButton6)
        ActionButton6ButtonText:SetMouseEnabled(false)
        ActionButton6ButtonText:SetMovable(false)

        ActionButton7ButtonText:ClearAnchors()
        ActionButton7ButtonText:SetAnchorFill(ActionButton7)
        ActionButton7ButtonText:SetMouseEnabled(false)
        ActionButton7ButtonText:SetMovable(false)

        ActionButton8ButtonText:ClearAnchors()
        ActionButton8ButtonText:SetAnchorFill(ActionButton8)
        ActionButton8ButtonText:SetMouseEnabled(false)
        ActionButton8ButtonText:SetMovable(false)

        QuickslotButtonButtonText:ClearAnchors()
        QuickslotButtonButtonText:SetAnchorFill(QuickslotButton)
        QuickslotButtonButtonText:SetMouseEnabled(false)
        QuickslotButtonButtonText:SetMovable(false)
		
end


local function OnAddOnLoaded(eventCode, addOnName)
    if (LABz.appName ~= addOnName) then return end

    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_SLOTS_FULL_UPDATE, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_SLOT_ABILITY_SLOTTED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_SLOT_ABILITY_USED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_SLOT_STATE_UPDATED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_SLOT_UPDATED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTION_UPDATE_COOLDOWNS, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTIVE_QUICKSLOT_CHANGED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_HOT_BAR_RESULT, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_WEAPON_PAIR_LOCK_CHANGED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_WEAPON_SWAP_LOCKED, moveActionBarSetup)
    EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_PLAYER_ACTIVATED, moveActionBarSetup)
end

EVENT_MANAGER:RegisterForEvent(LABz.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
