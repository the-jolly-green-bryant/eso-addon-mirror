local GS = GetString
local cll = CarosLootList

local myAccentColor = "9e0911"
local myTextColor = "1d6dad"

local cllD = cll.cllD
local cllPost = cll.cllPost

function cll.checkCraftRefinement(myFunc, refineMode)
	local craft = GetCraftingInteractionType()

	local passiveSkills = {
		[CRAFTING_TYPE_ENCHANTING] = 46769,
		[CRAFTING_TYPE_WOODWORKING] = 48180,
		[CRAFTING_TYPE_BLACKSMITHING] = 48165,
		[CRAFTING_TYPE_CLOTHIER] = 48195,
		[CRAFTING_TYPE_JEWELRYCRAFTING] = 103645,
	}
	
	local myText = {}
	
	for singleCraft, passiveSkill in pairs(passiveSkills) do
		if craft == 0 or craft == singleCraft then
			local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(passiveSkill)
			local passiveName, passiveIcon, _, _, _, purchased, _, rank = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)         
			local hasPassive = purchased and GetNumPassiveSkillRanks( skillType, skillLineIndex, skillIndex) <= rank 	
			if not hasPassive then table.insert(myText, zo_strformat(GS(CLL_Ask_CraftingPassive), passiveIcon, passiveName)) end
		end
	end
	
	if #myText > 0 then 
		
		if refineMode then table.insert(myText, GS(CLL_Ask_CraftingRefine)) else table.insert(myText, GS(CLL_Ask_CraftingDecon)) end

		ESO_Dialogs["CLLDeconConfirmFunction"] = {
			canQueue = true,
			uniqueIdentifier = "CLLDeconConfirmFunction",
			title = {text = "|c9e0911Caro's Loot List|r"},
			mainText = {text = table.concat(myText, "\n")},
			buttons = {
				[1] = {
					text = SI_DIALOG_YES,
					callback = function() myFunc() end,
				},
				[2] = {
					text = SI_DIALOG_NO,
					callback = function() end,
				},
			},
			setup = function() end,
		}
		ZO_Dialogs_ShowDialog("CLLDeconConfirmFunction")
	else
		myFunc()
	end
end


function cll.refine()
	local craft = GetCraftingInteractionType()
	if craft == 0 then return end
	local reqSize = GetRequiredSmithingRefinementStackSize()
	local function checkItemRefine(bagId, slotIndex)
		local _, stack = GetItemInfo(bagId, slotIndex)
		if not CanItemBeRefined(bagId, slotIndex, craft) then return false end
		if stack >= reqSize then
			return math.floor(stack/reqSize) * reqSize
		end
		return false
	end

	local virtualSlotId = GetNextVirtualBagSlotId()
	local myRefineList = {}
	local myRefineSum = 0
	PrepareDeconstructMessage()
	while virtualSlotId ~= nil do
		virtualSlotId =  GetNextVirtualBagSlotId(virtualSlotId)
		local stack = checkItemRefine(BAG_VIRTUAL, virtualSlotId)
		if stack then 
			table.insert(myRefineList, string.format("%sx %s", stack, GetItemLink(BAG_VIRTUAL, virtualSlotId)))
			myRefineSum = myRefineSum + stack
			AddItemToDeconstructMessage(BAG_VIRTUAL, virtualSlotId, stack) 
		end
	end
	if myRefineSum > 0 then
	  if SendDeconstructMessage() then
		
		local myText = zo_strformat(GS(CLL_RefineItems), 0)
		cll.sV.refineCount = cll.sV.refineCount + myRefineSum
		if #myRefineList > 0 then 
			myText = cll.addExtendTextLink(zo_strformat(GS(CLL_RefineItems), myRefineSum), myAccentColor, myRefineList)
		end
		
		cllPost(string.format(GS(CLL_Refined), myText, myTextColor)) 
		EVENT_MANAGER:RegisterForEvent("CLL_REFINE_SUCCESS", EVENT_CRAFT_COMPLETED, 
			function()
				--d(GetNumLastCraftingResultItemsAndPenalty())
				local numResults = GetNumLastCraftingResultItemsAndPenalty()
				for resultIndex=1, numResults do
					local _, _, stack, _, _, _, _, _, itemQuality = GetLastCraftingResultItemInfo(resultIndex)
					if itemQuality == ITEM_QUALITY_LEGENDARY then
						local resultingItemLink = GetLastCraftingResultItemLink(resultIndex)
						--d(stack.."x "..resultingItemLink)
					end
				end
			EVENT_MANAGER:UnregisterForEvent("CLL_REFINE_SUCCESS", EVENT_CRAFT_COMPLETED)
		end)
	
	  else
		--d("Message failed...")
	  end
	end
end

