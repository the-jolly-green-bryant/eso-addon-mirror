-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PAW = PA.Worker
local PAMF = PA.MenuFunctions
local PAHF = PA.HelperFunctions

-- ---------------------------------------------------------------------------------------------------------------------

local function KillTheRubbish(String)
  return  LocalizeString('<<1>>', String)
end 

-- ---------------------------------------------------------------------------------------------------------------------

local function ReenableLWCExitCraftStation()
	if PA.MenuFunctions.PAWorker.getAutoExitCraftingSetting() then
		if WritCreater then
			function WritCreater.IsOkayToExitCraftStation() 
				return true
			end
		end
	end
end

-- --------------------------------------------------------------------------------------------------------------------- 
	
local function CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait, silent)

  local maxResearchable = GetMaxSimultaneousSmithingResearch(craftingSkillType)
	
	local numCurrentlyResearching = 0
	
	if not PA.Worker.allResearchSlotsUsed[craftingSkillType] then
		for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
			local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			if numTraits > 0 then
				local researchingTraitIndex, areAllTraitsKnown = ZO_SharedSmithingResearch:FindResearchingTraitIndex(craftingSkillType, researchLineIndex, numTraits)
				if researchingTraitIndex then
					numCurrentlyResearching = numCurrentlyResearching + 1
					if KillTheRubbish(name) == KillTheRubbish(researchLineName) then -- that research line is currently used to search another trait 
					   if not silent then
						  PAW.println(SI_PA_CHAT_RESEARCH_BUSY, KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait)), researchLineName)
					   end
					   return false
					end
				end
			end
		end
	else 
	    return false
	end
	
	if numCurrentlyResearching >= maxResearchable  then -- all available researched slots are currently used
	    if not silent and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then
		   PAW.println(SI_PA_CHAT_RESEARCH_FULL, KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait)), researchLineName, numCurrentlyResearching, numCurrentlyResearching)
		end 
        PA.Worker.allResearchSlotsUsed[craftingSkillType] = true 		
		return false
	else
	    return true
    end	
end

-- ---------------------------------------------------------------------------------------------------------------------
	
local function TraitSelectedByUser(craftingSkillType, researchLineName, trait, bagId, slotIndex)
 
	-- here we filter the crafting stations
	local craftingStationSkillType = 999  
	if PAW.currentCraftingStation == "Universal" then 
	       craftingStationSkillType = nil
	elseif PAW.currentCraftingStation == "Clothier" then
	       craftingStationSkillType = CRAFTING_TYPE_CLOTHIER  
	elseif PAW.currentCraftingStation == "Blacksmithing" then
	       craftingStationSkillType = CRAFTING_TYPE_BLACKSMITHING
	elseif PAW.currentCraftingStation == "Woodworking" then
	       craftingStationSkillType = CRAFTING_TYPE_WOODWORKING
	elseif PAW.currentCraftingStation == "Enchanting" then
	       craftingStationSkillType = CRAFTING_TYPE_ENCHANTING
	elseif PAW.currentCraftingStation == "JewelryCrafting" then
	       craftingStationSkillType = CRAFTING_TYPE_JEWELRYCRAFTING
    end
	
	if craftingStationSkillType ~= craftingSkillType then
	   return false
	end 
	
	-- FCOItemSaver support
	if not IsInGamepadPreferredMode() and FCOIS then -- Gamepad mode ist VERBOTEN mit FCOIS (not supported and causes UI errors)
		if FCOIS.IsResearchLocked(bagId, slotIndex, nil) then -- protected, don't research 
			return false
		end
	end	
	
	local craftingSkillName = KillTheRubbish(GetString("SI_TRADESKILLTYPE", craftingSkillType))
  local traitName = KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait))
    
	local formatedValue = {}
	table.insert(formatedValue, "AutoResearchTrait")
	table.insert(formatedValue, craftingSkillName)
	table.insert(formatedValue, KillTheRubbish(researchLineName))
	table.insert(formatedValue, traitName)

	
	if PAMF.PAWorker.getTraitSetting(formatedValue) then
	   return true
	end
end

-- -- --------------------------------------------------------------------------------------------------------------------	

