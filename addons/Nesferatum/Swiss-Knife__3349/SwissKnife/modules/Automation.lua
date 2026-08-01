local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKC = SK.Collectables
local SKDC = SK.Data.common
local SKB = SK.Bindings
local EM, STM, SM, WM = EVENT_MANAGER, STABLE_MANAGER, SCENE_MANAGER, WINDOW_MANAGER

local TRAIN_MAXIMIZE = SK.STABLE_AFTER_THRESHOLD_TRAIN_RULES.MAXIMIZE
local TRAIN_IN_ROTATION = SK.STABLE_AFTER_THRESHOLD_TRAIN_RULES.IN_ROTATION

local TrainNames = {
	[RIDING_TRAIN_SPEED] = GetString(SI_SK_RIDING_TRAIN_SPEED),
	[RIDING_TRAIN_STAMINA] = GetString(SI_SK_RIDING_TRAIN_STAMINA),
	[RIDING_TRAIN_CARRYING_CAPACITY] = GetString(SI_SK_RIDING_TRAIN_CAPACITY)
}

local AfterThresholdTrainRule = {
	[TRAIN_MAXIMIZE] = GetString(SI_SK_RIDING_TRAIN_ORDER_MAXIMIZE),
	[TRAIN_IN_ROTATION] = GetString(SI_SK_RIDING_TRAIN_ORDER_IN_ROTATION)
}

local CompanionUnsafeEntryModes = {
	[SK.COMPANION_PREVENT_MODE.NOTHING] = GetString(SI_SK_SKW_MODE_NOTHING),
	[SK.COMPANION_PREVENT_MODE.WARNING] = GetString(SI_SK_SKW_MODE_WARNING),
	[SK.COMPANION_PREVENT_MODE.DISMISS] = GetString(SI_SK_SKW_MODE_DISMISS)
}

local function selectActiveGuild(guildId)
	for i = 1, 5 do
		local button = SK.GuildSelectDialogue:GetNamedChild("ListGuild"..i)
		if button.guildId  ~= nil then
			local name = button.label_text
			if button.guildId == guildId or (guildId == nil and i == 1 ) then
				name = SK.COLOR.LIGHT_YELLOW:Colorize(button.label_text)
			end
			button:GetLabelControl():SetText(name)
		end
	end
	ZO_GUILD_SELECTOR_MANAGER:SetSelectedGuildBankId(guildId)
end

local function initGuildSelect()
	if SK.GuildSelectDialogue == nil then
		SK.GuildSelectDialogue = WM:CreateControlFromVirtual("$(parent)GuildSelectDialogue",
			ZO_KeybindStripControlCenterParent, "SK_Guild_Select")
		local title = SK.GuildSelectDialogue:GetNamedChild("HeaderName")
		title:SetText(SK.COLORED_PREFIXES.SK..GetString(SI_PROMPT_TITLE_SELECT_GUILD_BANK))
	end
	local guildsCount = GetNumGuilds()
	local guildsList = SKH.getGuilds()
	local guilds = {}
	for i, name in ipairs(guildsList.Choices) do guilds[i] = name end
	for i = 1, 5 do
		local button = SK.GuildSelectDialogue:GetNamedChild("ListGuild"..i)
		if i <= guildsCount then
			local name = guilds[i]
			local guildId = guildsList.Maps[name]
			button.label_text = name
			button.guildId = guildId
			button:SetHandler("OnMouseUp", function()
				selectActiveGuild(guildId)
			end)
			button:SetHidden(false)
		else
			button:SetHidden(true)
		end
	end
	SK.GuildSelectDialogue:SetDimensions(280, guildsCount * 32 + 40)
	selectActiveGuild(PLAYER_INVENTORY.lastSuccessfulGuildBankId)
end

local function setDefaultGuildBank()
	if GetNumGuilds() == 0 then return end
	local guildId
	if SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "BankId"}) then
		guildId = SK.savedVars.defaultGuildData[SK.AccName].BankId
	end
	if guildId == nil then guildId = ZO_GUILD_SELECTOR_MANAGER:GetSelectedGuildStoreId() end
	ZO_GUILD_SELECTOR_MANAGER:SetSelectedGuildBankId(guildId)
	PLAYER_INVENTORY.lastSuccessfulGuildBankId = guildId
end

local function HandleGuildBankOpen()
	if GetNumGuilds() == 0 then return end
	setDefaultGuildBank()
	SKB.onGuildBankOpenKeybindStrip()
	if SK.savedVars.showGuildBankChooser then
		initGuildSelect()
		SK.GuildSelectDialogue:SetHidden(false)
	end
	SKBT.isGuildBankOpened = true
end

local function HandleGuildBankClose()
	if GetNumGuilds() == 0 then return end
	if SK.savedVars.showGuildBankChooser then SK.GuildSelectDialogue:SetHidden(true) end
	SKB.onGuildBankCloseKeybindStrip()
	if SKBT.isGuildBankOpened then
		SKBT.isGuildBankOpened = false
		SKBT:Close()
	end
end

local function HandleGuildShopOpen()
	if GetNumTradingHouseGuilds() == 0 then return end
	local guildId = SK.GUILD_TRADINGHOUSE
	local currentGuildID = GetSelectedTradingHouseGuildId()
	if guildId == nil and SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "ShopId"}) then
		guildId = SK.savedVars.defaultGuildData[SK.AccName].ShopId
	end
	if guildId ~= nil and currentGuildID ~= guildId then
		SelectTradingHouseGuildId(guildId)
	end
