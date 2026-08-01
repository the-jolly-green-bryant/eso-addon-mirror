CarosLootList = {
  name = "CarosLootList",
}

local cll = CarosLootList
local textPortions = {}
local GS = GetString
local deconLists = {false, false, false, false, false, false, false, false, false, false} -- 10 placeholders for the help texts
local lastUsedMode = false

local myAccentColor = "9e0911"
local myTextColor = "1d6dad"
	
local cllPostAuxList = {}
local cllPostPerfectedList = {}
local cllFoundItems = {}
local cllAltItemLinks = {}
local cllPostSubList = {}
local cllPostSubListLength = 0
local queuedSourceHeadline = false
local cllPostAtOnce = 5
local cllDebug = false
local postNumbers = {}
local deconTraits =  {
	ITEM_TRAIT_TYPE_WEAPON_ORNATE, ITEM_TRAIT_TYPE_ARMOR_ORNATE, ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
	ITEM_TRAIT_TYPE_ARMOR_NIRNHONED, ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,	
	ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY, ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
	ITEM_TRAIT_TYPE_JEWELRY_INFUSED, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
	ITEM_TRAIT_TYPE_JEWELRY_SWIFT, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
}
cll.deconTraits = deconTraits

local function cllD(myText, debugLevel)
	if not cllDebug then return end
	if debugLevel and debugLevel > cllDebug then return end
	if type(myText) == "table" or myText == nil then
		d(string.format("|c%s[CLL_DEBUG]:|r", myAccentColor))
		d(myText)
	else
		d(string.format("|c%s[CLL_DEBUG]: %s|r", myAccentColor, myText))
	end
end
cll.cllD = cllD

local function cllPost(myText, noAddonName)
	if noAddonName then
		CHAT_SYSTEM:AddMessage(string.format("|c%s%s|r", myTextColor, myText))
	else
		CHAT_SYSTEM:AddMessage(string.format("|c%s[CLL]|r|c%s%s|r", myAccentColor, myTextColor, myText))
	end
	
end

cll.cllPost = cllPost

function cll.debug(arg)
	if cllDebug and not arg then 
		cllDebug = false
	elseif arg then
		cllDebug = arg
	else
		cllDebug = 1
	end
	d("Debugging:")
	d(cllDebug)
end

local function getMode(args, arg2)
	local cllMode = {
		postEverything = false,
		whisper = false,
		channel = CHAT_CHANNEL_PARTY,
		batman = false,
		noArmor = false,
		onlyCurrentDungeon = false,
		bank = false,
		furniture = false,
		recipe = false,
		allCrafting = false,
		motif = false,
		mawa = false,
		style = false,
		writs = false,
		writsall = false,
	}
	
	-- since writ itemlinks are longer we save the usual value and lower it to 4 for that mode
	cllPostAtOnce = 5
	
	if args == "all" then 
		cllMode.postEverything = true
	elseif args == "batman" then 
		cllPost('Nananananananana...')
		cllMode.batman = true
	elseif args == "mawa" then
		cllMode.mawa = true
	elseif args == "noArmor" then
		cllMode.noArmor = true
	elseif args == "current" then
		cllMode.onlyCurrentDungeon = GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE --don't acivate outside of dungeons etc.
	elseif args == "wife" then 
		cllMode.batman = true
		cllMode.postEverything = true 
		cllMode.whisper = true
		cllMode.channel = CHAT_CHANNEL_WHISPER_SENT
	elseif args == "whisperMode" then 
		cllMode.postEverything = true 
		cllMode.whisper = true
		cllMode.channel = CHAT_CHANNEL_WHISPER_SENT
	elseif args == "bank" then
		cllMode.postEverything = true
		cllMode.bank = true
	elseif args == "furniture" or args == "housing" then
		cllMode.furniture = true
		cllMode.bank = true
	elseif args == "recipe" then
		cllMode.recipe = true
		cllMode.bank = true
	elseif args == "motif" then
		cllMode.motif = true
		cllMode.bank = true
	elseif args == "crafting" then
		cllMode.allCrafting = true
		cllMode.bank = true
	elseif args == "style" then
		cllMode.style = true
		cllMode.bank = true
	elseif args == "writsall" then
		cllMode.writs = true
		cllMode.writsall = true
		cllMode.bank = true
		cllPostAtOnce = 4
	elseif args == "writs" then
		cllMode.writs = true
		cllMode.bank = true
		if type(arg2) == "number" then cllMode.writs = arg2 end
		cllPostAtOnce = 4
	end 
	return cllMode
end

