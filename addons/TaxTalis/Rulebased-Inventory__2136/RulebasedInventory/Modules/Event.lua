-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Event.lua
-- File Description: This file contains the event listener definition
-- Load Order Requirements: after Task
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local ctx = RbI.Import(RbI.executionEnv.ctx)
local utils = RbI.Import(RbI.utils)
local tasks = RbI.Import(RbI.tasks)

local evt = {}
RbI.evt = evt

RbI.ItemQueue = utils.NewAsyncQueue(true, 1,
	function(itemRef) -- nextFn
		RbI.CheckItemInBag(itemRef)
	end,
	function(a, b) -- equalsFn
		return a.bag == b.bag and a.slot == b.slot
	end
)

local GetItemLinkForSorting = RbI.Import(RbI.GetItemLinkForSorting)
local itemRefClass = {
	__index = {
		GetItemLink = function(self)
			local link = self.link
			if(link) then return link end
			link = GetItemLink(self.bag, self.slot)
			self.link = link
			return link
		end,
		GetItemLinkForSorting = function(self)
			local linkS = self.linkS
			if(linkS) then return linkS end
			linkS = GetItemLinkForSorting(self:GetItemLink())
			self.linkS = linkS
			return linkS
		end
	}
}
local createItemRef = function(bag, slot)
	return setmetatable({ bag = bag, slot = slot }, itemRefClass)
end

function RbI.OnItemUpdate(bag, slot, isNewItem, stackCountChange)
	if(isNewItem and (bag == BAG_BACKPACK or bag == BAG_VIRTUAL)) then
		tasks.GetTask('Notify').checker.CheckBySlot(createItemRef(bag, slot), stackCountChange)
	end

	local slotStackSize = GetSlotStackSize(bag, slot)
	--d("OnItemUpate: "..bag.." "..slot.." "..GetItemLink(bag, slot).." "..slotStackSize)
	if(slotStackSize > 0) then
		RbI.ItemQueue.Push(createItemRef(bag, slot))
	end
end
local function OnSlotUpdate(eventCode, bag, slot, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if(SCENE_MANAGER:GetCurrentScene() == STABLES_SCENE
			or (Roomba and Roomba.WorkInProgress and Roomba.WorkInProgress())) then
		return
	end
	RbI.OnItemUpdate(bag, slot, isNewItem, stackCountChange)
end

local function OnFCOISMark(bag, slot)
	RbI.OnItemUpdate(bag, slot, false)
end

local function DelayedCall(func)
	zo_callLater(func, RbI.account.settings.taskDelay)
end


local function isScene(...)
	local sceneName = SCENE_MANAGER:GetCurrentScene().name
	-- d("found scene " .. sceneName)
	for _, name in ipairs({...}) do
		if(sceneName == name) then
			-- d("scene matches " .. name)
			return true
		end
	end
	return false
end

-- for debugging purposes
local function dumpInteractionType()
	local constantName = RbI.dataType["interactionType"][tostring(GetInteractionType())]
	d("InteractionType: "..GetInteractionType()..":"..tostring(constantName))
end
local function dumpSceneName()
	d("SceneName: "..SCENE_MANAGER:GetCurrentScene().name)
end

local interactionStartKeyMap
local function snapshotKeyMap()
	return {
		[KEY_COMMAND] = IsCommandKeyDown(),
		[KEY_CTRL] = IsControlKeyDown(),
		[KEY_SHIFT] = IsShiftKeyDown(),
	}
end
local function OnStationStart()
	interactionStartKeyMap = snapshotKeyMap()
end
local function OnStationEnd()
	interactionStartKeyMap = nil
end
local function preventAutoClose(key)
	return interactionStartKeyMap ~= nil and interactionStartKeyMap[key]
end
local function preventAutoOpen(key)
	return snapshotKeyMap()[key]
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Dolgubon's Lazy Writ Creator Support --------------------------------------
------------------------------------------------------------------------------

local AutoCrafter

-- We will adapt ourself the DLWC setting for autoClose
if(WritCreater ~= nil) then
	WritCreater.IsOkayToExitCraftStation = function()
		return not AutoCrafter.waiting
	end
end

AutoCrafter = (function()
	local registeredCraftComplete = false
	local waitForCraftComplete
	local waitForCraftCompleteCheck
	waitForCraftComplete = function(callback)
		-- Assumption: Crafting process begins immediately in EVENT_CRAFTING_STATION_INTERACT, EVENT_CRAFT_COMPLETED or EVENT_CRAFT_FAILED
		-- so we have to check after all other addon-callbacks have been processed
		AutoCrafter.waiting = true
		zo_callLater(function() waitForCraftCompleteCheck(callback) end, 1)
	end
	waitForCraftCompleteCheck = function(callback)
		if(IsPerformingCraftProcess()) then
			AutoCrafter.craftCount = AutoCrafter.craftCount + 1
			if(not registeredCraftComplete) then
				registeredCraftComplete = true
				local nextCallback = function() waitForCraftComplete(callback) end
				EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CRAFT_COMPLETED, nextCallback)
				EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CRAFT_FAILED, nextCallback)
			end
		else
			if(registeredCraftComplete) then
				registeredCraftComplete = false
				EVENT_MANAGER:UnregisterForEvent(RbI.name, EVENT_CRAFT_COMPLETED)
				EVENT_MANAGER:UnregisterForEvent(RbI.name, EVENT_CRAFT_FAILED)
			end
			AutoCrafter.waiting = false
			callback()
		end
	end

	local function isWritComplete(craftType)
		local questIndex = WritCreater.writSearch()[craftType]
		for i = 0, 7 do
			local text, _,_,_,_,_,_, conditionType = GetJournalQuestConditionInfo(questIndex, 1, i)
			if text~="" and conditionType == 45 then
				return true
			end
		end
		return false
	end

	local function writWillBeHandled(craftType)
		if (craftType == 0 or WritCreater == nil) then return false end
		local questIndex = WritCreater.writSearch()[craftType]
		-- if no writs are present or shouldn't be handled by DLWC return writs are "done"
		return questIndex and (WritCreater:GetSettings()[craftType] or WritCreater:GetSettings()[craftType]==nil)
	end

	return {
		waitForCraftComplete = waitForCraftComplete,

		willAutoGrabItems = function()
			if(not (WritCreater ~= nil and WritCreater:GetSettings().shouldGrab)) then return false end

			for _, craftType in pairs(RbI.dataTypeStatic.gearCraftingType) do
				if(craftType > 0 and writWillBeHandled(craftType) and not isWritComplete(craftType)) then
					return true
				end
			end
			return false
		end,

		wantExitWhenDone = function()
			return WritCreater~=nil and WritCreater:GetSettings().exitWhenDone and GetCraftingInteractionType() > 0 and writWillBeHandled(GetCraftingInteractionType())
		end,

		isWritComplete = function()
			return isWritComplete(GetCraftingInteractionType())
		end,
	}
	end)()


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Closing interface and dismissing assistant if necessary --------------------
------------------------------------------------------------------------------