end

local function GetSkillToTrain()
	local speedBonus, maxSpeedBonus, staminaBonus, maxStaminaBonus, inventoryBonus, maxInventoryBonus = STM:GetStats()
	local trainData =
	{
		[RIDING_TRAIN_SPEED] = {speedBonus, maxSpeedBonus},
		[RIDING_TRAIN_STAMINA] = {staminaBonus, maxStaminaBonus},
		[RIDING_TRAIN_CARRYING_CAPACITY] = {inventoryBonus, maxInventoryBonus},
	}
	local stableTrainOrder, stableTrainThreshold = SK.savedVars.stableTrainOrder, SK.savedVars.stableTrainThreshold
	for _, skillToTrain in ipairs(stableTrainOrder) do
		if trainData[skillToTrain][1] < stableTrainThreshold[skillToTrain] then
			return skillToTrain
		end
	end
	local stableAfterThresholdTrainRule = SK.savedVars.stableAfterThresholdTrainRule
	if stableAfterThresholdTrainRule == TRAIN_MAXIMIZE then
		for _, skillToTrain in ipairs(stableTrainOrder) do
			if trainData[skillToTrain][1] < trainData[skillToTrain][2] then
				return skillToTrain
			end
		end
	elseif stableAfterThresholdTrainRule == TRAIN_IN_ROTATION then
		local skillToTrain, prevMaxBonus = nil, nil
		for _, currentSkillToTrain in ipairs(stableTrainOrder) do
			if prevMaxBonus == nil then
				skillToTrain = currentSkillToTrain
				prevMaxBonus = trainData[currentSkillToTrain][1]
			elseif prevMaxBonus > trainData[currentSkillToTrain][1] then
				skillToTrain = currentSkillToTrain
				break
			end
		end
		if trainData[skillToTrain][1] < trainData[skillToTrain][2] then
			return skillToTrain
		end
	end
	return nil
end

local function DoStableTrain()
	local skillToTrain = GetSkillToTrain()
	if skillToTrain == nil then return end
	TrainRiding(skillToTrain)
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKA,
		SI_SK_RIDING_TRAIN_MESSAGE,
		SK.COLOR.WHITE:Colorize(TrainNames[skillToTrain])
	)
	return
end

local function CheckTrainConditions()
    local currentSkinId = GetMountSkinId()
    local hadSkin = currentSkinId and currentSkinId > 0
	local isRidingSkillMaxedOut, canAffordTraining = STM:IsRidingSkillMaxedOut(),  STM:CanAffordTraining()
    local timeUntilCanBeTrained, trainingCost = GetTimeUntilCanBeTrained(), GetTrainingCost()
	local hours, minutes, seconds = SKH.convertTSToHMS(timeUntilCanBeTrained)
	if hadSkin then
		if isRidingSkillMaxedOut then
			local text = GetString(SI_SK_RIDING_MAXED_OUT_MESSAGE)
			SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, text)
			SKH.showAnimateText(text)
		else
			if canAffordTraining then
				if timeUntilCanBeTrained > 0 then
					local text = table.concat({
						SKH.getFormattedText(
							SK.COLOR.WHITE:Colorize(GetString(SI_SK_RIDING_TRAIN_TIMEOUT_MESSAGE)),
							SK.COLOR.ORANGE:Colorize(hours),
							SK.COLOR.ORANGE:Colorize(minutes),
							SK.COLOR.ORANGE:Colorize(seconds)
						)
					})
					SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, text)
					SKH.showAnimateText(text)
				else
					return true
				end
			else
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKA,
					SI_SK_RIDING_CANT_AFFORD_TRAINING_MESSAGE,
					SKH.getFormattedCurrency(trainingCost)
				)
			end
		end
		SM:ShowBaseScene()
	else
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, SI_SK_RIDING_DO_NOT_HAVE_MOUNT_MESSAGE)
	end
	return false
end

local function ChatterOpenStable(eventCode, optionCount)
	if SK.savedVars.stableTrainEnabled then
		for i = 1, optionCount do
			local _, optionType = GetChatterOption(i)
			if optionType == SK.CHATTER_OPTION_TYPES.VIEW_STABLE then
				SelectChatterOption(i)
			end
		end
	end
end

local function ChatterOpenGuildShop(eventCode, optionCount)
	if SK.savedVars.openGuildShopEnabled then
		local openGuildShopIndex, openGuildShopBetIndex
		for i = 1, optionCount do
			local _, optionType = GetChatterOption(i)
			if optionType == SK.CHATTER_OPTION_TYPES.OPEN_GUILD_SHOP then
				openGuildShopIndex = i
			elseif optionType == SK.CHATTER_OPTION_TYPES.OPEN_GUILD_SHOP_BET then
				openGuildShopBetIndex = i
			end
		end
		if openGuildShopBetIndex ~= nil and openGuildShopIndex ~= nil then SelectChatterOption(openGuildShopIndex) end
	end
end

local function ChatterOpenCompanionMenu(eventCode, optionCount)
	if SK.savedVars.companionApparelShowQuality then
		for i = 1, optionCount do
			local _, optionType = GetChatterOption(i)
			if optionType == SK.CHATTER_OPTION_TYPES.OPEN_COMPANION_MENU then
				SKAC:UpdateAllSlots()
				if FCOIS and FCOIS.countAndUpdateEquippedArmorTypes then
					FCOIS.countAndUpdateEquippedArmorTypes(false, false, nil, true)
				end
			end
		end
	end
