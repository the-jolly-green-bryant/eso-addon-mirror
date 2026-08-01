local _addon = _G["DailyCraftStatus"]

_addon.trackResearch = {}

--keep the crafts below sorted by C_QUESTORDER!
_addon.C_RESEARCHCRAFTS = {CRAFTING_TYPE_BLACKSMITHING,CRAFTING_TYPE_CLOTHIER,CRAFTING_TYPE_WOODWORKING,CRAFTING_TYPE_JEWELRYCRAFTING}


local equipToCraftType = {
	[EQUIPMENT_FILTER_TYPE_BOW] = CRAFTING_TYPE_WOODWORKING,
	[EQUIPMENT_FILTER_TYPE_DESTRO_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[EQUIPMENT_FILTER_TYPE_HEAVY] = CRAFTING_TYPE_BLACKSMITHING,
	[EQUIPMENT_FILTER_TYPE_LIGHT] = CRAFTING_TYPE_CLOTHIER,
	[EQUIPMENT_FILTER_TYPE_MEDIUM] = CRAFTING_TYPE_CLOTHIER, 
	[EQUIPMENT_FILTER_TYPE_NECK] = CRAFTING_TYPE_JEWELRYCRAFTING,
	[EQUIPMENT_FILTER_TYPE_NONE] = 0,
	[EQUIPMENT_FILTER_TYPE_ONE_HANDED] = CRAFTING_TYPE_BLACKSMITHING,
	[EQUIPMENT_FILTER_TYPE_RESTO_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[EQUIPMENT_FILTER_TYPE_RING] = CRAFTING_TYPE_JEWELRYCRAFTING,
	[EQUIPMENT_FILTER_TYPE_SHIELD] = CRAFTING_TYPE_WOODWORKING,
	[EQUIPMENT_FILTER_TYPE_TWO_HANDED] = CRAFTING_TYPE_BLACKSMITHING,
}

local researchIcons = {
	[CRAFTING_TYPE_BLACKSMITHING] = "esoui/art/icons/mapkey/mapkey_smithy.dds",
	[CRAFTING_TYPE_CLOTHIER] = "esoui/art/icons/mapkey/mapkey_clothier.dds",
	[CRAFTING_TYPE_WOODWORKING] = "esoui/art/icons/mapkey/mapkey_woodworker.dds",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "esoui/art/icons/mapkey/mapkey_jewelrycrafting.dds"
}


function _addon.canDoResearch()
	local isAvail = false
	--local info = ""
	local crafts = {}
	local availItems = {}
	local timeLeft = 0
	local progressDetails = {}
	local colorObj = ZO_ColorDef:New("00AFAF")

	local researchableBanks = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	local items = {}
	
	for i=1, #researchableBanks do
		local bagId = researchableBanks[i]
		for slotId = 0, GetBagSize(bagId) do
			if GetItemTraitInformation(bagId,slotId)==ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
				local skip = IsItemPlayerLocked(bagId,slotId)
				local itemTrait = GetItemTrait(bagId,slotId)
				
				--people lock nirnhoned gear to prevent accidental deconstruction
				if skip then 
					if itemTrait==ITEM_TRAIT_TYPE_ARMOR_NIRNHONED or itemTrait==ITEM_TRAIT_TYPE_WEAPON_NIRNHONED then
						skip = false
					end
				end
				
				local itemQuality = GetItemFunctionalQuality(bagId,slotId)
    				if (itemQuality >= ITEM_FUNCTIONAL_QUALITY_LEGENDARY) then 
    					skip = true
    				end
				
				if not skip then
					--todo: check this new function below
					--d(GetItemLinkCraftingSkillType(GetItemLink(bagId,slotId)))
					local equipType = GetItemEquipmentFilterType(bagId,slotId)
					if equipType then
						local craft = equipToCraftType[equipType]
						if craft then 
							if _addon.trackResearch[craft] then
								if not items[craft] then items[craft] = {} end
								if not items[craft][itemTrait] then items[craft][itemTrait] = {} end
								items[craft][itemTrait][#items[craft][itemTrait]+1] = {bagId,slotId,true}
							end
						end
					end
				end
			end
		end
	end

	for _,craft in pairs(_addon.C_RESEARCHCRAFTS) do
		if _addon.trackResearch[craft] then

			local maxres = GetMaxSimultaneousSmithingResearch(craft) or 1
			local curres = 0	
			local canres = 0
			for line = 1, GetNumSmithingResearchLines(craft) do
				local lineName, lineIcon, numTraits = GetSmithingResearchLineInfo(craft,line)
				local lineAvailable = true
				for trait = 1, numTraits do
					local itemTrait, _, known = GetSmithingResearchLineTraitInfo(craft,line,trait)
					if not known then
						_,remaining = GetSmithingResearchLineTraitTimes(craft,line,trait)
						if remaining and remaining > 0 then
							curres = curres + 1
							if timeLeft==0 or remaining < timeLeft then
								timeLeft = remaining
							end
							lineAvailable = false
							progressDetails[#progressDetails+1] = {lineName,remaining}
						else
							canres = canres + 1
						end
					end
				end	
				
				--purge items that belong to unavailable research line
				if not lineAvailable then
					if items[craft] then
						for trait = 1, numTraits do
							local itemTrait, _, known = GetSmithingResearchLineTraitInfo(craft,line,trait)
							if items[craft][itemTrait] then
								for _,item in pairs(items[craft][itemTrait]) do
									if item[3] then
										if CanItemBeSmithingTraitResearched(item[1],item[2],craft,line,trait) then
											item[3] = false
										end
									end 
								end
							end
						end
					end	
				end
				
				
			end	
			if items[craft] then
				for _,itemsByTrait in pairs(items[craft]) do
					for _,item in pairs(itemsByTrait) do
						if item[3] then availItems[craft] = true end
					end
				end				
			end
			if canres > 0 and curres < maxres then 
				isAvail = true
				
				--local size = _addon.iconSizes[_addon.uiScale] - 2
				--local iconStr = string.format("|t%d:%d:%s:inheritColor|t",size,size,researchIcons[craft])	
				--if items[craft] then iconStr = colorObj:Colorize(iconStr) end
				--info = info .. iconStr  --.. curres .."/" .. maxres .." "

				crafts[craft] = true
			end
		end
	end
	return isAvail, crafts, availItems, timeLeft, progressDetails
end