local function closeInterface()
	zo_callLater(
		function()
			if(not SCENE_MANAGER:IsShowingBaseScene()) then
				if (RbI.account.settings.despawnAssistants) then
					ZO_SharedInteraction:CloseChatterAndDismissAssistant()
					--d("despawn")
				end
				SCENE_MANAGER:ShowBaseScene()
				--d("close")
				closeInterface()
			end
		end, 200)
end

-- Starting a task with auto-close mechanism
local function StartInteractionTask(taskName1, taskName2, actionFinishCallback)
	DelayedCall(
		function()
			tasks.Start(taskName1, taskName2)

			if(actionFinishCallback) then
				-- only add once, because both tasks added to the same ActionQueue
				if(RbI.ActionQueue.IsRunning(taskName1)) then
					RbI.ActionQueue.AddFinishCallback(taskName1, actionFinishCallback)
				else
					actionFinishCallback()
				end
			end

			-- check auto close
			if (evt.CanAutoClose(taskName1)) then
				-- only add once, because both tasks added to the same ActionQueue
				if (RbI.ActionQueue.IsRunning(taskName1)) then -- something is in the queue
					RbI.ActionQueue.AddFinishCallback(taskName1, closeInterface)
				else  -- nothing was done by RbI
					closeInterface()
				end
			end
		end
	)

end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- BANK ----------------------------------------------------------------------
------------------------------------------------------------------------------

local function DoBanking(eventCode, bagId, bankId, runNumber)
	if(not evt.IsBankOpen()) then return end

	-- check if a auto crafter might try to withdraw items
	if(runNumber < 1 and AutoCrafter.willAutoGrabItems()) then
		zo_callLater(function() DoBanking(eventCode, bagId, bankId, runNumber+1) end, math.max(RbI.account.settings.taskDelay, 1000))
	end

	tasks.Start('CraftToBag')

	RbI.ItemQueue.Pause(true)
	StartInteractionTask(bankId..'ToBag', 'BagTo'..bankId, function()
		RbI.ItemQueue.Run(true)
	end)

end

local currencyMapping = {
	gold = CURT_MONEY,
	telvar = CURT_TELVAR_STONES,
	ap = CURT_ALLIANCE_POINTS,
	vouchers = CURT_WRIT_VOUCHERS,
}
local function holdCurrency(currencyType, bagId, holdMin, holdMax)
	if(not holdMin or not holdMax) then return end
	local diff
	if(bagId == BAG_BACKPACK) then
		local amountInBag = GetCarriedCurrencyAmount(currencyType)
		if(amountInBag < holdMin) then
			diff = holdMin - amountInBag
		elseif(amountInBag > holdMax) then
			diff = holdMax - amountInBag
		end
	elseif(bagId == BAG_BANK) then
		local amountInBank = GetBankedCurrencyAmount(currencyType)
		if(amountInBank < holdMin) then
			diff = amountInBank - holdMin
		elseif(amountInBank > holdMax) then
			diff = amountInBank - holdMax
		end
	end
	if(diff) then
		if(diff < 0) then
			diff = math.abs(diff)
			DepositCurrencyIntoBank(currencyType, diff)
			RbI.out.msg("Currency-Transfer to bank: "..ZO_CurrencyControl_FormatCurrencyAndAppendIcon(diff, true, currencyType))
		elseif(diff > 0) then
			WithdrawCurrencyFromBank(currencyType, diff)
			RbI.out.msg("Currency-Transfer to backpack: "..ZO_CurrencyControl_FormatCurrencyAndAppendIcon(diff, true, currencyType))
		end
	end
end
local function handleCurrencies()
	if(not RbI.account.settings.usingCurrencies) then return end
	local currencySettings = RbI.character.currencies
	if(currencySettings) then
		for currencyType, settings in pairs(currencySettings) do
			holdCurrency(currencyMapping[currencyType], settings.bag, settings.holdMin, settings.holdMax)
		end
	end
end

local function SetBankingAllow(bagId, value)
	local bankName = RbI.data.getBankName(bagId)
	if(bankName ~= "Bank") then -- homebank
		if(value and RbI.account.settings.identifyHomebank) then
			RbI.out.msg("You're visiting "..bankName)
		end
		local homebankingMode = RbI.account.settings.homebankingMode
		if(homebankingMode == "Off") then
			return false
		elseif(homebankingMode == "Target Mode") then
			bankName = "Bank"
		end
	end
	RbI.allowAction['BagTo'..bankName] = value
	RbI.allowAction[bankName..'ToBag'] = value
	return bankName
