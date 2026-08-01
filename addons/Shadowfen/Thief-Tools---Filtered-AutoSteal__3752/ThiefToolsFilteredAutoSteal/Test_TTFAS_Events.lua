local L = GetString
local SF = LibSFUtils

local saved = SF.safeTable()
local curprof = nil

local dbg = TTFAS.dbg
local SystemMessage = TTFAS.SystemMessage

local runOnce

TestTTFAS = {}

-- create logger with separate tag
TestTTFAS.logger = LibDebugLogger.Create("TTFAS/Test")
TestTTFAS.logger:SetEnabled(true)

-- keep track of registered testing events for TestTTFAS
local testevtmgr = SF.EvtMgr:New("TTFAS-Test")

-- --------------------------------------------
-- handlers
local function OnLaunderResult(ec, result)
	--[[
	* ITEM_LAUNDER_RESULT_AT_LIMIT
	* ITEM_LAUNDER_RESULT_CANT_AFFORD_LAUNDER
	* ITEM_LAUNDER_RESULT_INVALID
	* ITEM_LAUNDER_RESULT_INVENTORY_FULL
	* ITEM_LAUNDER_RESULT_ITEM_NOT_LAUNDERABLE - never see
	* ITEM_LAUNDER_RESULT_NONE
	* ITEM_LAUNDER_RESULT_NOT_STOLEN - never see
	* ITEM_LAUNDER_RESULT_SUCCESS
	--]]
	local srslt
	if result == ITEM_LAUNDER_RESULT_SUCCESS then
		srslt = "ITEM_LAUNDER_RESULT_SUCCESS" 
	elseif result == ITEM_LAUNDER_RESULT_NONE then
		srslt = "ITEM_LAUNDER_RESULT_NONE"
	elseif result == ITEM_LAUNDER_RESULT_INVENTORY_FULL then
		srslt = "ITEM_LAUNDER_RESULT_INVENTORY_FULL"
	elseif result == ITEM_LAUNDER_RESULT_AT_LIMIT then
		srslt = "ITEM_LAUNDER_RESULT_AT_LIMIT"
	elseif result == ITEM_LAUNDER_RESULT_INVALID then
		srslt = "ITEM_LAUNDER_RESULT_INVALID"
	else
		srslt = "unknown"
	end
	TestTTFAS.logger:Debug(SF.str("OnLaunderResult  result=(", result,") ",srslt))
end