end

local function unregisterDailyQuestEvents()
	EM:UnregisterForEvent("SK_Chatter_Automation", EVENT_CONVERSATION_UPDATED)
	EM:UnregisterForEvent("SK_Chatter_Automation", EVENT_QUEST_OFFERED)
	EM:UnregisterForEvent("SK_Chatter_Automation", EVENT_QUEST_ADDED)
	EM:UnregisterForEvent("SK_Chatter_Automation", EVENT_QUEST_COMPLETE_DIALOG)
end

local function acceptDailyQuest(stage)
	if stage == QDS_START then
	    EM:RegisterForEvent("SK_Chatter_Automation", EVENT_CONVERSATION_UPDATED, function(_, _, opt)
		    if SK.savedVars.debugMode then d('EVENT_CONVERSATION_UPDATED') d(opt) end
		    local _, _, _, _, chosenBefore = GetChatterOption(1)
		    if opt == 0 or chosenBefore then acceptDailyQuest(QDS_CLOSE) else acceptDailyQuest(QDS_NEXT) end
	    end)
	    EM:RegisterForEvent("SK_Chatter_Automation", EVENT_QUEST_OFFERED, function()
		    if SK.savedVars.debugMode then d('EVENT_QUEST_OFFERED') end
		    AcceptOfferedQuest()
		    acceptDailyQuest(QDS_NEXT)
	    end)
	    EM:RegisterForEvent("SK_Chatter_Automation", EVENT_QUEST_ADDED, function()
		    if SK.savedVars.debugMode then d('EVENT_QUEST_ADDED') end
		    acceptDailyQuest(QDS_CLOSE)
	    end)
	    EM:RegisterForEvent("SK_Chatter_Automation", EVENT_QUEST_COMPLETE_DIALOG, function()
		    if SK.savedVars.debugMode then d('EVENT_QUEST_COMPLETE_DIALOG') end
		    CompleteQuest()
		    acceptDailyQuest(QDS_CLOSE)
	    end)
	    acceptDailyQuest(QDS_NEXT)
	elseif stage == QDS_NEXT then
		if SK.savedVars.debugMode then d('QDS_NEXT') end
		SelectChatterOption(1)
	elseif stage == QDS_CLOSE then
		if SK.savedVars.debugMode then d('QDS_CLOSE') end
		unregisterDailyQuestEvents()
		SM:ShowBaseScene()
	end
end

local function isAutoDailyNPC()
	if ZO_InteractWindowTargetAreaTitle then
		local npcName = string.sub(ZO_InteractWindowTargetAreaTitle:GetText(), 2, -2)
		SK.LastChatterName = npcName
		local opt = SK.savedVars.dailyQuestAcceptOptions
		if (opt.mage and SKH.isValueInList(SKDC.DAILY_QUEST_NPC.MAGE, npcName)) or
			(opt.fighters and SKH.isValueInList(SKDC.DAILY_QUEST_NPC.FIGHTERS, npcName)) or
			(opt.undaunted and SKH.isValueInList(SKDC.DAILY_QUEST_NPC.UNDAUNTED, npcName)) or
			(SK.savedVars.enableDailyQuestHelper and SK.savedVars.dailyQuestData[npcName] ~= nil and
			SK.savedVars.dailyQuestData[npcName].auto)
		then
			return true
		end
	end
end

local function ChatterDailyQuest(eventCode, optionCount)
	if isAutoDailyNPC() then
		if optionCount == 0 then SM:ShowBaseScene() end
		if optionCount ~= 1 then return end
		if GetNumJournalQuests() == MAX_JOURNAL_QUESTS then
			local text = GetString(SI_ERROR_QUEST_LOG_FULL)
			SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, text)
			SKH.showAnimateText(text)
		else
			acceptDailyQuest(QDS_START)
		end
	end
end

local function HandleChatterBegin(eventCode, optionCount)
	ChatterOpenStable(eventCode, optionCount)
	ChatterOpenGuildShop(eventCode, optionCount)
	ChatterOpenCompanionMenu(eventCode, optionCount)
	ChatterDailyQuest(eventCode, optionCount)
end

local function tryAppendQuestData(questIndex, questName)
	if SKH.isValueInList(SKDC.AUTOMATED_QUEST_REPEAT_TYPES, GetJournalQuestRepeatType(questIndex)) and
		not SKH.isValueInList(SKDC.NOT_AUTOMATED_QUEST_TYPES, GetJournalQuestType(questIndex)) and SK.LastChatterName
	then
		local npcName = SK.LastChatterName
		if SK.dailyQuestDataCache[questName] == nil then
			if SK.savedVars.dailyQuestData[npcName] == nil then
				SK.savedVars.dailyQuestData[npcName] = {
					questName = questName,
					auto = false
				}
				SK.dailyQuestDataCache[questName] = npcName
			else
				if questName ~= SK.savedVars.dailyQuestData[npcName].questName then
					if SK.savedVars.dailyQuestData[npcName].anotherQuestsNames == nil then
						SK.savedVars.dailyQuestData[npcName].anotherQuestsNames = {}
					end
					if not SKH.isValueInList(SK.savedVars.dailyQuestData[npcName].anotherQuestsNames, questName) then
						table.insert(SK.savedVars.dailyQuestData[npcName].anotherQuestsNames, questName)
						SK.dailyQuestDataCache[questName] = npcName
					end
				end
			end
		elseif SK.dailyQuestDataCache[questName] ~= npcName then
			local oldNPC = SK.dailyQuestDataCache[questName]
			SK.savedVars.dailyQuestData[npcName] = {
				questName = questName,
				auto = SK.savedVars.dailyQuestData[oldNPC].auto
			}
			SK.savedVars.dailyQuestData[oldNPC] = nil
			SK.dailyQuestDataCache[questName] = npcName
		end
		SK.LastChatterName = nil
	end