end

local function OnBankOpen(eventCode, bagId, ...)
	if(bagId == BAG_BANK) then
		handleCurrencies()
	end
	local bankId = SetBankingAllow(bagId, true)
	if(bankId) then
		OnStationStart()
		ctx.station = bagId
		DoBanking(eventCode, bagId, bankId, 0)
	end
end

local function OnBankClose()
	--d('Bank Closed')
	OnStationEnd()
	local bagId = ctx.station
	if(bagId) then
		SetBankingAllow(bagId, false)
		ctx.station = nil
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- STORE ---------------------------------------------------------------------
------------------------------------------------------------------------------

local function OnStoreOpen()
	--d('Shop Opened')
	OnStationStart()
	RbI.allowAction['Sell'] = true
	if(GetNumStoreItems() > 0) then
		RbI.allowAction['Buy'] = true
		ctx.store = 'VENDOR'
		StartInteractionTask('Sell', 'Buy')
	else
		StartInteractionTask('Sell')
	end
end

local function OnStoreClose()
	--d('Shop or Fence Closed')
	OnStationEnd()
	RbI.allowAction['Sell'] = false
	RbI.allowAction['Buy'] = false
	RbI.allowAction['Fence'] = false
	RbI.allowAction['Launder'] = false
	ctx.store = nil
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- FENCE ---------------------------------------------------------------------
------------------------------------------------------------------------------

local function OnFenceOpen(eventCode, allowFence, allowLaunder)
	--d('Fence Opened')
	OnStationStart()
	RbI.allowAction['Fence'] = allowFence or false
	RbI.allowAction['Launder'] = allowLaunder or false

	RbI.fenceTotal, RbI.fenceUsed = GetFenceSellTransactionInfo()
	RbI.launderTotal, RbI.launderUsed = GetFenceLaunderTransactionInfo()

	StartInteractionTask('Launder', 'Fence')
end

-- FENCE closed via EVENT_CLOSE_STORE and OnStoreClose()

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- CRAFTING ------------------------------------------------------------------
------------------------------------------------------------------------------

local function WaitForPanel(topLevelPanelName)
	if(not evt.IsCraftingOpen()) then return end

	local TopLevelPanel
	local taskName
	if(topLevelPanelName == 'DECONSTRUCTION') then
		TopLevelPanel = ZO_SmithingTopLevelDeconstructionPanelSlotContainer
		taskName = 'Deconstruct'
	elseif(topLevelPanelName == 'EXTRACTION') then
		TopLevelPanel = ZO_EnchantingTopLevelExtractionSlotContainer
		taskName = 'Extract'
	elseif(topLevelPanelName == 'REFINEMENT') then
		TopLevelPanel = ZO_SmithingTopLevelRefinementPanelSlotContainer
		taskName = 'Refine'
	end

	if(TopLevelPanel:IsHidden()) then
		zo_callLater(function() WaitForPanel(topLevelPanelName) end, 300)
	else
		StartInteractionTask(taskName)
	end
end

local function DoCrafting(craftingType, isDeconstructionAssistant)
	if(not evt.IsCraftingOpen()) then return end

	if(isDeconstructionAssistant) then
		StartInteractionTask('Deconstruct', 'Extract')
	elseif(RbI.account.settings.immediateExecutionAtCraftStation) then
		if(craftingType ~= CRAFTING_TYPE_ENCHANTING) then
			StartInteractionTask('Deconstruct', 'Refine')
		else
			StartInteractionTask('Extract')
		end
	else
		if(craftingType ~= CRAFTING_TYPE_ENCHANTING) then
			WaitForPanel('DECONSTRUCTION')
			WaitForPanel('REFINEMENT')
		else
			WaitForPanel('EXTRACTION')
		end
	end
end

-- also for deconstruction assistant, but with craftingType==0 and craftingMode == CRAFTING_INTERACTION_MODE_UNIVERSAL_DECONSTRUCTION
local function OnCraftingStationOpen(eventCode, craftingType, sameStation, craftingMode)
	-- double check if station is still open
	if(craftingType ~= CRAFTING_TYPE_ALCHEMY and craftingType ~= CRAFTING_TYPE_PROVISIONING) then
		OnStationStart()
		-- d('Station Opened')
		local isDeconstructionAssistant = craftingMode == CRAFTING_INTERACTION_MODE_UNIVERSAL_DECONSTRUCTION
		local isEnchanting = craftingType == CRAFTING_TYPE_ENCHANTING
		RbI.allowAction['Deconstruct'] = not isEnchanting or isDeconstructionAssistant
		RbI.allowAction['Extract'] = isEnchanting or isDeconstructionAssistant
		RbI.allowAction['Refine'] = not isEnchanting

		ctx.station = isDeconstructionAssistant and -1 -- deconstruction assistant
				or craftingType

		AutoCrafter.craftCount = 0
		AutoCrafter.waitForCraftComplete(function()
			DoCrafting(craftingType, isDeconstructionAssistant)
		end)

	end
end

local function OnCraftingStationClose()
	OnStationEnd()
	RbI.allowAction['Deconstruct'] = false
	RbI.allowAction['Refine'] = false
	RbI.allowAction['Extract'] = false
	ctx.station = nil
	--d('Station Closed')
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- CraftBag ------------------------------------------------------------------
------------------------------------------------------------------------------

