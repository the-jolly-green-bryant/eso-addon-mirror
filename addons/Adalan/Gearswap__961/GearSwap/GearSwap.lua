-- original by dboc
-- improved and fixed by Adalan@Aruntas
-- includes routines from Garkin for "Go naked" keypress-event
GearSwap = {}
GearSwap.name = "GearSwap"
GearSwap.version = "1.46"

local lastEvent = 0
local bLastModeWasMount = false
local PulldownChoosenGearSet = 0
local tmpSwapState = false
local bAllowSwap = true

--On AddOn Load event
function OnAddOnLoaded(event, addonName)
	--Only load if the correct addon
  	if (addonName == GearSwap.name) then
    	GearSwap:Initialize()
  	end
end

--GearSwap AddOn Initialize Function
function GearSwap:Initialize()
	--Set Keybinding XML strings
	GearSwap:CreateKeybindingStrings()

	EVENT_MANAGER:RegisterForEvent(GearSwap.name, EVENT_PLAYER_ACTIVATED, function()
		--Load the initial default values
		GearSwap:GetDefaultGearSets()
		GearSwap:GetDefaultOptions()

		--Load the saved variables into the set, pass default set if not saved
		GearSwap.GearSets = ZO_SavedVars:New("GearSwapVars", 1, "GearSets", GearSwap.DefaultGearSets)
		GearSwap.Options = ZO_SavedVars:New("GearSwapVars", 1, "Options", GearSwap.DefaultOptions)	
		
		--Load the initial GearSwap values
		GearSwap:GetGearSetVariables()
		--Load AddOn Menu using LAM
		GearSwap:CreateGearSwapAddOnMenu()

		--Create the Buttons on the Character Panel
		GearSwap:CreateUIControls()	
		GearSwap:RestorePosition()
		
		GearSwap:UpdateComboboxSelected(GearSwap.Options.LastUsedSet)
		if (GearSwap.Options.OutputAutoMount) then GearSwap:AnnounceMountONOFF() end
		if (GearSwap.Options.SwitchMountSetActive) then 
			EVENT_MANAGER:RegisterForEvent(GearSwap.name, EVENT_MOUNTED_STATE_CHANGED, function(...) GearSwap:fMountStateChanged(...) end)
		end
		
		zo_callLater(function() GearSwap:AnnounceGearSwapOnOff() GearSwap:AnnounceSwappingOnOff() end, 1200)
		EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_ACTION_SLOTS_FULL_UPDATE, function(...) GearSwap:HotBarSwapped(...) end)
		EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_OPEN_TRADING_HOUSE, function(...) GearSwap:TradingHouseOpen(...) end)
		EVENT_MANAGER:UnregisterForEvent(GearSwap.name, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function(...) GearSwap:WeaponChanged(...) end)
		
		-- register callback for inventory to set off functionality for swappings to suppress some event-floodings
		-- to make it possible to change rings and necklace
		local inventoryScene = SCENE_MANAGER:GetScene("inventory")
		inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
			if(newState == SCENE_SHOWN) then
			    bAllowSwap = false
			elseif(newState == SCENE_HIDDEN) then
				bAllowSwap = true
			end
		end)		
    end)
	
end

function GearSwap:TradingHouseOpen()
	EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_OPEN_TRADING_HOUSE)
	EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_CLOSE_TRADING_HOUSE, function(...) GearSwap:TradingHouseClose(...) end)
	tmpSwapState = GearSwap.Options.GearSwapOn
	GearSwap.Options.GearSwapOn = false
end
function GearSwap:TradingHouseClose()
	EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_CLOSE_TRADING_HOUSE)
	EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_OPEN_TRADING_HOUSE, function(...) GearSwap:TradingHouseOpen(...) end)
	GearSwap.Options.GearSwapOn = tmpSwapState
end

function GearSwap:AnnounceMountONOFF()
	if (GearSwap.Options.SwitchMountSetActive) then 
		--if (GearSwap.Options.OutputAutoMount) then d(GetString(MISC_MOUNT_SWAP_ON)) end
		d(GetString(MISC_MOUNT_SWAP_ON))
	elseif (GearSwap.Options.SwitchMountSetActive == false) then
		--if (GearSwap.Options.OutputAutoMount) then d(GetString(MISC_MOUNT_SWAP_OFF)) end
		d(GetString(MISC_MOUNT_SWAP_OFF))
	end
end

