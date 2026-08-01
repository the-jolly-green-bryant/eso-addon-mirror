--[[
-------------------------------------------------------------------------------
-- JunkHotkey, by Maxxermax, code snippets lent from Dustman https://www.esoui.com/downloads/info97-Dustman.html#info
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

-- Leaked for menu & data
JunkHotkey = {}

local ADDON_NAME = "JunkHotkey"

-- Libraries ------------------------------------------------------------------
-- local LR = LibStub("libResearch-2")

--FCOCompanion should not be necessary anymore
-- local isCompanionJunkEnabled = false
-- local companionJunkedItemsOfChar = nil

-- Local variables ------------------------------------------------------------
local hoveredBagId
local hoveredSlotId
local junkHotkeyJunkKeybind
local hoveredItemCanBeJunked
local isItemJunk
local descriptorName = GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
local junkableBags = {
		[BAG_BACKPACK] = true,
		[BAG_BANK] = true,
		[BAG_HOUSE_BANK_ONE] = true,
		[BAG_HOUSE_BANK_TWO] = true,
		[BAG_HOUSE_BANK_THREE] = true,
		[BAG_HOUSE_BANK_FOUR] = true,
		[BAG_HOUSE_BANK_FIVE] = true,
		[BAG_HOUSE_BANK_SIX] = true,
		[BAG_HOUSE_BANK_SEVEN] = true,
		[BAG_HOUSE_BANK_EIGHT] = true,
		[BAG_HOUSE_BANK_NINE] = true,
		[BAG_HOUSE_BANK_TEN] = true,
	}

local function OnSlotMouseEnter(inventorySlot)
	
	if inventorySlot and inventorySlot.dataEntry then
		hoveredBagId = inventorySlot.dataEntry.data.bagId
		hoveredSlotId = inventorySlot.dataEntry.data.slotIndex
		if hoveredBagId and hoveredSlotId and junkableBags[hoveredBagId] and CanItemBeMarkedAsJunk(hoveredBagId, hoveredSlotId) then
			hoveredItemCanBeJunked = true
			isItemJunk = IsItemJunk(hoveredBagId, hoveredSlotId)
			KEYBIND_STRIP:UpdateKeybindButtonGroup(junkHotkeyJunkKeybind)
		end
	end

end

local function OnSlotMouseExit()
	
	hoveredBagId = nil
	hoveredSlotId = nil
	hoveredItemCanBeJunked = false
	isItemJunk = false
	
	KEYBIND_STRIP:UpdateKeybindButtonGroup(junkHotkeyJunkKeybind)
	
end

local function CanHoveredItemBeJunked()
	return hoveredItemCanBeJunked
end

local function JunkHoveredItem()
	if CanHoveredItemBeJunked() then
		local isCompanionItem = nil
        local actorCategory = GetItemActorCategory(hoveredBagId, hoveredSlotId)
        isCompanionItem = (actorCategory ~= nil and actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION) or false
		
		SetItemIsJunk(hoveredBagId, hoveredSlotId, not isItemJunk)
		if isCompanionItem == false then
			PlaySound(isItemJunk and SOUNDS.INVENTORY_ITEM_UNJUNKED or SOUNDS.INVENTORY_ITEM_JUNKED)
		end
	end
end

local function UpdateAndDisplayKeybind()
	
	if isItemJunk then
		descriptorName = GetString(SI_ITEM_ACTION_UNMARK_AS_JUNK)
	else
		descriptorName = GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
	end
	
	return CanHoveredItemBeJunked()

end

local function InitializeInventoryKeybind()

	ZO_PreHook("ZO_InventorySlot_OnMouseEnter", OnSlotMouseEnter)
	ZO_PreHook("ZO_InventorySlot_OnMouseExit", OnSlotMouseExit)

	ZO_CreateStringId("SI_BINDING_NAME_JUNKHOTKEY_JUNK", descriptorName)
	
	junkHotkeyJunkKeybind =
	{
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name = function() return descriptorName end,
			keybind = "JUNKHOTKEY_JUNK", -- UI_SHORTCUT_NEGATIVE cannot be used
			callback = JunkHoveredItem,
			visible = UpdateAndDisplayKeybind,
		},
	}
	--FCOCompanion should not be necessary anymore
	-- if FCOCO ~= nil and FCOCO.IsCompanionJunkEnabled ~= nil then
		-- isCompanionJunkEnabled, companionJunkedItemsOfChar = FCOCO.IsCompanionJunkEnabled()
	-- end
	
	local function OnStateChanged(oldState, newState)
		if newState == SCENE_SHOWING then
			KEYBIND_STRIP:AddKeybindButtonGroup(junkHotkeyJunkKeybind)
		elseif newState == SCENE_HIDDEN then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(junkHotkeyJunkKeybind)
		end
	end
	
	INVENTORY_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)
	BANK_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)
	HOUSE_BANK_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)

end

function JunkHotkey_JunkHoveredItem()
	JunkHoveredItem()
end

local function OnLoad(eventCode, addonName)

	if addonName == "JunkHotkey" then
		EVENT_MANAGER:UnregisterForEvent("JunkHotkey", EVENT_ADD_ON_LOADED)
		InitializeInventoryKeybind()
	end
end

EVENT_MANAGER:RegisterForEvent("JunkHotkey", EVENT_ADD_ON_LOADED, OnLoad)