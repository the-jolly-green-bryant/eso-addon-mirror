-- Create namespace
DsRGuildPersonalDeconJunk = {}
local DsRGuildPersonalDeconJunk = DsRGuildPersonalDeconJunk or {}

DsRGuildPersonalDeconJunk.name = "DsRGuildPersonalDeconJunk"

DsRGuildPersonalDeconJunk.currentCraftingType = nil

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Junk
-------------------------------------------------------------------------------------------------------------------------------------------------
    local function isItemForCompanion(bagId, slotIndex)
        local actorCategory = GetItemActorCategory(bagId, slotIndex)
        return actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION
    end
    
    -------------------------------------------------------------------------------------------------------------------------------------------------
	local function FilterJunkItems(itemData)
	    local isStolen    = itemData.stolen
	    local isJunk      = itemData.isJunk
	    local isProtected = itemData.isPlayerLocked
	    if isStolen or isProtected then
	      	return false
        elseif isJunk then
	      	return true
	    end
	end

    -------------------------------------------------------------------------------------------------------------------------------------------------
    function DsRGuildPersonalDeconJunk.MarkItemAsJunk(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
        if not DsRGuildPersonal.ACCconfig.JunkOnOff then
            return
		end

        local isJunk     = IsItemJunk(bagId, slotIndex)
        local itemLink   = GetItemLink(bagId, slotIndex)
        local traitIndex = GetItemLinkTraitInfo(itemLink)
        local itemId     = GetItemId(bagId, slotIndex)
        local itemType, specializedItemType = GetItemType(bagId, slotIndex)

        local isStolen  = IsItemStolen(bagId, slotIndex)
        local isCrafted = IsItemLinkCrafted(itemLink)
        
        if isStolen then return end

        if not isCrafted then
            if bagId == BAG_BACKPACK then
                if CanItemBeMarkedAsJunk(bagId, slotIndex) and not isItemForCompanion(bagId, slotIndex) then
                    local CheckManuJunk = DsRGuildPersonal.ACCconfig.JunkMarkManu[itemId]

                    if CheckManuJunk ~= nil then
                        if CheckManuJunk.MarkJunk == true then
                            SetItemIsJunk(bagId, slotIndex, true)
                        end
                    else
                        if ( itemType == ITEMTYPE_TREASURE and specializedItemType == SPECIALIZED_ITEMTYPE_TREASURE ) and DsRGuildPersonal.GetSettings()["DeconJunk"]["PleyToJunk"] then
                            SetItemIsJunk(bagId, slotIndex, true)
                        end
                        if ( itemType == ITEMTYPE_TRASH or specializedItemType == SPECIALIZED_ITEMTYPE_TRASH ) and DsRGuildPersonal.GetSettings()["DeconJunk"]["PlunderToJunk"] then
                            SetItemIsJunk(bagId, slotIndex, true)
                        end
                        if(traitIndex == ITEM_TRAIT_TYPE_ARMOR_ORNATE or traitIndex == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitIndex == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) and DsRGuildPersonal.GetSettings()["DeconJunk"]["OrnateToJunk"] then
                            SetItemIsJunk(bagId, slotIndex, true)
                        end
                        if traitIndex == ITEM_TRAIT_TYPE_NONE and ( itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON ) and DsRGuildPersonal.GetSettings()["DeconJunk"]["NoTraitToJunk"] then
                            SetItemIsJunk(bagId, slotIndex, true)
                        end
                    end
                end
            end
        end
    end

    -------------------------------------------------------------------------------------------------------------------------------------------------
    function DsRGuildPersonalDeconJunk.OpenStore()
        if DsRGuildPersonal.ACCconfig.JunkSellOnOff then
            local bagpackCache = SHARED_INVENTORY:GenerateFullSlotData(FilterJunkItems, BAG_BACKPACK)
            local SellSum = 0
            for bagSlot, data in pairs(bagpackCache) do
                local _, _, sellPrice = GetItemInfo(BAG_BACKPACK, data.slotIndex)
                SellSum = SellSum + tonumber(sellPrice)
                SellAllJunk()
            end
            if SellSum > 0 then
               	CHAT_SYSTEM:Maximize()
                d(zo_strformat(" |c9fb6cd[DsR-Junk]|r " .. GetString(DsRGuildPersonal_JunkSellFinish), SellSum .. PRICE_TOOLTIP_GOLD_TEXT_ICON))
            end
        end
    end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Deconstruction
-------------------------------------------------------------------------------------------------------------------------------------------------
    local DeconQuantity  = 0  
    
    local function CanDeconstructItem(bagId, slotIndex)

        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    	if itemLink == "" or itemLink == nil then
    		return false
    	end
    
    	local itemType, specializedItemType = GetItemType(bagId, slotIndex)
    	local itemTrait                     = GetItemTrait(bagId, slotIndex)
        local traitIndex                    = GetItemLinkTraitInfo(itemLink)
        local icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionalQuality, displayQuality = GetItemInfo(bagId, slotIndex)

        local player = GetDisplayName()
        if player == "@xxarunaxx" then
            if ( itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE ) then
                return false
            end
            if displayQuality == 1 and ( itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR ) then
                return false
            end
        end

        if locked or displayQuality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
            return false
        end

        local isJunk = IsItemJunk(bagId, slotIndex)
    	if isJunk and not DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconJunk"] then
            return false
    	end

        local isCrafted = IsItemLinkCrafted(itemLink)
    	if isCrafted and not DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconCrafted"] then
            return false 
    	end
    
    	local isReconstructed = IsItemReconstructed(bagId,slotIndex)
    	if isReconstructed and not DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconReconstr"] then
    	   return false
    	end

        if(traitIndex == ITEM_TRAIT_TYPE_ARMOR_ORNATE or traitIndex == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitIndex == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) then
            return false
        end

        if ( itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTrait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE ) and not DsRGuildPersonal.GetSettings()["DeconJunk"]["IndricateToDecon"] then
            return false
        end

        local isSetItem  = GetItemLinkSetInfo ( itemLink, false )
        if isSetItem and not DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconSetItems"] then
            return false
        end

        if itemTrait == 0 and not DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconNoTrait"] then
            return false
        end

        local DeconGlypheQualiSavVari   = zo_strsub(DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconGlyphe"]  , 1 , 1)
            if DeconGlypheQualiSavVari == "-" then DeconGlypheQualiSavVari = 0 end
        local DeconJewelryQualiSavVari  = zo_strsub(DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconJewelry"] , 1 , 1)
            if DeconJewelryQualiSavVari == "-" then DeconJewelryQualiSavVari = 0 end
        local DeconArmorQualiSavVari    = zo_strsub(DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconArmor"]   , 1 , 1)
            if DeconArmorQualiSavVari == "-" then DeconArmorQualiSavVari = 0 end
        local DeconWeaponQualiSavVari   = zo_strsub(DsRGuildPersonal.GetSettings()["DeconJunk"]["DeconWeapon"]  , 1 , 1)
            if DeconWeaponQualiSavVari == "-" then DeconWeaponQualiSavVari = 0 end
        
    	if (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) then 
            local craftingSkillType, _,_,_,_ = GetItemCraftingInfo(bagId, slotIndex)
            local EquipmentFilterType        = GetItemEquipmentFilterType(bagId, slotIndex)

    		if craftingSkillType == CRAFTING_TYPE_ENCHANTING then 
                if displayQuality > tonumber(DeconGlypheQualiSavVari) then
                    return false
                end
    		elseif craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_NECK or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_RING then
                if displayQuality > tonumber(DeconJewelryQualiSavVari) then
                    return false
                end
    		elseif craftingSkillType == CRAFTING_TYPE_CLOTHIER or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_LIGHT or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_MEDIUM then
                if displayQuality > tonumber(DeconArmorQualiSavVari) then
                    return false
                end
    		elseif craftingSkillType == CRAFTING_TYPE_BLACKSMITHING or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_HEAVY or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_ONE_HANDED or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_TWO_HANDED then
                if EquipmentFilterType == EQUIPMENT_FILTER_TYPE_HEAVY and displayQuality > tonumber(DeconArmorQualiSavVari) then
                    return false
                end
                if ( EquipmentFilterType == EQUIPMENT_FILTER_TYPE_ONE_HANDED or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_TWO_HANDED ) and displayQuality > tonumber(DeconWeaponQualiSavVari) then
                    return false
                end
    		elseif craftingSkillType == CRAFTING_TYPE_WOODWORKING or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_BOW or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_DESTRO_STAFF or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_RESTO_STAFF or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_SHIELD then
                if ( EquipmentFilterType == EQUIPMENT_FILTER_TYPE_BOW or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_DESTRO_STAFF or EquipmentFilterType == EQUIPMENT_FILTER_TYPE_RESTO_STAFF ) and displayQuality > tonumber(DeconWeaponQualiSavVari) then
                    return false
                end
                if EquipmentFilterType == EQUIPMENT_FILTER_TYPE_SHIELD and displayQuality > tonumber(DeconArmorQualiSavVari) then
                    return false
                end
    		end
    	end

        -- filter crafting stations
        local craftingSkillType = 999  
    	if DsRGuildPersonalDeconJunk.currentCraftingType == 0 then 
    	    craftingSkillType = nil
    	elseif DsRGuildPersonalDeconJunk.currentCraftingType == 2 then
    	    craftingSkillType = CRAFTING_TYPE_CLOTHIER  
    	elseif DsRGuildPersonalDeconJunk.currentCraftingType == 1 then
    	    craftingSkillType = CRAFTING_TYPE_BLACKSMITHING
    	elseif DsRGuildPersonalDeconJunk.currentCraftingType == 6 then
    	    craftingSkillType = CRAFTING_TYPE_WOODWORKING
    	elseif DsRGuildPersonalDeconJunk.currentCraftingType == 3 then
    	    craftingSkillType = CRAFTING_TYPE_ENCHANTING
    	elseif DsRGuildPersonalDeconJunk.currentCraftingType == 7 then
    	    craftingSkillType = CRAFTING_TYPE_JEWELRYCRAFTING
        end

        if CanItemBeDeconstructed(bagId, slotIndex, craftingSkillType) then
    	    if craftingSkillType == CRAFTING_TYPE_ENCHANTING then
    		   if ZO_MenuBar_GetSelectedDescriptor(ENCHANTING.modeBar) ~= ENCHANTING_MODE_EXTRACTION then 
    	          ZO_MenuBar_SelectDescriptor(ENCHANTING.modeBar, ENCHANTING_MODE_EXTRACTION, true, false)
               end			  
            else
    		   if ZO_MenuBar_GetSelectedDescriptor(SMITHING.modeBar) ~= SMITHING_MODE_DECONSTRUCTION then
                  ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_DECONSTRUCTION, true, false) 
    		   end
    	   end
    	    return true
    	else
            return false	
    	end
    end

    -------------------------------------------------------------------------------------------------------------------------------------------------
    local function FilterThisBagAndAddToMessage(bagId)
        local bagSlots = GetBagSize(bagId)
        for slotIndex = 0, bagSlots do
            if CanDeconstructItem(bagId, slotIndex) then
                local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
                if AddItemToDeconstructMessage(bagId, slotIndex, 1) then
                    DeconQuantity = DeconQuantity + 1
                end  
            end
        end
    end

    -------------------------------------------------------------------------------------------------------------------------------------------------
    local function HasAnyCraftingWrit()
        local anyFound = false
        for i=1 , GetNumJournalQuests() do
            if GetJournalQuestType(i) == QUEST_TYPE_CRAFTING then 
                anyFound = true
            end
        end
        return anyFound
    end
    
    -------------------------------------------------------------------------------------------------------------------------------------------------
    function DsRGuildPersonalDeconJunk.DeconstructorSceneOpen(eventCode, craftingType, sameStation, craftingMode)
        if not DsRGuildPersonal.ACCconfig.DeconstructOnOff then
            return
		end

        -- -----------------------------
        -- craftinType  = name
        -- -----------------------------
        --      0       = Gehilfen
        --      1       = Schmied
        --      2       = Schneiderei
        --      3       = Verzauberung
        --      4       = Alchemie
        --      5       = Versorger
        --      6       = Schreinerei
        --      7       = Schmuck
        -- -----------------------------

        -- Check if Crafting Quest exist
        if HasAnyCraftingWrit() then
            if craftingType == 0 then
                CHAT_SYSTEM:Maximize()
                d(zo_strformat(" |c9fb6cd[DsR-Recycle]|r " .. GetString(DsRGuildPersonal_DeconstructAbort)))
            end
            return
        end	

        if craftingType == 4 or craftingType == 5 then return end

        local isBankIncluded = true

        if craftingType == 0 then
            isBankIncluded = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.savedVars.includeBankedItemsChecked
        elseif craftingType ~= 3 then
            isBankIncluded = SMITHING.deconstructionPanel.savedVars.includeBankedItemsChecked
        else
            isBankIncluded = true
        end
        
        DsRGuildPersonalDeconJunk.currentCraftingType = craftingType

        PrepareDeconstructMessage() 

        FilterThisBagAndAddToMessage(BAG_BACKPACK)
	
        if isBankIncluded == true then
            if IsESOPlusSubscriber() then
                FilterThisBagAndAddToMessage(BAG_SUBSCRIBER_BANK)
            end
            FilterThisBagAndAddToMessage(BAG_BANK)
        end
                        
        SendDeconstructMessage()

        if DeconQuantity > 0 then
            CHAT_SYSTEM:Maximize()
            if DeconQuantity == 1 then
                d(zo_strformat(" |c9fb6cd[DsR-Recycle]|r " .. GetString(DsRGuildPersonal_DeconstructFinishOne), DeconQuantity))
            else
                d(zo_strformat(" |c9fb6cd[DsR-Recycle]|r " .. GetString(DsRGuildPersonal_DeconstructFinish), DeconQuantity))
            end
        end
        DeconQuantity  = 0
    end
