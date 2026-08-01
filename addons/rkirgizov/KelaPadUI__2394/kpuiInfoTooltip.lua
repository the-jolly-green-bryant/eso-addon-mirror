local colors = kpuiConst.Colors	
local OPTIONS_LIST = "optionsList"






	-- replace tooltip Quad1 (left collection)
function kelaReplaceTooltipQuad1 (tooltip)	
	
	local oldLayoutCollectible = tooltip.LayoutCollectible
	tooltip.LayoutCollectible = function(control, collectibleId, collectionName, collectibleName, collectibleNickname, isPurchasable, description, hint, isPlaceholder, showVisualLayerInfo, cooldownSecondsRemaining, showBlockReason, ...)	

	--KelaPostMsg("LayoutCollectible")
		
		if not isPlaceholder then 
            --things added to the collection top section stacks to the right (side by side) 
            local topSection = control:AcquireSection(control:GetStyle("collectionsTopSection")) 

            if collectionName then 
                local formattedName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, collectionName) 
                topSection:AddLine(formattedName) 
            end 

            local unlockState = GetCollectibleUnlockStateById(collectibleId) 
            topSection:AddLine(GetString("SI_COLLECTIBLEUNLOCKSTATE", unlockState)) 

            if showVisualLayerInfo then 
                local visualLayerHidden, highestPriorityVisualLayerThatIsShowing = WouldCollectibleBeHidden(collectibleId) 
                if visualLayerHidden then 
                    topSection:AddLine(ZO_SELECTED_TEXT:Colorize(GetHiddenByStringForVisualLayer(highestPriorityVisualLayerThatIsShowing))) 
                end 
            end 

            control:AddSection(topSection) 
        end 

        local formattedName = colors.COLOR_WHITE:Colorize(ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName))
        control:AddLine(formattedName, QUALITY_NORMAL, control:GetStyle("QUAD1title")) 
     
        local headerSection = control:AcquireSection(control:GetStyle("bodyHeader")) 

        if collectibleNickname and collectibleNickname ~= "" then 
            formattedName = ZO_CachedStrFormat(SI_TOOLTIP_COLLECTIBLE_NICKNAME, collectibleNickname) 
            headerSection:AddLine(formattedName, QUALITY_NORMAL, control:GetStyle("bodyHeader")) 
        end 

        control:AddSection(headerSection) 
		
		--KelaPostMsg(tostring(type(tonumber(cooldownSecondsRemaining))))
        if cooldownSecondsRemaining and type(tonumber(cooldownSecondsRemaining)) == "number" then
			if cooldownSecondsRemaining > 0 then 
				local cooldownSection = control:AcquireSection(control:GetStyle("QUAD1collectionsStatsSection")) 
				local cooldownPair = cooldownSection:AcquireStatValuePair(control:GetStyle("statValuePair")) 
				cooldownPair:SetStat(COOLDOWN_TEXT, control:GetStyle("collectionsTopSection")) 
			 
				local secondsRemainingString = ZO_FormatTimeLargestTwo(cooldownSecondsRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL) 
				cooldownPair:SetValue(secondsRemainingString, control:GetStyle("collectionsStatsValue")) 
				cooldownSection:AddStatValuePair(cooldownPair) 
				control:AddSection(cooldownSection) 
			end
        end 

        local bodySection = control:AcquireSection(control:GetStyle("QUAD1collectionsInfoSection")) 
        local descriptionStyle = control:GetStyle("bodyDescription") 

        if description then 
            local formattedDescription = ZO_CachedStrFormat(ZO_CACHED_STR_FORMAT_NO_FORMATTER, description) 
            bodySection:AddLine(formattedDescription, descriptionStyle) 
        end 

        if isPurchasable then  
            bodySection:AddLine(PURCHASED_TEXT, descriptionStyle) 
        end 

        if hint and hint ~= "" then 
            local formattedHint = ZO_CachedStrFormat(ZO_CACHED_STR_FORMAT_NO_FORMATTER, hint) 
            bodySection:AddLine(formattedHint, descriptionStyle) 
        end 

        local emoteOverrideNames = {GetCollectiblePersonalityOverridenEmoteDisplayNames(collectibleId)} 
        if #emoteOverrideNames > 0 then 
            local numEmoteNames = #emoteOverrideNames 
            local emoteString = ZO_GenerateCommaSeparatedList(emoteOverrideNames) 
            local formattedEmoteString = zo_strformat(SI_COLLECTIBLE_TOOLTIP_PERSONALITY_OVERRIDES_DISPLAY_NAMES_FORMATTER, emoteString, numEmoteNames) 
            bodySection:AddLine(formattedEmoteString, descriptionStyle, control:GetStyle("collectionsPersonality")) 
        end 

        control:AddSection(bodySection) 

        -- Layout the use restrictions 
        local failsRestriction = false 
        local restrictionsSection = control:AcquireSection(control:GetStyle("QUAD1collectionsRestrictionsSection")) 

        for restrictionType = COLLECTIBLE_RESTRICTION_TYPE_MIN_VALUE, COLLECTIBLE_RESTRICTION_TYPE_MAX_VALUE do 
            local hasRestrictions, passesRestrictions, allowedNamesString = GetCollectibleRestrictionsByType(collectibleId, restrictionType) 
            if hasRestrictions then 
                local statValuePair = restrictionsSection:AcquireStatValuePair(control:GetStyle("statValuePair"), control:GetStyle("fullWidth")) 
                statValuePair:SetStat(GetString("SI_COLLECTIBLERESTRICTIONTYPE", restrictionType), control:GetStyle("statValuePairStat")) 
                if passesRestrictions then 
                    statValuePair:SetValue(allowedNamesString, control:GetStyle("statValuePairValue")) 
                else 
                    statValuePair:SetValue(allowedNamesString, control:GetStyle("failed"), control:GetStyle("statValuePairValue")) 
                    failsRestriction = true 
                end 
                restrictionsSection:AddStatValuePair(statValuePair) 
            end 
        end 

        control:AddSection(restrictionsSection) 

        bodySection = control:AcquireSection(control:GetStyle("QUAD1collectionsInfoSection")) 

        if failsRestriction then 
            bodySection:AddLine(GetString(SI_COLLECTIBLE_TOOLTIP_NOT_USABLE_BY_CHARACTER), descriptionStyle, control:GetStyle("failed")) 
        elseif showBlockReason then 
            local usageBlockReason = GetCollectibleBlockReason(collectibleId) 
            if usageBlockReason ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then 
                local formattedBlockReason = ZO_CachedStrFormat(ZO_CACHED_STR_FORMAT_NO_FORMATTER, GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", usageBlockReason)) 
                bodySection:AddLine(formattedBlockReason, descriptionStyle, control:GetStyle("failed")) 
            end 
        end 

        control:AddSection(bodySection) 
		-- local ret = oldCallbackkelaReplaceTitleStyle(control, itemLink, ...)
		-- return ret
	end

end
------------------------------------------------------------------------------
function kelaReplaceTooltipChamps (tooltip)	
	-- replace champions perks tooltips
	local oldLayoutChampionConstellation = tooltip.LayoutChampionConstellation
	tooltip.LayoutChampionConstellation = function(control, attributeName, attributeIcon, constellationName, constellationDescription, numPointsAvailable, numSpentPoints, ...)	
		local attributeTitleSection = control:AcquireSection(control:GetStyle("attributeTitleSection")) 
		attributeTitleSection:AddLine(attributeName, control:GetStyle("attributeTitle")) 
		attributeTitleSection:AddTexture(attributeIcon, control:GetStyle("attributeIcon")) 
		attributeTitleSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, control:GetStyle("dividerLine")) 
		control:AddSection(attributeTitleSection) 

		local availablePointsSection = control:AcquireSection(control:GetStyle("championPointsSection")) 
		availablePointsSection:AddLine(GetString(SI_GAMEPAD_CHAMPION_AVAILABLE_POINTS_LABEL), control:GetStyle("pointsHeader")) 
		availablePointsSection:AddLine(numPointsAvailable, control:GetStyle("pointsValue")) 
		control:AddSection(availablePointsSection) 

		local constellationTitleSection = control:AcquireSection(control:GetStyle("championTitleSection"), control:GetStyle("championTitle")) 
		constellationTitleSection:AddLine(constellationName, control:GetStyle("championTitle")) 
		constellationTitleSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, control:GetStyle("dividerLine")) 
		control:AddSection(constellationTitleSection) 

		local spentPointsSection = control:AcquireSection(control:GetStyle("championPointsSection")) 
		spentPointsSection:AddLine(GetString(SI_GAMEPAD_CHAMPION_ALLOCATED_POINTS_LABEL), control:GetStyle("pointsHeader")) 
		spentPointsSection:AddLine(numSpentPoints, control:GetStyle("pointsValue")) 
		control:AddSection(spentPointsSection) 

		local bodySection = control:AcquireSection(control:GetStyle("championBodySection"), control:GetStyle("bodySection")) 
		bodySection:AddLine(constellationDescription, control:GetStyle("bodyDescription")) 
		control:AddSection(bodySection) 
	end
	------------------------------------------------------------------------------
	local oldLayoutChampionSkillAbility = tooltip.LayoutChampionSkillAbility
	tooltip.LayoutChampionSkillAbility = function(control, disciplineIndex, skillIndex, pendingPoints) 
		local abilityId = GetChampionAbilityId(disciplineIndex, skillIndex) 
		local HIDE_RANK = true 
		local OVERRIDE_RANK = nil 
		--control:LayoutAbility(abilityId, HIDE_RANK, OVERRIDE_RANK, pendingPoints) 
		if(DoesAbilityExist(abilityId)) then 
			local hasProgression, progressionIndex, lastRankXP, nextRankXP, currentXP, atMorph = GetAbilityProgressionXPInfoFromAbilityId(abilityId) 
			--control:AddAbilityName(abilityId, HIDE_RANK, OVERRIDE_RANK) 
			local abilityName = GetAbilityName(abilityId) 
			local rank = OVERRIDE_RANK 
			if(OVERRIDE_RANK == nil) then 
				rank = GetAbilityProgressionRankFromAbilityId(abilityId) 
			end 
			if(not HIDE_RANK and rank ~= nil and rank > 0) then 
				control:AddLine(zo_strformat(SI_ABILITY_NAME_AND_RANK, abilityName, rank), control:GetStyle("championTitle")) 
			else 
				control:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_NAME, abilityName), control:GetStyle("championTitle")) 
			end 
			if(hasProgression) then 
				control:AddAbilityProgressBar(currentXP, lastRankXP, nextRankXP, atMorph) 
			end 
			if(not IsAbilityPassive(abilityId)) then 
				control:AddAbilityStats(abilityId) 
			end 
			if(addNewEffects) then 
				control:AddAbilityNewEffects(GetAbilityNewEffectLines(abilityId)) 
			end 
			--control:AddAbilityDescription(abilityId, pendingPoints) 
			local descriptionHeader = GetAbilityDescriptionHeader(abilityId) 
			local description 
			if not pendingPoints then 
				description = GetAbilityDescription(abilityId) 
			else 
				description = GetChampionAbilityDescription(abilityId, pendingPoints) 
			end 
			if(descriptionHeader ~= "" or description ~= "") then 
				local descriptionSection = control:AcquireSection(control:GetStyle("championBodySection"), control:GetStyle("bodySection"))  
				if(descriptionHeader ~= "") then 
					descriptionSection:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER, descriptionHeader), control:GetStyle("championBodyHeader")) 
				end 
				if(description ~= "") then 
					descriptionSection:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, description), control:GetStyle("bodyDescription")) 
				end 
				control:AddSection(descriptionSection) 
			end 
		end 
		local unlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex) 
		if unlockLevel ~= nil then 
			local unlockSection = control:AcquireSection(control:GetStyle("championBodySection"), control:GetStyle("bodySection")) 
			local unlockText 
			local textColor 
			if not WillChampionSkillBeUnlocked(disciplineIndex, skillIndex) then 
				unlockText = SI_CHAMPION_TOOLTIP_LOCKED 
				textColor = control:GetStyle("failed") 
			else 
				unlockText = SI_CHAMPION_TOOLTIP_UNLOCKED 
				textColor = control:GetStyle("succeeded") 
			end 
			unlockSection:AddLine(zo_strformat(unlockText, GetChampionDisciplineName(disciplineIndex), unlockLevel), control:GetStyle("bodyDescription"), textColor) 
			control:AddSection(unlockSection) 
		else 
			--if it's possible to spend more points on this skill (we haven't hit cap) 
			if GetNumPointsSpentOnChampionSkill(disciplineIndex, skillIndex) + pendingPoints < GetMaxPossiblePointsInChampionSkill() then 
				local upgradeSection = control:AcquireSection(control:GetStyle("championBodySection"), control:GetStyle("bodySection")) 
				local nextPointDescription = GetChampionAbilityDescription(abilityId, pendingPoints + 1) 
				if nextPointDescription ~= "" then 
					upgradeSection:AddLine(GetString(SI_CHAMPION_TOOLTIP_NEXT_POINT), control:GetStyle("championAbilityUpgrade"), control:GetStyle("championBodyHeader")) 
					upgradeSection:AddLine(zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, nextPointDescription), control:GetStyle("championAbilityUpgrade"), control:GetStyle("bodyDescription")) 
					control:AddSection(upgradeSection) 
				end 

				local attribute = GetChampionDisciplineAttribute(disciplineIndex) 
				local iconPath = GetChampionPointAttributeIcon(attribute) 
				local pointCostSection = control:AcquireSection(control:GetStyle("championBodySection"), control:GetStyle("bodySection")) 
				if HasAvailableChampionPointsInAttribute(attribute) then 
					if CHAMPION_PERKS:GetNumAvailablePointsThatCanBeSpent(attribute) > 0 then 
						pointCostSection:AddLine(zo_strformat(SI_CHAMPION_TOOLTIP_UPGRADE, iconPath), control:GetStyle("bodyDescription"), control:GetStyle("succeeded")) 
					else 
						local attributeName = ZO_Champion_GetUnformattedConstellationGroupNameFromAttribute(attribute) 
						pointCostSection:AddLine(zo_strformat(SI_CHAMPION_TOOLTIP_REACHED_MAX_SPEND_LIMIT, GetMaxSpendableChampionPointsInAttribute(), iconPath, attributeName), control:GetStyle("bodyDescription"), control:GetStyle("failed")) 
					end 
				else 
					pointCostSection:AddLine(zo_strformat(SI_CHAMPION_TOOLTIP_POINTS_REQUIRED, iconPath), control:GetStyle("bodyDescription"), control:GetStyle("failed")) 
				end 
				control:AddSection(pointCostSection) 
			end 
		end 
	end 
	------------------------------------------------------------------------------
