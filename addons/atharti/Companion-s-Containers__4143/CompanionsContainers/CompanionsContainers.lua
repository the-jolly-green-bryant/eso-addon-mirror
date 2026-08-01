CompCont = {
	Name = "CompanionsContainers",
}

local TARGET_ITEM_IDS = {
	[178470] = true,
	[197790] = true,
	[188144] = true,
	[187747] = true,
}

local NAMES = {}
for boxId, _ in pairs(TARGET_ITEM_IDS) do
    local itemLink = ("|H1:item:%d:0:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"):format(boxId)
	local name = GetItemLinkName(itemLink)

	NAMES[name] = true
end

-- ----------------------------------------------------------------------------

local function OnLootUpdated()
    local name, targetType, actionName, isOwned = GetLootTargetInfo()
	if name == "" then return end
    if not NAMES[name] then
        return
    end

    LootAll()

    return true
end

-- ----------------------------------------------------------------------------

local function HandleSingleSlot(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return end
	if GetNumBagFreeSlots(BAG_BACKPACK) <= 0 then return end

	local itemLink = GetItemLink(bagId, slotIndex)

	if itemLink == "" then return end

	local itemId = GetItemLinkItemId(itemLink)

	if not TARGET_ITEM_IDS[itemId] then return end

	local remaining = GetItemCooldownInfo(bagId, slotIndex)

	if remaining > 0 then
		zo_callLater(function() HandleSingleSlot(bagId, slotIndex) end, remaining+50)
	else
		CallSecureProtected('UseItem', bagId, slotIndex)
	end

	EVENT_MANAGER:UnregisterForUpdate(CompCont.Name .. 'FinalCheck')
	EVENT_MANAGER:RegisterForUpdate(CompCont.Name .. 'FinalCheck', 1000, function()
		OpenContainersCompCont()
	end)
end

local queuedSlots = {}
local queuedSlotKeys = {}
local isInCombat = false

local function TryOpenOrQueue(bagId, slotIndex)
    if isInCombat then
        local key = tostring(bagId) .. ':' .. tostring(slotIndex)
        if not queuedSlotKeys[key] then
            table.insert(queuedSlots, {bagId = bagId, slotIndex = slotIndex, key = key})
            queuedSlotKeys[key] = true
        end
        return
    end
    HandleSingleSlot(bagId, slotIndex)
end

local function ProcessQueuedSlots()
    for _, slot in ipairs(queuedSlots) do
        HandleSingleSlot(slot.bagId, slot.slotIndex)
    end
    queuedSlots = {}
    queuedSlotKeys = {}
end

local function OnCombatState(_, inCombat)
    isInCombat = inCombat
    if not inCombat then
        ProcessQueuedSlots()
    end
end

-- Replace direct HandleSingleSlot calls with TryOpenOrQueue
function CompCont.OnInventorySlotUpdate(_, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
    TryOpenOrQueue(bagId, slotIndex)
end

function OpenContainersCompCont()
	local inventoryCount = GetBagSize(BAG_BACKPACK) - 1

	for x = 0, inventoryCount do 
		TryOpenOrQueue(BAG_BACKPACK, x)
	end

	EVENT_MANAGER:UnregisterForUpdate(CompCont.Name .. 'FinalCheck')
end

---------------------------------------------------------------------------------------------------------
-- Initialize:
---------------------------------------------------------------------------------------------------------
function CompCont.OnAddOnLoaded(_, addonName)
	if addonName ~= CompCont.Name then return end
    EVENT_MANAGER:UnregisterForEvent(CompCont.Name, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(CompCont.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CompCont.OnInventorySlotUpdate)
    EVENT_MANAGER:RegisterForEvent(CompCont.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", OnLootUpdated)
end

---------------------------------------------------------------------------------------------------------
-- EVENT REGISTRATIONS:
---------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(CompCont.Name, EVENT_ADD_ON_LOADED, CompCont.OnAddOnLoaded)