end

local function HandleQuestAdded(eventId, questIndex, questName)
	if SK.savedVars.enableDailyQuestHelper then tryAppendQuestData(questIndex, questName) end
end

local function HandleQuestCompleteDialog(questIndex)
	if not SK.savedVars.enableDailyQuestHelper then return end
	local questName = GetJournalQuestName(questIndex)
	if SK.dailyQuestDataCache[questName] == nil then tryAppendQuestData(questIndex, questName) end
end

local function initCheckbox(checked, callback)
	if ZO_QuestJournalQuestsPanelQuestInfoContainerScrollChildStepText == nil then return end
	local checkBoxControl = SK_AutoAcceptTurnQuests
	if checkBoxControl == nil then
		checkBoxControl = WM:CreateControlFromVirtual("SK_AutoAcceptTurnQuests",
				ZO_QuestJournalQuestsPanelQuestInfoContainerScrollChildStepText, "SK_Checkbox")
		local r, g, b = SK.COLOR.ORANGE:UnpackRGB()
		checkBoxControl:GetNamedChild("Label"):SetText(GetString(SI_SK_MISC_DAILY_QUEST_HELPER_FLAG))
		checkBoxControl:GetNamedChild("Label"):SetColor(r, g, b, 0.9)
	end
	local checkBox = checkBoxControl:GetNamedChild("CheckBox")
    checkBoxControl:SetAnchor(TOPLEFT, ZO_QuestJournalQuestsPanelQuestInfoContainerScrollChildStepText,
			BOTTOMLEFT, -8, 27)
	checkBoxControl:SetHidden(false)
    if checked then ZO_CheckButton_SetChecked(checkBox) else ZO_CheckButton_SetUnchecked(checkBox) end
    ZO_CheckButton_SetToggleFunction(checkBox, function()
        callback(ZO_CheckButton_IsChecked(checkBox))
    end)
end

local function HandleQuestJournalRefreshDetails(self)
	if self == nil or not SK.savedVars.enableDailyQuestHelper then return end
	local questIndex = self:GetSelectedQuestIndex()
	local questName = GetJournalQuestName(questIndex)
	local npcName = SK.dailyQuestDataCache[questName]
	if npcName ~= nil and SK.savedVars.dailyQuestData[npcName] ~= nil then
		initCheckbox(SK.savedVars.dailyQuestData[npcName].auto, function(isChecked)
			SK.savedVars.dailyQuestData[npcName].auto = isChecked
		end)
	elseif SK_AutoAcceptTurnQuests ~= nil then
		SK_AutoAcceptTurnQuests:SetHidden(true)
	end
end

local function HandleStableOpen()
	if SK.savedVars.stableTrainEnabled and CheckTrainConditions() then
		DoStableTrain()
		SM:ShowBaseScene()
		return
	end
end

local function bindCollectablesItems(itemLink, slotIndex)
	if not SK.savedVars.bindUnknownCollectablesSetItems then return end
	local itemId = GetItemLinkItemId(itemLink)
	if SKH.isKeyInTable(SK.globalSV.notBindItems, itemId) then
		SKH.sendMessageToChat(
			SK.COLORED_PREFIXES.SKA,
			SI_SK_AUT_NOT_BIND_ITEM_MESSAGE,
			itemLink:gsub("%|H0", "|H1")
		)
		return
	end
	local isCollectables, setId, itemSlot = SKH.isItemLinkCollectables(itemLink)
	if isCollectables then
		local isCollectionsFull, _, _ = SKH.isItemSetCollectionsFull(setId)
		if not isCollectionsFull and not IsItemSetCollectionSlotUnlocked(setId, itemSlot) then
			BindItem(BAG_BACKPACK, slotIndex)
			if SK.savedVars.trackAccountsCollectionsItems then
				zo_callLater(function() SKC.validateCollectablesData(setId) end, 50)
			end
		end
	end
end

local function filterBackpackUnwantedItems(itemLink, slotIndex, isNewItem)
	if SKH.filterSingleSlotBackpackPermanentUnwantedItem(SK.globalSV.permanentUnwantedItemIds, slotIndex, isNewItem) and
        SK.savedVars.enableDestroyedNotification
	then
		SKH.sendMessageToChat(
			SK.COLORED_PREFIXES.SKA,
			SI_SK_AUT_LOOT_UNWANTED_DESTROY_MESSAGE,
			itemLink:gsub("%|H0", "|H1")
		)
	elseif SKH.filterSingleSlotBackpackJunkSetsPart(SK.globalSV.permanentUnwantedSetIds, slotIndex, SK.savedVars.junkDeconstructedToo) then
	elseif SKH.filterSingleSlotBackpackJunk(slotIndex) then end