end
	-- replace tooltips
function kelaReplaceTooltips (tooltip)	
	
	-- kelaTotalRedefineStyles()
	
	-- replace type, style and unique info
	local oldAddTypeSlotUniqueLine = tooltip.AddTypeSlotUniqueLine
	tooltip.AddTypeSlotUniqueLine = function(control, itemLink, itemType, section, text1, text2, ...)	
		--KelaPostMsg(tostring(text1))
		if(text1) then 
			local unique = IsItemLinkUnique(itemLink) 
			local uniqueEquipped = IsItemLinkUniqueEquipped(itemLink) 
			local formatSuffix 
			if(unique) then 
				formatSuffix = "_UNIQUE"
			elseif(uniqueEquipped) then 
				formatSuffix = "_UNIQUE_EQUIPPED"
			else 
				formatSuffix = "" 
			end 		
			local lineText 
			local itemStyle = GetItemLinkItemStyle(itemLink)
			local equipType = GetItemLinkEquipType(itemLink) 	
			if equipType and itemStyle ~= ITEMSTYLE_NONE and equipType ~= EQUIP_TYPE_INVALID and equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_POISON and equipType ~= EQUIP_TYPE_NECK and equipType ~= EQUIP_TYPE_COSTUME then
		
				local itemType, specializedItemType = GetItemLinkItemType(itemLink) 
				local specializedItemTypeText = ZO_GetSpecializedItemTypeText(itemType, specializedItemType) 
				local armorType = GetItemLinkArmorType(itemLink)
				local weaponType = GetItemLinkWeaponType(itemLink) 			
				local styleColor, styleText = getStyleHeaderLine(itemStyle)
				if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then 
					lineText = GetString("SI_EQUIPTYPE", equipType).." ("..GetString("SI_ARMORTYPE", armorType).." - "..styleColor:Colorize(styleText)..")"
				elseif weaponType ~= WEAPONTYPE_NONE then 
					lineText = GetString("SI_WEAPONTYPE", weaponType).." ("..GetString("SI_EQUIPTYPE", equipType).." - "..styleColor:Colorize(styleText)..")" 					
				end
			else
				if(text2) then 
					if equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_NECK and equipType ~= EQUIP_TYPE_COSTUME then
						local format = _G["SI_ITEM_FORMAT_STR_TEXT1_TEXT2"..formatSuffix]
						lineText = zo_strformat(format, text1, text2) 
					else
						local format = _G["SI_ITEM_FORMAT_STR_TEXT1"..formatSuffix] 
						lineText = zo_strformat(format, text1) 
					end					
				else 
					local format = _G["SI_ITEM_FORMAT_STR_TEXT1"..formatSuffix] 
					lineText = text1
					if formatSuffix == "_UNIQUE" then
						lineText = text1.." "..GetString(SI_ITEM_FORMAT_STR_UNIQUE)
					elseif formatSuffix == "_UNIQUE_EQUIPPED" then
						lineText = text1.." "..GetString(SI_ITEM_FORMAT_STR_UNIQUE_EQUIPPED)
					end
				end 				
			end 
			if(lineText) then 
				section:AddLine(lineText, {fontSize = KELA_TOOLTIPS_FONT_SMALL, customSpacing = 0, childSpacing = 0})
			end 
			

		end
		-- local ret = oldAddTypeSlotUniqueLine(control, itemLink, itemType, section, text1, text2, ...)	
		-- return ret	
	end 
	
	-- replace currency and add trading info
	local oldAddItemValue = tooltip.AddItemValue -- hide old AddItemValue
	tooltip.AddItemValue = function(control, itemLink, ...)
	
	end
	local oldAddItemTitle = tooltip.AddItemTitle
	tooltip.AddItemTitle = function(control, itemLink, name, ...)
		local ret = oldAddItemTitle(control, itemLink, name, ...)
		local kelaLine = control:AcquireSection(control:GetStyle("kelaTrade")) 
		local kelaRecipeLine = control:AcquireSection(control:GetStyle("kelaTrade"))
		local valueColor = colors.COLOR_WHITE
		local itemStyle = GetItemLinkItemStyle(itemLink)
		local itemType, specializedItemType = GetItemLinkItemType(itemLink) 
		local specializedItemTypeText = ZO_GetSpecializedItemTypeText(itemType, specializedItemType) 
		local equipType = GetItemLinkEquipType(itemLink) 
		local armorType = GetItemLinkArmorType(itemLink)
		local weaponType = GetItemLinkWeaponType(itemLink) 	

		-- собираем строку цен товара и продукции (для рецептов)
		local iconGold = zo_iconFormat("EsoUI/Art/currency/gamepad/gp_gold.dds", "40", "40") 

		local hideItemLevel = ignoreLevel or ShouldHideTooltipRequiredLevel(itemLink)
		local CONSIDER_CONDITION = true 
		local value = GetItemLinkValue(itemLink, not CONSIDER_CONDITION)
		local finalValue
		local effectiveValue
		local valueString = colors.COLOR_WHITE:Colorize(zo_strformat(SI_GAMEPAD_TOOLTIP_ITEM_VALUE_FORMAT, "0", iconGold))
		local resultItemLink = nil
		local resultValueString
		local averageGuildPrice = 0
		local countGuildPrice = 0
		if itemType == ITEMTYPE_RECIPE then
			resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			resultValueString = colors.COLOR_WHITE:Colorize(GetString(KELA_PRODUCT))
		end
		if(value > 0) then 
			effectiveValue = GetItemLinkValue(itemLink, CONSIDER_CONDITION) 
			finalValue = value 
			if(effectiveValue ~= value) then 
				finalValue = zo_strformat(SI_ITEM_FORMAT_STR_EFFECTIVE_VALUE_OF_MAX, effectiveValue, value)
			end 
			valueString = colors.COLOR_WHITE:Colorize(zo_strformat(SI_GAMEPAD_TOOLTIP_ITEM_VALUE_FORMAT, finalValue, iconGold))
			if resultItemLink then
				resultFinalValue = GetItemLinkValue(resultItemLink, not CONSIDER_CONDITION) 
				resultValueString = resultValueString..colors.COLOR_WHITE:Colorize(zo_strformat(SI_GAMEPAD_TOOLTIP_ITEM_VALUE_FORMAT, resultFinalValue, iconGold))				
			end			
		end
		if TamrielTradeCentre ~= nil then
			valueString = valueString..colors.COLOR_WHITE:Colorize(", ")
			local priceInfoTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if (priceInfoTTC ~= nil) then
				if (priceInfoTTC.SuggestedPrice ~= nil) then
					averageGuildPrice = averageGuildPrice + (priceInfoTTC.SuggestedPrice * 1.125)
					local valueTTC = KelaLocalizedFormatNumber(priceInfoTTC.SuggestedPrice * 1.125, 2)
					valueString = valueString..zo_strformat("|cf23d8e<<1>> TTC|r", valueTTC)
					countGuildPrice = countGuildPrice + 1
				else
					valueString = valueString..zo_strformat("|cf23d8e- TTC|r")
				end
			else
				valueString = valueString..zo_strformat("|cf23d8e- TTC|r")
			end
			if resultItemLink then
				resultValueString = resultValueString..colors.COLOR_WHITE:Colorize(", ")
				local priceInfoTTC = TamrielTradeCentrePrice:GetPriceInfo(resultItemLink)
				if (priceInfoTTC ~= nil) then
					if (priceInfoTTC.SuggestedPrice ~= nil) then
						local resultValueTTC = KelaLocalizedFormatNumber(priceInfoTTC.SuggestedPrice * 1.125, 2)
						resultValueString = resultValueString..zo_strformat("|cf23d8e<<1>> TTC|r", resultValueTTC)
					else
						resultValueString = resultValueString..zo_strformat("|cf23d8e- TTC|r")
					end
				else
					resultValueString = resultValueString..zo_strformat("|cf23d8e- TTC|r")
				end
			end		
		end
		if MasterMerchant ~= nil then 
			valueString = valueString..zo_strformat("|cf23d8e, |r") 
			local tipStats = MasterMerchant:itemStats(itemLink, false)
			if tipStats.avgPrice then
				if (tipStats.avgPrice ~= nil) then
					averageGuildPrice = averageGuildPrice + tipStats['avgPrice']
					local valueMM = KelaLocalizedFormatNumber(tonumber(tipStats['avgPrice']), 2)
					valueString = valueString..zo_strformat("|c7171d1<<1>> MM|r", valueMM)
					countGuildPrice = countGuildPrice + 1
				else
					valueString = valueString..zo_strformat("|c7171d1- MM|r")
				end
			else
				valueString = valueString..zo_strformat("|c7171d1- MM|r")
			end
			if resultItemLink then
				resultValueString = resultValueString..zo_strformat("|cf23d8e, |r")
				local tipStats = MasterMerchant:itemStats(resultItemLink, false)
				if tipStats.avgPrice then
					if (tipStats.avgPrice ~= nil) then
						local resultValueMM = KelaLocalizedFormatNumber(tonumber(tipStats['avgPrice']), 2)
						resultValueString = resultValueString..zo_strformat("|c7171d1<<1>> MM|r", resultValueMM)
					else
						resultValueString = resultValueString..zo_strformat("|c7171d1- MM|r")
					end
				else
					resultValueString = resultValueString..zo_strformat("|c7171d1- MM|r")
				end
			end		
		end
		if ArkadiusTradeTools ~= nil then 
			valueString = valueString..zo_strformat("|c7171d1, |r") 
			local averagePrice = GetATTPriceAndStatus(itemLink)
			if averagePrice then
				if (averagePrice ~= nil) then
					averageGuildPrice = averageGuildPrice + averagePrice
					local valueATT = averagePrice
					valueString = valueString..zo_strformat("|cf58585<<1>> ATT|r", valueATT)
					countGuildPrice = countGuildPrice + 1
				else
					valueString = valueString..zo_strformat("|cf58585- ATT|r")
				end
			else
				valueString = valueString..zo_strformat("|cf58585- ATT|r")
			end
			if resultItemLink then
				resultValueString = resultValueString..zo_strformat("|c7171d1, |r") 
				local averagePrice = GetATTPriceAndStatus(resultItemLink)
				if averagePrice then
					if (averagePrice ~= nil) then
						local resultValueATT = averagePrice
						resultValueString = resultValueString..zo_strformat("|cf58585<<1>> ATT|r", resultValueATT)
					else
						resultValueString = resultValueString..zo_strformat("|cf58585- ATT|r")
					end
				else
					resultValueString = resultValueString..zo_strformat("|cf58585- ATT|r")
				end
			end		
		end
		
		if countGuildPrice > 1 then 
			local averageGuildValue = KelaLocalizedFormatNumber(averageGuildPrice / countGuildPrice, 2)
			valueString = valueString.."   "..'|t24:24:EsoUI/Art/currency/currency_gold.dds|t'.." "..colors.COLOR_GOLD:Colorize (averageGuildValue)
		end
		kelaLine:AddLine(valueString)
		
		if resultItemLink then kelaRecipeLine:AddLine(resultValueString) end

		-- выводим дополнительную информацию
		local kelaGuildLine 
		local kelaRecipeGuildLine 
		local blnGuildInfo
		local blnGuildProductInfo 	
		if TamrielTradeCentre ~= nil or MasterMerchant ~= nil or ArkadiusTradeTools ~= nil then
			kelaGuildLine = control:AcquireSection(control:GetStyle("kelaTrade"))		
			kelaRecipeGuildLine = control:AcquireSection(control:GetStyle("kelaTrade")) 
			blnGuildInfo = false
			blnGuildProductInfo = false	
		end		
		if TamrielTradeCentre ~= nil then
			local blnData = true
			local blnProductData = false	
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			local infoTTC = zo_strformat("|cf23d8eTTC: |r")
			local infoTTCRecipe = zo_strformat("|cf23d8eTTC: |r")
			if (priceInfo == nil) then
				infoTTC = infoTTC..zo_strformat("|cf23d8e<<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA))
				blnData = false
			else
				if (true) then
					local countEntry = KelaLocalizedFormatNumber(priceInfo.EntryCount, 0)
					local countAmount = KelaLocalizedFormatNumber(priceInfo.AmountCount, 0)
					if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
						infoTTC = infoTTC..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_XLISTINGSYITEMS), countEntry, countAmount))
					else
						infoTTC = infoTTC..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_XLISTINGS), countEntry))
					end
				end				
				if (true) then 
					local priceMin = KelaLocalizedFormatNumber(priceInfo.Min, 2)
					local priceAvg = KelaLocalizedFormatNumber(priceInfo.Avg, 2)
					local priceMax = KelaLocalizedFormatNumber(priceInfo.Max, 2)
					infoTTC = infoTTC.." "..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_AGGREGATEPRICESXYZ), priceMin, priceMax, priceAvg))
				end
			end
			if resultItemLink then 
				local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(resultItemLink)
				blnProductData = true
				if (priceInfo == nil) then
					infoTTCRecipe = infoTTCRecipe..zo_strformat("|cf23d8e<<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA))
					blnProductData = false
				else
					if (true) then
						local countEntry = KelaLocalizedFormatNumber(priceInfo.EntryCount, 0)
						local countAmount = KelaLocalizedFormatNumber(priceInfo.AmountCount, 0)
						if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
							infoTTCRecipe = infoTTCRecipe..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_XLISTINGSYITEMS), countEntry, countAmount))
						else
							infoTTCRecipe = infoTTCRecipe..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_XLISTINGS), countEntry))
						end
					end
					if (true) then 
						local priceMin = KelaLocalizedFormatNumber(priceInfo.Min, 2)
						local priceAvg = KelaLocalizedFormatNumber(priceInfo.Avg, 2)
						local priceMax = KelaLocalizedFormatNumber(priceInfo.Max, 2)
						infoTTCRecipe = infoTTCRecipe.." "..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'..zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(KELA_TTC_PRICE_AGGREGATEPRICESXYZ), priceMin, priceMax, priceAvg))
					end      					
				end
			end		
			if blnData then 
				kelaGuildLine:AddLine(infoTTC)
				blnGuildInfo = true
			end
			if blnProductData then 
				kelaRecipeGuildLine:AddLine(infoTTCRecipe) 
				blnGuildProductInfo = true
			end
		end
		if MasterMerchant ~= nil then 
			local tipStats = MasterMerchant:itemStats(itemLink, false)
			local infoMM = zo_strformat("|c7171d1MM: |r")
			local infoMMRecipe = zo_strformat("|c7171d1MM: |r")
			local countEntry = tipStats['numSales']
			local countAmount = tipStats['numItems']
			local countDays = tipStats['numDays']
			local craftCost = MasterMerchant:itemCraftPrice(itemLink)
			local blnData = true
			local blnProductData = false	
			if countEntry or countAmount or countDays ~= 10000 then
				if countEntry then
					if countAmount then
						if (countEntry ~= countAmount) then
							infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGSYITEMS), countEntry, countAmount))
						else
							infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), countEntry))
						end
					else
						infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), countEntry))
					end
				end
				if countDays then
					infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_DAYS), countDays))
				end
			else
				infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA))
				blnData = false
			end
			if itemType ~= ITEMTYPE_RECIPE then
				if craftCost then
					craftCost = KelaLocalizedFormatNumber(craftCost, 2)
					if blnData then 
						infoMM = infoMM..zo_strformat("|c7171d1, <<1>>|r", GetString(KELA_MM_CRAFT_COST)..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'.." "..craftCost)
					else
						infoMM = zo_strformat("|c7171d1MM: |r")
						infoMM = infoMM..zo_strformat("|c7171d1<<1>>|r", GetString(KELA_MM_CRAFT_COST)..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'.." "..craftCost)
					end
					blnData = true
				end	
			end
			if resultItemLink then 
				local tipStats = MasterMerchant:itemStats(resultItemLink, false)
				local countEntry = tipStats['numSales']
				local countAmount = tipStats['numItems']
				local countDays = tipStats['numDays']
				local craftCost = MasterMerchant:itemCraftPrice(resultItemLink)
				blnProductData = true
				if countEntry or countAmount or countDays ~= 10000 then
					if countEntry then
						if countAmount then
							if (countEntry ~= countAmount) then
								infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGSYITEMS), countEntry, countAmount))
							else
								infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), countEntry))
							end
						else
							infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), countEntry))
						end
					end
					if countDays then
						infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", string.format(GetString(KELA_MM_DAYS), countDays))
					end
				else
					infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA))
					blnProductData = false	
				end
				if craftCost then
					craftCost = KelaLocalizedFormatNumber(craftCost, 2)
					if blnProductData then 
						infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1, <<1>>|r", GetString(KELA_MM_CRAFT_COST)..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'.." "..craftCost)
					else
						infoMMRecipe = zo_strformat("|c7171d1MM: |r")
						infoMMRecipe = infoMMRecipe..zo_strformat("|c7171d1<<1>>|r", GetString(KELA_MM_CRAFT_COST)..'|t16:16:EsoUI/Art/currency/currency_gold.dds|t'.." "..craftCost)
					end
					blnProductData = true	
				end	
				
			end	
			if blnData then 
				kelaGuildLine:AddLine(infoMM)
				blnGuildInfo = true
			end
			if blnProductData then 
				kelaRecipeGuildLine:AddLine(infoMMRecipe) 
				blnGuildProductInfo = true
			end
		end	
		if ArkadiusTradeTools ~= nil then 
			local averagePrice, statusLine = GetATTPriceAndStatus(itemLink)
			local infoATT = zo_strformat("|cf58585ATT: |r")
			local infoATTRecipe = zo_strformat("|cf58585ATT: |r")
			local blnData = true
			local blnProductData = false	
			if statusLine then
				infoATT = infoATT..zo_strformat("|cf58585<<1>>|r", statusLine)
			else
				infoATT = infoATT..zo_strformat("|cf58585<<1>>|r", statusLine)
				blnData = false	
			end
			if resultItemLink then 
				blnProductData = true
				local averagePrice, statusLine = GetATTPriceAndStatus(itemLink)				
				if statusLine then
					infoATTRecipe = infoATTRecipe..zo_strformat("|cf58585<<1>>|r", statusLine)
				else
					infoATTRecipe = infoATTRecipe..zo_strformat("|cf58585<<1>>|r", statusLine)
					blnProductData = false	
				end
			end	
			if blnData then 
				kelaGuildLine:AddLine(infoATT)
				blnGuildInfo = true
			end
			if blnProductData then 
				kelaRecipeGuildLine:AddLine(infoATTRecipe) 
				blnGuildProductInfo = true
			end
		end
			
		control:AddSection(kelaLine)
		if blnGuildInfo then 
			control:AddSection(kelaGuildLine)
		else
			kelaGuildLine = nil
		end

		if resultItemLink then control:AddSection(kelaRecipeLine) end
		if blnGuildProductInfo then 
			control:AddSection(kelaRecipeGuildLine)
		else
			kelaRecipeGuildLine = nil
		end		
	

		--local ret = oldAddItemValue(control, itemLink, ...)
		--return ret

	end
	-- replace charge, condition and poison bar
	local oldAddPoisonInfo = tooltip.AddPoisonInfo
	tooltip.AddPoisonInfo = function(control, itemLink, equipSlot, ...)	
		local hasPoison, poisonCount, poisonHeader, poisonItemLink = GetItemPairedPoisonInfo(equipSlot) 
		if(hasPoison) then 
			--Poison Count 
			local poisonSection = control:AcquireSection(control:GetStyle("bodyHeader"), {paddingTop = 2, paddingBottom = -5, uppercase = false})
			local poisonString = colors.COLOR_POISON:Colorize(zo_iconTextFormatNoSpace("EsoUI/Art/Tooltips/icon_poison.dds", 44, 44, poisonCount).." - "..poisonHeader)
			poisonSection:AddLine(poisonString, {fontSize = KELA_TOOLTIPS_FONT_MEDIUM}) 
			control:AddSection(poisonSection) 
			--Poison Ability 
			control:AddOnUseAbility(poisonItemLink, {fontSize = KELA_TOOLTIPS_FONT_SMALL})
		end 
		--local ret = oldAddPoisonInfo(control, itemLink, equipSlot, ...)	
	end
	-- local oldAddEnchantChargeBar = tooltip.AddEnchantChargeBar
	-- tooltip.AddEnchantChargeBar = function(control, itemLink, forceFullDurability, previewChargeToAdd, ...)	
		-- local minValue = 0 
		-- local maxValue = 100
		-- local currentValue = 0
		-- local previewToAdd = previewChargeToAdd
		-- local bar = nil 
		-- if(DoesItemLinkHaveArmorDecay(itemLink)) then
			-- currentValue = GetItemLinkCondition(itemLink) 
		-- elseif(DoesItemLinkHaveEnchantCharges(itemLink)) then	
			-- maxValue = GetItemLinkMaxEnchantCharges(itemLink) 
			-- currentValue = forceFullDurability and maxValue or GetItemLinkNumEnchantCharges(itemLink) 
		-- end 
		-- local kelaEnchantChargeBar = control:AcquireSection(control:GetStyle("conditionOrChargeBarSection"), {paddingTop = 0, paddingBottom = 7})
		-- if previewToAdd then 
		    -- bar = control:AcquireStatusBar(control:GetStyle("itemImprovementConditionOrChargeBar"), {paddingTop = 0, paddingBottom = 7}) 
			-- bar:SetMinMax(minValue, maxValue) 
			-- local newValue = zo_clamp(currentValue + previewToAdd, minValue, maxValue) 
			-- bar:SetValueAndPreviewValue(currentValue, newValue) 
		-- else
			-- bar = control:AcquireStatusBar(control:GetStyle("conditionOrChargeBar"), {paddingTop = 0, paddingBottom = 7})
			-- bar:SetMinMax(minValue, maxValue) 
			-- bar:SetValue(currentValue) 
		-- end 
		-- kelaEnchantChargeBar:AddStatusBar(bar) 
		-- control:AddSection(kelaEnchantChargeBar)	
	-- end			
	-- local oldAddConditionBar = tooltip.AddConditionBar
	-- tooltip.AddConditionBar = function(control, itemLink, previewConditionToAdd, ...)	
		-- local minValue = 0 
		-- local maxValue = 100
		-- local currentValue = 0
		-- local previewToAdd = previewConditionToAdd
		-- local bar = nil 
		-- if(DoesItemLinkHaveArmorDecay(itemLink)) then
			-- currentValue = GetItemLinkCondition(itemLink) 
		-- elseif(DoesItemLinkHaveEnchantCharges(itemLink)) then	
			-- maxValue = GetItemLinkMaxEnchantCharges(itemLink) 
			-- currentValue = forceFullDurability and maxValue or GetItemLinkNumEnchantCharges(itemLink) 
		-- end 
		-- local kelaConditionBar = control:AcquireSection(control:GetStyle("conditionOrChargeBarSection"), {paddingTop = 5, paddingBottom = 5})
		-- if previewToAdd then 
			-- bar = control:AcquireItemImprovementStatusBar(itemLink, currentValue, maxValue, previewToAdd) 
		-- else 
			-- bar = control:AcquireStatusBar(control:GetStyle("conditionOrChargeBar"), {paddingTop = 5, paddingBottom = 5})
			-- bar:SetMinMax(minValue, maxValue) 
			-- bar:SetValue(currentValue)		
		-- end 
		-- kelaConditionBar:AddStatusBar(bar) 
		-- control:AddSection(kelaConditionBar)
	-- end	