local function IncludeBankedItems()
	local isBankIncluded = SMITHING:GetResearchPanel():IsIncludeBankedItemsChecked() and not PA.MenuFunctions.PAWorker.getProtectBankSetting() 
	return isBankIncluded
end

-- --------------------------------------------------------------------------------------------------------------------	   
		   
local function StartResearchTrait(hasDeconstructedOrRefinedBefore)
  -- note: ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS is apparently "invigorating" :-/

    
	PAW.hasCraftedSomething = false
  if PAW.currentCraftingStation == "Enchanting" or PAW.currentCraftingStation == "Universal" or PAW.currentCraftingStation == "None" then
	   return
	end

	local bagId = BAG_BACKPACK
	local bagSlots = GetBagSize(bagId)
	
 
	for slotIndex = 0, bagSlots do
	  local itemId = GetItemId(bagId, slotIndex)
		local canBeResearched = GetItemTraitInformation(bagId, slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED 
		local trait = GetItemTrait(bagId, slotIndex)
		local EquipmentFilterType = GetItemEquipmentFilterType(bagId, slotIndex)
		local craftingSkillType, researchLineName = GetRearchLineInfoFromRetraitItem(bagId, slotIndex)
		
		local _, _, _, _, locked, _, itemStyleId, itemQuality, displayQuality = GetItemInfo(bagId, slotIndex)
		local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    local isCrafted = IsItemLinkCrafted(itemLink)
    local isReconstructed = IsItemReconstructed(bagId,slotIndex)
    
    
    local isSetProtected = PAMF.PAWorker.getProtectUncollectedSetItemsSetting() and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))

		if TraitSelectedByUser(craftingSkillType, researchLineName, trait, bagId, slotIndex) and canBeResearched and (not IsTraitKnownForItem(itemId, trait)) and (not locked) and
    	    (displayQuality ~= ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE) and (not isCrafted) and (not isReconstructed) and (not isSetProtected) and 
		   CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then

		    -- now we can open the research tab
		    if IsInGamepadPreferredMode() and SCENE_MANAGER:GetCurrentScene():GetName() ~= "gamepad_smithing_research" then
			    SCENE_MANAGER:Show("gamepad_smithing_research")
		    elseif ZO_MenuBar_GetSelectedDescriptor(SMITHING.modeBar) ~= SMITHING_MODE_RESEARCH then
			    ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_RESEARCH, true, false) 
			end
			
			zo_callLater(function() 
				 if CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait, true) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then
					 ResearchSmithingTrait(bagId, slotIndex)
					 PlaySound("Smithing_Start_Research")
					 local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
					 local traitLink = GetSmithingTraitItemLink(trait+1, LINK_STYLE_BRACKETS)
					 PAW.println(SI_PA_CHAT_ITEM_RESEARCHED, itemLink, traitLink, KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait)), researchLineName)
           end   
              zo_callLater(function() StartResearchTrait(true) end, 500)
			end, 100)
       return 
		end
	end
	
	-- ESOplus members can research banked items
	if IsESOPlusSubscriber() and IncludeBankedItems() then
	
	    bagId = BAG_BANK
	    bagSlots = GetBagSize(bagId) 
	
		for slotIndex = 0, bagSlots do
			local itemId = GetItemId(bagId, slotIndex)
			local canBeResearched = GetItemTraitInformation(bagId, slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED 
			local trait = GetItemTrait(bagId, slotIndex)
			local EquipmentFilterType = GetItemEquipmentFilterType(bagId, slotIndex)
			local craftingSkillType, researchLineName = GetRearchLineInfoFromRetraitItem(bagId, slotIndex)
			
			local _, _, _, _, locked, _, itemStyleId, itemQuality, displayQuality = GetItemInfo(bagId, slotIndex)
			local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
			local isCrafted = IsItemLinkCrafted(itemLink)
			local isReconstructed = IsItemReconstructed(bagId,slotIndex)

			local isSetProtected = PAMF.PAWorker.getProtectUncollectedSetItemsSetting() and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))

			if TraitSelectedByUser(craftingSkillType, researchLineName, trait, bagId, slotIndex) and canBeResearched and (not IsTraitKnownForItem(itemId, trait)) and (not locked) and
				displayQuality ~= ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE and (not isCrafted) and (not isReconstructed) and (not isSetProtected) and 
			   CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then

				-- now we can open the research tab
				if IsInGamepadPreferredMode() and SCENE_MANAGER:GetCurrentScene():GetName() ~= "gamepad_smithing_research" then
					SCENE_MANAGER:Show("gamepad_smithing_research")
				elseif ZO_MenuBar_GetSelectedDescriptor(SMITHING.modeBar) ~= SMITHING_MODE_RESEARCH then
					ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_RESEARCH, true, false) 
				end
				
				zo_callLater(function() 
					 if CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait, true) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then
						  ResearchSmithingTrait(bagId, slotIndex)
						  PlaySound("Smithing_Start_Research")
              local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
              local traitLink = GetSmithingTraitItemLink(trait+1, LINK_STYLE_BRACKETS)
              PAW.println(SI_PA_CHAT_ITEM_RESEARCHED, itemLink, traitLink, KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait)), researchLineName)
           end   
              zo_callLater(function() StartResearchTrait(true) end, 500) 
				end, 100)
         return
			end
		end
		
	    bagId = BAG_SUBSCRIBER_BANK
	    bagSlots = GetBagSize(bagId) 
	
		for slotIndex = 0, bagSlots do
			local itemId = GetItemId(bagId, slotIndex)
			local canBeResearched = GetItemTraitInformation(bagId, slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED 
			local trait = GetItemTrait(bagId, slotIndex)
			local EquipmentFilterType = GetItemEquipmentFilterType(bagId, slotIndex)
			local craftingSkillType, researchLineName = GetRearchLineInfoFromRetraitItem(bagId, slotIndex)
			
			local _, _, _, _, locked, _, itemStyleId, itemQuality, displayQuality = GetItemInfo(bagId, slotIndex)
			local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
			local isCrafted = IsItemLinkCrafted(itemLink)
			local isReconstructed = IsItemReconstructed(bagId,slotIndex)

			local isSetProtected = PAMF.PAWorker.getProtectUncollectedSetItemsSetting() and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))

			if TraitSelectedByUser(craftingSkillType, researchLineName, trait, bagId, slotIndex) and canBeResearched and (not IsTraitKnownForItem(itemId, trait)) and (not locked) and
				displayQuality ~= ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE and (not isCrafted) and (not isReconstructed) and (not isSetProtected) and 
			   CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then

				-- now we can open the research tab
				if IsInGamepadPreferredMode() and SCENE_MANAGER:GetCurrentScene():GetName() ~= "gamepad_smithing_research" then
					SCENE_MANAGER:Show("gamepad_smithing_research")
				elseif ZO_MenuBar_GetSelectedDescriptor(SMITHING.modeBar) ~= SMITHING_MODE_RESEARCH then
					ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_RESEARCH, true, false) 
				end
				
				zo_callLater(function() 
					 if CanWeResearchThatResearchLine(craftingSkillType, researchLineName, trait, true) and not PA.Worker.allResearchSlotsUsed[craftingSkillType] then
						  ResearchSmithingTrait(bagId, slotIndex)
						  PlaySound("Smithing_Start_Research")
			      	local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
			      	local traitLink = GetSmithingTraitItemLink(trait+1, LINK_STYLE_BRACKETS)
				      PAW.println(SI_PA_CHAT_ITEM_RESEARCHED, itemLink, traitLink, KillTheRubbish(GetString("SI_ITEMTRAITTYPE",trait)), researchLineName)
           end   
              zo_callLater(function() StartResearchTrait(true) end, 500)
				end, 100)
         return
			end
		end
	end

	
	if PAMF.PAWorker.getAutoExitCraftingSetting() and hasDeconstructedOrRefinedBefore then
     zo_callLater(function() CALLBACK_MANAGER:FireCallbacks("PersonalAssistant_AutomaticCraftingStationClose") SCENE_MANAGER:ShowBaseScene() ReenableLWCExitCraftStation() PAW.hasCraftedSomething = false PAW.hasDeconstructedSomething = false end, 1000) --- exit crafting table
	end
  EVENT_MANAGER:UnregisterForEvent("PArefine", EVENT_CRAFT_COMPLETED) 
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Export
PA.Worker = PA.Worker or {}
PA.Worker.StartResearchTrait = StartResearchTrait
