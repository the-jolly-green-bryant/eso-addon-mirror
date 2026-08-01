local GS = GetString
local qsBars = {}
local slotToEdit = false
local hf = CSPS.helperFunctions
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD

local typeComboBox = false
local categoryComboBox = false
local currentType = false
local currentCategory = false
local qsCooldown = false
local barCatsToApply = false
local activeQS = 1

local CSPS_qsCollectibleList = ZO_SortFilterList:Subclass()
local qsCollectibleList = false

local outfitCollectibleType = false
local outfitSpecialCollectibleTypes = {
	[COLLECTIBLE_CATEGORY_TYPE_MOUNT] = {4},
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = {3}			
}

local lastType, lastCategory = false, false

local waitingForQSChanges = false

function CSPS.getSlotToEdit()
	cspsPost(slotToEdit)
end

local barCategories = {
	HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
	HOTBAR_CATEGORY_ALLY_WHEEL,
	HOTBAR_CATEGORY_MEMENTO_WHEEL,
	HOTBAR_CATEGORY_TOOL_WHEEL,
	HOTBAR_CATEGORY_EMOTE_WHEEL
}
CSPS.qsBarCategories = barCategories	

local actionCatsForBarCats = {
	[HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = { ACTION_TYPE_COLLECTIBLE, ACTION_TYPE_EMOTE, ACTION_TYPE_ITEM, ACTION_TYPE_QUICK_CHAT, },
	[HOTBAR_CATEGORY_ALLY_WHEEL] = { ACTION_TYPE_COLLECTIBLE, }, 
	[HOTBAR_CATEGORY_MEMENTO_WHEEL] = { ACTION_TYPE_COLLECTIBLE, },
	[HOTBAR_CATEGORY_TOOL_WHEEL] = { ACTION_TYPE_COLLECTIBLE, }, 
	[HOTBAR_CATEGORY_EMOTE_WHEEL] = { ACTION_TYPE_EMOTE, 	ACTION_TYPE_QUICK_CHAT,	},
}

local slotTypesForId = {[ACTION_TYPE_EMOTE] = true, [ACTION_TYPE_QUICK_CHAT] = true, [ACTION_TYPE_COLLECTIBLE] = true}

local reRoute1 = {4, 3, 2, 1, 8, 7, 6, 5} -- want the quickslots to beginn at the top of the circle and not counterclockwise at 4 o'clock...

local routeBack1 = {}
for i, v in pairs(reRoute1) do routeBack1[v] = i end 

local function getItemIdsFromLink(itemLink, firstId)
	local firstId = firstId or GetItemLinkItemId(itemLink)

	local secondId = tonumber(string.match(itemLink, ":%d+:(%d+):"))
	local thirdId = tonumber(string.match(itemLink, "%d:%d+:(%d+):"))
	local lastId = tonumber(string.match(itemLink, ":(%d+)|"))
	return firstId, secondId, thirdId, lastId
end

CSPS.getItemIdsFromLink = getItemIdsFromLink
	
local collectibleCategoryIdByBarCat = {
	[HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {
			91, -- Companions
			5, -- Collectibles
			66, -- Tools
			3, -- Non-Combat Pet
			13, -- appearances
		},
	[HOTBAR_CATEGORY_ALLY_WHEEL] = { 91 },
	[HOTBAR_CATEGORY_MEMENTO_WHEEL] = { 5 },
	[HOTBAR_CATEGORY_TOOL_WHEEL] = { 66 },
}

CSPS.getQsBars = function() return qsBars end

local function doesActionFitSlot(hbIndex, slotIndex, slotData)
	
	local slotType = GetSlotType(reRoute1[slotIndex], barCategories[hbIndex])
	if (not slotData or slotData.type == ACTION_TYPE_NOTHING) then return slotType == ACTION_TYPE_NOTHING end
	
	if slotTypesForId[slotData.type] then
		return slotData.type == slotType and slotData.value == GetSlotBoundId(reRoute1[slotIndex], barCategories[hbIndex])
	elseif slotData.type == slotType then
		local itemLink = GetSlotItemLink(reRoute1[slotIndex], barCategories[hbIndex])
		if slotData.value == itemLink then return true end
		itemLink = itemLink or ""
		local itemIdTable1 = {getItemIdsFromLink(itemLink)}
		local itemIdTable2 = {getItemIdsFromLink(slotData.value)}
		for i, v in pairs(itemIdTable1) do
			if v ~= itemIdTable2[i] then return false end
		end
		return true
	end
	
	return false
end

function CSPS.findItemLinkForTwoIds(firstId, lastId)
	if not firstId then return "" end
	local bagsToSearch = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	for _, bagId in pairs(bagsToSearch) do
		for slotIndex = 0, GetBagSize(bagId) - 1 do
			if GetItemId(bagId, slotIndex) == firstId then
				local itemLink = GetItemLink(bagId, slotIndex)
				if not lastId or lastId == 0 then 
					return itemLink 
				end
				
				local _, _, _, entryLastId = getItemIdsFromLink(itemLink)
				if entryLastId == lastId then
					return itemLink 
				end
			end
		end
	end
	return string.format("|H0:item:%s:%s:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:%s|h|h", firstId, 308, 50, lastId or 0)
end

local function findItemToSlot(barCategory, slotData, bagId)
	if not bagId then
		local _, bagSlot, fitsExactly = findItemToSlot(barCategory, slotData, BAG_BACKPACK)
		if fitsExactly then 
			return BAG_BACKPACK, bagSlot, true 
		else
			local _, slotBank, fitsExactlyBank = findItemToSlot(barCategory, slotData, BAG_BANK)
			local _, slotBankPlus, fitsExactlyBankPlus = findItemToSlot(barCategory, slotData, BAG_SUBSCRIBER_BANK)
			if fitsExactlyBank then
				return BAG_BANK, slotBank, true
			elseif fitsExactlyBankPlus then
				return BAG_SUBSCRIBER_BANK, slotBankPlus, true
			elseif bagSlot then
				return BAG_BACKPACK, bagSlot, false
			elseif slotBank then
				return BAG_BANK, slotBank, false
			elseif slotBankPlus then
				return BAG_SUBSCRIBER_BANK, slotBankPlus, false
			else
				return nil
			end
		end
		
	end
	local itemToSlot = false
	local myItemId, myItemSecondId, myItemThirdId, myItemLastId = getItemIdsFromLink(slotData.value)
	for bagSlot=0, GetBagSize(bagId)-1 do
		if IsValidItemForSlot(bagId, bagSlot, 1, barCategory) then
			local oneItem = GetItemLink(bagId, bagSlot)
			
			if oneItem == itemLink then return bagId, bagSlot, true end
			
			local oneItemId = GetItemId(bagId, bagSlot)
			
			if oneItemId == myItemId then
				itemToSlot = bagSlot
				local _, secondId, thirdId, lastId = getItemIdsFromLink(oneItem, oneItemId)
			
				if myItemSecondId == secondId and myItemThirdId == thirdId and myItemLastId == lastId then
					return bagId, bagSlot, true
				end
			end	
		end
	end
	return itemToSlot and bagId or false, itemToSlot, false
end

local function applySingleSlot(hbIndex, slotIndex, slotData)
	slotData = slotData or qsBars and qsBars[hbIndex] and qsBars[hbIndex][slotIndex]
	
	if doesActionFitSlot(hbIndex, slotIndex, slotData) then return false end
	
	if not slotData or slotData.type == ACTION_TYPE_NOTHING or slotData.value == "" then
		if CallSecureProtected("ClearSlot",  routeBack1[slotIndex], barCategories[hbIndex]) == false then cspsPost(string.format("%s - %s %s", GS(SI_PROMPT_TITLE_ERROR), GS(SI_BINDING_NAME_GAMEPAD_ASSIGN_QUICKSLOT), slotIndex)) return false end
		return true
	end
	if slotTypesForId[slotData.type] then
		if CallSecureProtected("SelectSlotSimpleAction", slotData.type, slotData.value, routeBack1[slotIndex], barCategories[hbIndex]) == false then 
			cspsPost(string.format("%s - %s %s: %s", GS(SI_PROMPT_TITLE_ERROR), GS(SI_BINDING_NAME_GAMEPAD_ASSIGN_QUICKSLOT), slotIndex, slotData.value)) 
			return false
		end
		return true
	else
		
		
		local bagId, itemToSlot, fitsExactly = findItemToSlot(barCategories[hbIndex], slotData, BAG_BACKPACK)
		
		if itemToSlot then
			if CallSecureProtected("SelectSlotItem", BAG_BACKPACK, itemToSlot, routeBack1[slotIndex], barCategories[hbIndex])  == false then 
				cspsPost(string.format("%s - %s %s: %s", GS(SI_PROMPT_TITLE_ERROR), GS(SI_BINDING_NAME_GAMEPAD_ASSIGN_QUICKSLOT), slotIndex, slotData.value)) 
				return false
			else
				return true
			end
		end
	end
end

local function applyBarCat(hbIndex, calledByLoop)
	if barCatsToApply and not calledByLoop then cspsPost(GS(SI_SENDMAILRESULT10)) return end
	if not hbIndex then
		barCatsToApply = {}
		for i, v in pairs(barCategories) do
			table.insert(barCatsToApply, i)
		end
		
		local waitingTime = 1500
		
		local function applyNextBar()
			EVENT_MANAGER:UnregisterForUpdate("CSPS_ApplyQSBarsByCategory")
			if #barCatsToApply == 0 then
				barCatsToApply = false
				return
			end
			waitingTime = (waitingTime or 1000) + 1500
			local itemsToApply = applyBarCat(barCatsToApply[1], true) 
			if not itemsToApply or itemsToApply < 4 then waitingTime = false end 
			if itemsToApply and itemsToApply > 6 then waitingTime = waitingTime + 500 end
			local anythingToChange = itemsToApply and itemsToApply > 0
			
			local waitingTimeText = #barCatsToApply > 1 and string.format("%ss", ZO_FastFormatDecimalNumber((waitingTime or 0)/1000)) or GS(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE)
			
			if anythingToChange then
				cspsPost(string.format(GS(CSPS_QS_ApplyWait), 
					GS("SI_HOTBARCATEGORY", barCategories[barCatsToApply[1]]), 
					waitingTimeText))
			end
			table.remove(barCatsToApply, 1)
			EVENT_MANAGER:RegisterForUpdate("CSPS_ApplyQSBarsByCategory", waitingTime or 0, applyNextBar)		
		end
		
		applyNextBar()
	
		return
	end
	if not qsBars[hbIndex] or not hf.anyEntryNotFalse(qsBars[hbIndex], true) then return false end
	local numSlotsChanged = 0
	for slotIndex, slotData in pairs(qsBars[hbIndex]) do
		if applySingleSlot(hbIndex, slotIndex, slotData) then numSlotsChanged = numSlotsChanged + 1 end
	end
	if hbIndex == 1 and GetCurrentQuickslot() ~= activeQS then SetCurrentQuickslot(activeQS) end
	return numSlotsChanged
end

CSPS.applyQS = applyBarCat

local function getCurrentQsBars(givenQSBars)
	local myQSBars = givenQSBars or {}
	
	for hbIndex, hbCat in pairs(barCategories) do
		myQSBars[hbIndex] = myQSBars[hbIndex] or {}
		local myBar = myQSBars[hbIndex]
		
		for slotIndex=1, ACTION_BAR_UTILITY_BAR_SIZE do
			local slotType = GetSlotType(reRoute1[slotIndex], hbCat)
			if slotType == ACTION_TYPE_NOTHING then
				myBar[slotIndex] = {type = slotType, value=false}
			elseif slotTypesForId[slotType] then
				myBar[slotIndex] = {type = slotType, value=GetSlotBoundId(reRoute1[slotIndex], hbCat)}
			else
				local itemLink = GetSlotItemLink(reRoute1[slotIndex], hbCat)
				itemLink = itemLink or ""
				myBar[slotIndex] = {type = slotType, value=itemLink}
			end -- ACTION_TYPE_QUICK_CHAT
		end
	end
	
	return myQSBars
end

function CSPS.readCurrentQS()
	qsBars = getCurrentQsBars(qsBars)
	activeQS = GetCurrentQuickslot()
end

local function onQsChange()
	if CSPSWindow:IsHidden() then return end
	if waitingForQSChanges then return end
	waitingForQSChanges = true
	zo_callLater(function() waitingForQSChanges = false CSPS.refreshTree() end, 840)
end


local function compressSingleBar(tableToCompress)
	local auxTable = {}
	local anySlotFilled = false
	for qsIndex, qsActionInfo in pairs(tableToCompress) do
		local myValue = qsActionInfo and qsActionInfo.value or 0
		local myType = qsActionInfo and qsActionInfo.type or ACTION_TYPE_NOTHING
		local slotTable = {myType}
		if slotTypesForId[myType] then
			table.insert(slotTable, myValue)
			anySlotFilled = true
		elseif myType ~= 0 then
			anySlotFilled = true
			for _, subID in pairs({getItemIdsFromLink(myValue)}) do
				table.insert(slotTable, subID or 0)
			end
		end
		table.insert(auxTable, myType == 0 and "0" or table.concat(slotTable, ":"))
	end
	if not anySlotFilled then return "0" end
	return table.concat(auxTable, ",")
end

function CSPS.getQSProfileCategoryName(compressedString, myCat)
	if not myCat then
		if not compressedString or compressedString == "" then return "-" end
		if string.sub(compressedString, 1, 2) ~= "qs" then return 0, GS("SI_HOTBARCATEGORY", HOTBAR_CATEGORY_QUICKSLOT_WHEEL) end
		myCat = tonumber(string.sub(compressedString, 4, 4))
	end
	return myCat, myCat ~= 0 and GS("SI_HOTBARCATEGORY", barCategories[myCat]) or GS(SI_INVENTORY_WALLET_ALL_FILTER)
end

function CSPS.compressQS(tableToCompress, cat) -- if specifying a category never give the whole table to this function, only the bartable!
	tableToCompress = tableToCompress or cat and qsBars[cat] or qsBars
	if #tableToCompress == 0 then return "-" end
	tableToCompress = cat and {tableToCompress} or tableToCompress
	
	local auxTable = {}
	
	--fill header data ("qs" to see that it's not an old sv-entry, followed by the hbIndex)
	table.insert(auxTable, "qs")
	table.insert(auxTable, cat or 0)

	for hbIndex, barTable in pairs(tableToCompress) do
		table.insert(auxTable, compressSingleBar(barTable))
	end
	if not cat or cat == 0 or cat == 1 then table.insert(auxTable, string.format("aq:%s", activeQS)) end
	return table.concat(auxTable, ";")
end

local function cooldownAlert()
	cspsPost(string.format("%s: %ss", GS(SI_GAMEPAD_TOOLTIP_COOLDOWN_HEADER), qsCooldown)) 
	CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, GS(SI_GAMEPAD_TOOLTIP_COOLDOWN_HEADER), string.format("%s (%s s)", GS(SI_GAMEPAD_CONSOLE_WAIT_FOR_NAME_VALIDATION_TEXT), qsCooldown), nil, nil, nil, nil, 2000)
end

local function triggerQsCooldown()
	qsCooldown = 5
	--zo_callLater(function() qsCooldown = false end, 4200)
	EVENT_MANAGER:RegisterForUpdate(CSPS.name.."QsCooldown", 1000, function() 
		qsCooldown = qsCooldown and qsCooldown - 1
		if not qsCooldown or qsCooldown == 0 then
			qsCooldown = false
			EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."QsCooldown")
		end
	end)
end

local function extractSingleBar(compressedBar, hbIndex, fillTable)
	compressedBar = compressedBar ~= "0" and compressedBar or "0,0,0,0,0,0,0,0"
	local auxBar = {SplitString(",", compressedBar)}
	qsBars[hbIndex] = qsBars[hbIndex] or {}
	local fillTable = fillTable or {}
			
	for qsIndex, compressedQsData in pairs(auxBar) do
		local qsData = {SplitString(":", compressedQsData)}
			
		if qsData[1] == "0" then
			fillTable[qsIndex] = false
		else 
			local myType = tonumber(qsData[1])
			if slotTypesForId[myType] then
				fillTable[qsIndex] = {type = myType, value = tonumber(qsData[2])}
			else
				fillTable[qsIndex] = {
					type = myType, 
					value =	string.format(
						"|H0:item:%s:%s:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:%s|h|h",
						tonumber(qsData[2]) or 0, tonumber(qsData[3]) or 0, tonumber(qsData[4]) or 0, tonumber(qsData[5]) or 0
					)}
			end
		end
	end
end

local function extractOldQS(compressedString, fillTable)

	local qsProfile = {SplitString(",", compressedString)}
	
	fillTable = fillTable or {}
	
	fillTable[1] = fillTable[1] or {}
	
	for slotIndex, slotLink in pairs(qsProfile) do 
		local collectibleId = GetCollectibleIdFromLink(slotLink)
		local routedSlotIndex = reRoute1[slotIndex]	
		if collectibleId and collectibleId ~= 0 then
			fillTable[1][routedSlotIndex] = {type = ACTION_TYPE_COLLECTIBLE, value = collectibleId}
		elseif slotLink ~= "-" and slotLink ~= "" then
			fillTable[1][routedSlotIndex] = {type = ACTION_TYPE_ITEM, value = slotLink}
		else
			fillTable[1][routedSlotIndex] = false
		end
	end
	
end	


function CSPS.extractQS(compressedString, fillTable)
	if not compressedString or compressedString == "" or compressedString == "-" or type(compressedString) ~= "string" then return false end

	fillTable = fillTable or {}
	local auxTable = {SplitString(";", compressedString)}
	if auxTable[1] ~= "qs" then 
		extractOldQS(compressedString, fillTable)
		return fillTable
	end
	table.remove(auxTable, 1)
	local cat = tonumber(auxTable[1])
	table.remove(auxTable, 1)
	local activeAux = false
	if cat == 0 or cat == 1 and #auxTable > 0 then
		local lastEntry = auxTable[#auxTable]
		if string.sub(lastEntry,1,3) == "aq:" then
			activeAux = tonumber(string.sub(lastEntry, 4, 4))
			table.remove(auxTable, #auxTable)
		end
	end
	
	for hbIndex, compressedBar in pairs(auxTable) do
		local theHbIndex = cat == 0 and hbIndex or cat
		if compressedBar ~= "0" then
			fillTable[theHbIndex] = fillTable[theHbIndex] or {}
			extractSingleBar(compressedBar, theHbIndex, fillTable[theHbIndex])
		end
	end
	if fillTable == qsBars and activeAux then activeQS = activeAux end
	return fillTable, activeAux
end

local function getItemLinkTooltip(itemLink)
	local myIcon = GetItemLinkInfo(itemLink)
	
	local _, _, onUseText =  GetItemLinkOnUseAbilityInfo(itemLink)
	local additionalDescription = {}
	if onUseText and onUseText ~= "" then
		table.insert(additionalDescription, onUseText)
	end
	for i=1, 10 do
		local hasAb, abText = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
		if not hasAb then break end
		if abText and abText ~= "" then 
			table.insert(additionalDescription, abText)
		else 
			break
		end
	end
	local flavText = GetItemLinkFlavorText(itemLink)
	if flavText and flavText ~= "" then table.insert(additionalDescription, flavText) end
	
	return itemLink, myIcon, additionalDescription
end

local function qsActionInfo(myAction)
	if not myAction or not myAction.value or myAction.value == "" then 
		return "esoui/art/actionbar/passiveabilityframe_round_empty.dds", "-", false, false, false, "", ZO_NORMAL_TEXT
	end
	
	if myAction.type == ACTION_TYPE_EMOTE then
	
		local emoteIndex = GetEmoteIndex(myAction.value)
		local slashName, emoteCategory, _, emoteName = GetEmoteInfo(emoteIndex)
		local myIcon = GetEmoteCategoryKeyboardIcons(emoteCategory)
		local additionalDescription = GetCollectibleDescription(GetEmoteCollectibleId(emoteIndex))
		additionalDescription = additionalDescription ~= "" and additionalDescription or nil
		return myIcon, string.format("%s - %s", slashName, emoteName), emoteName, slashName, {additionalDescription}, emoteName, ZO_WHITE
		
	elseif myAction.type == ACTION_TYPE_QUICK_CHAT then
	
			local myName = GetDefaultQuickChatName(myAction.value)
			local myMessage = GetDefaultQuickChatMessage(myAction.value)
			
			return "esoui/art/hud/radialicon_whisper_over.dds", myName, myName, false, {myMessage}, myName, ZO_WHITE
			
	elseif myAction.type == ACTION_TYPE_COLLECTIBLE then
	
		local myLink = GetCollectibleLink(myAction.value)
		local myIcon = GetCollectibleIcon(myAction.value)
		local rawName = zo_strformat("<<C:1>>", GetCollectibleName(myAction.value))
		local nameColor = GetItemQualityColor(ITEM_DISPLAY_QUALITY_LEGENDARY)
		local additionalDescription = GetCollectibleDescription(myAction.value)
		
		return myIcon, myLink, myLink, false, {additionalDescription}, rawName, nameColor
		
	else
		
		local _, myIcon, additionalDescription = getItemLinkTooltip(myAction.value)
		local rawName = zo_strformat("<<C:1>>", GetItemLinkName(myAction.value))
		local nameColor = GetItemQualityColor(GetItemLinkDisplayQuality(myAction.value))
		
		return myIcon, myAction.value, myAction.value, false, additionalDescription, rawName, nameColor
		
	end
end

CSPS.qsActionInfo = qsActionInfo

function CSPS.addQsBarsToTooltip(qsProfile, qsActive)	
	local numCats = 0
	for hbIndex, hbData in pairs(qsProfile) do
		if type(hbData) == "table" and #hbData > 0 then
			numCats = numCats + 1
		end
	end
	
	local categoryTooltip = {}
	local currentCat = 0
	
	for hbIndex, hbData in pairs(qsProfile) do
		if type(hbData) == "table" and #hbData > 0 then
			currentCat = currentCat + 1
			local lineLength = 0
			for slotIndex, slotData in pairs(hbData) do
				local icon, _, _, _, _, name, nameColor = qsActionInfo(slotData)
				local nameLength = string.len(name)
				if numCats > 1 and nameLength > 14 then name = string.sub(name, 1, 11).."..." nameLength = 14 end
				if nameLength < 5 then nameLength = 5 end
				name = nameColor:Colorize(name)
				lineLength = lineLength + nameLength
				local newLine = lineLength > 28
				if newLine then lineLength = nameLength end
				newLine = (numCats == 1 or newLine) and slotIndex > 1
				local slotIndexF = slotIndex..")"
				if currentCat == 1 and qsActive and qsActive == reRoute1[slotIndex] then slotIndexF = CSPS.cpColors[4]:Colorize(slotIndexF) end
				table.insert(categoryTooltip, newLine and "\n" or " ")
				table.insert(categoryTooltip, string.format("%s |t23:23:%s|t %s", slotIndexF, icon, name or "-"))
			end
			if currentCat < numCats then table.insert(categoryTooltip, "\n|t300:7:EsoUI/Art/Miscellaneous/horizontalDivider.dds|t\n") end
			
		end
	end
	local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	InformationTooltip:AddLine(table.concat(categoryTooltip, ""), "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
end

function CSPS.cancelQuickSlotEdit()
	CSPSWindowCollectibles:SetHidden(true)
	slotToEdit = false
	outfitCollectibleType = false
	CSPS.refreshTree()
end

local function setQuickSlot(actionType, actionValue)
	CSPSWindowCollectibles:SetHidden(true)
	if outfitCollectibleType then
		CSPS.outfits.setSlot(outfitCollectibleType, actionValue)
		outfitCollectibleType = false
		return
	end
	if not slotToEdit then return end
	local slotData = qsBars[slotToEdit.bar][slotToEdit.slot] or {}
	qsBars[slotToEdit.bar][slotToEdit.slot] = slotData
	slotData.type = actionType
	slotData.value = actionValue
	slotToEdit = false
	CSPS.refreshTree()
end

function CSPS_qsCollectibleList:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

function CSPS_qsCollectibleList:SetupItemRow( control, data )
	control.data = data
	GetControl(control, "Name").normalColor = ZO_DEFAULT_TEXT
	GetControl(control, "Name"):SetText(data.name)	
	control.tooltipFunction = function()
		qsCollectibleList:Row_OnMouseEnter(control)
		if data.tooltipFunction then data.tooltipFunction(control) end
	end
	control.mouseExitFunction = function() qsCollectibleList:Row_OnMouseExit(control) end
	ZO_SortFilterList.SetupRow(self, control, data)
end

function CSPS_qsCollectibleList:Setup( )
	ZO_ScrollList_AddDataType(self.list, 1, "CSPSqsEditListEntry", 28, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = {}
		
	local sortKeys = {}
	self.currentSortKey = ""
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortFunction = function( listEntry1, listEntry2 )	return listEntry1.data.name < listEntry2.data.name end
		
	self.searchBox = self.frame:GetNamedChild("SearchBox")
    self.searchBox:SetHandler("OnTextChanged", function()  ZO_EditDefaultText_OnTextChanged(self.searchBox) self:RefreshFilters() end)

	self:RefreshData()
end

function CSPS_qsCollectibleList:SortScrollList()
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		table.sort(ZO_ScrollList_GetDataList(self.list), self.sortFunction)
		self:RefreshVisible()
	end
end

local function showItemTooltip(control, itemLink, myIcon, additionalDescription)
	InitializeTooltip(InformationTooltip, control, LEFT)
	local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", myIcon , itemLink), "ZoFontWinH2", r, g, b)
	if additionalDescription and #additionalDescription > 0 then
		ZO_Tooltip_AddDivider(InformationTooltip)
		for i, v in pairs(additionalDescription) do
			InformationTooltip:AddLine(v, "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
		end
	end	
end

local function autoFillBar(fillTable, barIndex)
	if barCategories[barIndex] == HOTBAR_CATEGORY_QUICKSLOT_WHEEL then return end
	fillTable[barIndex] = fillTable[barIndex] or {}
	fillTable = fillTable[barIndex]
	local emptySlots = {}
	local usedActions = {}
	
	for i=1, ACTION_BAR_UTILITY_BAR_SIZE do
		if fillTable[i] and fillTable[i].value then
			slotData = fillTable[i]
			usedActions[slotData.type] = usedActions[slotData.type] or {}
			usedActions[slotData.type][slotData.value] = true
		else
			table.insert(emptySlots, i)
		end
	end
	if #emptySlots == 0 then return end
	
	
	if barCategories[barIndex] == HOTBAR_CATEGORY_EMOTE_WHEEL then 
		usedActions = usedActions[ACTION_TYPE_EMOTE] or {}
		for _, emoteType in pairs(PLAYER_EMOTE_MANAGER:GetEmoteCategories()) do	
			for _, emote in pairs(PLAYER_EMOTE_MANAGER:GetEmoteListForType(emoteType)) do
				if #emptySlots == 0 then break end
				local emoteInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emote)
				if not usedActions[emoteInfo.emoteId] then
					fillTable[emptySlots[1]] = {type = ACTION_TYPE_EMOTE, value = emoteInfo.emoteId}
					table.remove(emptySlots, 1)
					usedActions[emoteInfo.emoteId] = true
				end
			end
		end
	else
		usedActions = usedActions[ACTION_TYPE_COLLECTIBLE] or {}
		local function collectibleCategoryIterator(catData)
			for i=1, catData:GetNumCollectibles() do
				if #emptySlots == 0 then break end
				local collectibleData = catData:GetCollectibleDataByIndex(i)
				if collectibleData:IsUnlocked() then
					local collectibleId = collectibleData:GetId()
					if not usedActions[collectibleId] then
						fillTable[emptySlots[1]] = {type = ACTION_TYPE_COLLECTIBLE, value = collectibleId}
						table.remove(emptySlots, 1)
						usedActions[collectibleId] = true
					end
				end
			end
		end
	
		local collectibleCategoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(collectibleCategoryIdByBarCat[barCategories[barIndex]][1])
		collectibleCategoryIterator(collectibleCategoryData)
		
		for i = 1, collectibleCategoryData:GetNumSubcategories() do
			if #emptySlots == 0 then break end
			collectibleCategoryIterator(collectibleCategoryData:GetSubcategoryData(i))
		end
	end
	CSPS.refreshTree()
	return
end

function CSPS_qsCollectibleList:BuildMasterList()
	self.masterList = {}
	--CSPSqsEditListEntry
	if currentType == ACTION_TYPE_EMOTE then
	
		local emoteList = {}
		if currentCategory then
			emoteList = PLAYER_EMOTE_MANAGER:GetEmoteListForType(currentCategory)
		else
			for _, emoteType in pairs(PLAYER_EMOTE_MANAGER:GetEmoteCategories()) do	
				for _, emote in pairs(PLAYER_EMOTE_MANAGER:GetEmoteListForType(emoteType)) do
					table.insert(emoteList, emote)
				end
			end
		end
		
		for i, emote in ipairs(emoteList) do
			local emoteInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emote)
			table.insert(self.masterList, 
				{
					name = string.format("%s - %s", emoteInfo.emoteSlashName, emoteInfo.displayName),
					tooltipFunction = function(control) ZO_Tooltips_ShowTextTooltip(control, RIGHT, GS(CSPS_QS_TT_Select).."\n"..GS(CSPS_QS_TT_TestIt)) end,
					leftClickFunction = function() setQuickSlot(ACTION_TYPE_EMOTE, emoteInfo.emoteId) end,
					rightClickFunction = function() PlayEmoteByIndex(emoteInfo.emoteIndex) end,
				})
			-- emoteCategory = emoteCategory,
			--emoteId = emoteId,
			--emoteIndex = emoteIndex,
			--displayName = displayName,
			-- emoteSlashName = emoteSlashName,
			--showInGamepadUI = showInGamepadUI,
			--isOverriddenByPersonality = isOverriddenByPersonality,
		end
		
	elseif currentType == ACTION_TYPE_QUICK_CHAT then
		local quickChatList = QUICK_CHAT_MANAGER:BuildQuickChatList()
        for i, quickChatId in ipairs(quickChatList) do
			table.insert(self.masterList, 
				{
					name = QUICK_CHAT_MANAGER:GetFormattedQuickChatName(quickChatId),
					tooltipFunction = function(control) end,
					leftClickFunction = function() setQuickSlot(ACTION_TYPE_QUICK_CHAT, quickChatId) end,
					rightClickFunction = function() end,
				})
        end
	
	elseif currentType == ACTION_TYPE_COLLECTIBLE then
		local idsDone = {}
		local function collectibleCategoryIterator(catData)
			for i=1, catData:GetNumCollectibles() do
				local collectibleData = catData:GetCollectibleDataByIndex(i)
				local collectibleId = collectibleData:GetId()
				if collectibleData:IsUnlocked() and not idsDone[collectibleId] and (not outfitCollectibleType or GetCollectibleCategoryType(collectibleId) == outfitCollectibleType) then
					idsDone[collectibleId] = true
					table.insert(self.masterList,
						{
							name = collectibleData:GetFormattedName(),
							tooltipFunction = function(control) 
								InitializeTooltip(InformationTooltip, control, LEFT)
								local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
								InformationTooltip:AddLine(collectibleData:GetFormattedName(), "ZoFontWinH2", r, g, b)
								InformationTooltip:AddLine(string.format("\n|t48:48:%s|t\n", collectibleData:GetIcon()), "ZoFontGame", r, g, b)
								ZO_Tooltip_AddDivider(InformationTooltip)
								InformationTooltip:AddLine(collectibleData:GetDescription(), "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)InformationTooltip:AddLine(GS(CSPS_QS_TT_Select))
								InformationTooltip:AddLine(GS(CSPS_QS_TT_TestIt))
							end,  
							leftClickFunction = function() setQuickSlot(ACTION_TYPE_COLLECTIBLE, collectibleId) end,
							rightClickFunction = function() 
								if collectibleData:IsUsable(GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
									collectibleData:Use(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
								end
							end,
						})
				end
			end
		end
	
		local function insertCategory(categoryId)
			local collectibleCategoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(categoryId)
			collectibleCategoryIterator(collectibleCategoryData)
					
			for i = 1, collectibleCategoryData:GetNumSubcategories() do
				collectibleCategoryIterator(collectibleCategoryData:GetSubcategoryData(i))
			end
		end	
		
		if currentCategory then 
			insertCategory(currentCategory)
		else
			local collectibleCategories = outfitCollectibleType and (outfitSpecialCollectibleTypes[outfitCollectibleType] or {13}) or  collectibleCategoryIdByBarCat[barCategories[slotToEdit.bar]]
			
			for _, v in pairs(collectibleCategories) do
				insertCategory(v)
			end
		end
	elseif currentType == ACTION_TYPE_ITEM then
		if currentCategory ~= 3 then 
			local itemTypes = { -- more categories?
			
				[ITEMTYPE_POTION] = 1,
				[ITEMTYPE_FOOD] = 2,
				[ITEMTYPE_DRINK] = 2,
			}
			for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
				if IsValidItemForSlot(BAG_BACKPACK, slotIndex, 1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) then 
					local itemType = GetItemType(BAG_BACKPACK, slotIndex)
					if not currentCategory or itemTypes[itemType] == currentCategory or currentCategory == 4 then
						table.insert(self.masterList, 
							{
								name = zo_strformat("<<C:1>>", GetItemName(BAG_BACKPACK, slotIndex)),
								tooltipFunction = function(control)
									showItemTooltip(control, getItemLinkTooltip(GetItemLink(BAG_BACKPACK, slotIndex)))
									InformationTooltip:AddLine(GS(CSPS_QS_TT_Select))
									end,
								leftClickFunction = function() setQuickSlot(ACTION_TYPE_ITEM, GetItemLink(BAG_BACKPACK, slotIndex)) end,
								rightClickFunction = function() end,
							})
					end
				end
			end
		else
			for journalIndex=1, MAX_JOURNAL_QUESTS do 
				for toolIndex=1, GetQuestToolCount(journalIndex) do
					local _, _, _, questItemName, questItemId = GetQuestToolInfo(journalIndex, toolIndex)
					questItemName = zo_strformat("<<C:1>>", questItemName)
					if CanQuickslotQuestItemById(questItemId) then
						table.insert(self.masterList, 
							{
								name = questItemName,
								tooltipFunction = function(control)
									local descr = GetQuestItemTooltipText(questItemId)
									local myIcon = GetQuestItemIcon(questItemId)
									showItemTooltip(control, questItemName, myIcon, {descr})
								end,
								leftClickFunction = function() end,
								rightClickFunction = function() end,
							})
					end
				end
			end
		end
		-- 1) potions
		-- 2) food/drink
		-- 3) quest items
		-- 4) others
			
	end	
end

function CSPS_qsCollectibleList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	local searchText = string.lower(self.searchBox:GetText())
	for _, data in ipairs(self.masterList) do
		if searchText == "" or string.find(string.lower(data.name), searchText) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		end
	end
end


local function updateCategoryCombo(myType)
	currentType = myType
	currentCategory = false
	categoryComboBox = categoryComboBox or ZO_ComboBox_ObjectFromContainer(CSPSWindowCollectiblesCategories)
	
	categoryComboBox:ClearItems()
	categoryComboBox:SetSortsItems(false)
	
	local function OnItemSelect(choiceValue)
		currentCategory = choiceValue
		
		if not qsCollectibleList then qsCollectibleList = CSPS_qsCollectibleList:New(CSPSWindowCollectibles) end
		qsCollectibleList:RefreshData()
		
		CSPSWindowCollectiblesList:SetHidden(false)
		CSPSWindowCollectiblesSearchBox:SetHidden(false)
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end
		
	local myTypes = {}
	local preSelectName = false
	
	if myType == ACTION_TYPE_EMOTE then
		for _, emoteType in pairs(PLAYER_EMOTE_MANAGER:GetEmoteCategories()) do	
			if emoteType ~= EMOTE_CATEGORY_INVALID then
				table.insert(myTypes, {name = zo_strformat("<<C:1>>", GS("SI_EMOTECATEGORY", emoteType)), value = emoteType})
			end
		end
	elseif myType == ACTION_TYPE_QUICK_CHAT then
		CSPSWindowCollectiblesCategories:SetHidden(true)
		currentCategory = 1
	elseif myType == ACTION_TYPE_ITEM then
		local itemTypeCategories = {
			GS(SI_ITEMTYPE7), --potions
			string.format("%s/%s", GS(SI_ITEMTYPE4), GS(SI_ITEMTYPE12)), -- 4: food, 12: drink
			GS(SI_ITEMFILTERTYPE26), -- quest items (not in the regular inventory)
			GS(SI_FURNITURETHEMETYPE1), -- others
		}
		for i, v in pairs(itemTypeCategories) do
			table.insert(myTypes, {name = zo_strformat("<<C:1>>", v), value = i})
		end
	elseif myType == ACTION_TYPE_COLLECTIBLE then
		local collectibleCategories = outfitCollectibleType and (outfitSpecialCollectibleTypes[outfitCollectibleType] or {13}) or  collectibleCategoryIdByBarCat[barCategories[slotToEdit.bar]]
		for _, v in pairs(collectibleCategories) do
			table.insert(myTypes, {name = zo_strformat("<<C:1>>", (ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(v):GetName())), value = v})
		end
		if #collectibleCategories == 1 then
			preSelectName = myTypes[1].name
			currentCategory = collectibleCategories[1]
		end
	end
	
	for _, v in pairs(myTypes) do
		categoryComboBox:AddItem(categoryComboBox:CreateItemEntry(v.name, function() OnItemSelect(v.value) end))
	end
	
	OnItemSelect(currentCategory)	

	categoryComboBox:SetSelectedItem(preSelectName or "-")
end

local function updateTypeCombo()
	typeComboBox = typeComboBox or ZO_ComboBox_ObjectFromContainer(CSPSWindowCollectiblesTypes)
	
	typeComboBox:ClearItems()
	typeComboBox:SetSortsItems(false)
		
	local choosableCategoryNames = {
			[ACTION_TYPE_COLLECTIBLE] = GS(SI_ITEMFILTERTYPE12),
			[ACTION_TYPE_EMOTE] = GS(SI_HOTBARCATEGORY11),
			[ACTION_TYPE_ITEM] = GS(SI_INVENTORY_MODE_ITEMS),
			[ACTION_TYPE_QUICK_CHAT] = GS(SI_QUICK_CHAT_EMOTE_MENU_ENTRY_NAME),
	}
	
	local function OnItemSelect(actionCategory)
		CSPSWindowCollectiblesCategories:SetHidden(false)
		updateCategoryCombo(actionCategory)
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end
	
	local preSelectName = false
	local preSeletType = false
	local numberTypes = 0
	
	local actionCats = outfitCollectibleType and {ACTION_TYPE_COLLECTIBLE} or actionCatsForBarCats[barCategories[slotToEdit.bar]]
	for _, actionCategory in pairs(actionCats) do
		preSelectName = choosableCategoryNames[actionCategory]
		typeComboBox:AddItem(typeComboBox:CreateItemEntry(preSelectName, function() OnItemSelect(actionCategory) end))
		numberTypes = numberTypes + 1
		preSeletType = actionCategory

	end
	
	if numberTypes > 1 then 
		preSelectName = false 
	else
		CSPSWindowCollectiblesCategories:SetHidden(false)
		updateCategoryCombo(preSeletType)
	end
	
	typeComboBox:SetSelectedItem(preSelectName or "-")
	--updateCategoryCombo(HOTBAR_CATEGORY_ALLY_WHEEL)
end


local function setupCombos()
	-- tooltip 
	--CSPSWindowCollectiblesCategories.data = {tooltipText = GS(CSPS_Tooltiptext_ProfileCombo)}
	--CSPSWindowCollectiblesCategories:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	--CSPSWindowCollectiblesCategories:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	-- tooltip 
	--CSPSWindowCollectiblesTypes.data = {tooltipText = GS(CSPS_Tooltiptext_ProfileCombo)}
	--CSPSWindowCollectiblesTypes:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	--CSPSWindowCollectiblesTypes:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
end

function CSPS.openCollectibleList(setOutfitCollectibleType)
	outfitCollectibleType = setOutfitCollectibleType

	--Categories
	CSPSWindowCollectiblesCategories:SetHidden(true)
	CSPSWindowCollectiblesList:SetHidden(true)
	CSPSWindowCollectiblesSearchBox:SetHidden(true)
	setupCombos()
	updateTypeCombo()
	
	--Types
	--List
	--Cancel
	--Ok
	CSPSWindowCollectibles:SetHidden(false)
end

local function NodeSetupQS(node, control, data, open, userRequested, enabled)

	-- control.receiveDragFunction = function() receiveDrag(mySlot) end
	local ctrText = control:GetNamedChild("Text")
	local ctrMarker = control:GetNamedChild("Marker")
	local ctrIcon = control:GetNamedChild("Icon")
	local ctrIndicator = control:GetNamedChild("Indicator")
	local ctrMinus = control:GetNamedChild("BtnMinus")
		
	local myAction = data.barTable[data.qsIndex]
	local myIcon, listText, myName, subtitle, additionalDescription = qsActionInfo(myAction)
	
	local fitsSlot = doesActionFitSlot(data.barIndex, data.qsIndex, myAction)
	
	ctrIndicator:SetHidden(not myAction or myAction.type == 0)
	
	if fitsSlot then 
		ctrIndicator:SetTexture("esoui/art/inventory/inventory_icon_equipped.dds")
		ctrIndicator:SetColor(ZO_SUCCEEDED_TEXT:UnpackRGB())
	elseif myAction and myAction.type == ACTION_TYPE_ITEM then
		local bagId, bagSlot, fitsExactly = findItemToSlot(barCategories[data.barIndex], myAction)
		if bagSlot then
			ctrIndicator:SetTexture(bagId == BAG_BACKPACK and  "esoui/art/tooltips/icon_bag.dds" or "esoui/art/tooltips/icon_bank.dds")
			ctrIndicator:SetColor((fitsExactly and GetItemQualityColor(ITEM_QUALITY_ARTIFACT) or ZO_ORANGE):UnpackRGB())
		else
			ctrIndicator:SetTexture("esoui/art/inventory/inventory_sell_forbidden_icon.dds")
			ctrIndicator:SetColor(ZO_ERROR_COLOR:UnpackRGB())
		end
	elseif myAction and myAction.type ~= 0 then
		ctrIndicator:SetTexture("esoui/art/inventory/inventory_sell_forbidden_icon.dds")
		ctrIndicator:SetColor(ZO_ERROR_COLOR:UnpackRGB())
	end
	
	ctrMinus:SetHidden(not myAction or myAction.type == 0)
	ctrMinus:SetHandler("OnClicked", function() 		
		data.barTable[data.qsIndex] = false
		CSPS.refreshTree()
	end)
	ctrMinus:SetHandler("OnMouseEnter", function()
		ZO_Tooltips_ShowTextTooltip(ctrMinus, RIGHT, GS(SI_ABILITY_ACTION_CLEAR_SLOT))
	end)
	
	if myName then
		control.tooltipFunction = function()
			InitializeTooltip(InformationTooltip, ctrText, LEFT)
			local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
			InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", myIcon , myName), "ZoFontWinH2", r, g, b)
			--, r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			--ZO_Tooltip_AddDivider(InformationTooltip)
			if subtitle then InformationTooltip:AddLine(subtitle, "ZoFontGame", r, g, b) end 
			if additionalDescription and #additionalDescription > 0 then
				ZO_Tooltip_AddDivider(InformationTooltip)
				for i, v in pairs(additionalDescription) do
					InformationTooltip:AddLine(v, "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
				end
			end
			
			
			
			if data.barIndex == 1 and activeQS ~= reRoute1[data.qsIndex] then
				InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", GS(SI_GUILD_RECRUITMENT_DEFAULT_SELECTION_TEXT)))
			end
			
			-- SI_KEYCODE4 (Ctrl)
						
			if not fitsSlot then
				InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t + %s: %s", GS(SI_KEYCODE7), GS(SI_APPLY)))
			end
			
			InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit)) 
		end
	else
		control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, TOP, GS(CSPS_QS_TT_Edit)) end
	end
	
	control:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift)
		if not upInside then return end
		if button == 2 then
			slotToEdit = {bar = data.barIndex, slot = data.qsIndex}
			
			CSPS.openCollectibleList()
			CSPS.refreshTree()
			return
		elseif shift then
			applySingleSlot(data.barIndex, data.qsIndex, myAction)
		elseif button == 1 then
			activeQS = reRoute1[data.qsIndex]
			CSPS.refreshTree()
		end
	end)
	
	ctrText:SetText(listText)
	ctrIcon:SetTexture(myIcon)
	local markerTexture = "esoui/art/compass/repeatablequest_assistedareapin.dds"
	if slotToEdit and slotToEdit.bar == data.barIndex and slotToEdit.slot == data.qsIndex then
		markerTexture = "esoui/art/compass/repeatablequest_available_icon.dds"
	end
	ctrMarker:SetTexture(markerTexture)
	-- + means counterclockwise
	ctrMarker:SetTextureRotation(-3/4 * math.pi - (data.qsIndex * math.pi/4), 0.5,0.5)
	if data.barIndex == 1 then
		if reRoute1[data.qsIndex] == activeQS then
			ctrMarker:SetColor(CSPS.cpColors[4]:UnpackRGB())
		else
			ctrMarker:SetColor(1,1,1)
		end
	end