------------------------------------------------------------------------------
	-- replace enchant section	ESOUI/art/enchanting/enchanting_highlight.dds
	local oldAddEnchant = tooltip.AddEnchant	
	tooltip.AddEnchant = function(control, itemLink, enchantDiffMode, equipSlot, ...) 
		stringEnchant = ""
		enchantDiffMode = enchantDiffMode or ZO_ENCHANT_DIFF_NONE 
		local enchantSection = control:AcquireSection(control:GetStyle("bodySection"))  
		local hasEnchant, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink) 
		local itemType = GetItemLinkItemType(itemLink)
		local equipType = GetItemLinkEquipType(itemLink) 	
		local strIcon = "ESOUI/art/enchanting/enchanting_highlight.dds"
		if(hasEnchant) then 
			stringEnchant = enchantHeader
				local stringEnchantShort
			if string.find(stringEnchant,":") then 
				stringEnchantShort = string.upper(string.sub(stringEnchant, string.find(stringEnchant,":") + 2, string.len(stringEnchant)))
			else 
				stringEnchantShort = string.upper(stringEnchant)
			end
			if enchantDiffMode == ZO_ENCHANT_DIFF_NONE then 
				if (IsItemAffectedByPairedPoison(equipSlot)) then 
					stringEnchant = zo_iconFormat(strIcon, 44, 44).." "..colors.COLOR_WHITE:Colorize(stringEnchantShort).." - "..colors.COLOR_POISON:Colorize(GetString(SI_TOOLTIP_ENCHANT_SUPPRESSED_BY_POISON))
					local suppressedStyle = control:GetStyle("suppressedAbility") 
				else 
					stringEnchant = zo_iconFormat(strIcon, 44, 44).." "..colors.COLOR_WHITE:Colorize(stringEnchantShort).." - "..enchantDescription
				end 
			end 
		end 
		enchantSection:AddLine(stringEnchant, control:GetStyle("bodyDescription"))  
		control:AddSection(enchantSection) 
		if hasEnchant and enchantDiffMode ~= ZO_ENCHANT_DIFF_NONE then 
			local diffColorStyle, icon 
			if enchantDiffMode == ZO_ENCHANT_DIFF_ADD then 
				diffColorStyle = control:GetStyle("enchantDiffAdd") 
				icon = "EsoUI/Art/Buttons/pointsPlus_up.dds" 
			elseif enchantDiffMode == ZO_ENCHANT_DIFF_REMOVE then 
				diffColorStyle = control:GetStyle("enchantDiffRemove") 
				icon = "EsoUI/Art/Buttons/pointsMinus_up.dds" 
			else 
				-- If this assert is hit, support needs to be added for the additional 
				-- enchant diff modes, which do not exist at the time of writing. 
				assert(false) 
			end 
			local enchantmentDescriptionSection = control:AcquireSection(diffColorStyle, control:GetStyle("enchantDiff")) 
			local diffSection = control:AcquireSection(control:GetStyle("enchantDiffTextureContainer")) 
			diffSection:AddTexture(icon, control:GetStyle("enchantDiffTexture")) 
			enchantmentDescriptionSection:AddSection(diffSection) 
			enchantmentDescriptionSection:AddLine(enchantDescription, control:GetStyle("bodyDescription")) 
			control:AddSection(enchantmentDescriptionSection) 
		end 
		--local ret = oldAddEnchant(control, itemLink, enchantDiffMode, equipSlot, ...) 
	end	