-- only fires if items where moved from the inventory to the craft bag after login or fast traveling into another zone
-- it doesn't fire when an item goes directly into the craft bag (p.e: through looting)
EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG, function()
	tasks.Start('CraftToBag')
end)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Initial PlayerActivated ---------------------------------------------------
------------------------------------------------------------------------------

local function LibCharacterKnowledgeReady()
	if(not LibCharacterKnowledge) then return true end
	local status, result = pcall(LibCharacterKnowledge.GetLastScanTime)
	return status and result > 0
end
function RbI.ConsistencyCheck()
	if (FCOIS and not FCOIS.addonVars.gPlayerActivated
			or not LibCharacterKnowledgeReady()) then
		zo_callLater(RbI.ConsistencyCheck, 300)
	else
		tasks.CheckAllItems(BAG_BACKPACK, true)
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Loot ----------------------------------------------------------------------
------------------------------------------------------------------------------

local function checkSafeLoot(numLootTransmute)
	local max = GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
	local numTransmute = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
	local sum = numTransmute + numLootTransmute
	if(sum > max) then
		return "Transmutations crystals would exceed the maximum, so we won't loot it: "..sum.." > "..max
	end
end

local function getLootDump()
	local content = {}
	-- also loot currencies
	for currencyType in pairs(ZO_CURRENCIES_DATA) do
		local currencyLoot = GetLootCurrency(currencyType)
		if(currencyLoot > 0) then
			content[#content+1] = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(currencyLoot, true, currencyType)
		end
	end
	for i = 1, GetNumLootItems() do
		local lootId, name,_,count,_,_,_,_,lootType = GetLootItemInfo(i)
		local itemLink = GetLootItemLink(lootId)
		if(count > 0) then
			content[#content+1] = count..'x '..itemLink
		else
			content[#content+1] = itemLink
		end
	end
	return table.concat(content, ", ")
end
local function lootAll(fnOnLootId)
	local content = {}
	if(fnOnLootId == nil) then
		LootAll()
		-- also loot currencies
		for currencyType in pairs(ZO_CURRENCIES_DATA) do
			local currencyLoot = GetLootCurrency(currencyType)
			if(currencyLoot > 0) then
				content[#content+1] = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(currencyLoot, true, currencyType)
			end
		end
	end
	for i = 1, GetNumLootItems() do
		local lootId, name,_,count,_,_,_,_,lootType = GetLootItemInfo(i)
		local itemLink = GetLootItemLink(lootId)
		if(fnOnLootId ~= nil) then fnOnLootId(lootId) end
		if(count > 0) then
			content[#content+1] = count..'x '..itemLink
		else
			content[#content+1] = itemLink
		end
	end
	return table.concat(content, ", ")
end

-- loot only items without currency
local function lootOnlyItems()
	local lootResult = lootAll(LootItemById)
	EndLooting()
	return lootResult
end

local function safeLoot()
	local lootResult, lootError
	local numLootTransmute = GetLootCurrency(CURT_CHAOTIC_CREATIA)
	if numLootTransmute == 0 then
		lootResult = lootAll()
	else
		lootError = checkSafeLoot(numLootTransmute)
		if(type(lootError) ~= 'string') then
			lootResult = lootAll()
		else
			-- loot only items no currency
			-- LootCurrency(slot.lootEntry.currencyType)
			lootResult = lootOnlyItems()
			return lootError
		end
	end
	return lootResult, lootError
end

function RbI.isLooting(msecs)
	local elapsedTime = msecs or 1000
	return (GetGameTimeMilliseconds() - (RbI.lootTime or 0)) < elapsedTime
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- AutoOpen ------------------------------------------------------------------
------------------------------------------------------------------------------

-- for debugging purposes
local function dumpChatOptions(chatOptionCount, debugSource)
	-- d("debugSource: " .. tostring(debugSource))
	for i= 1, chatOptionCount do
		local str, optionType = GetChatterOption(i)
		local constantName = RbI.dataType["chatterOption"][tostring(optionType)]
		d(i.." ["..optionType..":CHATTER_"..constantName.."]: "..str)
	end
end
local function OnChatterBegin(eventCode, chatOptionCount, debugSource)
	local chatterOptionBank
	local chatterOptionShop
	local chatterOptionCraft -- only for assistant
	local chatterOptionQuest

	-- dumpChatOptions(chatOptionCount, debugSource)
	for i= 1, chatOptionCount do
		local _, optionType = GetChatterOption(i)
		if (optionType == CHATTER_START_BANK) then chatterOptionBank = i end
		if (optionType == CHATTER_START_SHOP) then chatterOptionShop = i end
		if (optionType == CHATTER_START_CRAFT) then chatterOptionCraft = i end
		-- don't skip chatter if npc is questgiver (e.g. undaunted pledge)
		if (optionType == CHATTER_START_NEW_QUEST_BESTOWAL 
			or optionType == CHATTER_START_COMPLETE_QUEST 
			or optionType == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS) then 
			chatterOptionQuest = i 
		end
	end

	if (evt.CanAutoOpen(chatOptionCount, chatterOptionBank, chatterOptionShop, chatterOptionCraft, chatterOptionQuest)) then
		SelectChatterOption(chatterOptionBank or chatterOptionShop or chatterOptionCraft)
	end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- ZoneTypes -----------------------------------------------------------------
------------------------------------------------------------------------------

local instanceDisplayType = -1
local newInstanceDisplayType

-- InGameAPI -----------------------------------------------------------------
-- https://wiki.esoui.com/PvP_Zone_Detection
function evt.IsInPvP()
	return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
end
function evt.IsInCyrodiil() -- we think Delves in Cyrodiil should still count as in Cyrodiil
	return IsPlayerInAvAWorld() and not IsInImperialCity()
end
function evt.IsInCyrodiilOverland()
	return IsInCyrodiil()
end
function evt.IsInImperialCity()
	return IsInImperialCity()
end 
function evt.IsInImperialCityDistrict()
	return IsInImperialCity() and GetCurrentMapIndex() ~= nil
end 
function evt.IsInImperialSewers()
	return IsInImperialCity() and GetCurrentMapIndex() == nil
end
function evt.IsCPDisabled()
	return not DoesCurrentCampaignRulesetAllowChampionPoints()
end
function evt.IsInBattlegrounds()
	return IsActiveWorldBattleground()
end
function evt.IsInOutlawRefuge()
	return IsInOutlawZone()
end
function evt.IsJusticeEnabled() -- suspected to be only true for PvE overland
	return IsInJusticeEnabledZone()
end
function evt.IsTelvarEnabled()
	return DoesCurrentZoneHaveTelvarStoneBehavior()
end
function evt.IsInCampaign()
	return IsInCampaign()
end
function evt.IsInOwnHouse()
	return GetCurrentHouseOwner() == GetDisplayName()
end
-- Workaround ----------------------------------------------------------------
function evt.IsInHouse()
	local x,y,z,rotRad = GetPlayerWorldPositionInHouse()
	return x ~= 0 or y ~= 0 or z ~= 0 or rotRad ~= 0
end
-- Workaround via stored INSTANCE_DISPLAY ------------------------------------
function evt.IsInTrial()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_RAID
end
function evt.IsInDungeon()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_DUNGEON
end
function evt.IsInPublicDungeon()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON
end
function evt.IsInSoloContent()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_SOLO
end
function evt.IsInDelve()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_DELVE
end
function evt.IsInGroupDelve()
	return instanceDisplayType == INSTANCE_DISPLAY_TYPE_GROUP_DELVE
end

-- determin zoneTypes and set zoneTypes in ctx, try sorting by reliability of zoneType determining function
local function setZoneTypes()
	local zoneTypes = {}

	-- main zone type
	if (evt.IsInPvP()) then zoneTypes[#zoneTypes+1] = "pvp"
	else zoneTypes[#zoneTypes+1] = "pve" end
	
	-- additional types 
	if(evt.IsJusticeEnabled()) then zoneTypes[#zoneTypes+1] = "justice_enabled" end
	if (evt.IsInCyrodiil()) then zoneTypes[#zoneTypes+1] = "cyrodiil" end
	if (evt.IsInCampaign()) then zoneTypes[#zoneTypes+1] = "campaign" end
	if (evt.IsTelvarEnabled()) then zoneTypes[#zoneTypes+1] = "telvar_enabled" end
	if (evt.IsInImperialCity()) then zoneTypes[#zoneTypes+1] = "imperial_city" end
	if(evt.IsCPDisabled()) then zoneTypes[#zoneTypes+1] = "cp_disabled" end
	
	-- only of of those types can be active at any given time
	if (evt.IsInBattlegrounds()) then zoneTypes[#zoneTypes+1] = "battlegrounds"
	elseif (evt.IsInImperialSewers()) then zoneTypes[#zoneTypes+1] = "imperial_sewers"
	elseif (evt.IsInOutlawRefuge()) then zoneTypes[#zoneTypes+1] = "outlaw_refuge"
	elseif (evt.IsInHouse()) then zoneTypes[#zoneTypes+1] = "house"
		if(evt.IsInOwnHouse()) then zoneTypes[#zoneTypes+1] = "my_house" end
	elseif (evt.IsInDelve()) then zoneTypes[#zoneTypes+1] = "delve"
	elseif (evt.IsInGroupDelve()) then zoneTypes[#zoneTypes+1] = "group_delve"
	elseif (evt.IsInDungeon()) then zoneTypes[#zoneTypes+1] = "dungeon"
	elseif (evt.IsInPublicDungeon()) then zoneTypes[#zoneTypes+1] = "public_dungeon"
	elseif (evt.IsInTrial()) then zoneTypes[#zoneTypes+1] = "trial"
	elseif (evt.IsInSoloContent()) then zoneTypes[#zoneTypes+1] = "solo"
	else zoneTypes[#zoneTypes+1] = "overland" end -- fallback if no other type was detected
		
	ctx.zoneTypes = zoneTypes
end


-- allow only certain types of pins in search closest one
local allowPOIType = {
	  [POI_TYPE_PUBLIC_DUNGEON] = true
	, [POI_TYPE_GROUP_DUNGEON] = true
}
local allowZoneCompletionType = {
	  [ZONE_COMPLETION_TYPE_DELVES] = true
	, [ZONE_COMPLETION_TYPE_GROUP_DELVES] = true
	, [ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS] = true
}
local allowPinTextureName = {
	  ["/esoui/art/icons/poi/poi_delve_incomplete.dds"] = true
	, ["/esoui/art/icons/poi/poi_delve_complete.dds"] = true
	, ["/esoui/art/icons/poi/poi_groupdelve_incomplete.dds"] = true
	, ["/esoui/art/icons/poi/poi_groupdelve_complete.dds"] = true
	, ["/esoui/art/icons/poi/poi_raiddungeon_incomplete.dds"] = true
	, ["/esoui/art/icons/poi/poi_raiddungeon_complete.dds"] = true
	, ["/esoui/art/icons/poi/poi_solotrial_incomplete.dds"] = true
	, ["/esoui/art/icons/poi/poi_solotrial_complete.dds"] = true
}

local function debugGetPinTextureNames()
	MapZoomOut() -- zoom out map once to get correct parent map for weird maps like Asylum Sanctorium -> Brass Fortress but GetParentZoneId is Clockwork
	local zoneIndex = GetCurrentMapZoneIndex()
	SetMapToPlayerLocation() -- zoom in again to not mess with map setting, TODO: save initial zone and restore it?
	d("---" .. GetZoneNameByIndex(zoneIndex) .. "---")
	local textures = {}
	for poiIndex = 1, GetNumPOIs(zoneIndex) do
		local normalizedX, normalizedZ, mapDisplayPinType, textureName, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
		local name = GetPOIInfo(zoneIndex, poiIndex)
		d(name .. " - " .. textureName) textures[textureName] = true 
	end
end

local function GetInstanceDisplayTypeFromNearestPOI()
	MapZoomOut() -- zoom out map once to get correct parent map for weird maps like Asylum Sanctorium -> Brass Fortress but GetParentZoneId is Clockwork
	local zoneIndex = GetCurrentMapZoneIndex()
	local playerX, playerZ = GetMapPlayerPosition("player")
	local distance, poiIndex, poiType, zoneCompletionType, textureName
	SetMapToPlayerLocation() -- zoom in again to not mess with map setting, TODO: save initial zone and restore it?
	
	for poiIndexCandidate = 1, GetNumPOIs(zoneIndex) do
		local normalizedX, normalizedZ, _, textureNameCandidate = GetPOIMapInfo(zoneIndex, poiIndexCandidate)
		local poiTypeCandidate = GetPOIType(zoneIndex, poiIndexCandidate)
		local zoneCompletionTypeCandidate = GetPOIZoneCompletionType(zoneIndex, poiIndexCandidate)
		if ((normalizedX ~= 0 or normalizedZ ~= 0)
			and (allowPOIType[poiTypeCandidate] 
				or allowZoneCompletionType[zoneCompletionTypeCandidate] 
				or allowPinTextureName[textureNameCandidate])) then
			local dx = playerX - normalizedX
			local dz = playerZ - normalizedZ
			local distanceCandidate = dx * dx + dz * dz
			if(distance == nil or distance > distanceCandidate) then 
				distance = distanceCandidate
				poiIndex = poiIndexCandidate
				poiType = poiTypeCandidate
				zoneCompletionType = zoneCompletionTypeCandidate
				textureName = textureNameCandidate
			end
		end
	end
	
	local instanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE
	if(zoneCompletionType == ZONE_COMPLETION_TYPE_DELVES) then instanceDisplayType = INSTANCE_DISPLAY_TYPE_DELVE 
	elseif (zoneCompletionType == ZONE_COMPLETION_TYPE_GROUP_DELVES) then instanceDisplayType = INSTANCE_DISPLAY_TYPE_GROUP_DELVE 
	elseif (poiType == POI_TYPE_PUBLIC_DUNGEON) then instanceDisplayType = INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON
	elseif (poiType == POI_TYPE_GROUP_DUNGEON) then instanceDisplayType = INSTANCE_DISPLAY_TYPE_DUNGEON
	elseif (textureName == "/esoui/art/icons/poi/poi_raiddungeon_incomplete.dds" 
		or textureName == "/esoui/art/icons/poi/poi_raiddungeon_complete.dds") then instanceDisplayType = INSTANCE_DISPLAY_TYPE_RAID
	elseif (textureName == "/esoui/art/icons/poi/poi_solotrial_incomplete.dds"
		or textureName == "/esoui/art/icons/poi/poi_solotrial_complete.dds") then instanceDisplayType = INSTANCE_DISPLAY_TYPE_SOLO
	end	
	return instanceDisplayType
end

local function setInstanceDisplayType()
	--if(not newInstanceDisplayType) then d("loading instanceDisplayType from character") end
	newInstanceDisplayType = newInstanceDisplayType or RbI.character.lastInstanceDisplayType or INSTANCE_DISPLAY_TYPE_NONE

	-- validate InstanceDisplayType: we might have ported to a player in a non overland zone
	-- we assume there are two jumps for those ports, one to the overland, then into the actual zone/subzone
	-- the second one happens inside the loadingscreen where we can't catch the EVENT_PREPARE_FOR_JUMP to get the correct instance INSTANCE_DISPLAY_TYPE
	-- as the first one is always for overland (except when porting to the same instance and zone) it's set as INSTANCE_DISPLAY_TYPE_NONE
	-- we can port to players in (Public) Dungeons, (Group) Delves, Trials and Houses
	-- INSTANCE_DISPLAY_TYPE_NONE is also set when we entere a PvP Campaign
	if (newInstanceDisplayType == INSTANCE_DISPLAY_TYPE_NONE) then
		local mapContentType = GetMapContentType()
		-- we speculate justic is only enabled in PvE Overland as MAP_CONTENT_NONE is sometimes also used in Delves
		if (not (evt.IsJusticeEnabled() or evt.IsInPvP()) or mapContentType == MAP_CONTENT_DUNGEON) then
			--d("player port detected")
			if(evt.IsInHouse()) then newInstanceDisplayType = INSTANCE_DISPLAY_TYPE_HOUSING
			else newInstanceDisplayType = GetInstanceDisplayTypeFromNearestPOI() end
			--d("newInst " .. tostring(newInstanceDisplayType))
		end
	
	-- validate InstanceDisplayType: we might got ported out of our previous map/zone during logout so the saved zoneType has changed
	-- we could be ported out from PvP, Dungeons, Trials and Houses we don't own and into overland
	elseif (	(newInstanceDisplayType == INSTANCE_DISPLAY_TYPE_BATTLEGROUND and not IsActiveWorldBattleground())
			or 	(newInstanceDisplayType == INSTANCE_DISPLAY_TYPE_DUNGEON and not GetMapContentType() == MAP_CONTENT_DUNGEON)
			or 	(newInstanceDisplayType == INSTANCE_DISPLAY_TYPE_RAID and not GetMapContentType() == MAP_CONTENT_DUNGEON)
			or 	(newInstanceDisplayType == INSTANCE_DISPLAY_TYPE_HOUSING and not evt.IsInHouse())
			-- we also could have entered a PvP campaign which seems to not use EVENT_PREPARE_FOR_JUMP from a non-overland region
			) then
		--d("logoff port detected")
		newInstanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE -- we view NONE as "Overland"
	end
	RbI.character.lastInstanceDisplayType = newInstanceDisplayType
	instanceDisplayType = newInstanceDisplayType
	newInstanceDisplayType = nil
end

-- set newInstanceDisplayType on EVENT_PREPARE_FOR_JUMP
local function OnPrepareForJump(eventCode, zoneName, zoneDescription, loadingTexture, instanceDisplayType)
	--d("OnPrepareForJump " .. tostring(instanceDisplayType))
	newInstanceDisplayType = instanceDisplayType
	--newInstanceDisplayType = 0 d("pretend player port") -- pretend port to player situation
end

-- set newInstanceDisplayType when entering PvP on EVENT_CAMPAIGN_STATE_INITIALIZED
-- EVENT_PREPARE_FOR_JUMP doesn't fire for it, would normally be overland when initial port
local function OnCampaignStateInitialized(eventCode, campaignId)
	--d("OnCampaignStateInitialized " .. tostring(campaignId))
	newInstanceDisplayType = INSTANCE_DISPLAY_TYPE_NONE
end

-- set instanceDisplayType and zoneType only after jump finished
-- if jump failed we don't need to do anything as we stayed in the same zone, newInstanceDisplayType will be discarded next port
local function OnPlayerActivated(eventCode, initial)	
	setInstanceDisplayType()
	setZoneTypes()
	--d("###ZoneTypes###", RulebasedInventory.executionEnv.ctx.zoneTypes, "###############")
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Events --------------------------------------------------------------------
------------------------------------------------------------------------------

function evt.AutoOpenEventUnRegister()
	if(RbI.account.settings.autoOpenBank ~= "Never" or RbI.account.settings.autoOpenShop ~= "Never" or RbI.account.settings.autoOpenAssistants) then
		EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CHATTER_BEGIN, OnChatterBegin)
	else
		EVENT_MANAGER:UnregisterForEvent(RbI.name, EVENT_CHATTER_BEGIN)
	end
end

function RbI.RegisterForEvents()
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
	-- Filter Events
	EVENT_MANAGER:AddFilterForEvent(RbI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	EVENT_MANAGER:AddFilterForEvent(RbI.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_OPEN_BANK, OnBankOpen)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CLOSE_BANK, OnBankClose)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_OPEN_STORE, OnStoreOpen)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_OPEN_FENCE, OnFenceOpen)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CLOSE_STORE, OnStoreClose)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CRAFTING_STATION_INTERACT, OnCraftingStationOpen)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_END_CRAFTING_STATION_INTERACT, OnCraftingStationClose)
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_PREPARE_FOR_JUMP, OnPrepareForJump) -- for handling instanceDisplayType
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated) -- for handling instanceDisplayType
	EVENT_MANAGER:RegisterForEvent(RbI.name, EVENT_CAMPAIGN_STATE_INITIALIZED, OnCampaignStateInitialized) -- for handling instanceDisplayType

	evt.AutoOpenEventUnRegister()

	-- put all items in the item queue, needs to be registered to enable menu switches without reloadUI
	EVENT_MANAGER:RegisterForEvent(RbI.name .. "startupitemcheck", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent(RbI.name .. "startupitemcheck", EVENT_PLAYER_ACTIVATED)
		if (RbI.account.settings.startupitemcheck) then RbI.ConsistencyCheck() end
	end)

	ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", function(...)
		if(not IsLooting()) then return end
		local name, targetType, actionName, isOwned = GetLootTargetInfo()
		-- d("name: ", name, targetType, actionName, isOwned)
		-- INTERACT_TARGET_TYPE_OBJECT corpses only appear, when eso auto-looting is off
		-- d("LootDump: "..tostring(IsLooting()).." ", getLootDump())
		if (targetType == INTERACT_TARGET_TYPE_ITEM and RbI.isLooting()) then
			local lootResult, lootError = safeLoot()
			if(lootResult ~= '') then
				RbI.loot = {
					content= lootResult,
					error= lootError
				}
			end
			return true
		end
	end)

	if(FCOIS) then
		local markItemOrig = FCOIS.MarkItem
		-- bag, slot, iconId, showIcon, updateInventories
		FCOIS.MarkItem = function(...)
			local args = {...}
			local bag = args[1]
			local slot = args[2]
			OnFCOISMark(bag, slot)
			return markItemOrig(...)
		end
	end

end

-- sceneName=interact all npcs/assistants. Stations have other sceneNames: "smithing", "enchanting", "alchemy", "provisioner"
-- IsInteracting() is generally true for all npc interaction and stations
-- so isScene(..) is a bit more specific
-- Including scene checks. Perhaps the onClose-event is late. So this check is more accurate.
function evt.IsBankOpen() -- true also for homebanks
	return IsBankOpen() -- RbI.allowAction['BagToBank'] and isScene("interact", "bank")
end
function evt.IsGuildBankOpen()
	return IsGuildBankOpen() -- RbI.allowAction['BagToBank'] and isScene("interact")
end
function evt.IsStoreOpen()
	return RbI.allowAction['Sell'] and ZO_Store_IsShopping() -- and isScene("interact" => "store")
end
function evt.IsStoreVending()
	return RbI.allowAction['Buy'] and ZO_Store_IsShopping() -- and isScene("interact" => "store")
end
function evt.IsFenceOpen()
	return RbI.allowAction['Fence'] and ZO_Store_IsShopping() -- and isScene("interact" => "fence_keyboard")
end
function evt.IsCraftingOpen() -- for station and deconstruction assistant
	return GetInteractionType()==INTERACTION_CRAFT
end
function evt.CanDeconstruct()
	return RbI.allowAction['Deconstruct'] and evt.IsCraftingOpen()
end
function evt.CanRefine()
	return RbI.allowAction['Refine'] and evt.IsCraftingOpen()
end
function evt.CanExtract()
	return RbI.allowAction['Extract'] and evt.IsCraftingOpen()
end
function evt.CanSendDeconstruct()
	return evt.IsCraftingOpen() and (RbI.allowAction['Deconstruct'] or RbI.allowAction['Refine'] or RbI.allowAction['Extract'])
end
function evt.IsInteractingWithAssistant()
	local _, name = GetGameCameraInteractableActionInfo()
	if (name == nil or name == "") then return false end
	name = name:lower()
	-- speed up at own assistant and in houses where the name matches
	if (IsInteractingWithMyAssistant() or RbI.dataType["assistantName"][name] ~= nil) then return true end
	-- name is only partially taken for world instances of collections
	for assistantName in pairs(RbI.dataType["assistantName"]) do
		--d(name, assistantName)
		if (utils.startsWith(assistantName, name)) then return true end
	end
	return false
end

-- returns if autoOpen should be executed in regards to user settings and current interface
function evt.CanAutoOpen(chatOptionCount, chatterOptionBank, chatterOptionShop, chatterOptionCraft, chatterOptionQuest)
	if(preventAutoOpen(RbI.account.settings.autoOpenPreventionKey)) then return false end

	local autoOpenSetting = "Never"
	if (chatterOptionBank) then
		autoOpenSetting = RbI.account.settings.autoOpenBank
	elseif (chatterOptionShop) then 
		autoOpenSetting = RbI.account.settings.autoOpenShop
	end
	
	-- skip dialog at assistant
	if (RbI.account.settings.autoOpenAssistants and evt.IsInteractingWithAssistant()) then return true end
	-- don't skip dialog if unwanted
	if (autoOpenSetting == "Never") then return false end
	-- always skip dialog 
	if (autoOpenSetting == "Always") then return true end
	-- OnActions is only available for Bank, skip when items will be processed 
	if (autoOpenSetting == "OnActions" and tasks.NeedToRun('BankToBag', 'BagToBank')) then return true end
	-- NoDialog is only available for Shop, skip when shop is the only dialog option
	if (autoOpenSetting == "NoDialog" and chatOptionCount == 1) then return true end
	-- fallback no skip 
	return false
end

-- returns if autoClose should be executed in regards to user settings and current interface
function evt.CanAutoClose(taskName1)
	if(preventAutoClose(RbI.account.settings.autoClosePreventionKey)) then return false end

	local autoCloseSetting = "Never"
	if(evt.IsBankOpen()) then
		autoCloseSetting = RbI.account.settings.autoCloseBank
	elseif(evt.IsStoreOpen()) then 
		autoCloseSetting = RbI.account.settings.autoCloseShop
	elseif(evt.IsFenceOpen()) then 
		autoCloseSetting = RbI.account.settings.autoCloseFence
	elseif(evt.IsCraftingOpen()) then 
		-- we skipped autocrafter auto-close so we have to do it here and only if we're at crafting
		if(AutoCrafter.wantExitWhenDone() and AutoCrafter.isWritComplete() and AutoCrafter.craftCount > 0) then return true end
		-- we can't autoclose if not all tasks start running immediately otherwise when would we, when all had run?
		if(RbI.account.settings.immediateExecutionAtCraftStation or evt.IsInteractingWithAssistant()) then
			autoCloseSetting = RbI.account.settings.autoCloseCraft
		end
	end
	
	-- don't close if unwanted or prevented
	if (autoCloseSetting == "Never") then return false end
	-- always close
	if (autoCloseSetting == "Always") then return true end
	-- close if at an assistant
	if ((autoCloseSetting == "AtAssistant" or autoCloseSetting == "AtAssistantOrOnActions") and evt.IsInteractingWithAssistant()) then return true end
	-- OnActions only closes when item have been processed, will be checked externally when determening immediate or finishcallback closing of UI
	if ((autoCloseSetting == "OnActions" or autoCloseSetting == "AtAssistantOrOnActions") and RbI.ActionQueue.IsRunning(taskName1)) then return true end
	return false
end

if(false) then -- for testing purposes
	local function dumpSceneName() -- GetNameOfGameCameraQuestToolTarget()
		local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
		d("SceneName: ", zo_strformat(SI_GAME_CAMERA_TARGET, action))
		zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action)
		zo_callLater(dumpSceneName, 10000)
	end -- Lagerkasette, beschlagen
	zo_callLater(dumpSceneName, 10000)
end

local allowMap = {
	BagToBank = evt.IsBankOpen,
	BankToBag = evt.IsBankOpen,
	Deconstruct = evt.CanDeconstruct,
	Refine = evt.CanRefine,
	Extract = evt.CanExtract,
	Sell = evt.IsStoreOpen,
	Buy = evt.IsStoreVending,
	Fence = evt.IsFenceOpen,
	Launder = evt.IsFenceOpen,
}
evt.isAllowed = function(name)
	return allowMap[name]()
end
local function functionTrue() return true end
setmetatable(allowMap, {__index = function()
	return functionTrue
end})