function GearSwap:ToggleAutoSwapMount()
	if (GearSwap.Options.SwitchMountSetActive) then 
		GearSwap:EnableDisableMounting(false)
	elseif (GearSwap.Options.SwitchMountSetActive == false) then
		GearSwap:EnableDisableMounting(true)
	end
end	

function GearSwap:EnableDisableMounting(bON)
	if (bON) then 
		EVENT_MANAGER:RegisterForEvent(GearSwap.name, EVENT_MOUNTED_STATE_CHANGED, function(...) GearSwap:fMountStateChanged(...) end)		
		GearSwap.Options.SwitchMountSetActive = true
	else
		EVENT_MANAGER:UnregisterForEvent(GearSwap.name, EVENT_MOUNTED_STATE_CHANGED)
		GearSwap.Options.SwitchMountSetActive = false		
	end
	GearSwap:AnnounceMountONOFF()
end


function GearSwap:fMountStateChanged(eventCode, bMounted)
	if (GearSwap.Options.LastUsedSet == 0) then return end

	if (GearSwap.Options.SwitchMountSetActive) then
		if (bMounted) then
				GearSwap.Options.LastUsedSet = GearSwap:GetGearSetFromCombobox()
				GearSwap:EquipGearSet(GearSwap.Options.MountSet, 2, eventCode)
				bLastModeWasMount = true
		elseif (bMounted == false and GearSwap.Options.LastUsedSet ~= nil) then
			zo_callLater(function()				
				GearSwap:EquipGearSet(GearSwap.Options.LastUsedSet, 2, eventCode)
				bLastModeWasMount = false
			end, GearSwap.Options.UnmountSwapDelay)			
		end
	end
end

function GearSwap:ToggleGearSwap()
	if (GearSwap.Options.GearSwapOn == true) then
		GearSwap.Options.GearSwapOn = false
		GearSwap:AnnounceGearSwapOnOff()
	else
		GearSwap.Options.GearSwapOn = true
		GearSwap:AnnounceGearSwapOnOff()
	end
end
function GearSwap:AnnounceGearSwapOnOff()
	if (GearSwap.Options.GearSwapOn == false) then d(GetString(MISC_GEARSWAP_TOGGLE_OFF))
	else d(GetString(MISC_GEARSWAP_TOGGLE_ON)) end
end

function GearSwap:ToggleSwapping()
	if (GearSwap.Options.GearSwapOn == false) then return end
	if (GearSwap.Options.ChangeGearSetOnWeaponSwap == true) then
		GearSwap.Options.ChangeGearSetOnWeaponSwap = false
		GearSwap:AnnounceSwappingOnOff()
	else
		GearSwap.Options.ChangeGearSetOnWeaponSwap = true
		GearSwap:AnnounceSwappingOnOff()
	end
end
function GearSwap:AnnounceSwappingOnOff()
	if (GearSwap.Options.GearSwapOn == false) then return end
	if (GearSwap.Options.ChangeGearSetOnWeaponSwap == false) then d(GetString(MISC_GEARSET_WEAPONSWAP_OFF))
	else d(GetString(MISC_GEARSET_WEAPONSWAP_ON)) end
end

--Save gearset button click event
function GearSwap:SaveGearSet(gearSet)
	GearSwap:GetGearSetFromCombobox()
	--Load local table depending on the weaponset
	local theGearSet = GearSwap.GearSets[gearSet]
	--For each item slot where  value1 is the slotID and value2 is the itemID
	for i=1,15,1 do
		--Get the Slot (eg Head, legs etc), get the itemID and put into the GearSet
		local slotID = theGearSet[i][1]
		local itemID = GetItemUniqueId(BAG_WORN, slotID)
		GearSwap.GearSets[gearSet][i][2] = tostring(itemID) 
	end
	--Output the Save message	
	GearSwap:OutputSavedSet(gearSet)
end

function GearSwap:HotBarSwapped(eventCode, isHotbarSwapped)
	-- This is in addition to the WeaponChanged event needed, because the system do raise events as weapon-swap just 
	-- for some milliseconds (i.e. after relog on stealth, using a mount after relog and so on) even if no swap was made
	-- this do create a weird effect, so that a weapon change is raised and will be made by those routines then
	-- To suppress such an effect, this here is needed with an optional check up in WeaponChanged(...)-Event-Routine
	if(IsUnitInCombat('player') == false and isHotbarSwapped == true and GearSwap.Options.GearSwapOn == true) then
		EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_WEAPON_PAIR_LOCK_CHANGED, function(...) GearSwap:checkLock(...) end)
	end
