-- Basic Addon Info
-- This addon is a fork of "Static's Quickslot Profiles"-addon. Thank you Static Recharge for allowing me to use your code!
local CQS = {
	addonName = "CyroQuickslots",
	addonVersion = "1.31.1",
	author = "Gerrit",
}

-- Default Settings
CQS.Character = {
	Defaults = {
		Profiles = {},
	},
	SavedVars = {
		Profiles = {},
	},
	varsVersion = 2,
}

CQS.WasInCyrodiil = false

-- Constants
local Const = {
	chatPrefix = "[CQS]: ",
	firstQuickslotIndex = 9,
	lastQuickslotIndex = 16,
	quickslotSize = 8,
	inventoryBagID = 1,
	itemLinkDefaultStyle = 0,
	inventoryStartIndex = 0,
	actionDelayMS = 350,
}

-- Sends info to the chatbox
function CQS.SendToChat(text)
	if text ~= nil then
		d(Const.chatPrefix .. text)
	else
		d(Const.chatPrefix .. "nil string")
	end
end

function CQS.Save(profile)
	CQS.Character.SavedVars.Profiles[profile] = CQS.GetQuickslotInfo()
	-- CQS.SendToChat("Quickslots saved to profile " .. profile .. ".")
end

function CQS.GetItemIDFromLink(itemLink)
	local itemID
	_, _, itemID = string.find(itemLink, ":(%d+):")
	return tonumber(itemID)
end

function CQS.GetIdentifierFromLink(itemLink)
	local identifier
	_, _, identifier = string.find(itemLink, ":(%d+)|")
	return tonumber(identifier)
end

-- Cycles through each item in the profile to load it into the quickslots
function CQS.QuickslotLoadIterator(profile, slot)
	local itemLink = CQS.Character.SavedVars.Profiles[profile][slot].itemLink
	local itemID = CQS.Character.SavedVars.Profiles[profile][slot].itemID
	local identifier = CQS.Character.SavedVars.Profiles[profile][slot].identifier
	local found = false
	CallSecureProtected("ClearSlot", slot)
	if itemLink ~= "" then
		local collectibleID = GetCollectibleIdFromLink(itemLink)
		if collectibleID ~= nil then
			CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_COLLECTIBLE, collectibleID, slot)
		else
			if CQS.Inventory[itemID] ~= nil then
				if CQS.Inventory[itemID][2] ~= nil then
					for i,v in pairs(CQS.Inventory[itemID]) do
						if v.identifier == identifier then
							CallSecureProtected("SelectSlotItem", Const.inventoryBagID, v.slot, slot)
							found = true
							break
						end
					end
					if found == false then
						CallSecureProtected("SelectSlotItem", Const.inventoryBagID, CQS.Inventory[itemID][1].slot, slot)
					end
				else
					CallSecureProtected("SelectSlotItem", Const.inventoryBagID, CQS.Inventory[itemID][1].slot, slot)
				end
			else
				CQS.SendToChat(itemLink .. " not found in inventory.")
			end
		end		
	end
	slot = slot + 1
	if slot <= Const.lastQuickslotIndex then
		zo_callLater(function() CQS.QuickslotLoadIterator(profile, slot) end, Const.actionDelayMS)
	else
		CQS.SendToChat("Quickslots loaded for " .. profile .. ".")
	end
end

-- Loads the profile into the quickslots
function CQS.Load(profile)
	if CQS.Character.SavedVars.Profiles[profile] == nil then
		CQS.SendToChat("Quickslots for " .. profile .. " will be saved separately from now on.")
	else
		CQS.GetInventoryQuickslotInfo()
		CQS.QuickslotLoadIterator(profile, Const.firstQuickslotIndex)
	end
end

function CQS.GetInventoryQuickslotInfo()
	local bagSpace = GetBagSize(Const.inventoryBagID)
	CQS.Inventory = {}
	for i = Const.inventoryStartIndex, bagSpace do
		if IsValidItemForSlot(Const.inventoryBagID, i, Const.firstQuickslotIndex) then
			local itemID = GetItemId(Const.inventoryBagID, i)
			local itemLink = GetItemLink(Const.inventoryBagID, i)
			local identifier = CQS.GetIdentifierFromLink(itemLink)
			if CQS.Inventory[itemID] == nil then
				CQS.Inventory[itemID] = {}
				CQS.Inventory[itemID][1] = {slot = i, itemLink = itemLink, identifier = identifier}
			else
				info = {slot = i, itemLink = itemLink, identifier = identifier}
				table.insert(CQS.Inventory[itemID], info)
			end
		end
	end
end

function CQS.GetQuickslotInfo()
	local Info = {}
	for i = Const.firstQuickslotIndex, Const.lastQuickslotIndex do
		local itemLink = GetSlotItemLink(i)
		local itemID = CQS.GetItemIDFromLink(itemLink)
		local identifier = CQS.GetIdentifierFromLink(itemLink)
		Info[i] = {
			itemLink = itemLink,
			itemID = itemID,
			identifier = identifier
		}
	end
	return Info
end

function CQS.Initialize()
	CQS.Character.SavedVars = ZO_SavedVars:NewCharacterIdSettings("CQSCharVars", CQS.Character.varsVersion, nil, CQS.Character.Defaults, nil)
	CQS.WasInCyrodiil = IsInCyrodiil()

	EVENT_MANAGER:UnregisterForEvent(CQS.addonName, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(CQS.addonName, EVENT_PLAYER_ACTIVATED, CQS.OnPlayerActivated)
end

--  EVENT_PLAYER_ACTIVATED (number eventCode, boolean initial)
function CQS.OnPlayerActivated(eventCode, initial)
	if CQS.WasInCyrodiil ~= IsInCyrodiil() then
		CQS.WasInCyrodiil = IsInCyrodiil()
		if IsInCyrodiil() then
			CQS.Save('PvE')
			CQS.Load('Cyrodiil')
		else
			CQS.Save('Cyrodiil')
			CQS.Load('PvE')
		end
	end
end

EVENT_MANAGER:RegisterForEvent(CQS.addonName, EVENT_ADD_ON_LOADED, CQS.Initialize)