local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local SKDI = SK.Data.itemsData
local EM, SM, SDM = EVENT_MANAGER, SCENE_MANAGER, SKILLS_DATA_MANAGER

SK.CraftStation = ZO_Object:Subclass()

function SK.CraftStation:New()
	local obj = ZO_Object.New(self)
	obj.craftStationActionsStack = {}
	obj.closeDialogAfterAction = false
	return obj
end

function SK.CraftStation:Init()
	EM:RegisterForEvent("SK_CraftStations_Automation", EVENT_CRAFTING_STATION_INTERACT,
		function(_, craftingType) self:StartInteract(craftingType) end)
	EM:RegisterForEvent("SK_CraftStations_Automation", EVENT_CRAFT_COMPLETED,
		function(_, craftingType) self:NextAction(craftingType) end)
end

function SK.CraftStation:StartInteract(craftingType)
	if IsAwaitingCraftingProcessResponse() then return end
	local canRefine = SKH.isValueInList(SKDC.TRADE_SKILL_TYPE_REFINE, craftingType)
	local canDeconstruct = SKH.isValueInList(SKDC.TRADE_SKILL_TYPE_DECONSTRUCT, craftingType)
	local canFilletFish = craftingType == CRAFTING_TYPE_PROVISIONING
	self.craftStationActionsStack = {}
	self.closeDialogAfterAction = false
	if canRefine and SK.savedVars.autoRefineRawMaterial and ((SK.savedVars.autoRefineIfESOPlus and IsESOPlusSubscriber()) or
		not SK.savedVars.autoRefineIfESOPlus)
	then
		SKH.setTableChild(self.craftStationActionsStack, {"refineRawMaterial", "f"}, self["refineRawMaterial"])
	end
	if canDeconstruct and (SK.savedVars.deconstructUnwantedSetsByQuality or (FCOIS and SK.savedVars.autoDeconstructFCOISMarked) or
		SK.savedVars.useIntricateForCraftTraining or SK.savedVars.useGlyphsForCraftTraining)
	then
		SKH.setTableChild(self.craftStationActionsStack, {"deconstructItems", "f"}, self["deconstructItems"])
	end
	if canFilletFish and SK.savedVars.autoFilletFish then
		SKH.setTableChild(self.craftStationActionsStack, {"filletFish", "f"}, self["filletFish"])
	end
	self:NextAction(craftingType)
end

function SK.CraftStation:NextAction(craftingType)
	if IsAwaitingCraftingProcessResponse() then return end
	for _, v in pairs(self.craftStationActionsStack) do
		v.f(self, craftingType)
		return
	end
	if self.closeDialogAfterAction and SK.savedVars.isCloseCraftStationAfterDeconstruction then SM:ShowBaseScene() end
end

function SK.CraftStation:filletFish(craftingType)
	if SK.savedVars.debugMode then d("==== filletFish ====") end
	self.craftStationActionsStack.filletFish = nil
	local isDeconstructed
	local bagId = BAG_BACKPACK
	local chatItemList = {}
	PrepareDeconstructMessage()
	for slotIndex in ZO_IterateBagSlots(bagId) do
		local isFish = GetItemUseType(bagId, slotIndex) == ITEM_USE_TYPE_FILLET_FISH
		if isFish then
			local itemLink = GetItemLink(bagId, slotIndex)
			local quantity = GetSlotStackSize(bagId, slotIndex)
			if SK.savedVars.debugMode then d("itemLink "..itemLink) end
			if AddItemToDeconstructMessage(bagId, slotIndex, quantity) then
				table.insert(chatItemList, itemLink)
				isDeconstructed = true
			end
		end
	end
	if SK.savedVars.debugMode then
		d("debug mode enabled - fake proceed")
	elseif isDeconstructed then
		self.closeDialogAfterAction = true
		SendDeconstructMessage()
		if SK.savedVars.enableHasBeenFilletNotification then
			for _, itemLink in ipairs(chatItemList) do
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKA,
					SI_SK_AUT_FILLET_MESSAGE,
					itemLink:gsub("%|H0", "|H1")
				)
			end
		end
		return
	end
	self:NextAction(craftingType)
end