end

function CSPS.setupQsSection(control, node, data)
	local btnApply = control:GetNamedChild("BtnApply") 
	control:GetNamedChild("BtnPlus"):SetWidth(0)
	
	local btnMinus = control:GetNamedChild("BtnMinus")
	local btnPlus = control:GetNamedChild("BtnPlus")
	btnMinus:SetHidden(true)
	btnMinus:SetWidth(0)
	btnPlus:SetHidden(true)
	btnPlus:SetWidth(0)
	
	if node:IsOpen() and not data.fillContent then
		btnApply:SetHidden(false)
		
		if not data.isMainCat then
			local isEmpty = not hf.anyEntryNotFalse(qsBars[data.barIndex])
			local showPlusButton = false

			if data.barIndex > 1 then
				for i=1, ACTION_BAR_UTILITY_BAR_SIZE do
					slotData = qsBars[data.barIndex][i]
					if not slotData or not slotData.value then showPlusButton = true break end
				end
			end
			
			btnMinus:SetHidden(isEmpty)
			btnMinus:SetWidth(isEmpty and 0 or 21)
			btnMinus:SetHandler("OnClicked", function()
				ZO_ClearNumericallyIndexedTable(qsBars[data.barIndex])
				CSPS.refreshTree()
			end)
			btnMinus:SetHandler("OnMouseEnter", function()
				ZO_Tooltips_ShowTextTooltip(btnMinus, RIGHT, GS(SI_SKILLPOINTALLOCATIONMODE_CLEARKEYBIND2))
			end)
			
			btnPlus:SetHidden(not showPlusButton)
			btnPlus:SetWidth(showPlusButton and 21 or 0)
			btnPlus:SetHandler("OnClicked", function()
				autoFillBar(qsBars, data.barIndex)
			end)
			btnPlus:SetHandler("OnMouseEnter", function()
				ZO_Tooltips_ShowTextTooltip(btnMinus, RIGHT, GS(SI_GAMEPAD_INTERFACE_OPTIONS_ACCOUNT_EMAIL_DIALOG_AUTOFILL))
			end)
		end
		btnApply:SetWidth(21)
		btnApply:SetHandler("OnClicked", function() 	
			if not qsCooldown then
				applyBarCat(data.barIndex)
				PlaySound(SOUNDS.CHAMPION_RESPEC_ACCEPT)
				triggerQsCooldown()
			else
				cooldownAlert()
			end
		end)
		btnApply:SetHandler("OnMouseEnter", function()
			ZO_Tooltips_ShowTextTooltip(btnApply, RIGHT, qsCooldown and ZO_ERROR_COLOR:Colorize(GS(SI_GAMEPAD_TOOLTIP_COOLDOWN_HEADER)) or GS(SI_APPLY))
		end)
	else
		btnApply:SetHidden(true)
		btnApply:SetWidth(0)
	end
	local qsBarIndex = false
	if data.isMainCat then CSPS.setupTreeSectionConnections(node, control, 4, CSPS.cpColors[4], node:IsOpen() and not data.fillContent, node:IsOpen() and not data.fillContent, qsBarIndex) end
end

function CSPS.setupQsTree()
	local myTree = CSPS.getTreeControl()
	myTree:AddTemplate("CSPSQSLE", NodeSetupQS, nil, nil, 24, 0)
	local fillContent = {}
	for barIndex, barTable in pairs(qsBars) do
		local fillContentBar = {}
		for qsIndex, itemLink in pairs(barTable) do
			table.insert(fillContentBar, {"CSPSQSLE", {barIndex = barIndex, barTable = barTable, qsIndex = qsIndex}})
		end
		table.insert(fillContent, {"CSPSLH", {name = GS("SI_HOTBARCATEGORY", barCategories[barIndex]), variant=8, barIndex = barIndex, fillContent=fillContentBar}})
	end
	local overNode = myTree:AddNode("CSPSLH", {name = GS(SI_HOTBARCATEGORY10), isMainCat=true, variant=8, fillContent=fillContent}) 

end

EVENT_MANAGER:RegisterForEvent(CSPS.name.."OnHotbarSlotUpdate", EVENT_HOTBAR_SLOT_UPDATED, onQsChange)