end

local function trackSetsPartsItems(itemLink, bagId, slotIndex, stackCountChange)
	if stackCountChange == nil then return end
	if not SK.savedVars.trackSetsItems or not SK.isTrackedSetsItemsDataLoad then return end
	local ownerName = SK.PlayerName
	if not SKH.isValueInList(SKDC.BAG_CHARACTERS, bagId) then
		if bagId == BAG_COMPANION_WORN then
			ownerName = SKH.getCurrentCompanionOwnerName()
		else
			ownerName = SK.storageName
		end
	end
	if ownerName == nil then return end
	if stackCountChange < 0 then
		local setId = SKH.deleteOneTrackedSetsItem(bagId, slotIndex, ownerName)
		if setId ~= nil then
			SKH.compressEmptyChild(setId)
			SKH.conditionalRefreshSetsItemsList()
		end
	elseif stackCountChange >= 0 then
		--if bagId == BAG_BACKPACK and IsItemJunk(bagId, slotIndex) then d('ignore') return end
		local isTracked, setId = SKH.isTrackedSetPartsItem(itemLink, bagId, slotIndex)
		if isTracked then
			SKH.addOneTrackedSetsItem(setId, ownerName, bagId, slotIndex, itemLink)
			SKH.compressEmptyChild(setId)
			SKH.conditionalRefreshSetsItemsList()
		end
	end
end

local function HandleOnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if SKH.isValueInList(SKDC.IGNORED_INVENTORY_UPDATE_REASONS, inventoryUpdateReason) then return end
	if Roomba and Roomba.WorkInProgress and Roomba.WorkInProgress() then return end
	local itemLink = GetItemLink(bagId, slotIndex)
	-- further filtering only if the loot is added to the inventory
	if bagId == BAG_BACKPACK and stackCountChange > 0 then
		bindCollectablesItems(itemLink, slotIndex)
		local isStolenFiltered = false
		if SK.savedVars.isPickyThiefEnabled then
			isStolenFiltered = SKH.filterSingleSlotBackpackStolen(slotIndex)
		end
		if not isStolenFiltered then
			if not SKH.filterSingleSlotBackpackIntricateAndGlyphs(slotIndex) then
				filterBackpackUnwantedItems(itemLink, slotIndex, isNewItem)
			end
		end
	end
	-- unconditional filtration regardless of bag or quantity
	trackSetsPartsItems(itemLink, bagId, slotIndex, stackCountChange)
end

local function addItemToSimpleList(listTable, itemId, itemLink, control, mode, successText, errorText, action)
	if not SKH.isKeyInTable(listTable, itemId) then
		local localItemLink = SKH.getNonStolenItemLink(itemLink)
		local compressedItemLink = SKH.compressItemLink(localItemLink)
		listTable[itemId] = {itemLink = compressedItemLink}
		if action then listTable[itemId].action = action end
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, successText, itemLink:gsub("%|H0", "|H1"))
		control:Refresh()
		ZO_MenuBar_SelectDescriptor(SKMD.modeBar, mode)
	else
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, errorText, itemLink:gsub("%|H0", "|H1"))
	end
end

local function removeItemFromSimpleList(listTable, itemId, itemLink, control, mode, successText, errorText)
	if SKH.isKeyInTable(listTable, itemId) then
		listTable[itemId] = nil
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, successText, itemLink:gsub("%|H0", "|H1"))
		control:Refresh()
		ZO_MenuBar_SelectDescriptor(SKMD.modeBar, mode)
	else
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, errorText, itemLink:gsub("%|H0", "|H1"))
	end
end

local function addItemToPermanentUnwanted(itemLink, action)
	local itemId = GetItemLinkItemId(itemLink)
	addItemToSimpleList(
		SK.globalSV.permanentUnwantedItemIds, itemId, itemLink, SKMD.itemsList, SKDC.MAIN_DIALOGUE_UNWANTED_ITEMS_MODE,
		SI_SK_AUT_LOOT_UNWANTED_ADD, SI_SK_AUT_LOOT_UNWANTED_ALREADY_EXISTS_MESSAGE, action
	)
end

local function removeItemFromPermanentUnwanted(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	removeItemFromSimpleList(
		SK.globalSV.permanentUnwantedItemIds, itemId, itemLink, SKMD.itemsList, SKDC.MAIN_DIALOGUE_UNWANTED_ITEMS_MODE,
		SI_SK_AUT_LOOT_UNWANTED_DEL, SI_SK_AUT_LOOT_UNWANTED_NOT_EXISTS_MESSAGE
	)
end

local function addItemToNotBind(itemLink, itemId)
	if not itemId then itemId = GetItemLinkItemId(itemLink) end
	addItemToSimpleList(
		SK.globalSV.notBindItems, itemId, itemLink, SKMD.notBindItemsList, SKDC.MAIN_DIALOGUE_NOT_BIND_ITEMS_MODE,
		SI_SK_AUT_NOT_BIND_ITEM_ADD, SI_SK_AUT_NOT_BIND_ITEM_ALREADY_EXISTS_MESSAGE
	)
end

local function removeItemFromNotBind(itemLink, itemId)
	if not itemId then itemId = GetItemLinkItemId(itemLink) end
	removeItemFromSimpleList(
		SK.globalSV.notBindItems, itemId, itemLink, SKMD.notBindItemsList, SKDC.MAIN_DIALOGUE_NOT_BIND_ITEMS_MODE,
		SI_SK_AUT_NOT_BIND_ITEM_DEL, SI_SK_AUT_NOT_BIND_ITEM_NOT_EXISTS_MESSAGE
	)
end

local function addSetToPermanentUnwanted(itemLink)
	local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	if hasSet then
		if not SKH.isKeyInTable(SK.globalSV.permanentUnwantedSetIds, setId) then
			SKEUS:Open(itemLink)
		else
			SKH.sendMessageToChat(
				SK.COLORED_PREFIXES.SKA,
				SI_SK_AUT_LOOT_UNWANTED_SETS_ALREADY_EXISTS_MESSAGE,
				setName
			)
		end
	end
end

local function removeSetFromPermanentUnwanted(itemLink)
	local _, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKA,
		SI_SK_AUT_LOOT_UNWANTED_SETS_DEL,
		setName
	)
	SK.globalSV.permanentUnwantedSetIds[setId] = nil
	SKMD.setsList:Refresh()
	ZO_MenuBar_SelectDescriptor(SKMD.modeBar, SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE)