------------------------------------------------------------------------------	
	-- replace trait section
	local oldAddTrait = tooltip.AddTrait
	tooltip.AddTrait = function(control, itemLink, ...)
		local kelaNewLine = control:AcquireSection(control:GetStyle("bodySection")) 
		local itemStyle = GetItemLinkItemStyle(itemLink)
		local equipType = GetItemLinkEquipType(itemLink)
		local traitType, traitDescription, traitSubtype, traitSubtypeName, traitSubtypeDescription = GetItemLinkTraitInfo(itemLink)
		local armorType = GetItemLinkArmorType(itemLink)
		local weaponType = GetItemLinkWeaponType(itemLink)
		local researchColor = nil
		local researchIcon = nil	
		local traitText = ""		
		local countBank = KelaPadUI:GetSameTraitCount(BAG_BANK, armorType, weaponType, equipType, traitType)
		local countPack = KelaPadUI:GetSameTraitCount(BAG_BACKPACK, armorType, weaponType, equipType, traitType)
		local countWorn = KelaPadUI:GetSameTraitCount(BAG_WORN, armorType, weaponType, equipType, traitType)
		local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
		researchIcon, researchColor, traitText = getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
		local traitTextIntricate = traitText
		local traitTextOrnate = traitText		
		if equipType and traitType ~= 0 then --itemStyle ~= ITEMSTYLE_NONE and equipType ~= EQUIP_TYPE_INVALID and equipType ~= EQUIP_TYPE_POISON and equipType ~= EQUIP_TYPE_COSTUME then
			if researchStatus then
				if traitText then
					traitText = zo_iconFormat(researchIcon, 44, 44).." "..colors.COLOR_WHITE:Colorize(string.upper(GetString("SI_ITEMTRAITTYPE", traitType))).." ("..researchColor:Colorize(string.lower(traitText))..")"
				end
				kelaNewLine:AddLine(traitText.." - "..traitDescription, control:GetStyle("bodyDescription")) 
				control:AddSection(kelaNewLine)
			end
		end
		if traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
			traitTextIntricate = zo_iconFormat("/esoui/art/tutorial/inventory_trait_intricate_icon.dds", 44, 44).." "..colors.COLOR_WHITE:Colorize(GetString("SI_ITEMTRAITTYPE", traitType))
			kelaNewLine:AddLine(string.upper(traitTextIntricate).." - "..traitDescription, control:GetStyle("bodyDescription")) 
			control:AddSection(kelaNewLine)
		elseif traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
			traitTextOrnate = zo_iconFormat("/esoui/art/tutorial/inventory_trait_ornate_icon.dds", 44, 44).." "..colors.COLOR_WHITE:Colorize(GetString("SI_ITEMTRAITTYPE", traitType))
			kelaNewLine:AddLine(string.upper(traitTextOrnate).." - "..traitDescription, control:GetStyle("bodyDescription")) 
			control:AddSection(kelaNewLine)
		end
		--local ret = oldAddTrait(control, itemLink, ...)
		--return ret
	end
