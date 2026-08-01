
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local Interaction = {}
Harvest:RegisterModule("interaction", Interaction)

local GetInteractionType = GetInteractionType

function Interaction.Initialize()
	Interaction.lastInteractionTimeInMs = 0
	Interaction.lastInteractableName = ""
	-- harvesting interaction takes 2 seconds, or 1 second with the champion perk
	-- so choose a delay that is a bit less than 1 second
	local delayInMs = 750
	EVENT_MANAGER:RegisterForUpdate("HarvestMap-InteractionType", delayInMs, Interaction.UpdateInteractionType)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_BEGIN_LOCKPICK, Interaction.BeginLockpicking)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_LOOT_RECEIVED, Interaction.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_LOOT_UPDATED, Interaction.OnLootUpdated)
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_SHOW_BOOK, Interaction.OnShowBook)
	
	EVENT_MANAGER:RegisterForEvent("HarvestMap", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Interaction.OnSlotUpdate)
	EVENT_MANAGER:AddFilterForEvent("HarvestMap", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
	EVENT_MANAGER:AddFilterForEvent("HarvestMap", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	EVENT_MANAGER:AddFilterForEvent("HarvestMap", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	
	SHARED_INVENTORY:RegisterCallback("SlotRemoved", Interaction.SlotRemoved)
	SHARED_INVENTORY:RegisterCallback("SlotAdded", Interaction.SlotAdded)
	local bagCache = SHARED_INVENTORY.bagCache[BAG_BACKPACK]
	if bagCache then
		for _, itemData in pairs(bagCache) do
			itemData.itemId = GetItemId(itemData.bagId, itemData.slotIndex)
			itemData.itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
		end
	end
	
	-- this hook stores the name of the object that was last interacted with
	local getInteractionInfo = function()
		local action, name, blockedNode, isOwned, additionalInfo, contextInfo, contextLink, isCriminal = GetGameCameraInteractableActionInfo()
		Interaction.lastInteractableAction = action
		Interaction.lastInteractableName = name
		Interaction.lastInteractableAdditionalInfo = additionalInfo
		Interaction.lastInteractableContextLink = contextLink
		Interaction.lastInteractableTimeInMs = GetGameTimeMilliseconds()
		Interaction.wasLastInteractableOwned = isOwned
		Interaction.wasLastInteractCriminal = isCriminal
		
		
		-- there is no EVENT_BEGIN_FISHING, so we have to use this hack instead
		-- here we check if the action is called "Fish"
		if action == GetString(SI_GAMECAMERAACTIONTYPE16) then
			-- there are some "Fish" quest interactions, which we don't want
			-- so we have to verify that we really start a fishing interaction
			local delayInMs = 500
			EVENT_MANAGER:UnregisterForUpdate("HarvestMap-FishState")
			EVENT_MANAGER:RegisterForUpdate("HarvestMap-FishState", delayInMs, Interaction.CheckFishingState)
		end
	end
	ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", getInteractionInfo)
	ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "HandleUpAction", getInteractionInfo)
end

function Interaction.OnLootReceived( eventCode, receivedBy, itemLink, stackCount, soundCategory, lootType, lootedBySelf )
	if not lootedBySelf then return end
	if not (lootType == LOOT_TYPE_ITEM) then return end
	if Interaction.lastInteractableName == "" then return end
	local wasHarvesting = (Interaction.lastInteractionType == INTERACTION_HARVEST)
	local wasContainer = Harvest.IsInteractableAContainer( Interaction.lastInteractableName )
	if wasContainer then
		-- if the last interaction was more than 5 sec ago, then it is probably not the source of the loot
		if GetGameTimeMilliseconds() - Interaction.lastInteractableTimeInMs >= 5 * 1000 then
			Interaction:Error("last interaction was a container (%s), but too long ago (%d)!",
				Interaction.lastInteractableName,
				GetGameTimeMilliseconds() - Interaction.lastInteractableTimeInMs)
			wasContainer = false
			Interaction.lastInteractableName = ""
		end
	end
	if not (wasHarvesting or wasContainer) then return end
	
	local itemId = select(4, ZO_LinkHandler_ParseLink( itemLink ))
	itemId = tonumber(itemId) or 0
	-- get the pin type depending on the item we looted and the name of the harvest node
	local pinTypeId = Harvest.GetPinTypeId(itemId, Interaction.lastInteractableName)
	-- abort if we couldn't find a matching pin type
	if pinTypeId == nil then
		Interaction:Info(
				"OnLootReceived failed: pin type id is nil for itemlink %s and interactable '%s'",
				itemLink, Interaction.lastInteractableName )
		return
	end
	
	local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
	local worldX, worldY, worldZ = Harvest.GetPlayer3DPosition()
	
	Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
			pinTypeId, mapMetaData.map, worldX, worldY, worldZ )
	CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId)
	
	-- reset the interaction state, so we do not fire the event again for other items in the same container/node
	Interaction.lastInteractionType = nil
	-- reset the interactable name variable
	-- otherwise looting a container item after opening heavy sacks, thieves troves, stashes etc can cause wrong pins
	Interaction.lastInteractableName = ""
	