function cll.deconstruct(deconIntricates, glyphQuality, intricatesOnly)
	deconIntricates = deconIntricates == "true"
	if GetInteractionType() ~= INTERACTION_CRAFT then cllPost(GS(CLL_DeconStation)) return end
	local stationCraftType = GetCraftingInteractionType()
	local universalDecon = stationCraftType == CRAFTING_TYPE_INVALID
	local validCrafts = {
		[CRAFTING_TYPE_BLACKSMITHING] = true,
		[CRAFTING_TYPE_CLOTHIER] = true,
		[CRAFTING_TYPE_ENCHANTING] = true,
		[CRAFTING_TYPE_JEWELRYCRAFTING] = true,
		[CRAFTING_TYPE_WOODWORKING] = true,
	}
	if stationCraftType == CRAFTING_TYPE_ALCHEMY or stationCraftType == CRAFTING_TYPE_PROVISIONING then return end
	if stationCraftType == CRAFTING_TYPE_ENCHANTING and not glyphQuality then return end
	local myBags = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	local doBanks = SMITHING and SMITHING.deconstructionPanel and SMITHING.deconstructionPanel.savedVars and SMITHING.deconstructionPanel.savedVars.includeBankedItemsChecked or false
	if not doBanks then myBags = {BAG_BACKPACK} end
	local bagText = {GS(SI_MAIN_MENU_INVENTORY), GS(SI_GAMEPAD_BANK_CATEGORY_HEADER), GS(SI_GAMEPAD_BANK_CATEGORY_HEADER)}
	local freeSpace = 0
	for i, v in pairs(myBags) do
		freeSpace = freeSpace + GetNumBagFreeSlots(v)
	end
	local myDeconList = {}
	PrepareDeconstructMessage()
	local deconNumber = 0
	
	local filterTraits = {}
	
	for _, traitId in pairs(cll.deconTraits) do
		filterTraits[traitId] = not cll.sV.includeDeconTraits[traitId]
	end
	
	local intricateTraits = {
		[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = true,
		[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
		[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = true,
	}
	local itemIdFilter = 
		{[68343] = true, [68344] = true, --Hakeijo
		[166046] = true,  [166047] = true -- Indeko
	} 
	
	local function checkItem(theBag, slotIndex)
		if IsItemPlayerLocked(theBag, slotIndex) then return false end
		
		local itemCraftingType = GetRearchLineInfoFromRetraitItem(theBag, slotIndex)
		
		local glyphTypes = {
			[ITEMTYPE_GLYPH_ARMOR] = true,
			[ITEMTYPE_GLYPH_JEWELRY] = true,
			[ITEMTYPE_GLYPH_WEAPON] = true,
		}
		
		local myItemType = GetItemType(theBag, slotIndex)
		
		if glyphTypes[myItemType] then itemCraftingType = CRAFTING_TYPE_ENCHANTING end
		
		if itemCraftingType ~= stationCraftType and not universalDecon then return false end		
		if universalDecon then
			if not validCrafts[itemCraftingType] then return false end
			if itemCraftingType == CRAFTING_TYPE_ENCHANTING and not glyphQuality then return false end
		end
		
		if FCOIS and FCOIS.IsDeconstructionLocked(theBag, slotIndex) then return false end
		
		local myLink = GetItemLink(theBag, slotIndex)
		local myType = GetItemType(theBag, slotIndex)
		
		if IsItemLinkCrafted(myLink) then return false end
		
		if IsItemLinkReconstructed(myLink) then return false end
		
		if LibPrice and cll.sV.deconPrice and cll.sV.deconPrice > 0 then
			local myPrice = LibPrice.ItemLinkToPriceGold(myLink)
			if not myPrice or myPrice == 0 or myPrice > cll.sV.deconPrice then return false end
		end

		if itemCraftingType == CRAFTING_TYPE_ENCHANTING and glyphQuality then 
			if GetItemLinkQuality(myLink) >= glyphQuality then return false end
			
			local itemIdFilter = {[68343] = true, [68344] = true, [166046] = true,  [166047] = true} --Hakeijo, Indeko
			if itemIdFilter[GetItemLinkItemId(myLink)] then return false end
			
			return myLink
		else 
			if GetItemLinkQuality(myLink) >= 5 then return false end
		end
		
		
		local myTrait = GetItemTrait(theBag, slotIndex)
		if filterTraits[myTrait] then return false end
		
		local myFilterType = {GetItemLinkFilterTypeInfo(myLink)}
		for i, v in pairs(myFilterType) do
			if v == ITEMFILTERTYPE_COMPANION then return false end
		end
		
		if CCMG and cll.sV.deconCCMG then
			if CCMG.checkItem(theBag, slotIndex, true) then return false end
		end
		
		if intricateTraits[myTrait] and not deconIntricates then return false end
		if intricatesOnly and not intricateTraits[myTrait] then return false end
						
		return myLink
	end
	
	for bagIndex, theBag in pairs(myBags) do
		for slotIndex=0, GetBagSize(theBag) do
			local myLink = checkItem(theBag, slotIndex)
			if myLink then
				if AddItemToDeconstructMessage(theBag, slotIndex, 1) then
					deconNumber = deconNumber + 1
					table.insert(myDeconList, {myLink, bagText[bagIndex], theBag, slotIndex})
				else
					cllPost(string.format(GS(CLL_DeconFail), myLink))
				end
			end
		end
	end
	if SendDeconstructMessage() then 
		zo_callLater(function()
			local myText = zo_strformat(GS(CLL_DeconItems), 0)
			if #myDeconList > 0 then 
				local deconTexts = {}
				for i, v in pairs(myDeconList) do
					if GetItemLink(v[3], v[4]) == v[1] then
						myDeconList[i] = nil
					else
						table.insert(deconTexts, string.format("%s (%s)", v[1], v[2]))
						cll.sV.deconCount = cll.sV.deconCount + 1
					end
				end 
				myText = cll.addExtendTextLink(GS(CLL_DeconItems), myAccentColor, deconTexts)
			end
			cllPost(string.format(GS(CLL_Deconstructed), myText, myTextColor)) 

		end, 1000)
	else
		--d("Message failed...")
	end
end