end

local function filterAllBackpackItemsByRules(isDeconstructToo)
	SKH.filterAllBackpackPermanentUnwantedItems(SK.globalSV.permanentUnwantedItemIds)
	SKH.filterAllBackpackJunkSetsParts(SK.globalSV.permanentUnwantedSetIds, isDeconstructToo)
	SKH.filterAllBackpackJunk()
	SKH.filterAllBackpackIntricateAndGlyphs()
	SKH.filterAllBackpackStolenJunk()
	SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, SI_SK_AUT_ALL_BACKPACK_ITEMS_FILTERED)
end

local function sendMailAllFilteredItems()
	if not mailerSK then return end
	if SK.savedVars.sendMailToAnotherAccount and not SK.savedVars.isAutomaticModeSendMail then
		if not mailerSK.mailBoxOpen then
			RequestOpenMailbox()
			mailerSK.closeMailBoxAfterSend = true
		end
		mailerSK.isManualMode = true
	end
end

local function sellStolenItems(allowSell, allowLaunder)
	local bagId = BAG_BACKPACK
	if allowLaunder and SK.savedVars.isAutoLaunderEnabled then
		local numLaunders, numLaundered = GetFenceLaunderTransactionInfo()
		if numLaunders > numLaundered then
			local slotsCount = GetBagSize(bagId)
			for slotIndex = 0, slotsCount - 1 do
				if IsItemStolen(bagId, slotIndex) then
					local itemType = GetItemType(bagId, slotIndex)
				    local launderPrice = GetItemLaunderPrice(bagId, slotIndex)
					if itemType ~= ITEMTYPE_NONE and SKH.isItemForLaunder(bagId, slotIndex) and
						launderPrice and launderPrice > 0
					then
						local quantity = GetSlotStackSize(bagId, slotIndex)
						LaunderItem(bagId, slotIndex, quantity)
						if SK.savedVars.enableHasBeenLaunderNotification then
							local itemLink = GetItemLink(bagId, slotIndex)
							SKH.sendMessageToChat(
								SK.COLORED_PREFIXES.SKA,
								SI_SK_AUT_LAUNDER_ITEM_MESSAGE,
								itemLink:gsub("%|H0", "|H1")
							)
						end
						numLaundered = numLaundered + 1
						if numLaunders == numLaundered then break end
					end
				end
			end
		end
	end
	if allowSell and SK.savedVars.isSmartSaleEnabled then
		local numSales, numUsed = GetFenceSellTransactionInfo()
		if numSales > numUsed then
			local slotsCount = GetBagSize(bagId)
			for _, quality in ipairs({4, 3, 2}) do
				for slotIndex = 0, slotsCount - 1 do
					if IsItemStolen(bagId, slotIndex) and SKH.isStolenItemForSell(bagId, slotIndex) then
						local itemQuality = GetItemFunctionalQuality(bagId, slotIndex)
						if itemQuality == quality then
							local quantity = GetSlotStackSize(bagId, slotIndex)
							SellInventoryItem(bagId, slotIndex, quantity)
							if SK.savedVars.enableHasBeenSellNotification then
								local itemLink = GetItemLink(bagId, slotIndex)
								SKH.sendMessageToChat(
									SK.COLORED_PREFIXES.SKA,
									SI_SK_AUT_SELL_ITEM_MESSAGE,
									itemLink:gsub("%|H0", "|H1")
								)
							end
							numUsed = numUsed + 1
							if numSales == numUsed then break end
						end
					end
				end
			end
		end
	end
end

local function OnMailOpenMailBox()
	if not mailerSK then return end
	SKB.onMailboxOpenKeybindStrip()
	mailerSK.mailBoxOpen = true
	if SK.savedVars.sendMailToAnotherAccount then
		if SK.savedVars.isAutomaticModeSendMail then mailerSK.closeMailBoxAfterSend = false end
		if SK.savedVars.isAutomaticModeSendMail or mailerSK.isManualMode then
			mailerSK:PrepareAllMail()
			mailerSK:SendAllMail()
		end
	end
end

local function OnMailCloseMailBox()
	if not mailerSK then return end
	SKB.onMailboxCloseKeybindStrip()
	mailerSK.mailBoxOpen = false
	mailerSK.isManualMode = false
	mailerSK.isReceiptPending = false
	mailerSK.closeMailBoxAfterSend = false
