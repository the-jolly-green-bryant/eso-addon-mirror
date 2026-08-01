local namespace = 'SPAULDER'
local isUIUnlocked = false
local sv
local initialLogin = false

local defaults = {
    isSpaulderActive = false,
    currentZoneId = nil,
    isSpaulderEquipped = false,
}

local EM = EVENT_MANAGER

-- Register Spaulder active state
local function OnEffectGained()
	sv.isSpaulderActive = true
    SPAULDERIndicator:SetHidden(true)
end
local function OnEffectFaded()
	if IsUnitInDungeon("player") and sv.isSpaulderEquipped then
		sv.isSpaulderActive = false
		SPAULDERIndicator:SetHidden(false)
	end
end

local function OnGearUpdate()
    local hasSet, setName, numBonuses, numNormalEquipped = GetItemLinkSetInfo('|H1:item:181695:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:5200:0|h|h', true)
	
	if sv.isSpaulderEquipped and numNormalEquipped == 1 and sv.isSpaulderActive then return end
	
    if numNormalEquipped == 1 and IsUnitInDungeon("player") then 
		sv.isSpaulderEquipped = true
		SPAULDERIndicator:SetHidden(false)
    else 
		sv.isSpaulderEquipped = false
		SPAULDERIndicator:SetHidden(true)
	end
end

-- If player entered new zone or just logged in spaulder is deactivated, therefore ui should do the same
local function OnPlayerActivated(_, initial)
    local zoneId = GetUnitWorldPosition('player')
    if initialLogin or zoneId ~= sv.currentZoneId then
		initialLogin = false
        sv.currentZoneId = zoneId
        sv.isSpaulderActive = false
		OnGearUpdate()
    end
end

-- Get saved variables, reposition ui and register events
local function OnAddonLoaded(_, addonName)
    if addonName == namespace then
        EM:UnregisterForEvent(namespace, EVENT_ADD_ON_LOADED)

        initialLogin = true

        sv = ZO_SavedVars:NewAccountWide('SPAULDERVars', 1, nil, defaults)
		
		local gainedNameSpace = namespace .. "_GAINED"
		local fadedNameSpace = namespace .. "_FADED"
		EM:RegisterForEvent(gainedNameSpace , EVENT_COMBAT_EVENT, OnEffectGained)
        EM:AddFilterForEvent(gainedNameSpace , EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163359, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
		EM:RegisterForEvent(fadedNameSpace , EVENT_COMBAT_EVENT, OnEffectFaded)
        EM:AddFilterForEvent(fadedNameSpace , EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163359, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        

        EM:RegisterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnGearUpdate)
        EM:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
		EM:RegisterForEvent(namespace, EVENT_INVENTORY_FULL_UPDATE, OnGearUpdate)

        EM:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

EM:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, OnAddonLoaded)
