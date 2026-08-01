--------------------------Equip / Bag--------------------------
-- Checks to see if the item is nil, already equipped or not meant to be swapped
function GearSwap:ItemCanBeEquipped(itemID, equipSlotID, event)
	local equippedItemID = GetItemUniqueId(BAG_WORN, equipSlotID)
	--Item not nil and not currently equipped
	if (itemID ~= "nil" and itemID ~= tostring(equippedItemID)) then
		return true
	else
		return false
	end
end

--Gets the slot integer of the item to be equipped (if possible)
function GearSwap:GetItemSlotFromBag(itemID)
	local bagCount = GetBagSize(BAG_BACKPACK) 
	--Iterate over the slots in the bag to find the item
	for b=0,bagCount,1 do
		local bagItemID = GetItemUniqueId(BAG_BACKPACK, b)
		--Compare against itemID
		if (itemID == tostring(bagItemID)) then
			return b
		end 
	end 
	--Didn't find, return nil
	return nil
end

-- Unequip Gear Table (Garkin)
do
	local unequipArray = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_LEGS, EQUIP_SLOT_HAND, EQUIP_SLOT_FEET, EQUIP_SLOT_WAIST }

	function GearSwap:GetUnequipGearArray()
		return unequipArray
	end
end

--------------------------Updaters--------------------------

--Update Character UI Label Function eg "Primary Set Active"
function GearSwap:UpdateGearSwapUILabel(gearSet)
	local gearSetName = GearSwap:GetGearSetName(gearSet)
	GearSwap.Label:SetText(gearSetName..GetString(MISC_ACTIVE_TEXT))
end

--Update the combobx with the named value of the gearset
function GearSwap:UpdateComboboxSelected(gearSet)
	local gearSetName = GearSwap:GetGearSetName(gearSet)	
	GearSwap.Combobox:SetSelectedItem(gearSetName)
end

--Updates the defaults or primary and secondary sets when weaponswapping [defaultSet = 1 or 2]
function GearSwap:UpdateWeaponSwapDefaultSet(gearSetName, defaultSet)
	local gearSetID = GearSwap:GetGearSetID(gearSetName)
	
	if(defaultSet == 1) then
		GearSwap.Options.GearSetForPrimary = gearSetID
	elseif (defaultSet == 2) then
		GearSwap.Options.GearSetForSecondary = gearSetID
	end
end

--------------------------Get / Set--------------------------
-- Returns all gearset names for a pulldown
--
function GearSwap:GetAllGearSetNames()
	local SettingsGearsetsPulldown = {}
	for i=1,4,1 do
		table.insert(SettingsGearsetsPulldown,GearSwap.GearSetVariables[i].Name)
	end
	return SettingsGearsetsPulldown
end

function GearSwap:UpdateMountSet(gearSetName)
	self.Options.MountSet = GearSwap:GetGearSetID(gearSetName)
end

--Returns an int 1-4 , based on the gearSetName
function GearSwap:GetGearSetID(gearSetName)
	--Find the correct table
	for i=1,4,1 do
		if(GearSwap.GearSetVariables[i].Name == gearSetName) then
			return GearSwap.GearSetVariables[i].Index
		end
	end
end

--Returns the Name of the gearSet, given an index
function GearSwap:GetGearSetName(gearSetID)
	--Find the correct table
	for i=1,4,1 do
		if(GearSwap.GearSetVariables[i].Index == gearSetID) then
			return GearSwap.GearSetVariables[i].Name
		end
	end
end

--Returns the ID of the currently selected GearSet
function GearSwap:GetGearSetFromCombobox()
	-- Get the string of the selected item
	local selected = GearSwap.Combobox:GetSelectedItem()
	return GearSwap:GetGearSetID(selected )
end

--------------------------Callbacks--------------------------


--------------------------Output--------------------------
--Output Currently Equippped Set
function GearSwap:OutputEquippedSet(gearSet)
	local gearSetName = GearSwap:GetGearSetName(gearSet)
	--Only Output if option is enabled

	if(GearSwap.Options.OutputOnGearSwap and lastKeySet ~= gearSet) then
		GearSwap:ShowMessage(GearSwap:GetGearSetName(gearSet)..GetString(MISC_EQUIPPED_TEXT))
	end
end

--Output Gear Set Saved
function GearSwap:OutputSavedSet(gearSet)
	local gearSetName = GearSwap:GetGearSetName(gearSet)
	--Only Output if option is enabled
	if(GearSwap.Options.OutputOnGearSave) then
		d(GearSwap:GetGearSetName(gearSet)..GetString(MISC_SAVED_TEXT))
	end
end

-- Using ZO-Routine to set up a timer for output with delay
function GearSwap:ShowMessage(value)
	ctlGearSwap:SetHidden(false)
	ctlGearSwapOutput:SetText(value)
	-- set onscreen messagebox hidden, if msgbox not set as visible on settings
	if (GearSwap.Options.MoveMsgbox == false) then
		local MsgDelay = self.Options.MsgDelay
		zo_callLater(function() ctlGearSwap:SetHidden(true) end, MsgDelay)
	end

end