end


function GearSwap:checkLock(eventCode, locked)
	if locked == false then
		EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_WEAPON_PAIR_LOCK_CHANGED)
		EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function(...) GearSwap:WeaponChanged(...) end)		
	end
end

--Weapon Swap Triggered function - may be triggered on Character Load
function GearSwap:WeaponChanged(eventCode, activeWeaponPair, locked)
	if (GearSwap.Options.GearSwapOn == false or GearSwap.Options.ChangeGearSetOnWeaponSwap == false or bAllowSwap == false) then return end
	if (activeWeaponPair == GearSwap.Options.LastUsedSet) then return end

		--Only Attempt to swap if not in combat
	if(IsUnitInCombat('player') == false) then
		--Check Options
		if (GearSwap.Options == {}) then return end -- no Options loaded (happens on first load and first start)
		if(GearSwap.Options.GearSwapOn) then
			bLastModeWasMounted = false
			if (activeWeaponPair == 1) then
				GearSwap:EquipGearSet(GearSwap.Options.GearSetForPrimary , 1, eventCode)
				GearSwap.Options.LastUsedSet = 1
			elseif (activeWeaponPair == 2) then
				GearSwap:EquipGearSet(GearSwap.Options.GearSetForSecondary , 1, eventCode)
				GearSwap.Options.LastUsedSet = 2
			end
		end
	end
end

--Equip Function - Where gearset is 1 or 2 (primary / secondary) and swapEvent is 1 or 2 (weaponswap or keybinding)
function GearSwap:EquipGearSet(gearSet, swapEvent, eventCode)
	if (GearSwap.Options.GearSwapOn == false) then return end
	
	EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
	
	--Load local table depending on the weaponset
	local theGearSet = GearSwap.GearSets[gearSet]
	--For Each array in the geat set where an array value is item[arrayIndex][value]
	local timer = 0
	local timerAdd = 200
	local nUnequipped = 0
	local arrEquip = GearSwap:GetUnequipGearArray()
	zo_callLater(function()
		for i=1,15,1 do
			local equipSlotID = theGearSet[i][1]
			local itemID = theGearSet[i][2]
			if (itemID == "nil" and GearSwap.Options.UnequipSingleItem and i < 12 and i ~= 8) then --includes armour, neck and rings
				zo_callLater(function() UnequipItem(equipSlotID) end, timer)
				timer = timer + timerAdd
				nUnequipped = nUnequipped + 1			
			elseif (itemID ~= "nil") then
				if (equipSlotID == EQUIP_SLOT_COSTUME or equipSlotID == EQUIP_SLOT_RING1 or equipSlotID == EQUIP_SLOT_RING2 or equipSlotID == EQUIP_SLOT_NECK or equipSlotID == EQUIP_SLOT_HEAD or 
				    equipSlotID == EQUIP_SLOT_SHOULDERS or equipSlotID == EQUIP_SLOT_CHEST or equipSlotID == EQUIP_SLOT_LEGS or equipSlotID == EQUIP_SLOT_HAND or equipSlotID == EQUIP_SLOT_FEET or 
					equipSlotID == EQUIP_SLOT_WAIST) then
					if (GearSwap:ItemCanBeEquipped(itemID, equipSlotID, swapEvent)) then
						--Get the ID from bag is possible
						local bagSlotID = GearSwap:GetItemSlotFromBag(itemID)
						if (bagSlotID ~= nil) then
							EquipItem(BAG_BACKPACK, bagSlotID, equipSlotID)
						end	
					end
				end
				-- this routine is made because of a weapon-change event-deadlock. A timer of 1500 seconds seems to be ok. (With one second there still happened sometimes a deadlock)
				if (equipSlotID == EQUIP_SLOT_MAIN_HAND or equipSlotID == EQUIP_SLOT_OFF_HAND or equipSlotID == EQUIP_SLOT_BACKUP_MAIN or equipSlotID == EQUIP_SLOT_BACKUP_OFF)then 
					if (GearSwap:ItemCanBeEquipped(itemID, equipSlotID, swapEvent)) then
						--Get the ID from bag is possible
						local bagSlotID = GearSwap:GetItemSlotFromBag(itemID)
						if (bagSlotID ~= nil) then
							zo_callLater(function() 
								EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
								EVENT_MANAGER:UnregisterForEvent(GearSwap.name,EVENT_ACTION_SLOTS_FULL_UPDATE)
								EVENT_MANAGER:UnregisterForEvent(GearSwap.name, EVENT_MOUNTED_STATE_CHANGED)
								EquipItem(BAG_BACKPACK, bagSlotID, equipSlotID)
								-- not needed to register EVENT_ACTIVE_WEAPON_PAIR_CHANGED here, because it gets registered on EVENT_ACTION_SLOTS_FULL_UPDATE
								EVENT_MANAGER:RegisterForEvent(GearSwap.name, EVENT_MOUNTED_STATE_CHANGED, function(...) GearSwap:fMountStateChanged(...) end)
								EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_ACTION_SLOTS_FULL_UPDATE, function(...) GearSwap:HotBarSwapped(...) end)
							end, 1650)
						end	
					end
				end
			--Costume is an exception, sometimes we don't want one
			elseif (equipSlotID == EQUIP_SLOT_COSTUME and GearSwap.Options.SwapCostume == true) then
				local equippedItemID = GetItemUniqueId(BAG_WORN, equipSlotID)
				if (GearSwap.Options.SwapCostume == true and equippedItemID ~= nil) then UnequipItem(equipSlotID) end
			end
		end
	end, 200)

	-- give out a message on chat, if there are unused slots detected (means empty) for your armour, rings and necklace
	if (nUnequipped > 0 and self.Options.OutputUnusedSlots) then 
		d(GetString(MISC_UNEQUIPPED_ITEMS_GEARSET_PREFIX_TEXT)..gearSet..GetString(MISC_UNEQUIPPED_ITEMS_TEXT)..nUnequipped) 
	end
	
	--Perform Updates
	GearSwap:UpdateComboboxSelected(gearSet)
	GearSwap:UpdateGearSwapUILabel(gearSet)
	GearSwap:OutputEquippedSet(gearSet)
