HWSIz = {}
HWSIz = {
    appName = "HideWeaponSwapIcon",
}

local function HideWeaponSwapIconInit()
	ZO_ActionBar1WeaponSwap:SetAlpha(0)
		
end


local function OnAddOnLoaded(eventCode, addOnName)
    if (HWSIz.appName ~= addOnName) then return end

    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_SLOTS_FULL_UPDATE, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_SLOT_ABILITY_SLOTTED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_SLOT_ABILITY_USED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_SLOT_STATE_UPDATED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_SLOT_UPDATED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTION_UPDATE_COOLDOWNS, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTIVE_QUICKSLOT_CHANGED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_HOT_BAR_RESULT, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_WEAPON_PAIR_LOCK_CHANGED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_WEAPON_SWAP_LOCKED, HideWeaponSwapIconInit)
    EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_PLAYER_ACTIVATED, HideWeaponSwapIconInit)
end

EVENT_MANAGER:RegisterForEvent(HWSIz.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
