local CompanionsContainers = {}

local CC = CompanionsContainers
local EM = EVENT_MANAGER

CC.name = "CompanionsContainers"

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

-- =========================
-- Core
-- =========================
local queuedContainers = {}
local isInCombat = false

function CC.OnLootUpdated()
	local name = GetLootTargetInfo()
	if name == "" then return end
	if not NAMES[name] then return end

	LootAll()
	return true
end

function CC.HandleSlot(bagId, slotIndex)
	if bagId ~= BAG_BACKPACK then return end
	if GetNumBagFreeSlots(BAG_BACKPACK) <= 0 then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if itemLink == "" then return end

	local itemId = GetItemLinkItemId(itemLink)
	if not TARGET_ITEM_IDS[itemId] then return end

	local remaining = GetItemCooldownInfo(bagId, slotIndex)
	if remaining > 0 then
		zo_callLater(function()
			CC.HandleSlot(bagId, slotIndex)
		end, remaining + 50)
		return
	end

	CallSecureProtected('UseItem', bagId, slotIndex)
end

function CC.TryOpenOrQueue(bagId, slotIndex)
	if isInCombat then
		local key = tostring(bagId) .. ":" .. tostring(slotIndex)
		if not queuedContainers[key] then
			queuedContainers[key] = {bagId = bagId, slotIndex = slotIndex}
		end
		return
	end

	CC.HandleSlot(bagId, slotIndex)
end

function CC.ProcessQueued()
	for _, slot in pairs(queuedContainers) do
		CC.HandleSlot(slot.bagId, slot.slotIndex)
	end
	ZO_ClearTable(queuedContainers)

	EM:UnregisterForUpdate(CC.name)
	EM:RegisterForUpdate(CC.name, 1000, function()
		CC.OpenContainers()
		EM:UnregisterForUpdate(CC.name)
	end)
end

function CC.OnCombatState(_, inCombat)
	isInCombat = inCombat
	if not inCombat then
		CC.ProcessQueued()
	end
end

function CC.OnInventorySlotUpdate(_, bagId, slotIndex)
	CC.TryOpenOrQueue(bagId, slotIndex)
end

function CC.OpenContainers()
	local inventoryCount = GetBagSize(BAG_BACKPACK) - 1
	for x = 0, inventoryCount do
		CC.TryOpenOrQueue(BAG_BACKPACK, x)
	end
	EM:UnregisterForUpdate(CC.name)
end

-- =========================
-- Init
-- =========================
function CC.OnAddOnLoaded(_, addonName)
	if addonName ~= CC.name then return end
	EM:UnregisterForEvent(CC.name, EVENT_ADD_ON_LOADED)

	EM:RegisterForEvent(CC.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CC.OnInventorySlotUpdate)
	EM:RegisterForEvent(CC.name, EVENT_PLAYER_COMBAT_STATE, CC.OnCombatState)

	ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", CC.OnLootUpdated)
end

EM:RegisterForEvent(CC.name, EVENT_ADD_ON_LOADED, CC.OnAddOnLoaded)