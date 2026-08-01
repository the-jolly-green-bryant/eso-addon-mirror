local _addonName = "AutoBind"
local _savedVariables

local _isOnOpenStoreActive = false
local _isOnInventoryUpdateActive = false

local _eventNameOpenStore = _addonName .. "_OpenStore"
local _eventNameInventorySlotUpdateOnCollect = _addonName .. "_InventorySlotUpdateOnCollect"

AutoBind = {
	AddonName = _addonName,
	AddonDisplayName = "Auto Bind",
	Version = "3.0.0",

	Traits = {},
	Settings = {},
	PreviewWindow = {},
}

local function ThrowAlert(text)
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat("[<<1>>] <<2>>", _addonName, text))
end

local function ThrowAlertError(text)
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat("[<<1>>] <<2>>", _addonName, text))
end

function AutoBind.ThrowAlertItemsBound(count)
	ThrowAlert(zo_strformat("<<1>> <<2>>", count, GetString(SI_SBAUTOBIND_ALERT_ITEMS_BOUND)))
end

function AutoBind.ThrowAlertNoItemsFound()
	ThrowAlertError(GetString(SI_SBAUTOBIND_ALERT_NO_ITEMS_FOUND))
end

function AutoBind.SortItemsByQuality(items)
	table.sort(items, function(firstValue, secondValue)
		return firstValue.Quality < secondValue.Quality
	end)
end

local function GetItemDataIfUnknown(bagId, slotIndex)
	if IsItemPlayerLocked(bagId, slotIndex) == false then
		local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

		if IsItemLinkSetCollectionPiece(itemLink) == true and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) == false then
			local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink, false)

			if hasSet == true then
				local quality = GetItemLinkQuality(itemLink)

				if quality <= _savedVariables.MaxQuality then
					local traitType = GetItemLinkTraitInfo(itemLink)

					if not _savedVariables.ExcludedTraits[traitType] then
						local itemType = GetItemLinkWeaponType(itemLink)

						if itemType == WEAPONTYPE_NONE then
							itemType = GetItemLinkEquipType(itemLink)
						else
							itemType = EQUIP_TYPE_MAX_VALUE + itemType
						end

						return {
							ItemLink = itemLink,
							SetId = setId,
							ItemType = itemType,
							Quality = quality,
							Bind = function() BindItem(bagId, slotIndex) end,
						}
					end
				end
			end
		end
	end
end

function AutoBind.GetUnknownItems(bagId)
	local bagSize = GetBagSize(bagId)
	local unknownItems = {}

	for slotIndex = 1, bagSize do
		local itemData = GetItemDataIfUnknown(bagId, slotIndex)

		if itemData ~= nil then
			local setId = itemData.SetId
			local itemType = itemData.ItemType

			if unknownItems[setId] == nil then
				unknownItems[setId] = {
					[itemType] = { itemData, }
				}
			elseif unknownItems[setId][itemType] == nil then
					unknownItems[setId][itemType] = { itemData, }
			else
				table.insert(unknownItems[setId][itemType], itemData)
			end
		end
	end

	return unknownItems
end

local function BindAllUnknown()
	local boundCount = 0
	local unknownItems = AutoBind.GetUnknownItems(BAG_BACKPACK)

	for setId, itemTypes in pairs(unknownItems) do
		for itemType, items in pairs(itemTypes) do
			AutoBind.SortItemsByQuality(items)

			items[1].Bind()
			boundCount = boundCount + 1
		end
	end

	return boundCount
end

AutoBind.BindAllUnknownSilently = BindAllUnknown

function AutoBind.BindAllUnknown()
	local boundCount = BindAllUnknown()

	if boundCount > 0 then
		AutoBind.ThrowAlertItemsBound(boundCount)
	else
		AutoBind.ThrowAlertNoItemsFound()
	end
end

function AutoBind.SetStoreEventActive(isActive)
	if _isOnOpenStoreActive == isActive then return end
	_isOnOpenStoreActive = isActive

	if isActive == true then
		EVENT_MANAGER:RegisterForEvent(_eventNameOpenStore, EVENT_OPEN_STORE, function(eventCode)
			local boundCount = BindAllUnknown()

			if boundCount > 0 then
				AutoBind.ThrowAlertItemsBound(boundCount)
			end
		end)
	else
		EVENT_MANAGER:UnregisterForEvent(_eventNameOpenStore, EVENT_OPEN_STORE)
	end
end

function AutoBind.SetInventorySlotEventActive(isActive)
	if _isOnInventoryUpdateActive == isActive then return end
	_isOnInventoryUpdateActive = isActive

	if isActive == true then
		local function OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
			local itemData = GetItemDataIfUnknown(bagId, slotIndex)
			if itemData ~= nil then itemData.Bind() end
		end

		EVENT_MANAGER:RegisterForEvent(_eventNameInventorySlotUpdateOnCollect, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
		EVENT_MANAGER:AddFilterForEvent(_eventNameInventorySlotUpdateOnCollect, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
		EVENT_MANAGER:AddFilterForEvent(_eventNameInventorySlotUpdateOnCollect, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	else
		EVENT_MANAGER:UnregisterForEvent(_eventNameInventorySlotUpdateOnCollect, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

function AutoBind.AddSlashCommand(command, validArgs, infoOverride)
	if infoOverride == nil then infoOverride = {} end

	SLASH_COMMANDS[command] = function(arg)
		local targetFunction = validArgs[string.lower(arg)]

		if targetFunction ~= nil then
			targetFunction()
			return
		end

		local argList = {}

		for k, v in pairs(validArgs) do
			if k ~= "" then
				local text = infoOverride[k]

				if text == nil then
					table.insert(argList, k)
				else
					table.insert(argList, text)
				end
			end
		end

		table.sort(argList, function(firstValue, secondValue) return firstValue < secondValue end)

		d(command .. " valid arguments:")

		for i, v in ipairs(argList) do
			d("- " .. v)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(_addonName, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= _addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	AutoBind.Traits.Initialize()
	_savedVariables = AutoBind.Settings.Initialize()
	AutoBind.PreviewWindow.Initialize()

	AutoBind.AddSlashCommand("/autobind", {
		[""] = AutoBind.PreviewWindow.ToggleShown,
		["bind"] = AutoBind.BindAllUnknown,
	})
end)