local function cllAddEntry(myLink, myNumber, postRemaining)
	local myStringLength = myLink and string.len(myLink) or 0
	if myNumber then myStringLength = string.len(myNumber) + myStringLength + 1 end
	if #cllPostSubList >= cllPostAtOnce or postRemaining or cllPostSubListLength + myStringLength >= 350 then
		local listEntry = table.concat(cllPostSubList, ", ")
		if queuedSourceHeadline then 
			listEntry = queuedSourceHeadline..listEntry
			queuedSourceHeadline = false
		end
		table.insert(cll.lootList, listEntry)
		table.insert(postNumbers, #cllPostSubList)
		cllPostSubList = {}
		cllPostSubListLength = 0
	end
	if postRemaining then return end
	local myText = myLink
	if myNumber and myNumber > 1 then myText = string.format("%sx%s", myNumber, myText) end
	cllPostSubListLength = cllPostSubListLength + myStringLength + 2
	table.insert(cllPostSubList, myText)
end


local function getSetItemInfo(myLink)
	local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(myLink) 
	setName = ZO_CachedStrFormat("<<C:1>>", setName)
	local mySetPiece = GetItemLinkEquipType(myLink)
	local myWeaponType = GetItemLinkWeaponType(myLink)
	if myWeaponType ~= WEAPONTYPE_NONE then mySetPiece = myWeaponType + 42 end
	return hasSet, setId, mySetPiece, setName
end

cll.getSetItemInfo = getSetItemInfo

local function shouldPostCraftingItem(myLink, itemType, specialItemType, cllMode)
	if cllMode.furniture then
		if IsItemLinkFurnitureRecipe(myLink) then return true end
	elseif cllMode.recipe then
		if itemType == ITEMTYPE_RECIPE and not IsItemLinkFurnitureRecipe(myLink) then return true end
	elseif cllMode.motif then
		if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then return true end
	elseif cllMode.allCrafting then
		if itemType == ITEMTYPE_RECIPE or itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then return true end
	elseif cllMode.style then
		if specialItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then return true end
	elseif cllMode.writs or cllMode.writsall then
		if itemType == ITEMTYPE_MASTER_WRIT then
			if WritWorthy and not cllMode.writsall then
				local mat_list, know_list = WritWorthy.ToMatKnowList(myLink)
				if #know_list > 2 and (not know_list[1].is_known or not know_list[2].is_known) then
					return true
				else
					if #mat_list > 0 and type(cllMode.writs) == "number" then
						local vouchers = WritWorthy.ToVoucherCount(myLink)
						local matPrice = 0
						for _, matData in pairs(mat_list) do
							matPrice = matPrice + matData.ct * matData.mm
						end
						if matPrice/vouchers > cllMode.writs then 
							return true 
						end
					end
				end
			else
				return true
			end
		end
	end
	return false
end

local function simplifyLocationame(myStr)
	return string.gsub(string.lower(string.match(myStr, "(.+)^") or myStr), "-", "")
end

function cll.testLocationNames()
	local validSetTypes = {[ITEM_SET_TYPE_DUNGEON] = true, [ITEM_SET_TYPE_MONSTER] = true, [ITEM_SET_TYPE_WEAPON] = true}
	
	local foundZones, checkedZones = {}, {}
	
	local function findZone(colName)
		for i=1, 2000 do
			local zoneName = GetZoneNameById(i)
			if zoneName and zoneName ~= "" then
				zoneName = simplifyLocationame(zoneName)
				if colName == zoneName or string.match(zoneName, colName) then return zoneName, i end
			end
		end
		return false
	end

	local colId = GetNextItemSetCollectionId()
	while colId do
		local iL = GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(colId, 1))
		local colName = simplifyLocationame(GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryId(colId)))
		if not checkedZones[colName]  then -- and validSetTypes[GetItemSetType(colId)]
			local zoneName, zoneId = findZone(colName) 
			checkedZones[colName] = true
			if not zoneName then
				d(string.format("Not found: %s (%s)", colName, iL))
			else
				foundZones[colName] = zoneId
			end
		end
		colId = GetNextItemSetCollectionId(colId)
	end
	return foundZones
end

local function isFromCurrentDungeon(setId)
	local zoneId = GetUnitWorldPosition("player")

	local validSetTypes = {[ITEM_SET_TYPE_DUNGEON] = true, [ITEM_SET_TYPE_MONSTER] = true, [ITEM_SET_TYPE_WEAPON] = true}
	
	if not validSetTypes[GetItemSetType(setId)] then return false end
	
	local setLocationName = simplifyLocationame(GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryId(setId)))
	local zoneName = simplifyLocationame(GetZoneNameById(zoneId))
	
	if setLocationName == zoneName or string.match(zoneName, setLocationName) then  return true end
	
	return false
end

local function shouldPostCollectionPiece(myLink, bagId, slotIndex, cllMode)
	if not IsItemLinkSetCollectionPiece(myLink) then return false end
	if bagId and slotIndex and (IsItemPlayerLocked(bagId, slotIndex) or IsItemBound(bagId, slotIndex)) then return false end
	if not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink)) and not cllMode.batman then return false end
	if not cllMode.postEverything and bagId and slotIndex and not (GetItemBoPTimeRemainingSeconds(bagId, slotIndex) > 0) then return false end
	
	local hasSet, setId, mySetPiece, setName = getSetItemInfo(myLink)
	
	if not hasSet then return false end
	
	if cllMode.onlyCurrentDungeon and not isFromCurrentDungeon(setId) then return false end
	
	if cllMode.noArmor and mySetPiece < 42 and mySetPiece ~= EQUIP_TYPE_NECK and mySetPiece ~= EQUIP_TYPE_RING then return false end
	-- Entry for the actual number of items that should be posted
	cllFoundItems[setName] = cllFoundItems[setName] or {}
	-- Entry for the itemlink that should be posted if different items are variants of the same set-item 
	cllAltItemLinks[setName] = cllAltItemLinks[setName] or {}
	
	if cllFoundItems[setName][mySetPiece] then
		cllFoundItems[setName][mySetPiece] = cllFoundItems[setName][mySetPiece] + 1
	else
		cllFoundItems[setName][mySetPiece] = 1
		cllAltItemLinks[setName][mySetPiece] = myLink
	end

	local postLink = cllAltItemLinks[setName][mySetPiece]
	local isItemPerfected = false
	if GetItemSetUnperfectedSetId(setId) and GetItemSetUnperfectedSetId(setId) ~= 0 then isItemPerfected = true end
				
	return postLink, setName, mySetPiece, isItemPerfected
end

local function cllIterateAndPostBag(bagId, cllMode, resetLists, keepListsOpen)
	
	if resetLists then 
		cllPostAuxList = {}
		cllPostPerfectedList = {}
		cllFoundItems = {}
		cllAltItemLinks = {}
		cllPostSubList = {}
	end
	
	-- Iterate over the whole bag and check each item
	for slotIndex=0, GetBagSize(bagId) do
		local myLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS) or ""
		local itemType, specialItemType = GetItemLinkItemType(myLink)
		local _, myStack = GetItemInfo(bagId, slotIndex)
		myStack = myStack and myStack > 0 and myStack or 1
		
		if cllMode.furniture or cllMode.recipe or cllMode.motif or cllMode.allCrafting or cllMode.style or cllMode.writs then
			if shouldPostCraftingItem(myLink, itemType, specialItemType, cllMode) then
				cllPostAuxList[myLink] = cllPostAuxList[myLink] and cllPostAuxList[myLink] + 1 or 1
			end
		else 
			local postLink, setName, mySetPiece, isItemPerfected = shouldPostCollectionPiece(myLink, bagId, slotIndex, cllMode)
			if postLink then
				if isItemPerfected then
					cllPostPerfectedList[postLink] = cllFoundItems[setName][mySetPiece]
				else
					cllPostAuxList[postLink] = cllFoundItems[setName][mySetPiece]
				end
			end
		end
	end
	
	-- Items will be added to the list for posting.
	-- The function cllAddEntry will add text to a cllPostSubList until it's length is 5 or cllPostAtOnce. 
	-- Then it's added to cll.lootList and emptied for the next round.
    -- While adding them to the list the number of occurences is added to the text (sorting items alphabetically happens before that and is not affected).
	-- Entries in both cllPostAuxList and cllPostPerfectedList use itemLinks for keys. So we need separate sort lists for alphabetical sorting.
	
	if keepListsOpen then return end
	
	local perfectListSort = {}
	for i, v in pairs(cllPostPerfectedList) do table.insert(perfectListSort, i) end
	table.sort(perfectListSort, function(a, b) return GetItemLinkName(a) < GetItemLinkName(b) end)
	for i, v in ipairs(perfectListSort) do cllAddEntry(v, cllPostPerfectedList[v]) end
	
	-- Only post non-perfected items if MAWA-MODE is not activated.
	if not cllMode.mawa then
		-- Sort the aux list of non-perfected items (cllPostAuxList)
		local auxListSort = {}
		for i, v in pairs(cllPostAuxList) do table.insert(auxListSort, i) end
		table.sort(auxListSort, function(a, b) return GetItemLinkName(a) < GetItemLinkName(b) end)
		for i, v in ipairs(auxListSort) do cllAddEntry(v, cllPostAuxList[v]) end
	end
	
	-- After iteration is finished we have to see, if there is still a sublist to post that wasn't added to cll.lootList (because # < cllPostAtOnce)
	-- Only do that, if the list contains more entries than the headline
	if #cllPostSubList > 0 then cllAddEntry(nil, nil, true) end