end

local function OnMailInboxUpdate()
	if not mailerSK then return end
	if not mailerSK.isManualMode and not mailerSK.isReceiptPending and SK.savedVars.isAutomaticModeReceiptMail then
		mailerSK.closeMailBoxAfterSend = false
		local resourcesOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.RESOURCES]
		if resourcesOptions.isAutomaticReceiptEnabled or SK.savedVars.isAutomaticResourcesMailReceiptEnabled then
			mailerSK:ReceiptAllMails()
		end
	end
end

--local function OnMailNumUnreadChanged()
--	if not mailer then mailer = SK.Mailer:New() end
--	local resourcesOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.RESOURCES]
--	if resourcesOptions.isAutomaticReceiptEnabled or SK.savedVars.isAutomaticResourcesMailReceiptEnabled then
--		if SK.savedVars.useAutomaticReceiptWhenESOPlusOnly and not IsESOPlusSubscriber() then return end
--		if not mailer.isReceiptPending then
--			if not mailer.mailBoxOpen then
--				RequestOpenMailbox()
--				mailer.closeMailBoxAfterSend = true
--			end
--			mailer:ReceiptAllMails()
--		end
--	end
--end

local function HandlePrepareForJump(evt, zoneName, zoneDescription, loadingTexture, zoneDisplayType)
	SK.isWarningShowed = false
	-- todo: сделать тут интерактив с блокировкой спутников в нелюбимых зонах
	--d('--')
	--d(evt)
	--d(zoneName)
	--d(loadingTexture)
	--d(zoneDisplayType)
	--d('--')
	--if HasActiveCompanion() and
	--		SKH.getCurrentCompanionName() == SKH.getCompanionNameById(SK.COMPANIONS.MIRRI) then
	--	SKH.summonCompanion(SK.COMPANIONS.MIRRI)
	--end
	--d('--')
	zo_callLater(function()
        if SK.savedVars.trackSetsItems and IsOwnerOfCurrentHouse() and SK.isTrackedSetsItemsDataLoad and
            SKH.isHouseStoreAvailable()
        then
			for _, bagId in ipairs(SKDC.BAG_HOUSE_BANKS) do
				SKH.fillOneBagSetItems(bagId, SK.storageName)
			end
			SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKW, SI_SK_AUT_HOUSE_STORAGE_AVAILABLE, zoneName)
        end
		if SKH.isDarkBrotherhoodQuestZone() then
			if SK.savedVars.hideDangerInteraction then
				SK.savedVars.previousHideDangerInteraction = true
				SKH.toggleDangerInteraction()
			else
				SK.savedVars.previousHideDangerInteraction = false
			end
		elseif SK.savedVars.previousHideDangerInteraction ~= SK.savedVars.hideDangerInteraction then
			SKH.toggleDangerInteraction()
		end
    end)
end

local function houseBankOpen(eventCode, bagId, slot)
	if not SK.savedVars.trackSetsItems or not SK.isTrackedSetsItemsDataLoad then return end
	SKH.fillOneBagSetItems(bagId, SK.storageName)
end

local function HandleBankOpen(eventCode, bagId, slot)
	if SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId) then
		houseBankOpen(eventCode, bagId, slot)
	end
end

local function HandleFenceOpen(allowSell, allowLaunder)
	if allowSell or allowLaunder then sellStolenItems(allowSell, allowLaunder) end
end

--local function TooltipHook(tooltipControl, method)
--	local origMethod = tooltipControl[method]
--	d("ddd")
--	tooltipControl[method] = function(self, ...)
--		d("Hook fired!")
--		return origMethod(self, ...)
--	end
--end