------------------------------------------------------------------------------
	-- replace set
	local oldAddSet = tooltip.AddSet
	tooltip.AddSet = function(control, itemLink, equipped, ...)	
		local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink) 
		if(hasSet) then
			local setSection = control:AcquireSection(control:GetStyle("bodySection")) 
			setSection:AddLine(colors.COLOR_WHITE:Colorize(string.upper(zo_strformat(SI_ITEM_FORMAT_STR_SET_NAME, setName, numEquipped, maxEquipped))), control:GetStyle("bodyDescription"))  
			for i = 1, numBonuses do 
				local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, equipped, i) 
				if(numEquipped >= numRequired) then 
					setSection:AddLine(bonusDescription, control:GetStyle("activeBonus"), control:GetStyle("bodyDescription")) 
				else 
					setSection:AddLine(bonusDescription, control:GetStyle("inactiveBonus"), control:GetStyle("bodyDescription")) 
				end  
			end	
			control:AddSection(setSection)
		end
		-- local ret = oldAddSet(control, itemLink, ...)
		-- return ret
	end
------------------------------------------------------------------------------
	-- replace achievement bars sections
	local oldLayoutAchievementSummary = tooltip.LayoutAchievementSummary
	tooltip.LayoutAchievementSummary = function(control, ...)	
		for categoryIndex=1, GetNumAchievementCategories() do 
			local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(categoryIndex) 

			local categorySection = control:AcquireSection(control:GetStyle("achievementSummaryCategorySection")) 
			categorySection:AddLine(categoryName, control:GetStyle("achievementSummaryCriteriaHeader")) 

			local barSection = control:AcquireSection(control:GetStyle("achievementTopSummarySection")) 
			local statusBar = control:AcquireStatusBar(control:GetStyle("achievementCriteriaBar")) 
			statusBar:SetMinMax(0, totalPoints) 
			statusBar:SetValue(earnedPoints) 
			barSection:AddStatusBar(statusBar) 
			categorySection:AddSection(barSection) 

			control:AddSection(categorySection) 
		end 
	end 	