end

local function portionedChat(theChannel)
	StartChatInput(textPortions[1])
	local function OutputNextLine(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
		if channelType == theChannel then
			if text == textPortions[1] then
				table.remove(textPortions, 1)
				if postNumbers[1] then
					cll.sV.postCount = cll.sV.postCount + postNumbers[1]
					table.remove(postNumbers, 1)
				end
				if #textPortions>0 then
					StartChatInput(textPortions[1])
				else
					EVENT_MANAGER:UnregisterForEvent(cll.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
				end
			else
			end
		end
	end
	EVENT_MANAGER:UnregisterForEvent(cll.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
	EVENT_MANAGER:RegisterForEvent(cll.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL, OutputNextLine)
end

function cll.allChars(houseBanks)
	if not IIfA or not IIfA.database then cllPost(GS(CLL_NoII)) return end
	if not lastUsedMode then return end
	local cllMode = lastUsedMode
	houseBanks = houseBanks == "true" or false
	cll.lootList = {}
	postNumbers = {}
	cllPostAuxList = {}
	cllPostPerfectedList = {}
	cllFoundItems = {}
	cllAltItemLinks = {}
	cllPostSubList = {}
		
	local myCharNames = {}
	local myCharItems = {}
	
	if not houseBanks then
		for i=1, GetNumCharacters() do 
			local charName, _, _, _, _, _, charID = GetCharacterInfo(i) 
			if charID ~= GetCurrentCharacterId() then
				myCharNames[charID] = zo_strformat("<<C:1>>", charName)
				myCharItems[charID] = {}
			end
		end
	else
		for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
			local collectible = GetCollectibleForHouseBankBag(bagId)
			local bankName = GetCollectibleNickname(collectible)
			if bankName == "" then bankName = GetCollectibleName(collectible) end
			if bankName ~= "" then
				myCharNames[collectible] = zo_strformat("<<C:1>>", bankName)
				myCharItems[collectible] = {}
			end
		end	
	end
	
	cll.charNames	= myCharNames
	cll.charItems = myCharItems
	for itemKey, itemData in pairs(IIfA.database) do
		local myLink = itemKey
		if zo_strlen(itemKey) < 10 then
			myLink = itemData.itemLink
		end
		local itemType, specialItemType = GetItemLinkItemType(myLink)
	
		
		if cllMode.furniture or cllMode.recipe or cllMode.motif or cllMode.allCrafting or cllMode.style or cllMode.writs then
		
			if shouldPostCraftingItem(myLink, itemType, specialItemType, cllMode) then
				for charId, charItems in pairs(itemData.locations) do
					if myCharNames[charId] and charItems.bagID ~= BAG_WORN then
						for _, itemStacks in pairs(charItems.bagSlot) do
							myCharItems[charId][myLink] = myCharItems[charId][myLink] and myCharItems[charId][myLink] + itemStacks or itemStacks
						end
					end
				end
			end
		else
			
			if shouldPostCollectionPiece(myLink, false, false, cllMode) then
				for charId, charItems in pairs(itemData.locations) do
					if myCharNames[charId] and charItems.bagID ~= BAG_WORN then
						for _, itemStacks in pairs(charItems.bagSlot) do
							myCharItems[charId][myLink] = myCharItems[charId][myLink] and myCharItems[charId][myLink] + itemStacks or itemStacks
						end
					end
				end
			end
		end	
	end
	
	for charId, charName in pairs(myCharNames) do
		queuedSourceHeadline = string.format("--- %s ---", charName)
		for itemLink, itemNumber in pairs(myCharItems[charId]) do
			cllAddEntry(itemLink, itemNumber)
		end
		if #cllPostSubList > 0 then cllAddEntry(nil, nil, true) end
		queuedSourceHeadline = false
	end
	if #cll.lootList > 0 then
		-- In whisperMode we won't change the channel because we assume that the player already has targetted a specific player for whispering. 
		-- But we will still check if the channel is correct when calling portionedChat!
		if cllMode.whisper == false then ZO_ChatWindowTextEntryEditBox:SetText("/party ") end
		textPortions = cll.lootList
		portionedChat(cllMode.channel)
	end
	
	cllPostAuxList = {}
	cllPostPerfectedList = {}
	cllFoundItems = {}
	cllAltItemLinks = {}
	cllPostSubList = {}
end

local function waechter()	
	-- The next routine is a guild intern joke, that hopefully won't show up for anyone else or slow down their process. 
	-- So don't mind the German chatter...
	local groupMembers = {}
	local numSorcs = 0
	local groupSize = GetGroupSize()
	if groupSize == 0 then return end
	for i=1, groupSize do
		local unitTag = "group"..i
		groupMembers[GetUnitDisplayName(unitTag) or ""] = true
		if GetUnitClass(unitTag) == 2 then numSorcs = numSorcs + 1 end
	end
	if groupMembers["@Orejana"] then   
		local wdz = {}
		local dateTable = os.date("*t", os.time())
		if dateTable.month == 2 and dateTable.day == 14 then
			local valentFuncs = {
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Blumen - für dich!", "\n|t124:124:esoui/art/icons/quest_summerset_rose_of_archon_blossom.dds|t", nil, nil, nil, nil, 4200) end,
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Ein Huhn von einem heimlichen Verehrer:", "\n|t124:124:esoui/art/icons/pet_spectralchicken.dds|t", nil, nil, nil, nil, 4200) end, 
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Blumen - für dich!", "\n|t124:124:esoui/art/icons/collectible_memento_sprigganaura002.dds|t", nil, nil, nil, nil, 4200) end, 
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Blumen - für dich!", "\n|t124:124:esoui/art/icons/achievement_jestersfestival_005.dds|t", nil, nil, nil, nil, 4200) end, 
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Ein Geschenk für dich!", "\n|t124:124:esoui/art/icons/achievement_midyearevent_005.dds|t", nil, nil, nil, nil, 4200) end, 
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Ein Herz - für dich!", "\n|t124:124:esoui/art/icons/passive_necromancer_008.dds|t", nil, nil, nil, nil, 4200) end, 
				function() CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.ITEM_ON_COOLDOWN, "Schnell, ein verwunschener Prinz!", "\n|t124:124:esoui/art/icons/quest_murkmire_moss_foot_croaker.dds|t", nil, nil, nil, nil, 4200) end,
			}
			local valentFunc = valentFuncs[math.random(1, #valentFuncs)]
			valentFunc()
		end
		
		if groupSize == 4 and groupMembers["@winterQueen"] and groupMembers["@DerOger91"] and groupMembers["@Irniben"] then
			wdz = {"Wah, ein Oger!", "Winter is coming.", "Some say loot: it is a river.", 
				"Loot schmeckt besser aus einem echten Reiskocher.", "Udo sagt, du musst noch üben, vorher gibts keinen Loot.", 
				"Loot: 24x |H1:item:68222:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hPaderborner Helles|h --> @DerOger91", "Daaaniel, das tötet Menschen...",
				"Manchmal drück ich einfach random Tasten.", "Wir haben eine Echse gefunden - dürfen wir sie verbrennen?",
				"Ihr laggt schon wieder.", "Romantisierend, cool, angenehm.", "Aufgeblasener Stößel-Stupser!",
				"Hier kommt der Servierwagen!", "Nicht genug |H1:item:77590:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hNachtschaten|h.",
				}
		elseif tonumber(os.date("%w", os.time())) == 2 then -- only for our tuesday group...
			wdz = {"Nehmt alles mit, was ihr in die Füße - äh - Hände kriegt!", 
				string.format("Nächste Woche auf dem Plan: |H1:achievement:2467:1:%s|h|h", os.time() + (3600*24*7)),
				string.format("Errungenschaft freigeschaltet: |H1:achievement:1069:1:%s|h[Bananenkönig]|h", os.time()),
				"Entscheide dich: Raucherpause oder Loot?", 
				}
			if groupMembers["@Robustum"] then table.insert(wdz, "Der Loot wäre sicher besser gewesen, hättet ihr zum richtigen Zeitpunkt Robustum geopfert.") end
		else
			wdz = {"Hier kann man übrigens reiten.", "Der heutige Loot wird ihnen präsentiert von: Seitenbacher.", "3, 2, 1... meins:",
			"Drachen, in eurer eigenen Heimat!", "Seht, was die Pfeile können, die ich gefunden habe!", "Gummibärn hüpfen hier und dort und überall..",
			"Dich hat die Gruppe verlassen.", "Loot ist wie Ohren, nur mit Quark.", "Hier könnte Ihre Werbung stehen!", "Caro repariert, Caro tauscht aus."}			
		end
		if groupMembers["@MuesliMan550"] then
			table.insert(wdz, "Drücke nun eine beliebige Taste, um all dein Gold an MuesliMan zu spenden.")
			table.insert(wdz, "Loot: 42x |H1:item:115028:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h --> @MuesliMan550")
			table.insert(wdz, "Wird die Rez-Ulti bei esologs eigentlich mitgezählt? Frage für einen Freund.")
		end
		local zoneId = GetUnitWorldPosition("player")
		if zoneId == 1344 then
			table.insert(wdz, zo_strformat("<<C:1>> - wir parshippen jetzt!", GetZoneNameById(zoneId)))
		elseif zoneId == 1000 then
			table.insert(wdz, "Festgelage und Siege sind nichts ohne leckere Schnittchen.") 
		end
		if numSorcs > 5 then 
			table.insert(wdz, string.format("Ab %s Zauberern in der Gruppe sinkt die Loot-Qualität.", numSorcs)) 
			table.insert(wdz, "Mit jedem Wipe sind die Tanks einen Schritt näher an der Errungenschaft |H1:achievement:960:100:1647271726|h|h!")
		end
		table.insert(wdz, "Machen wir uns nichts vor - den guten Loot bekommt sowieso Caro.")
		local myText = wdz[math.random(1, #wdz)]
		if myText then d(string.format("|c9e0911%s|r", myText)) end
	end
end

function cll.lootPost(args, arg2)
	local cllMode = getMode(args, arg2)
	lastUsedMode = cllMode
	if cllMode.writs and not cllMode.writsall and not WritWorthy then
		cllPost(GS(CLL_NoWW))
	end
	-- call the guild intern joke if applieable
	if GetGuildMemberIndexFromDisplayName(584562, GetUnitDisplayName("player")) then waechter()	end
	
	cll.lootList = {}
	postNumbers = {}
	
	-- the last two parameters are:
	-- -- "forceHeadline" which should not be true except for the bank
	-- -- "resetLists" which should always be true except for the subscriber bank
	queuedSourceHeadline = false
	if cllMode.bank then queuedSourceHeadline = zo_strformat("--- <<C:1>> ---", GS(SI_MAIN_MENU_INVENTORY)) end
	cllIterateAndPostBag(BAG_BACKPACK, cllMode, true, false)
	
	if cllMode.bank then
		queuedSourceHeadline = zo_strformat("--- <<C:1>> ---", GS(SI_CURRENCYLOCATION1))
		cllIterateAndPostBag(BAG_BANK, cllMode, true, true)
		cllIterateAndPostBag(BAG_SUBSCRIBER_BANK, cllMode, false, false)
		queuedSourceHeadline = false
	end
	
	-- only start the chat output if # > 0
	if #cll.lootList > 0 then
		-- In whisperMode we won't change the channel because we assume that the player already has targetted a specific player for whispering. 
		-- But we will still check if the channel is correct when calling portionedChat!
		if cllMode.whisper == false then ZO_ChatWindowTextEntryEditBox:SetText("/party ") end
		textPortions = cll.lootList
		if cll.sV and cll.sV.postMessage and cll.sV.personalMessage and not cllMode.recipe and not cllMode.motif and not cllMode.furniture and not cllMode.style and not cllMode.writs and not cllMode.whisper then
			table.insert(textPortions, cll.sV.personalMessage)
		end
		portionedChat(cllMode.channel)
	end
	
	cllPostAuxList = {}
	cllPostPerfectedList = {}
	cllFoundItems = {}
	cllAltItemLinks = {}
	cllPostSubList = {}
end

function cll.lootBind()
	local bagItems = GetBagSize(BAG_BACKPACK)
	local bagId = BAG_BACKPACK
	local boundItems = {}
	local cllDupclitates = {}
	for slotIndex=0, bagItems do
		local myLink = ""
		myLink = GetItemLink(bagId, slotIndex)
		--local itemType, specialItemType = GetItemLinkItemType(myLink)
		if IsItemLinkSetCollectionPiece(myLink) then
			if (not IsItemBound(bagId, slotIndex)) then
				if not (IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink))) then
					local hasSet, setName = GetItemLinkSetInfo(myLink) 
					setName = ZO_CachedStrFormat("<<C:1>>", setName)
					local mySetPiece = GetItemLinkEquipType(myLink)
					local myWeaponType = GetItemLinkWeaponType(myLink)
					if myWeaponType ~= WEAPONTYPE_NONE then mySetPiece = myWeaponType + 42 end
					boundItems[setName] = boundItems[setName] or {}
					if boundItems[setName][mySetPiece] then
						table.insert(cllDupclitates, myLink)
					else
						if cll.sV.listBoundItems then cllPost(string.format(GS(CLL_BindItem), myLink)) end
						BindItem(bagId, slotIndex)
					end
					boundItems[setName][mySetPiece] = true
				end
			end
		end
	end
	--if #cllDupclitates > 0 then d("Duplicates:") end
	--for i, v in pairs(cllDupclitates) do
	--		d(v)
	--end
	--cll.testList = boundItems
end


local function formatDeconLink(myText, myIndex, hexColor)
	return string.format("|c%s|H1:clldecon:%s|h%s|h|r", hexColor, myIndex, myText)
		
end

function cll.addExtendTextLink(myText, hexColor, textArray)
	local myIndex = #deconLists + 1
	deconLists[myIndex] = textArray
	return formatDeconLink(zo_strformat(myText, #textArray), myIndex, hexColor)
end

function cll.linkHandler(rawLink, mouseButton, linkText, linkStyle, linkType, myIndex) --everything after linktType is the data
	  if linkType == "clldecon" then
			myIndex = tonumber(myIndex)
			if myIndex == nil then return true end
			if deconLists[myIndex] == false then return true end
			for i, v in pairs(deconLists[myIndex]) do
				d(v)
			end
		return true
	  end
end

function cll.lootBindPost(arg)
	cll.lootBind()
	zo_callLater(function() cll.lootPost(arg) end, 1000)
end


function cll.info()

	d(GS(CLL_InfoHead))
	local myIndex = 1 -- Remember to add empty entries in the beginning when having more than 10 entries for info
	local myText = {}
	local myFormat = zo_strformat("|c<<1>>%s|r - |c<<2>>%s|r", myAccentColor, myTextColor)
	
	myText = {
		string.format(myFormat, "/caroloot", GS(CLL_InfoSlashCommandsPost)),
		string.format(myFormat, "/carolootall", GS(CLL_InfoSlashCommandsPostAll)),
		string.format(myFormat, "/carolootw", GS(CLL_InfoSlashCommandsPostW)),
		string.format(myFormat, "/carolootnoarmor", GS(CLL_InfoSlashCommandsPostNoArmor)),
		string.format(myFormat, "/carobind", GS(CLL_InfoSlashCommandsBind)),
		string.format(myFormat, "/carobp", GS(CLL_InfoSlashCommandsBP)),		
		string.format(myFormat, "/carobpc", GS(CLL_InfoSlashCommandsBPC)),		
	}
	deconLists[myIndex] = myText
	d(formatDeconLink(GS(CLL_InfoHeadSlashCommandsPost), myIndex, "9e0911"))
	
	myText = {
		string.format(myFormat, "/carolootmotif", GS(CLL_InfoSlashCommandsMotif)),
		string.format(myFormat, "/carolootrecipe", GS(CLL_InfoSlashCommandsRecipe)),
		string.format(myFormat, "/carolootfurniture", GS(CLL_InfoSlashCommandsFurniture)),
		string.format(myFormat, "/carolootcrafting", GS(CLL_InfoSlashCommandsCrafting)),
		"--- --- ---",
		string.format(myFormat, "/carolootstyle", GS(CLL_InfoSlashCommandsStyle)),
		"--- --- ---",
		string.format(myFormat, "/caroloothousebank", GS(CLL_InfoSlashCommandsHousebank)),
		string.format(myFormat, "/carolootchars", GS(CLL_InfoSlashCommandsChars)),
		"--- --- ---",
		string.format(myFormat, "/carolootwrits", GS(CLL_InfoSlashCommandsWrits)),
	}
	
	myIndex = myIndex + 1
	deconLists[myIndex] = myText
	d(formatDeconLink(GS(CLL_InfoHeadSlashCommandsPostMore), myIndex, "9e0911"))

	myText = {
		string.format(myFormat, "/carobank", GS(CLL_InfoSlashCommandsBank)),
		string.format(myFormat, "/carobankother", GS(CLL_InfoSlashCommandsBankOther)),
		string.format(myFormat, "/carobankall", GS(CLL_InfoSlashCommandsBankAll)),
	}
	myIndex = myIndex + 1
	deconLists[myIndex] = myText
	d(formatDeconLink(GS(CLL_InfoHeadSlashCommandsBank), myIndex, "9e0911"))
	
	myText = {
		string.format(myFormat, "/carodecon", GS(CLL_InfoSlashCommandsDecon)),
		string.format(myFormat, "/carodeconall", GS(CLL_InfoSlashCommandsDeconAll)),
	}
	
	myIndex = myIndex + 1
	deconLists[myIndex] = myText
	d(formatDeconLink(GS(CLL_InfoHeadSlashCommandsDecon), myIndex, "9e0911"))
	
	myIndex = myIndex + 1
	deconLists[myIndex] = {zo_strformat(GS(CLL_InfoDeconstruction), myAccentColor, myTextColor)}
	d(formatDeconLink(GS(CLL_InfoHeadDeconstruction), myIndex, "9e0911"))
	
	myText = {
		string.format(myFormat, "LibAddonMenu & Lib Custom Menu", GS(CLL_InfoMoreAddonsLAMLCM)),
		string.format(myFormat, "WritWorthy", GS(CLL_InfoMoreAddonsWritWorthy)),
		string.format(myFormat, "Inventory Insight", GS(CLL_InfoMoreAddonsIIfA)),
		"--- --- ---",
		string.format(myFormat, "Set Collection Marker (Sticker Book)", GS(CLL_InfoMoreAddonsSetCollectionMarkerStickerBook)),
		string.format(myFormat, "Caro`s CraftStore Marker Extension", GS(CLL_InfoMoreAddonsCarosCraftStoreMarkerExtension)),
	}
	myIndex = myIndex + 1
	deconLists[myIndex] = myText
	d(formatDeconLink(GS(CLL_InfoHeadMoreAddons), myIndex, "9e0911"))
	
end

 SLASH_COMMANDS["/carolootinfo"] = cll.info
 SLASH_COMMANDS["/caroloot"] = cll.lootPost
 SLASH_COMMANDS["/carolootall"] = function() cll.lootPost("all") end
 SLASH_COMMANDS["/carolootw"] = function() cll.lootPost("whisperMode") end
 SLASH_COMMANDS["/carolootnoarmor"] = function() cll.lootPost("noArmor") end
 SLASH_COMMANDS["/carolootcurrent"] = function() cll.lootPost("current") end
 SLASH_COMMANDS["/carobind"] = cll.lootBind
 SLASH_COMMANDS["/carobp"] = cll.lootBindPost
 SLASH_COMMANDS["/carobpc"] = function() cll.lootBindPost("current") end
 SLASH_COMMANDS["/carobank"] = function() cll.depositItems(true, false) end
 SLASH_COMMANDS["/carobankall"] = function() cll.depositItems(true, true) end
 SLASH_COMMANDS["/carobankother"] = function() cll.depositItems(false, true) end
 SLASH_COMMANDS["/carodecon"] = function() cll.checkCraftRefinement(cll.deconstruct) end
 SLASH_COMMANDS["/carorefine"] = function() cll.checkCraftRefinement(cll.refine, true) end
 SLASH_COMMANDS["/carodeconall"] = function() cll.checkCraftRefinement(function() cll.deconstruct("true") end) end
 SLASH_COMMANDS["/carolootcrafting"] = function() cll.lootPost("crafting") end
 SLASH_COMMANDS["/carolootfurniture"] = function() cll.lootPost("furniture") end
 SLASH_COMMANDS["/carolootstyle"] = function() cll.lootPost("style") end
 SLASH_COMMANDS["/carolootrecipe"] = function() cll.lootPost("recipe") end
 SLASH_COMMANDS["/carolootmotif"] = function() cll.lootPost("motif") end
 SLASH_COMMANDS["/caroloothousebank"] = function() cll.allChars("true") end
 SLASH_COMMANDS["/carolootchars"] = cll.allChars
 SLASH_COMMANDS["/carolootwrits"] = function(args) 
	if args == "all" then 
		cll.lootPost("writsall") 
	else 
		args = tonumber(args) 
		if args then
			cll.lootPost("writs", args) 
		else
			cll.lootPost("writs") 
		end
	end
 end


local function cllShowInfoTT(control)

	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(string.format("|c%sCaro's Loot List|r", myAccentColor), "ZoFontWinH2")
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipRStart), os.date("%c", cll.sV.counterStart)), "ZoFontGame")
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipPosted), "esoui/art/chatwindow/chat_notification_up.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.postCount))), "ZoFontGame")
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipTransferred), "esoui/art/tooltips/icon_bank.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.transferCount))), "ZoFontGame")
	if HasCraftBagAccess() then
		InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipTransferredCB), "esoui/art/inventory/inventory_tabicon_craftbag_up.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.matTransferCount))), "ZoFontGame")
	end
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipLearned), "esoui/art/inventory/inventory_tabicon_recipe_up.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.autoLearnCount))), "ZoFontGame")
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipDeconstructed), "esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.deconCount))), "ZoFontGame")
	InformationTooltip:AddLine(string.format(GS(CLL_InfoTooltipRefined), "esoui/art/crafting/smithing_tabicon_refine_up.dds", ZO_FastFormatDecimalNumber(ZO_CommaDelimitNumber(cll.sV.refineCount))), "ZoFontGame")
	