function SK.CraftStation:deconstructItems(craftingType)
	if SK.savedVars.debugMode then d("==== deconstructItems ====") end
	self.craftStationActionsStack.deconstructItems = nil
	local isDeconstructed
	local maximizedSkill = true
	local skillLineData = SDM:GetCraftingSkillLineData(craftingType)
    if skillLineData then
        local t, i = skillLineData:GetIndices()
        local _, rank = SKH.getSkillLineInfo(t, i)
        if rank < 50 then maximizedSkill = false end
    end
	local bagId = BAG_BACKPACK
	local chatItemList = {}
	PrepareDeconstructMessage()
	for slotIndex in ZO_IterateBagSlots(bagId) do
		local stackCount = GetSlotStackSize(bagId, slotIndex)
		if stackCount > 0 and CanItemBeDeconstructed(bagId, slotIndex, craftingType) then
			local itemLink = GetItemLink(bagId, slotIndex)
			if not (SKH.isItemDeconstructionProtected(bagId, slotIndex) or
				(IsItemLinkCrafted(itemLink) and not SK.savedVars.isDeconstructCraftedItems))
			then
				if SK.savedVars.debugMode then d("itemLink "..itemLink) end
			    local itemType = GetItemLinkItemType(itemLink)
			    local traitType = GetItemLinkTraitInfo(itemLink)
			    local isIntricate, isGlyph = SKH.isValueInList(SKDI.ITEM_TRAIT_INTRICATE, traitType), SKH.isValueInList(SKDI.ITEM_GLYPH_TYPES, itemType)
				local _, isDeconstructConditions = SKH.checkUnwantedConditions(itemLink)
				if SK.savedVars.debugMode and isDeconstructConditions then d("isDeconstructConditions") end
				if (SK.savedVars.deconstructUnwantedSetsByQuality and
						SKH.checkSingleSlotBackpackDeconstructSetsPart(slotIndex)) or
					(SK.savedVars.autoDeconstructFCOISMarked and FCOIS and FCOIS.IsMarked ~= nil and
						FCOIS.IsMarked(bagId, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION)) or
					(SK.savedVars.junkNonSetEquipments and isDeconstructConditions) or (
						not maximizedSkill and ((isGlyph and SK.savedVars.useGlyphsForCraftTraining) or
						(isIntricate and SK.savedVars.useIntricateForCraftTraining)))
				then
					if AddItemToDeconstructMessage(bagId, slotIndex, 1) then
						if craftingType == CRAFTING_TYPE_ENCHANTING then
							if ENCHANTING.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
								local modeBar = ZO_EnchantingTopLevel:GetNamedChild("ModeMenuBar")
								ZO_MenuBar_SelectDescriptor(modeBar, ENCHANTING_MODE_EXTRACTION)
							end
						end
						table.insert(chatItemList, itemLink)
						isDeconstructed = true
					end
				end
			end
		end
	end
	if SK.savedVars.debugMode then
		d("debug mode enabled - fake proceed")
	elseif isDeconstructed then
		self.closeDialogAfterAction = true
		SendDeconstructMessage()
		if SK.savedVars.enableHasBeenDeconstructedNotification then
			for _, itemLink in ipairs(chatItemList) do
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKA,
					SI_SK_AUT_DECONSTRUCTED_MESSAGE,
					itemLink:gsub("%|H0", "|H1")
				)
			end
		end
		return
	end
	self:NextAction(craftingType)
end

function SK.CraftStation:refineRawMaterial(craftingType)
	if SK.savedVars.debugMode then d("==== refineRawMaterial ====") end
	self.craftStationActionsStack.refineRawMaterial = nil
	local isRefined
	local skillLineData = SDM:GetCraftingSkillLineData(craftingType)
	local chatItemList = {}
	if skillLineData then
		local skillType, skillLineIndex = skillLineData:GetIndices()
		local _, _, _, _, _, _, _, refineProgress = GetSkillAbilityInfo(skillType, skillLineIndex,
			SKDC.REFINE_SKILL_IDX[craftingType])
		if (SK.savedVars.autoRefineIfSkillMaxed and refineProgress == 3) or not SK.savedVars.autoRefineIfSkillMaxed then
			local rawMaterialsList = {}
			rawMaterialsList = SKH.getPotentialRefineMaterialsByType(rawMaterialsList, craftingType)
			if rawMaterialsList and rawMaterialsList ~= {} then
				local step = GetRequiredSmithingRefinementStackSize()
				local sortedItems = {}
				for _, data in pairs(rawMaterialsList) do
					if data.quantity >= step then
						table.insert(sortedItems, {
							bagId = data.bagId,
							slotIndex = data.slotIndex,
							itemLink = GetItemLink(data.bagId, data.slotIndex),
							quantity = zo_floor(data.quantity / step) * step
						})
					end
				end
				table.sort(sortedItems, SKH.sortByQuantity)
				if SK.savedVars.debugMode then
					for _, item in ipairs(sortedItems) do
						d('itemLink '..item.itemLink)
					end
				end
				PrepareDeconstructMessage()
				for _, item in ipairs(sortedItems) do
					if AddItemToDeconstructMessage(item.bagId, item.slotIndex, item.quantity) then
						table.insert(chatItemList, item.itemLink)
					end
					isRefined = true
				end
			end
		elseif SK.savedVars.debugMode then
			d("refine skill too small - lvl "..refineProgress)
		end
	end
	if SK.savedVars.debugMode then
		d("debug mode enabled - fake proceed")
	elseif isRefined then
		self.closeDialogAfterAction = true
		SendDeconstructMessage()
		if SK.savedVars.enableHasBeenRefinedNotification then
			for _, itemLink in ipairs(chatItemList) do
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKA,
					SI_SK_AUT_REFINED_MESSAGE,
					itemLink:gsub("%|H0", "|H1")
				)
			end
		end
		return
	end
	self:NextAction(craftingType)
end
