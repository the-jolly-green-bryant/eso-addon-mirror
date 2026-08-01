RengarusOakensoulSwap = {}
RengarusOakensoulSwap.name = "RengarusOakensoulSwap"
RengarusOakensoulSwap.version= "1"

ZO_CreateStringId("SI_BINDING_NAME_SWAP_START", "Unequip Oakensoul")

local swaping = false
local slot = 0
local link = 0

function RengarusOakensoulSwap:SwapStart()
	if IsUnitInCombat('player') then return end
	if swaping == false then
		if GetItemLinkItemId(GetItemLink(0, 11, LINK_STYLE_BRACKETS)) == 187658 then
			swaping = true
			slot = 1
			link = GetItemLink(0, 11, LINK_STYLE_BRACKETS)
			RequestUnequipItem(0, 11)
			--d("Oakensoul unequiped from Slot 1")
		elseif GetItemLinkItemId(GetItemLink(0, 12, LINK_STYLE_BRACKETS)) == 187658 then
			swaping = true
			slot = 2
			link = GetItemLink(0, 12, LINK_STYLE_BRACKETS)
			RequestUnequipItem(0, 12)
			--d("Oakensoul unequiped from Slot 2")
		else
			slot = 0
			link = 0
			--d("Oakensoul is not equiped")
		end
	end
end

local function SwapEnd()
	if IsUnitInCombat('player') then return end
	if swaping == true then
		local slotBag = 255
		for i = 0, 250, 1 do 
			if GetItemLink(1, i, LINK_STYLE_BRACKETS) == link then
				slotBag = i
				if slot == 1 then
					RequestEquipItem(1,slotBag,0, 11)
					--d("Oakensoul equiped in Slot 1")
				elseif slot == 2 then
					RequestEquipItem(1,slotBag,0, 12)
					--d("Oakensoul equiped in Slot 2")
				end
				swaping = false
				return
			end
		end
		swaping = false
		d("Error: Oakensoul could not be found.")
	end
end

local function OnCombatState(eventCode, inCombat)	
	if inCombat == true and swaping == true then
		d("Warning: Oakensoul is not equiped.")
	elseif inCombat == false and swaping == true then
		SwapEnd()
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName == RengarusOakensoulSwap.name then
		EVENT_MANAGER:RegisterForEvent(RengarusOakensoulSwap.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, SwapEnd)
		EVENT_MANAGER:RegisterForEvent(RengarusOakensoulSwap.name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
	end
end

EVENT_MANAGER:RegisterForEvent(RengarusOakensoulSwap.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)