------------------------------------------------------------------------------
	local oldLayoutAchievementCriteria = tooltip.LayoutAchievementCriteria
	tooltip.LayoutAchievementCriteria = function(control, achievementId, ...)	
		local numCriteria = GetAchievementNumCriteria(achievementId) 
		if numCriteria == 1 then 
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, 1) 
			if numRequired == 1 then 
				-- Do not show a single checkbox. 
				return 
			end 
		end 

		local criteriaSection = control:AcquireSection(control:GetStyle("achievementCriteriaSection")) 

		for i = 1, numCriteria do 
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, i) 
			local isComplete = (numCompleted == numRequired) 

			if numRequired == 1 then -- Checkbox 
				criteriaSection:AddSection(control:GetCheckboxSection(zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description), isComplete, SI_ACHIEVEMENT_CRITERION_FORMAT)) 

			else -- Progress bar. 
				local entrySection = control:AcquireSection(control:GetStyle("achievementTopCriteriaSection")) 
				local statusBar = control:AcquireStatusBar(control:GetStyle("achievementCriteriaBar")) 
				statusBar:SetMinMax(0, numRequired) 
				statusBar:SetValue(numCompleted) 
				entrySection:AddStatusBar(statusBar) 
				local stringDescription = colors.COLOR_WHITE:Colorize(zo_strformat(SI_JOURNAL_PROGRESS_BAR_PROGRESS, numCompleted, numRequired)).." - "..colors.COLOR_BROWN:Colorize(description)
				entrySection:AddLine (stringDescription, control:GetStyle("achievementSubtitleText"))
				-- entrySection:AddLine(zo_strformat(SI_JOURNAL_PROGRESS_BAR_PROGRESS, numCompleted, numRequired), control:GetStyle("statValuePairValueSmall")) 
				-- entrySection:AddLine(zo_strformat(SI_ACHIEVEMENT_CRITERION_FORMAT, description)) 

				criteriaSection:AddSection(entrySection) 
			end 
		end 
		control:AddSection(criteriaSection) 
	end 
------------------------------------------------------------------------------



------------------------------------------------------------------------------
end