end

-- neded for those players that play without auto loot
function Interaction.OnLootUpdated()
	-- verify the most basic conditions, so we do not iterate over all
	-- loot whenever the player takes one item
	local wasHarvesting = (Interaction.lastInteractionType == INTERACTION_HARVEST)
	local wasContainer = Harvest.IsInteractableAContainer( Interaction.lastInteractableName )
	if not (wasHarvesting or wasContainer) then return end
	-- i usually play with auto loot on
	-- everything was programmed with auto loot in mind
	-- if auto loot is disabled (ie OnLootUpdated is called)
	-- let harvestmap believe auto loot is enabled by calling
	-- OnLootReceived for each item in the loot window
	local items = GetNumLootItems()
	for lootIndex = 1, items do
		local lootId, _, _, count = GetLootItemInfo( lootIndex )
		Interaction.OnLootReceived( nil, nil, GetLootItemLink( lootId, LINK_STYLE_DEFAULT ), count, nil, LOOT_TYPE_ITEM, true )
	end
end

function Interaction.UpdateInteractionType(timeInMs)
	-- remember the most recent interaction type for upto 2 seconds
	-- this is because lag can cause the loot window to open a bit after
	-- the harvesting interaction has ended
	local currentInteractionType = GetInteractionType()
	if currentInteractionType ~= 0 then
		Interaction.lastInteractionType = currentInteractionType
		Interaction.lastInteractionTimeInMs = timeInMs
	elseif timeInMs - Interaction.lastInteractionTimeInMs > 2000 then
		Interaction.lastInteractionType = nil
	end
end

function Interaction.BeginLockpicking()
	local pinTypeId = nil
	local shouldDelete = false
	
	local stealFrom = GetString(SI_GAMECAMERAACTIONTYPE20)
	local unlock = GetString(SI_GAMECAMERAACTIONTYPE12)
	-- normal chests aren't owned and their interaction is called "unlock"
	-- other types of chests (ie for heists) aren't owned but their interaction is "search"
	if (not Interaction.wasLastInteractableOwned) and (Interaction.lastInteractableAction == unlock) then
		-- normal chest
		pinTypeId = Harvest.CHESTS
	elseif Interaction.wasLastInteractableOwned and (Interaction.lastInteractableAction == unlock) then
		-- Remove pin if tag is "Unlock", e.g. for locked doors.
		-- In spanish localization "unlock" and "open" are the same,
		-- so entering an unlocked door (interaction = "open") is incorrectly marked as a safebox
		pinTypeId = Harvest.JUSTICE
		shouldDelete = true
	elseif Interaction.wasLastInteractableOwned and (Interaction.lastInteractableAction == stealFrom) then
		-- safeboxes are owned and use the interaction "steal from"
		pinTypeId = Harvest.JUSTICE
	end
	if not pinTypeId then
		Interaction:Debug("not a chest or justice container. owned: %s, action: %s",
				tostring(Interaction.wasLastInteractableOwned), tostring(Interaction.lastInteractableAction))
		return
	end
	-- we want to store the interaction camera's position as it's more accurate than player position
	if not IsInteractionUsingInteractCamera() then
		Interaction:Debug("detected pintype %d, but interaction camera is inactive", pinTypeId)
		return
	end
	-- lockpicking has its own interaction camera, which is different from the player position
	local worldX, worldY, worldZ = Harvest.GetCamera3DPosition()
	
	local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
	Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
			pinTypeId, mapMetaData.map, worldX, worldY, worldZ )
	if shouldDelete then
		CallbackManager:FireCallbacks(Events.NODE_DELETION_REQUEST, mapMetaData, worldX, worldY, worldZ, Harvest.JUSTICE)
		CallbackManager:FireCallbacks(Events.NODE_DELETION_REQUEST, mapMetaData, worldX, worldY, worldZ, Harvest.CHESTS)
	else
		CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId)
	end