end

function cll.Initialize()

	--Setup the custom links to post lists of the deconstructed items
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, cll.linkHandler)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT,  cll.linkHandler) 
	
	--Setup SavedVars
	local serverName = GetWorldName()
	cll.sV = ZO_SavedVars:NewAccountWide("CarosLootListSavedVariables", 1, nil, {}, serverName) -- account wide
	
	if not LibCustomMenu then return end
	local LAM = LibAddonMenu2
	if not LAM then return end
	
	cll.sV.buttonOffset = cll.sV.buttonOffset or 0
	cll.sV.showButton =  cll.sV.showButton or false
	cll.sV.writLimit = cll.sV.writLimit or 900
	cll.sV.lastFunctions = cll.sV.lastFunctions or {}
	cll.sV.lastFunctions2 = cll.sV.lastFunctions2 or {}
	cll.sV.lastFunctions3 = cll.sV.lastFunctions3 or {}
	cll.sV.lastFunctions4 = cll.sV.lastFunctions4 or {}
	
	cll.sV.recipePriceFilter = cll.sV.recipePriceFilter or false
	cll.sV.recipePriceFilterChars = cll.sV.recipePriceFilterChars or {}
	
	cll.sV.counterStart = cll.sV.counterStart or os.time()
	cll.sV.deconCount = cll.sV.deconCount  or 0
	cll.sV.refineCount = cll.sV.refineCount or 0
	cll.sV.transferCount = cll.sV.transferCount or 0
	cll.sV.postCount = cll.sV.postCount or 0
	cll.sV.autoLearnCount = cll.sV.autoLearnCount or 0
	cll.sV.matTransferCount = cll.sV.matTransferCount or 0
	cll.sV.cbLimitAmount = cll.sV.cbLimitAmount or 50
	cll.sV.sameForAllHousingChests = cll.sV.sameForAllHousingChests or false
	
	local cllButton = cll.cllButton
	cllButton()
	
	local panelData = {
		type = "panel",
		name = "Caro's Loot List",
		displayName = "|c9e0911Caro|r's Loot List",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	
	local optionsData = {
		
		{ 
			type = "button",
			name = "Info",
			func = function() cllShowInfoTT(CLLInfoButton) end,
			width = "full",
			reference = "CLLInfoButton",
		},
		{
			type = "divider",
			width = "full",
		},
		{
			type = "checkbox",
			name = GS(CLL_LAM_ShowButton), 
			width = "full",
			getFunc = function() return cll.sV.showButton end,
			setFunc = function(value) cll.sV.showButton = value cllButton() end,
		},
		{
			type = "slider",
			name = GS(CLL_LAM_ButtonOffset),
			min = 0,
			max = 330,
			step = 33, --(optional)
			--clampInput = true, 
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
			decimals = 0, 
			autoSelect = true,
			width = "full",
			getFunc = function() return cll.sV.buttonOffset  end,
			setFunc = function(value) cll.sV.buttonOffset = value cllButton() end,
			disabled = function() return not cll.sV.showButton end,
		},
		{
			type = "checkbox",
			name = GS(CLL_LAM_SameForAll), 
			tooltip = GS(CLL_LAM_SameForAll),
			width = "full",
			getFunc = function() return cll.sV.sameForAllHousingChests end,
			setFunc = function(value) cll.sV.sameForAllHousingChests = value end,
		},
		{
			type = "divider",
		},
		{ 
			type = "checkbox",
			name = GS(CLL_LAM_PostMessage),
			tooltip = GS(CLL_LAM_PostMessage),
			getFunc = function() return cll.sV.postMessage or false end,
			setFunc = function(value) cll.sV.postMessage = value end,
		},
		{
			type = "editbox",
			name = GS(CLL_LAM_MyMessage),
			tooltip = GS(CLL_LAM_MyMessage),
			maxchars = 300,
			width = "full",
			getFunc = function() return cll.sV.personalMessage or "" end,
			setFunc = function(value) cll.sV.personalMessage = value end,
			disabled = function() return not cll.sV.postMessage end,
		},
		{
			type = "divider",
			width = "full",
		},
		{
			type = "checkbox",
			name = GS(CLL_LAM_ShowBoundItems), 
			width = "full",
			getFunc = function() return cll.sV.listBoundItems or false end,
			setFunc = function(value) cll.sV.listBoundItems = value end,
		},
		
		
	}
	
	if WritWorthy then 
		table.insert(optionsData, 
		{
			type = "divider",
		})
		table.insert(optionsData, 
		{
			type = "slider",
			name = GS(CLL_LAM_WritLimit),
			tooltip = GS(CLL_LAM_WritLimit),
			min = 400,
			max = 1200,
			step = 50, --(optional)
			--clampInput = true, 
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
			decimals = 0, 
			autoSelect = true,
			width = "full",
			getFunc = function() return cll.sV.writLimit  end,
			setFunc = function(value) cll.sV.writLimit = value end,
		})
	end
	
	local deconSubMenu = {
		type = "submenu",
			name = GS(SI_DECONSTRUCTACTIONNAME2), 
			icon = "esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
			width = "full", 
			controls = {
		}
	}
	if CCMG or LibPrice then 
		if CCMG then
			table.insert(deconSubMenu.controls, 
			{
				type = "checkbox",
				name = GS(CLL_LAM_DeconCCMG),
				tooltip = GS(CLL_LAM_DeconCCMG),
				width = "full",
				getFunc = function() return cll.sV.deconCCMG or false  end,
				setFunc = function(value) cll.sV.deconCCMG = value end,
			})
		end
		if LibPrice then
			table.insert(deconSubMenu.controls, 
			{
				type = "slider",
				name = GS(CLL_LAM_DeconPrice),
				tooltip = GS(CLL_LAM_DeconPrice),
				min = 0,
				max = 8000,
				step = 500, --(optional)
				--clampInput = true, 
				--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				getFunc = function() return cll.sV.deconPrice or 0  end,
				setFunc = function(value) cll.sV.deconPrice = value end,
			})
		end
		table.insert(deconSubMenu.controls, 
			{
				type = "divider",
			})
	end

	cll.sV.includeDeconTraits = cll.sV.includeDeconTraits or {}
	local traitCategories = {	
		[ITEM_TRAIT_TYPE_CATEGORY_ARMOR] = GS(SI_SMITHINGFILTERTYPE4),
		[ITEM_TRAIT_TYPE_CATEGORY_JEWELRY] = GS(SI_SMITHINGFILTERTYPE6),
		[ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = GS(SI_SMITHINGFILTERTYPE2),
	}
	
	for _, traitId in pairs(deconTraits) do
		local traitName = GS("SI_ITEMTRAITTYPE", traitId)
		local traitTypeCat = GetItemTraitTypeCategory(traitId)
		traitName = traitCategories[traitTypeCat] and string.format("%s (%s)", traitName, traitCategories[traitTypeCat]) or traitName
		table.insert(deconSubMenu.controls, 
			{
				type = "checkbox",
				name = traitName,
				tooltip = traitName,
				width = "half",
				getFunc = function() return cll.sV.includeDeconTraits[traitId] or false  end,
				setFunc = function(value) cll.sV.includeDeconTraits[traitId] = value end,
			})
	end	
	
	table.insert(optionsData, deconSubMenu)

	if CraftStoreFixedAndImprovedLongClassName and LibPrice then
		table.insert(optionsData, {
			type = "submenu",
			name = GS(CLL_LAM_RecipesAndMotifs), 
			icon = "esoui/art/inventory/inventory_tabicon_recipe_up.dds",
			width = "full", 
			controls = {
				{
					type = "description",
					text = GS(CLL_LAM_RetrieveDescription),
				},
				{
					type = "slider",
					name = GS(CLL_LAM_RetrievePriceLimit),
					min = 0,
					max = 10000,
					step = 100, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					getFunc = function() return cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] or cll.sV.recipePriceFilter or 0 end,
					setFunc = function(value) 
						if cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] then
							cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] = value
						else
							cll.sV.recipePriceFilter = value
						end
					end,
				}, 
				{
					type = "checkbox",
					name = GS(CLL_LAM_RetrievePriceCharSpecific),
					width = "full",
					getFunc = function() return cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] ~= nil end,
					setFunc = function(value) 
						if value then 
							cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] = cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] or cll.sV.recipePriceFilter
						else
							cll.sV.recipePriceFilterChars[GetCurrentCharacterId()] = nil
						end
					end,
				},
				{
					type = "divider",
				},
				{
					type = "header",
					text = GS(SI_GAMEPAD_GUILD_HEADER_GUILD_SERVICES_BANK),
				},
				{
					type = "checkbox",
					name = GS(CLL_LAM_GuildBankShow),
					width = "full",
					warning = GS(CLL_LAM_GuildStoreDisclaimer),
					getFunc = function() return cll.sV.showOptionOnGuildBank end,
					setFunc = function(value) cll.sV.showOptionOnGuildBank = value	end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_RetrievePriceLimitGuildBank),
					min = 0,
					max = 10000,
					step = 100, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					getFunc = function() return cll.sV.recipePriceFilterGuildBank or 0 end,
					setFunc = function(value) cll.sV.recipePriceFilterGuildBank = value end,
					disabled = function() return not cll.sV.showOptionOnGuildBank end,
				}, 
			}
		})
	end

	if HasCraftBagAccess() then
		cll.sV.cbExclude = cll.sV.cbExclude or {		
			[75365] = true,
			[64501] = true, 
			["raw"] = true,
			["bait"] = true, 
		}
		local craftingItemLink =  "|H0:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
		local craftingBagOptions = {
			type = "submenu",
			name = GS(CLL_LAM_CB), 
			icon = "esoui/art/inventory/inventory_tabicon_craftbag_up.dds",
			width = "full", 
			controls = {
				{
					type = "description",
					text = GS(CLL_LAM_CB_Descr),
				},
				{
					type = "header",
					name = GS(CLL_LAM_CB_Limit),
					width = "full",
				},	
				{
					type = "slider",
					name = GS(CLL_LAM_CB_LimitProvAlch),
					tooltip = GS(CLL_LAM_CB_LimitProvAlch),
					min = 100,
					max = 5000,
					step = 100, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 300,
					getFunc = function() return cll.sV.cbLimitProvAlch or 300 end,
					setFunc = function(value) cll.sV.cbLimitProvAlch = value end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_CB_LimitOther),
					tooltip = GS(CLL_LAM_CB_LimitOther),
					min = 100,
					max = 5000,
					step = 100, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 300,
					getFunc = function() return cll.sV.cbLimitOther or 1000 end,
					setFunc = function(value) cll.sV.cbLimitOther = value end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_CB_LimitGolden),
					tooltip = GS(CLL_LAM_CB_LimitGolden),
					min = 50,
					max = 2000,
					step = 50, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 100,
					getFunc = function() return cll.sV.cbLimitGolden or 1000 end,
					setFunc = function(value) cll.sV.cbLimitGolden = value end,
				},
				{
					type = "header",
					name = GS(CLL_LAM_CB_Filter),
					width = "full",
				},	
				{
					type = "checkbox", -- alcahest
					name = string.format(craftingItemLink, 75365),
					width = "half",
					getFunc = function() return cll.sV.cbExclude[75365] end,
					setFunc = function(value) cll.sV.cbExclude[75365] = value end,
				},
				{
					type = "checkbox", -- lorkhan
					name = string.format(craftingItemLink, 64501),
					width = "half",
					getFunc = function() return cll.sV.cbExclude[64501] end,
					setFunc = function(value) cll.sV.cbExclude[64501] = value end,
				},
				{
					type = "checkbox", -- raw material
					name = GS(SI_ITEMTYPE63),
					width = "half",
					getFunc = function() return cll.sV.cbExclude["raw"] end,
					setFunc = function(value) cll.sV.cbExclude["raw"] = value end,
				},
				{
					type = "checkbox", -- bait
					name = GS(SI_ITEMTYPE16),
					width = "half",
					getFunc = function() return cll.sV.cbExclude["bait"] end,
					setFunc = function(value) cll.sV.cbExclude["bait"] = value end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_CB_StackSizeGolden),
					tooltip = GS(CLL_LAM_CB_StackSizeGolden),
					min = 8,
					max = 200,
					step = 8, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 16,
					getFunc = function() return cll.sV.cbGoldenStacks or 16 end,
					setFunc = function(value) cll.sV.cbGoldenStacks = value end,
				},

				{
					type = "divider",
				},
				{	
					type = "dropdown",
					name = GS(CLL_LAM_CB_Sort), 
					width = "full",
					choices = {GS(CLL_LAM_CB_SortAlph), GS(CLL_LAM_CB_SortAmount), GS(CLL_LAM_CB_SortPriceUp), GS(CLL_LAM_CB_SortPriceDown), GS(CLL_LAM_CB_SortStackPriceUp), GS(CLL_LAM_CB_SortStackPriceDown)},
					choicesValues = {1,2,3, 4, 5, 6},
					default = 1,
					getFunc = function() return cll.sV.cbSort or 1 end,
					setFunc = function(value) cll.sV.cbSort = value end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_CB_MaxiNum),
					tooltip = GS(CLL_LAM_CB_MaxiNum),
					min = 10,
					max = 150,
					step = 10, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 50,
					getFunc = function() return cll.sV.cbLimitAmount or 50 end,
					setFunc = function(value) cll.sV.cbLimitAmount = value end,
				},
				{
					type = "slider",
					name = GS(CLL_LAM_CB_MaxiIdent),
					tooltip = GS(CLL_LAM_CB_MaxiIdent),
					min = 0,
					max = 42,
					step = 1, --(optional)
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 0,
					getFunc = function() return cll.sV.cbLimitIdentical or 0 end,
					setFunc = function(value) cll.sV.cbLimitIdentical = value end,
				},
			}
		}
		table.insert(optionsData, craftingBagOptions)
	end
	LAM:RegisterAddonPanel("cllOptions", panelData)
	LAM:RegisterOptionControls("cllOptions", optionsData)
	
end

function cll.OnAddOnLoaded(event, addonName)
	if addonName == cll.name then
		EVENT_MANAGER:UnregisterForEvent(cll.name.."OnLoad", EVENT_ADD_ON_LOADED)
		cll.Initialize()
	end
end

 
EVENT_MANAGER:RegisterForEvent(cll.name.."OnLoad", EVENT_ADD_ON_LOADED, cll.OnAddOnLoaded)