function kelaAddInfoTooltipMain()

	-- KelaPostMsg(tostring(SCENE_MANAGER:GetCurrentScene():GetName()))

	
	-- готовим tooltip 			
	KPUI_GAMEPAD_TOOLTIPS:Reset(KPUI_GAMEPAD_LEFT_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_LEFT_TOOLTIP, false)
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltip(KPUI_GAMEPAD_LEFT_TOOLTIP)	
	

	
	local isChampion = IsUnitChampion("player")


	-- имя и аккаунт
	local kelaPlayerName = GetUnitName('player')
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	if isChampion then
		local iconChampion = zo_iconFormat("EsoUI/Art/Champion/Gamepad/gp_champion_icon.dds", 25, 25)
		kelaPlayerName = iconChampion.." "..kelaPlayerName
	end
	kelaPlayerName = kelaPlayerName..colors.COLOR_BROWN:Colorize(" ("..string.lower(kelaPlayerAccountName)..")")

	-- локация
	local stringLocation = GetPlayerLocationName()
	if stringLocation then 
		stringLocation = colors.COLOR_WHITE:Colorize(stringLocation)
	else
		stringLocation = colors.COLOR_WHITE:Colorize(GetString(SI_GAMEPAD_PLAYER_PROGERSS_BAR_UNKNOWN_ZONE))
	end
	
	-- золото и инвентарь
	local strGold = zo_strformat("|<<1>> (<<2>>)|r |t20:20:<<3>>|t", ZO_CurrencyControl_FormatCurrency(GetCurrencyAmount(CURT_MONEY)), ZO_CurrencyControl_FormatCurrency(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)), GetCurrencyGamepadIcon(CURT_MONEY))
	local strBackpack = zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))
	local countStolen, countIntricate, countOrnate = KelaPadUI:GetItemsCounts()
	local myLevel = GetUnitEffectiveLevel("player")
	local _, iconSoulGem, countSoulGem = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, myLevel, false);
	local strCounts = ""
	if countOrnate > 0 then
		strCounts = zo_strformat("|<<1>>|r|t20:20:/esoui/art/tutorial/inventory_trait_ornate_icon.dds|t", countOrnate)
	end
	if countIntricate > 0 then
		if strCounts ~= "" then 
			strCounts = strCounts..", "..zo_strformat("|<<1>>|r|t20:20:/esoui/art/tutorial/inventory_trait_intricate_icon.dds|t", countIntricate)
		else
			strCounts = zo_strformat("|<<1>>|r|t20:20:/esoui/art/tutorial/inventory_trait_intricate_icon.dds|t", countIntricate)
		end
	end
	if countStolen > 0 then
		if strCounts ~= "" then 
			strCounts = strCounts..", "..zo_strformat("|<<1>>|r|t20:20:/EsoUI/Art/Inventory/inventory_stolenItem_icon.dds|t", countStolen)
		else
			strCounts = zo_strformat("|<<1>>|r|t20:20:/EsoUI/Art/Inventory/inventory_stolenItem_icon.dds|t", countStolen)
		end	
	end
	-- if countSoulGem > 0 then
		-- if strCounts ~= "" then 
			-- strCounts = strCounts..", "..countSoulGem..zo_iconFormat(iconSoulGem, 30, 30)
		-- else
			-- strCounts = countSoulGem..zo_iconFormat(iconSoulGem, 30, 30)
		-- end	
	-- end	
	if countStolen > 0 or countIntricate > 0 or countOrnate > 0 then --or countSoulGem > 0 then
		stringStat = strGold..", "..GetString(SI_INVENTORY_MENU_INVENTORY)..": "..strBackpack.." ("..strCounts..")"
	else
		stringStat = strGold..", "..GetString(SI_INVENTORY_MENU_INVENTORY)..": "..strBackpack
	end
	
	KPUI_GAMEPAD_TOOLTIPS:SetStatusLabelText(KPUI_GAMEPAD_LEFT_TOOLTIP, kelaPlayerName, stringStat, stringLocation)

	-- опыт
	local hideEnlightenment = true
	local level
	local current
	local levelSize
	local label
	local labelEnlightened
	local percentageXP
	local barEnlightned = nil
	local barXP = nil 			
	local barSec = nil
	local barSecEnlightned = nil
	local colorXP
	local colorXPEnlightened
	local r, g, b, a
	local r1, g1, b1, a1
	if isChampion then
		level = GetPlayerChampionPointsEarned()
		current = GetPlayerChampionXP()
		levelSize = GetNumChampionXPInChampionPoint(level)
		label = GetString(KELA_LABEL_CHAMPION)
		hideEnlightenment = false
	else
		level = GetUnitLevel("player")
		current = GetUnitXP("player")
		levelSize = GetNumExperiencePointsInLevel(level)
		label = GetString(KELA_LABEL_LEVEL)
		colorXP = ZO_XP_BAR_GRADIENT_COLORS
		colorXPEnlightened = ZO_XP_BAR_GRADIENT_COLORS
	end
	if not levelSize then -- this is for the end of the line
		levelSize = 1
		current = 1
		hideEnlightenment = true
		label = GetString(SI_EXPERIENCE_LIMIT_REACHED)
		colorXP = ZO_CP_BAR_GRADIENT_COLORS[GetChampionPointAttributeForRank(level)]
	else
		local percentageXP = zo_floor(current / levelSize * 100)
		if isChampion then
			local iconActiveCHPAtribute = zo_iconFormat(GetChampionPointAttributeActiveIcon(GetChampionPointAttributeForRank(level+1)), 20, 20)
			label = label..current.."/"..levelSize.." ("..percentageXP.."%)".." "..iconActiveCHPAtribute
		else
			label = label..current.."/"..levelSize.." ("..percentageXP.."%)"
		end
	end			
	local expSectionLevel = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("topSectionTooltipInfo")) 
	expSectionLevel:AddLine(level)
	tooltipInfo:AddSection(expSectionLevel)
	barSecLabel = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipBarSectionLabel"))
	barSecLabel:AddLine(label, tooltipInfo:GetStyle("InfoTooltipBarDesc"), {fontSize = KELA_TOOLTIPS_FONT_SMALL})	
	tooltipInfo:AddSection(barSecLabel)	
	-- barSec = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipBarSection"))
	-- bar = tooltipInfo:AcquireStatusBar(tooltipInfo:GetStyle("InfoTooltipBar"))						
	barSecEnlightned = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipBarSectionEnlightned")) 	
	barEnlightned = tooltipInfo:AcquireStatusBar(tooltipInfo:GetStyle("InfoTooltipBarEnlightned"))
	barSecEnlightned:AddStatusBar(barEnlightned)
	tooltipInfo:AddSection(barSecEnlightned)				
	if not hideEnlightenment  then
		if GetNumChampionXPInChampionPoint(level) ~= nil then
			level = level + 1
		end
		local nextPoint = GetChampionPointAttributeForRank(level)
		colorXP = ZO_CP_BAR_GRADIENT_COLORS[nextPoint]
		r, g, b, a = ZO_CP_BAR_GRADIENT_COLORS[nextPoint][1]:UnpackRGBA()
		r1, g1, b1, a1 = ZO_CP_BAR_GRADIENT_COLORS[nextPoint][2]:UnpackRGBA()				
		if levelSize then
			local poolSize = GetEnlightenedPool()
			barEnlightned:SetMinMax(0, levelSize)
			barEnlightned:SetValue(zo_min(levelSize, current + poolSize))	
		end
	else
		barEnlightned:SetMinMax(0, levelSize)
		barEnlightned:SetValue(0)	
	end
	if not hideEnlightenment  then
		barEnlightned:SetGradientColors(r1, g1, b1, a1, r, g, b, a)
	end	
	barSec = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipBarSection"))
	bar = tooltipInfo:AcquireStatusBar(tooltipInfo:GetStyle("InfoTooltipBar"))						
	barSec:AddStatusBar(bar)	
	tooltipInfo:AddSection(barSec)	
	bar:SetMinMax(0, levelSize)
	bar:SetValue(current) 
	ZO_StatusBar_SetGradientColor(bar, colorXP)		
	
	-- путевые заметки
	local headerInfo = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo"))	
	headerInfo:AddLine(GetString(KELA_TOOLTIP_INTERESTING_INFORMATION), {fontSize = KELA_TOOLTIPS_FONT_MEDIUM, horizontalAlignment = TEXT_ALIGN_CENTER, customSpacing = 20})
	tooltipInfo:AddSection(headerInfo)	
	local countInfo = 0
	if GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK) < 5 then	-- рюкзак полон
		countInfo = countInfo + 1
		local infoBackPackSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
		local infoBackPack = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		infoBackPack:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))
		infoBackPack:SetValue(colors.COLOR_RED:Colorize(GetString(KELA_TOOLTIP_II_BACKPACK_FULL)), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
		infoBackPackSection:AddStatValuePair(infoBackPack)
		tooltipInfo:AddSection(infoBackPackSection)
	elseif GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK) < 15 then	-- рюкзак почти полон
		countInfo = countInfo + 1
		local infoBackPackSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
		local infoBackPack = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		infoBackPack:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))
		infoBackPack:SetValue(colors.COLOR_NOTSOON:Colorize(GetString(KELA_TOOLTIP_II_BACKPACK_NEAR_FULL)), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
		infoBackPackSection:AddStatValuePair(infoBackPack)
		tooltipInfo:AddSection(infoBackPackSection)			
	end		
	if GetTimeUntilCanBeTrained() == 0 then -- конюшня
		countInfo = countInfo + 1
		local infoTrainingSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
		local infoTraining = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		infoTraining:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))
		infoTraining:SetValue(colors.COLOR_NEARLY:Colorize(GetString(KELA_TOOLTIP_II_STABLETRAINING_AVAILABLE)), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
		infoTrainingSection:AddStatValuePair(infoTraining)
		tooltipInfo:AddSection(infoTrainingSection)		
	end
	local countBlacksmithing, countClothier, countWoodworking, countJewelry = KelaPadUI:GetAvailableResearchLines() -- исследования
	if countBlacksmithing > 0 or countClothier > 0 or countWoodworking > 0 or countJewelry > 0 then
		if countBlacksmithing > 0 then
			local _, _, _, countAvailableTraits = KelaPadUI:GetAvailableTraitCount(CRAFTING_TYPE_BLACKSMITHING)

			if countAvailableTraits > 0 then
				countInfo = countInfo + 1
				local stringAvailable
				if countBlacksmithing == 1 then
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE_ONE)
				else
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE)
				end				
				local infoBlacksmithingSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
				local infoBlacksmithing = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
				infoBlacksmithing:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))				
				infoBlacksmithing:SetValue(colors.COLOR_NEARLY:Colorize(string.upper(GetString(SI_ITEMFILTERTYPE13)).." - "..tostring(countBlacksmithing)..stringAvailable), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
				infoBlacksmithingSection:AddStatValuePair(infoBlacksmithing)
				tooltipInfo:AddSection(infoBlacksmithingSection)		
			end
		end	
		if countClothier > 0 then
			local _, _, _, countAvailableTraits = KelaPadUI:GetAvailableTraitCount(CRAFTING_TYPE_CLOTHIER)
			if countAvailableTraits > 0 then
				countInfo = countInfo + 1
				local stringAvailable
				if countClothier == 1 then
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE_ONE)
				else
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE)
				end		
				local infoClothierSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
				local infoClothier = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
				infoClothier:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))				
				infoClothier:SetValue(colors.COLOR_NEARLY:Colorize(string.upper(GetString(SI_ITEMFILTERTYPE14)).." - "..tostring(countClothier)..stringAvailable), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
				infoClothierSection:AddStatValuePair(infoClothier)
				tooltipInfo:AddSection(infoClothierSection)		
			end		
		end
		if countWoodworking > 0 then
			local _, _, _, countAvailableTraits = KelaPadUI:GetAvailableTraitCount(CRAFTING_TYPE_WOODWORKING)
			if countAvailableTraits > 0 then
				countInfo = countInfo + 1
				local stringAvailable
				if countWoodworking == 1 then
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE_ONE)
				else
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE)
				end		
				local infoWoodworkingSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
				local infoWoodworking = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
				infoWoodworking:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))				
				infoWoodworking:SetValue(colors.COLOR_NEARLY:Colorize(string.upper(GetString(SI_ITEMFILTERTYPE15)).." - "..tostring(countWoodworking)..stringAvailable), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
				infoWoodworkingSection:AddStatValuePair(infoWoodworking)
				tooltipInfo:AddSection(infoWoodworkingSection)		
			end			
		end
		if countJewelry > 0 then
			local _, _, _, countAvailableTraits = KelaPadUI:GetAvailableTraitCount(CRAFTING_TYPE_JEWELRYCRAFTING)
			if countAvailableTraits > 0 then
				countInfo = countInfo + 1
				local stringAvailable
				if countJewelry == 1 then
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE_ONE)
				else
					stringAvailable = GetString(KELA_TOOLTIP_II_RESEARCH_AVAILABLE)
				end		
				local infoJewelrySection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
				local infoJewelry = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
				infoJewelry:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))				
				infoJewelry:SetValue(colors.COLOR_NEARLY:Colorize(string.upper(GetString(SI_ITEMFILTERTYPE24)).." - "..tostring(countJewelry)..stringAvailable), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
				infoJewelrySection:AddStatValuePair(infoJewelry)
				tooltipInfo:AddSection(infoJewelrySection)		
			end					
		end
	end
	if countSoulGem < 5 then -- камни душ
		countInfo = countInfo + 1
		local infoSoulGemSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
		local infoSoulGem = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		infoSoulGem:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))
		infoSoulGem:SetValue(colors.COLOR_NOTSOON:Colorize(GetString(KELA_TOOLTIP_II_SOULGEM_LOW)), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
		infoSoulGemSection:AddStatValuePair(infoSoulGem)
		tooltipInfo:AddSection(infoSoulGemSection)		
	end	
	if UPU then -- Undaunted Pledges Utilities Dailies Info
		local MAJ      = 1
		local GLIRION  = 2
		local URGARLAG = 3
		local TodaysDailies = {}
		local TodaysQuestInfo = {}
		local daysSinceCycleStartMajAndGlirion = UPU.GetDaysSinceCycleStart(MAJ)
		local daysSinceCycleStartUrgarlag = UPU.GetDaysSinceCycleStart(URGARLAG)
		local iconDailyComplete = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_journalCheck.dds", 30, 30)
		TodaysDailies[MAJ] = UPU.GetLocalizedPledge(daysSinceCycleStartMajAndGlirion, MAJ)
		TodaysQuestInfo[MAJ] = UPU.IsQuestCompleted(daysSinceCycleStartMajAndGlirion, MAJ)
		TodaysDailies[GLIRION] = UPU.GetLocalizedPledge(daysSinceCycleStartMajAndGlirion, GLIRION)
		TodaysQuestInfo[GLIRION] = UPU.IsQuestCompleted(daysSinceCycleStartMajAndGlirion, GLIRION)
		TodaysDailies[URGARLAG] = UPU.GetLocalizedPledge(daysSinceCycleStartUrgarlag, URGARLAG)
		TodaysQuestInfo[URGARLAG] = UPU.IsQuestCompleted(daysSinceCycleStartUrgarlag, URGARLAG)		
		local function GetDailies()
			local DailiesText = colors.COLOR_BLUE:Colorize(GetString(UPU_UNDAUNTED_DAILES)).."\n"
			if UPU.IsQuestCompleted(daysSinceCycleStartMajAndGlirion, MAJ) then
				DailiesText = DailiesText..ZO_DISABLED_TEXT:Colorize(GetString(UPU_MAJ).." - "..TodaysDailies[MAJ].Regular).." "..iconDailyComplete.."\n"
			else
				DailiesText = DailiesText..colors.COLOR_WHITE:Colorize(GetString(UPU_MAJ).." - "..TodaysDailies[MAJ].Regular).."\n"
			end
			if UPU.IsQuestCompleted(daysSinceCycleStartMajAndGlirion, GLIRION) then
				DailiesText = DailiesText..ZO_DISABLED_TEXT:Colorize(GetString(UPU_GLIRION).." - "..TodaysDailies[GLIRION].Regular).." "..iconDailyComplete.."\n"
			else
				DailiesText = DailiesText..colors.COLOR_WHITE:Colorize(GetString(UPU_GLIRION).." - "..TodaysDailies[GLIRION].Regular).."\n"
			end
			if UPU.IsQuestCompleted(daysSinceCycleStartUrgarlag, URGARLAG) then
				DailiesText = DailiesText..ZO_DISABLED_TEXT:Colorize(GetString(UPU_URGARLAG).." - "..TodaysDailies[URGARLAG].Regular).." "..iconDailyComplete
			else
				DailiesText = DailiesText..colors.COLOR_WHITE:Colorize(GetString(UPU_URGARLAG).." - "..TodaysDailies[URGARLAG].Regular)
			end
			return DailiesText
		end		
		countInfo = countInfo + 1
		local infoUPUSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
		local infoUPU = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		infoUPU:SetStat(countInfo..".  ", tooltipInfo:GetStyle("InfoTooltipStatValuePairStat"))
		infoUPU:SetValue(GetDailies(), tooltipInfo:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
		infoUPUSection:AddStatValuePair(infoUPU)
		tooltipInfo:AddSection(infoUPUSection)
	end
	if countInfo == 0 then
		local headerInfo = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))	
		headerInfo:AddLine(colors.COLOR_GREY:Colorize(GetString(KELA_TOOLTIP_INTERESTING_INFORMATION_NO)), {horizontalAlignment = TEXT_ALIGN_CENTER})
		tooltipInfo:AddSection(headerInfo)	
	end
	
	
	-- -- торговля
	-- local headerTrades = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo"))	
	-- headerTrades:AddLine("Торговля", {fontSize = KELA_TOOLTIPS_FONT_MEDIUM, horizontalAlignment = TEXT_ALIGN_CENTER, customSpacing = 10})
	-- tooltipInfo:AddSection(headerTrades)			

	-- for i = 1, GetNumGuilds() do
		-- local guildId = GetGuildId(i)
		-- local guildName = GetGuildName(guildId)
		-- local guildAlliance = GetGuildAlliance(guildId) 
		-- local guildText = zo_iconTextFormat(GetAllianceBannerIcon(guildAlliance), 32, 32, guildName)
		-- --local entry = self:CreateItemEntry(guildText, self.OnGuildSelected)
		-- --entry.guildId = guildId
		-- --entry.guildText = guildText
		-- local currentListings, maxListings = GetTradingHouseListingCounts() 
		-- local headerGuilds = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))	
		-- headerGuilds:AddLine(guildText)
		-- headerGuilds:AddLine(zo_strformat(SI_GAMEPAD_TRADING_HOUSE_LISTING_CREATE, currentListings, maxListings))
		-- tooltipInfo:AddSection(headerGuilds)	
	-- end



	
	-- текущее задание
	local sectionQuest = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
	
	local questIndex = QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()
	
	local questName, bgText, stepText, _, stepOverrideText, _, _, _, _, _, instanceDisplayType = GetJournalQuestInfo(questIndex)
	
	if questName then
	
		local questLevel = GetJournalQuestLevel(questIndex)
		local conColorDef = ZO_ColorDef:New(GetConColor(questLevel))		

		local questIcon = nil
		local questTypeText = ""
		local ICON_SIZE = 28
		local iconTrackedQuest = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_trackedQuestIcon.dds", ICON_SIZE, ICON_SIZE)
		if instanceDisplayType == INSTANCE_DISPLAY_TYPE_SOLO then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_instance.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE1).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_DUNGEON then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_groupDungeon.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE2).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_RAID then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_raid.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE3).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_GROUP_AREA then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_groupArea.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE5).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_GROUP_DELVE then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_groupDelve.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE4).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_PUBLIC_DUNGEON then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_dungeon.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE6).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_DELVE then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_delve.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE7).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_HOUSING then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_housing.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE8).." "..questIcon
		elseif instanceDisplayType == INSTANCE_DISPLAY_TYPE_ZONE_STORY then
			questIcon = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_questTypeIcon_zoneStory.dds", ICON_SIZE, ICON_SIZE)
			questTypeText = GetString(SI_INSTANCEDISPLAYTYPE10).." "..questIcon
		end

		local repeatableType = GetJournalQuestRepeatType(questIndex)
		local repeatableText = ""
		if repeatableType ~= QUEST_REPEAT_NOT_REPEATABLE then
			repeatableText = GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT).." "..zo_iconFormat("EsoUI/Art/Journal/journal_Quest_Repeat.dds", 16, 20)
			if questTypeText ~= "" then
				questTypeText = questTypeText..", "..repeatableText
			else
				questTypeText = repeatableText
			end
		end	

		local function GetQuestCategory()
			local questMasterList = QUEST_JOURNAL_MANAGER:GetQuestListData()
			for i, quest in ipairs(questMasterList) do
				if quest.questIndex == questIndex then
					return quest.categoryName
				end
			end
			return ""
		end
		
		sectionQuest:AddLine(iconTrackedQuest..conColorDef:Colorize(questName), tooltipInfo:GetStyle("bodyHeader"), {fontFace = "$(GAMEPAD_LIGHT_FONT)", horizontalAlignment = TEXT_ALIGN_CENTER, customSpacing = 15, childSpacing = 15})
		sectionQuest:AddLine("   "..colors.COLOR_WHITE:Colorize(GetQuestCategory()))
		if questTypeText ~= "" then sectionQuest:AddLine("   "..colors.COLOR_WHITE:Colorize(questTypeText)) end
		sectionQuest:AddLine("   "..bgText)
		if stepText ~= "" then sectionQuest:AddLine("   "..stepText) end
		sectionQuest:AddLine("   "..colors.COLOR_WHITE:Colorize(GetString(SI_QUEST_JOURNAL_QUEST_TASKS)..":"))

		local conditionText = ""
		local iconTaskComplete = zo_iconFormat("EsoUI/Art/Journal/Gamepad/gp_journalCheck.dds", 30, 30)
		local iconTaskBullet = zo_iconFormat("EsoUI/Art/Miscellaneous/bullet.dds", 13, 13)
		local currentCount, maxCount, isFailCondition, isComplete, isVisible
		if stepOverrideText and (stepOverrideText ~= "") then
			conditionText, currentCount, maxCount, isFailCondition, isComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, nil)
			if(isVisible and not isFailCondition and conditionText ~= "") then
				if isComplete then
					conditionText = ZO_DISABLED_TEXT:Colorize("   "..conditionText.." "..iconTaskComplete)
				else
					conditionText = colors.COLOR_WHITE:Colorize("   "..conditionText)
				end
				sectionQuest:AddLine(conditionText)
			end
		else
			local conditionCount = GetJournalQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX)
			for i = 1, conditionCount do
				conditionText, currentCount, maxCount, isFailCondition, isComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, i)
				if(isVisible and not isFailCondition and conditionText ~= "") then
					if isComplete then
						conditionText = ZO_DISABLED_TEXT:Colorize("   "..conditionText.." "..iconTaskComplete)
					else
						conditionText = colors.COLOR_WHITE:Colorize("   "..conditionText)
					end	
					sectionQuest:AddLine(conditionText)
				end			
			end
		end		
		
	-- local function GetDungeonName(dungeonIndex)
        -- return GetLFGOption(LFG_ACTIVITY_DUNGEON, dungeonIndex)
    -- end		
		-- dungeonIndex = 1
		-- KelaPostMsg("dungeonIndex "..dungeonIndex)
		-- KelaPostMsg("LFG_ACTIVITY_DUNGEON "..LFG_ACTIVITY_DUNGEON)
		


		
		tooltipInfo:AddSection(sectionQuest)
	end


	
	-- -- --GAMEPAD_TOOLTIPS:ShowBg(GAMEPAD_LEFT_TOOLTIP) 
	-- KPUI_GAMEPAD_TOOLTIPS:ShowBg(KPUI_GAMEPAD_RIGHT_TOOLTIP) 

end