end

function Interaction.CheckFishingState()
	EVENT_MANAGER:UnregisterForUpdate("HarvestMap-FishState")
	if GetInteractionType() == INTERACTION_FISH then
		local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
		local worldX, worldY, worldZ = Harvest.GetPlayer3DPosition()
		local pinTypeId = Harvest.FISHING
		Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
			pinTypeId, mapMetaData.map, worldX, worldY, worldZ )
		CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId)
	end
end

function Interaction.OnShowBook(eventCode, bookTitle, body, medium, isTitleShown, bookId)
	local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
	if categoryIndex and collectionIndex and bookIndex then
		Interaction.DiscoverBook(categoryIndex, collectionIndex, bookIndex)
	end
end

local EIDETIC_CATEGORY = 3
local SHALIDOR_CATEGORY = 1
local LoreCategoryIndexToPinTypeId = {
	[SHALIDOR_CATEGORY] = Harvest.LOREBOOK,
	[EIDETIC_CATEGORY] = Harvest.LOREBOOK,
}

function Interaction.DiscoverBook(categoryIndex, collectionIndex, bookIndex)
	local title, icon, isKnown, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	if GetPlayerWorldPositionInHouse() ~= 0 then return end
	if Interaction.lastInteractableName == title then
		local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
		local worldX, worldY, worldZ = Harvest.GetPlayer3DPosition()
		local pinTypeId = LoreCategoryIndexToPinTypeId[categoryIndex]
		if not pinTypeId then return end
		
		local flag = bookId * (2^Harvest.BOOK_OFFSET)
		Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
			pinTypeId, mapMetaData.map, worldX, worldY, worldZ)
		CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId, flag)
	end
end

local isSpecializedItemTypeMap = {
	[SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = true,
	[SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = true,
}

function Interaction.OnSlotUpdate(event, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if stackCountChange ~= -1 then return end	
	if Interaction.lastInteractableAdditionalInfo ~= ADDITIONAL_INTERACT_INFO_REQUIRES_KEY then return end
	local itemType, specializedItemType = GetItemLinkItemType(Interaction.lastInteractableContextLink)
	if specializedItemType ~= SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then return end
	-- we just used a treasure map. store current location.
	local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
	local worldX, worldY, worldZ = Harvest.GetPlayer3DPosition()
	local pinTypeId = Harvest.TREASURE
	
	local itemId = GetItemLinkItemId(Interaction.lastInteractableContextLink)
	local flag = itemId * (2^Harvest.BOOK_OFFSET)
	
	Interaction.lastInteractableAdditionalInfo = nil
	Interaction.lastInteractableContextLink = nil
	
	Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
		pinTypeId, mapMetaData.map, worldX, worldY, worldZ)
	CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId, flag)
end

function Interaction.SlotAdded(bagId, slotIndex, slotData, suppressItemUpdate)
	if bagId ~= BAG_BACKPACK then return end
	slotData.itemId = GetItemId(bagId, slotIndex)
	slotData.itemLink = GetItemLink(bagId, slotIndex)
end

function Interaction.SlotRemoved(bagId, slotIndex, oldSlotData, suppressItemAlert)
	if bagId ~= BAG_BACKPACK then return end
	if oldSlotData.specializedItemType ~= SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then return end 
	if GetInteractionType() ~= INTERACTION_HARVEST then return end
	-- we just used a survey map. store current location.
	local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
	local worldX, worldY, worldZ = Harvest.GetPlayer3DPosition()
	local pinTypeId = Harvest.TREASURE
	local itemId = oldSlotData.itemId
	local flag = itemId * (2^Harvest.BOOK_OFFSET)
	Interaction:Info("Discovered a new node. pintypeid: %d, map: %s, world: %f, %f, %f",
		pinTypeId, mapMetaData.map, worldX, worldY, worldZ)
	CallbackManager:FireCallbacks(Events.NODE_DISCOVERED, mapMetaData, worldX, worldY, worldZ, pinTypeId, flag)
end