local function InitAbilitiesAutomation()
	local function UseActionSlotsPreHook()
		-- hmm.. if this function return `false` its means you CAN use ability, otherwise you can`t use them. Strange.
		return not SKH.CanUseActionSlots()
	end
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", UseActionSlotsPreHook)
	--TooltipHook(AbilityTooltip, "SetAbilityId")
end

local function HandleCompanionActivated()
	SK.isWarningShowed = false
	if SK.savedVars.trackCompanionItems and SK.isTrackedSetsItemsDataLoad then
		SKH.fillOneBagSetItems(BAG_COMPANION_WORN, SKH.getCurrentCompanionOwnerName())
		SKH.conditionalRefreshSetsItemsList()
	end
end

local function HandlePlayerActivated()
	SK.isWarningShowed = false
end

local function HandlePowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if SKCI ~= nil and unitTag == "reticleover" and DoesUnitExist(unitTag) and IsUnitAttackable(unitTag) and
		powerType == POWERTYPE_HEALTH
	then
		if not IsUnitDead(unitTag) then
			SKCI.currentTargetHP = tonumber(string.format("%.6f", (100 * powerValue / powerMax)))
			SKCI.currentTargetMaxHP = tonumber(powerMax)
		else
			SKCI.currentTargetHP = 0
			SKCI.currentTargetMaxHP = 0
		end
		if SK.savedVars.showExecutionIndicator then SKCI:updateExecutionIndicator() end
	end
end

local function HandleTargetChanged()
	if SK.savedVars.showExecutionIndicator and SKCI and not DoesUnitExist("reticleover") then
		SKCI:cleanupIndicators()
	end
end

local function HandleOpenStore()
	if not SK.savedVars.isAutoSaleEnabled then return end
	if not HasAnyJunk(BAG_BACKPACK, true) then return end
	local currentMoneyBefore = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
	local numBagUsedSlotsBefore = GetNumBagUsedSlots(BAG_BACKPACK)
	local timeout = GetLatency() + 50
	SellAllJunk()
	zo_callLater(function()
		local currencyAmount, sellCount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) - currentMoneyBefore,
			numBagUsedSlotsBefore - GetNumBagUsedSlots(BAG_BACKPACK)
		SKH.sendMessageToChat(
			SK.COLORED_PREFIXES.SKA, SI_SK_AUT_SELL_ALL_JUNK_MESSAGE,
			sellCount,
			SKH.getFormattedCurrency(currencyAmount)
		)
	end, timeout)
end

local function initQuestJournalAutomation()
	ZO_PreHook(ZO_QuestJournal_Quests_Keyboard, "RefreshDetails", HandleQuestJournalRefreshDetails)
    QUEST_JOURNAL_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if(newState == SCENE_SHOWING) then HandleQuestJournalRefreshDetails(ZO_QUEST_JOURNAL_QUESTS_KEYBOARD) end
    end)
	SK.LastChatterName = nil
end

local function InitAutomation()
	InitAbilitiesAutomation()
	initQuestJournalAutomation()
	if not mailerSK then mailerSK = SK.Mailer:New() end
	if not craftStation then
		craftStation = SK.CraftStation:New()
		craftStation:Init()
	end

	EM:RegisterForEvent("SK_Chatter_Automation", EVENT_CHATTER_BEGIN, HandleChatterBegin)
	EM:RegisterForEvent("SK_Quest_Automation", EVENT_QUEST_ADDED, HandleQuestAdded)
	EM:RegisterForEvent("SK_Quest_Automation", EVENT_QUEST_COMPLETE_DIALOG, HandleQuestCompleteDialog)
	EM:RegisterForEvent("SK_Stable_Automation", EVENT_STABLE_INTERACT_START, HandleStableOpen)
	EM:RegisterForEvent("SK_Guild_Bank_Automation", EVENT_OPEN_GUILD_BANK, HandleGuildBankOpen)
	EM:RegisterForEvent("SK_Guild_Bank_Automation", EVENT_CLOSE_GUILD_BANK, HandleGuildBankClose)
	EM:RegisterForEvent("SK_Guild_Shop_Automation", EVENT_OPEN_TRADING_HOUSE, HandleGuildShopOpen)
	EM:RegisterForEvent("SK_Loot_Automation", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleOnInventorySingleSlotUpdate)
	EM:RegisterForEvent("SK_Loot_Automation", EVENT_INVENTORY_FULL_UPDATE, HandleOnInventorySingleSlotUpdate)
	EM:RegisterForEvent("SK_Mail_Automation", EVENT_MAIL_OPEN_MAILBOX, OnMailOpenMailBox)
	EM:RegisterForEvent("SK_Mail_Automation", EVENT_MAIL_CLOSE_MAILBOX, OnMailCloseMailBox)
	EM:RegisterForEvent("SK_Mail_Automation", EVENT_MAIL_INBOX_UPDATE, OnMailInboxUpdate)
	EM:RegisterForEvent("SK_Info_Automation", EVENT_PREPARE_FOR_JUMP, HandlePrepareForJump)
	EM:RegisterForEvent("SK_Info_Automation", EVENT_OPEN_BANK, HandleBankOpen)
	EM:RegisterForEvent("SK_Info_Automation", EVENT_OPEN_FENCE, HandleFenceOpen)
	EM:RegisterForEvent("SK_Companion_Automation", EVENT_COMPANION_ACTIVATED, HandleCompanionActivated)
	EM:RegisterForEvent("SK_Companion_Automation", EVENT_PLAYER_ACTIVATED, HandlePlayerActivated)
	EM:RegisterForEvent("SK_Ability_Automation", EVENT_POWER_UPDATE, HandlePowerUpdate)
	EM:RegisterForEvent("SK_Ability_Automation", EVENT_RETICLE_TARGET_CHANGED, HandleTargetChanged)
	EM:AddFilterForEvent("SK_Ability_Automation", EVENT_RETICLE_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
    EM:RegisterForEvent("SK_Store_Automation", EVENT_OPEN_STORE, HandleOpenStore)
	--EM:RegisterForEvent("SK_Mail_Automation", EVENT_MAIL_NUM_UNREAD_CHANGED, OnMailNumUnreadChanged)
	SKH.setPreventAttackingInnocents()
end

-- Export
SK.Automation = {
	InitAutomation = InitAutomation,
	TrainNames = TrainNames,
	AfterThresholdTrainRule = AfterThresholdTrainRule,
	CompanionUnsafeEntryModes = CompanionUnsafeEntryModes,
	addItemToPermanentUnwanted = addItemToPermanentUnwanted,
	removeItemFromPermanentUnwanted = removeItemFromPermanentUnwanted,
	addItemToNotBind = addItemToNotBind,
	removeItemFromNotBind = removeItemFromNotBind,
	addSetToPermanentUnwanted = addSetToPermanentUnwanted,
	removeSetFromPermanentUnwanted = removeSetFromPermanentUnwanted,
	filterAllBackpackItemsByRules = filterAllBackpackItemsByRules,
	sendMailAllFilteredItems = sendMailAllFilteredItems
}