end

-- save position on window move
function GearSwap:WinMoveStop()
  GearSwap.Options.left = ctlGearSwap:GetLeft()
  GearSwap.Options.top = ctlGearSwap:GetTop()
end

-- restore window position
function GearSwap:RestorePosition()
  local left = GearSwap.Options.left
  local top = GearSwap.Options.top
  
  ctlGearSwap:ClearAnchors()
  ctlGearSwap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--Special function to handle weapons - messes up because of zenimax weapon swap
function GearSwap:EquipGearSetWithWeapons(gearSet)
	GearSwap:UnequipItem(EQUIP_SLOT_MAIN_HAND)
	GearSwap:UnequipItem(EQUIP_SLOT_OFF_HAND)
	GearSwap:UnequipItem(EQUIP_SLOT_BACKUP_MAIN)
	GearSwap:UnequipItem(EQUIP_SLOT_BACKUP_OFF)
end

-- Garkin
--Unequip function - unequipArray is an array of equip slots or nil to unequip all items with durability 
do
	local unequipQueue = {}
	local inProgress = false
	local locked = false

	function GearSwap:UnequipItems(unequipArray)
		unequipArray = unequipArray or self:GetUnequipGearArray()

		--lock to allow update queue
		locked = true
		d(GetString(MISC_UNDRESSING_ALL_ITEMS_TEXT))
		--rebuild queue
		local slots = {}
		for _, v in pairs(unequipQueue) do
			slots[v] = true
		end
		for _, v in pairs(unequipArray) do
			slots[v] = true
		end
		unequipQueue = {}
		for slot, _ in pairs(slots) do
			table.insert(unequipQueue, slot)
		end

		--unlock
		locked = false

		if not inProgress then
			inProgress = true
			EVENT_MANAGER:RegisterForUpdate(self.name, 200, function()
					if not (locked or IsUnitInCombat('player')) then
						if(#unequipQueue > 0) then
							local gearSlot = unequipQueue[1]
							local wornItem = GetItemUniqueId(BAG_WORN, gearSlot)
							-- See if the slot is empty
							if (wornItem ~= nil) then 
								UnequipItem(gearSlot)
							end

							table.remove(unequipQueue, 1)
						else
							EVENT_MANAGER:UnregisterForUpdate(self.name)
							inProgress = false
						end
					end
				end)
		end
	end
end

--Register Events
EVENT_MANAGER:RegisterForEvent(GearSwap.name,EVENT_ADD_ON_LOADED, OnAddOnLoaded)