function TestTTFAS:OnLootClosed(eventCode)
	TestTTFAS.logger:Debug("Executing OnLootClosed")
    --EVENT_MANAGER:UnregisterForEvent(TestTTFAS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

function TestTTFAS:OnLootRecvd(ec, rcvd, itmname, qty, _, loottype, unkn,
	pickLoot, qstIcon, itemId, stolen)
--[[
* EVENT_LOOT_RECEIVED (*string* _receivedBy_, *string* _itemName_, 
				*integer* _quantity_, *[ItemUISoundCategory|#ItemUISoundCategory]* _soundCategory_, 
				*[LootItemType|#LootItemType]* _lootType_, 
				*bool* _self_, *bool* _isPickpocketLoot_, 
				*string* _questItemIcon_, *integer* _itemId_, 
				*bool* _isStolen_)
]]
	TestTTFAS.logger:Debug(SF.str("OnLootRecvd: rcvdBy=", rcvd,
		" name=", itmname, " qty=",qty," loottype=",loottype,
		" unkn=",unkn," pick=",pickLoot," qst=",qstIcon," itemId=",itemId,
		" stolen=",stolen))
end

function TestTTFAS:OnItemDestroyed(uisound)
--[[
	* EVENT_INVENTORY_ITEM_DESTROYED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
]]
	TestTTFAS.logger:Debug(SF.str("OnItemDestroyed: uisound=", uisound))
end

function TestTTFAS:OnItemChanged(uisound)
--[[
	* EVENT_ITEM_SLOT_CHANGED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
]]
	TestTTFAS.logger:Debug(SF.str("OnItemChanged: uisound=", uisound))
end

function TestTTFAS:OnJusticeRemoved()
--[[
EVENT_JUSTICE_STOLEN_ITEMS_REMOVED
]]
	TestTTFAS.logger:Debug(SF.str("OnJusticeRemoved"))
end

--[[
		DEBUG ONLY

* EVENT_INVENTORY_SINGLE_SLOT_UPDATE (*[Bag|#Bag]* _bagId_, 
				*integer* _slotIndex_, *bool* _isNewItem_, 
				*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_, 
				*integer* _inventoryUpdateReason_, *integer* _stackCountChange_, 
				*string:nilable* _triggeredByCharacterName_, 
				*string:nilable* _triggeredByDisplayName_, 
				*bool* _isLastUpdateForMessage_, 
				*[BonusDropSource|#BonusDropSource]* _bonusDropSource_)
]]
local function onSlotUpdate(ec, bagId, slotIndex, isNewItem, itemSoundCategory, 
	updateReason,  stackCountChange, trigChar, trigDisp, isLastUpdate)

	TestTTFAS.logger:Debug(SF.str("onSlotUpdate: reason = ",updateReason, 
		" bagID=", bagId, " slotIndex=",slotIndex,
		" cntChng=",stackCountChange))
    if updateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return end
	--[[
	* INVENTORY_UPDATE_REASON_ARMORY_BUILD_CHANGED
	* INVENTORY_UPDATE_REASON_DEFAULT
	* INVENTORY_UPDATE_REASON_DURABILITY_CHANGE
	* INVENTORY_UPDATE_REASON_DYE_CHANGE
	* INVENTORY_UPDATE_REASON_ITEM_CHARGE
	* INVENTORY_UPDATE_REASON_PLAYER_LOCKED
	]]
    local itm = {}
	if ThiefTools then
		itm = ThiefTools_HotItem:New(bagId,slotIndex)
		itm.link = GetItemLink(bagId,slotIndex)
		itm.IsJunk = IsItemJunk(bagId, slotIndex)
		TestTTFAS.logger:Debug(SF.str("onSlotUpdate:  ",itm.name, 
			"  new=", isNewItem,"  junked=(",itm.IsJunk,") ",IsItemJunk(bagId, slotIndex),
			"  lastupd=",isLastUpdate))
		TestTTFAS.logger:Debug(SF.str("onSlotUpdate:  ",itm.link, 
			"  itemId=", GetItemId(bagId,slotIndex)))

		TestTTFAS.logger:Debug(SF.str("onSlotUpdate:  id=",Id64ToString(itm.uniqueId), 
			"  itemType=", itm.itemType, "  specType=", itm.specializedItemType,
			"  equipType=",itm.equipType))
	end
end


-- --------------------------------------------
-- does not include EVENT_ADD_ON_LOADED because this can be
-- invoked more than once.
function TestTTFAS.RegisterEvents()
	TestTTFAS.logger:Debug("Registering all events")
	
	testevtmgr:registerEvt(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)
	testevtmgr:filterEvt(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
		REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	testevtmgr:registerEvt(EVENT_ITEM_LAUNDER_RESULT, OnLaunderResult)
	testevtmgr:registerEvt(EVENT_LOOT_CLOSED, function(...)
        TestTTFAS:OnLootClosed(...)
    end)
	testevtmgr:registerEvt(EVENT_LOOT_RECEIVED, function(...)
        TestTTFAS:OnLootRecvd(...)
    end)
	testevtmgr:registerEvt(EVENT_ITEM_SLOT_CHANGED, function(...)
        TestTTFAS:OnItemChanged(...)
    end)
	testevtmgr:registerEvt(EVENT_INVENTORY_ITEM_DESTROYED, function(...)
        TestTTFAS:OnItemDestroyed(...)
    end)
	testevtmgr:registerEvt(EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, function(...)
        TestTTFAS:OnJusticeRemoved(...)
    end)
	
end

function TestTTFAS.UnregisterAllEvts()
	TestTTFAS.logger:Debug("Unregistering all events")
	testevtmgr:unregAllEvt()
end

--[[
-> Interesting Events:
* EVENT_INVENTORY_IS_FULL (*integer* _numSlotsRequested_, 
				*integer* _numSlotsFree_)
* EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG
* EVENT_INVENTORY_ITEM_DESTROYED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
* EVENT_INVENTORY_ITEM_USED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
* EVENT_INVENTORY_SINGLE_SLOT_UPDATE (*[Bag|#Bag]* _bagId_, 
				*integer* _slotIndex_, *bool* _isNewItem_, 
				*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_, 
				*integer* _inventoryUpdateReason_, *integer* _stackCountChange_, 
				*string:nilable* _triggeredByCharacterName_, 
				*string:nilable* _triggeredByDisplayName_, 
				*bool* _isLastUpdateForMessage_, 
				*[BonusDropSource|#BonusDropSource]* _bonusDropSource_)
* EVENT_INVENTORY_SLOT_LOCKED (*[Bag|#Bag]* _bagId_, *integer* _slotIndex_)
* EVENT_INVENTORY_SLOT_UNLOCKED (*[Bag|#Bag]* _bagId_, *integer* _slotIndex_)
* EVENT_ITEM_LAUNDER_RESULT (*[ItemLaunderResult|#ItemLaunderResult]* _result_)
* EVENT_ITEM_SLOT_CHANGED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
* EVENT_JUSTICE_STOLEN_ITEMS_REMOVED
* EVENT_LOCKPICK_BROKE (*integer* _inactivityLengthMs_)
* EVENT_LOCKPICK_FAILED
* EVENT_LOCKPICK_SUCCESS
* EVENT_LOOT_CLOSED
* EVENT_LOOT_ITEM_FAILED (*[LootItemResult|#LootItemResult]* _reason_, 
				*string* _itemLink_)
* EVENT_LOOT_RECEIVED (*string* _receivedBy_, *string* _itemName_, 
				*integer* _quantity_, *[ItemUISoundCategory|#ItemUISoundCategory]* _soundCategory_, 
				*[LootItemType|#LootItemType]* _lootType_, 
				*bool* _self_, *bool* _isPickpocketLoot_, 
				*string* _questItemIcon_, *integer* _itemId_, 
				*bool* _isStolen_)
* EVENT_LOOT_UPDATED
* EVENT_RECIPE_ALREADY_KNOWN
* EVENT_RECIPE_LEARNED (*luaindex* _recipeListIndex_, *luaindex* _recipeIndex_)
* EVENT_SLOT_IS_LOCKED_FAILURE (*[Bag|#Bag]* _bagId_, *integer* _slotIndex_)
* EVENT_STACKED_ALL_ITEMS_IN_BAG (*[Bag|#Bag]* _bagId_)
* EVENT_STEALTH_STATE_CHANGED (*string* _unitTag_, 
				*[StealthState|#StealthState]* _stealthState_)

* EVENT_CURRENCY_UPDATE (*[CurrencyType|#CurrencyType]* _currencyType_, 
				*[CurrencyLocation|#CurrencyLocation]* _currencyLocation_, 
				*integer* _newAmount_, *integer* _oldAmount_, 
				*[CurrencyChangeReason|#CurrencyChangeReason]* _reason_, 
				*integer* _reasonSupplementaryInfo_)
--]]
