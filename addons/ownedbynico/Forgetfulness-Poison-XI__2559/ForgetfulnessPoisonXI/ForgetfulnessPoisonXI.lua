FPXI = FPXI or {}
FPXI.name = "ForgetfulnessPoisonXI"
FPXI.version = "1.2"

FPXI.nextPoisonSlot = -1

FPXI.poisons = {
	CRAFTED = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:138240|h|h",
	CROWN = "|H0:item:79690:6:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h",
}

FPXI.zones = {
	[636] = true,  -- Hel Ra Citadel
	[638] = true,  -- Aetherian Archive
	[639] = true,  -- Sanctum Ophidia
	[725] = true,  -- Maw of Lorkhaj
	[975] = true,  -- Halls of Fabrication
	[1000] = true, -- Asylum Sanctorium
	[1051] = true, -- Cloudrest
	[1121] = true, -- Sunspire
	[1196] = true, -- Kyne's Aegis
	[635] = true,  -- Dragonstar Arena
	[677] = true,  -- Maelstrom Arena
	[1082] = true, -- Blackrose Prison
	[1227] = true, -- Vateshran
}

function FPXI.scanInventory(poisonType)

	for i = 0, GetBagSize(BAG_BACKPACK) -1 do
		local itemType, _ = GetItemType(BAG_BACKPACK, i)
		if itemType == ITEMTYPE_POISON then
			local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
			if poisonType == itemLink then
				return i
			end
		end
	end

	return -1
end

function FPXI.equipPoison(prefPoisonType, fallbackPoisonType)
	
	local slot = FPXI.scanInventory(prefPoisonType)
	if slot > -1 then
		-- equip poisons after fight
		FPXI.debugd("Found more poisons in your bag and will equip them asap.")
		FPXI.nextPoisonSlot = slot
		FPXI.onCombatChange(_, IsUnitInCombat("player")) -- change instantly if not in fight
	else
		-- check fallback poisonType
		if fallbackPoisonType ~= nil then
			
			slot = FPXI.scanInventory(fallbackPoisonType)
			if slot > -1 then
				-- equip fallback poisons after fight
				FPXI.debugd("Found fallback poisons in your bag and will equip them asap.")
				FPXI.nextPoisonSlot = slot
				FPXI.onCombatChange(_, IsUnitInCombat("player")) -- change instantly if not in fight
			else
				-- out of poisons
				FPXI.debugd("You ran our of poisons!")
				if FPXI.savedVariables.alert then
					FPXI.poisonAlertLoop()
					EVENT_MANAGER:RegisterForUpdate(FPXI.name .. "Loop", FPXI.savedVariables.alertInterval * 1000, FPXI.poisonAlertLoop)
				end
			end
		else
			-- out of poisons
			FPXI.debugd("You ran our of poisons!")
			if FPXI.savedVariables.alert then
				FPXI.poisonAlertLoop()
				EVENT_MANAGER:RegisterForUpdate(FPXI.name .. "Loop", FPXI.savedVariables.alertInterval * 1000, FPXI.poisonAlertLoop)
			end
		end
	end	
end

function FPXI.onCombatChange(_, inCombat)
	if inCombat == false and FPXI.nextPoisonSlot > -1 then
		zo_callLater(function()
			FPXI.debugd("Equipping poisons from Slot " .. FPXI.nextPoisonSlot .. ". (after the fight)")
			EquipItem(BAG_BACKPACK, FPXI.nextPoisonSlot, EQUIP_SLOT_POISON)
			FPXI.nextPoisonSlot = -1
			-- check if it rly has equipped
			zo_callLater(function()
				local _, stack, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, EQUIP_SLOT_POISON)
				if stack == 0 then
					FPXI.debugd("Could not equip poisons. Let's try it again.")
					FPXI.onInventoryChange(_, BAG_WORN, EQUIP_SLOT_POISON, _, _, _, _)
				end
			end, 1000)
		end, 500)
	end
end

function FPXI.onZoneChange(_, _)
	
	local zone, x, y, z = GetUnitWorldPosition("player")
	local _, stack, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, EQUIP_SLOT_POISON)
	
	if stack == 0 and FPXI.savedVariables.alert == true and (FPXI.savedVariables.raidonly == false or FPXI.zones[zone] ~= nil) then
		FPXI.poisonAlertLoop()
		EVENT_MANAGER:RegisterForUpdate(FPXI.name .. "Loop", FPXI.savedVariables.alertInterval * 1000, FPXI.poisonAlertLoop)
	else
		EVENT_MANAGER:UnregisterForUpdate(FPXI.name .. "Loop")
	end
	
	if (FPXI.savedVariables.raidonly == true and FPXI.zones[zone] ~= nil) or FPXI.savedVariables.raidonly == false then
		FPXI.debugd("active")
		EVENT_MANAGER:RegisterForEvent(FPXI.name, EVENT_PLAYER_COMBAT_STATE, FPXI.onCombatChange)
		EVENT_MANAGER:RegisterForEvent(FPXI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, FPXI.onInventoryChange)
		EVENT_MANAGER:AddFilterForEvent(FPXI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(FPXI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	else
		FPXI.debugd("inactive")
		EVENT_MANAGER:UnregisterForEvent(FPXI.name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(FPXI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

function FPXI.onInventoryChange(_, _, slotId, _, _, _, _) 

	if slotId == EQUIP_SLOT_POISON then
		
		local zone, x, y, z = GetUnitWorldPosition("player")
		local _, stack, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, EQUIP_SLOT_POISON) 
		
		if stack == 0 and (FPXI.savedVariables.raidonly == false or FPXI.zones[zone] ~= nil) then
		
			if FPXI.savedVariables.refill == true then
				if FPXI.savedVariables.crownPoisons == true then
					if FPXI.savedVariables.prefCrownPoisons == true then
						FPXI.equipPoison(FPXI.poisons.CROWN, FPXI.poisons.CRAFTED)
					else
						FPXI.equipPoison(FPXI.poisons.CRAFTED, FPXI.poisons.CROWN)
					end
				else
					FPXI.equipPoison(FPXI.poisons.CRAFTED, nil)
				end
			else
				if FPXI.savedVariables.alert then
					FPXI.poisonAlertLoop()
					EVENT_MANAGER:RegisterForUpdate(FPXI.name .. "Loop", FPXI.savedVariables.alertInterval * 1000, FPXI.poisonAlertLoop)
				end
			end
		else
			EVENT_MANAGER:UnregisterForUpdate(FPXI.name .. "Loop")
		end
	end
end

function FPXI.debugd(message)
	if FPXI.savedVariables.debugd == true then
		d("|cFFFFFFF|c32CD32P|cFFFFFFXI|cDBDBDB: " .. tostring(message) .. "|r")
	end
end

function FPXI.onAddOnLoaded(event, addonName)
	if addonName ~= FPXI.name then return end
	
	FPXI.initializeSettingsMenu()
	EVENT_MANAGER:RegisterForEvent(FPXI.name, EVENT_PLAYER_ACTIVATED, FPXI.onZoneChange)
	
	FPXI.onInventoryChange(_, _, EQUIP_SLOT_POISON, _, _, _, _)
	
	zo_callLater(function()
		FPXI.debugd("Addon loaded.")
	end, 1)
end

EVENT_MANAGER:RegisterForEvent(FPXI.name, EVENT_ADD_ON_LOADED, FPXI.onAddOnLoaded)