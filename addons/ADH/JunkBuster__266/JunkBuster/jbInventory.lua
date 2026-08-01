jb = jb or {}
local utils = jb.utils

function jb.inventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason, triggCharName, trigDisplayName, isLastUpdateForMsg, bonusDropSource)
    if bagId == BAG_BACKPACK and isNewItem then
        local item = utils.getItemData(bagId, slotId)
        item.soundCategory = itemSoundCategory
		--item.link:gsub("%[.*%]", zo_strformat("<<tx:1>>", item.link))
        local itemName = jb.getStringInfo(item)
        local action, rIdx = jb.getAction(item)
		local rStr = ", Rule " .. jb.color.ruleNr .. "[" .. rIdx .. "]"

		if action == JB_RTYPE_SAVE and jb.vars.doSave then
            if jb.vars.showSave then
                d(jb.chatTag .. jb.color.keep .. "Kept|r " .. itemName .. rStr)
            end
            SetItemIsJunk(bagId, slotId, false)
		elseif action == JB_RTYPE_DESTROY and jb.vars.doDestroy then
            if jb.vars.showDestroy then
                d(jb.chatTag .. jb.color.destroy .. "Destroyed|r " .. itemName .. rStr)
            end
			DestroyItem(bagId, slotId)
		elseif action == JB_RTYPE_JUNK and jb.vars.doJunk then
            if jb.vars.showJunk then
                d(jb.chatTag .. jb.color.junk .. "Junked|r " .. itemName .. rStr)
            end
            SetItemIsJunk(bagId, slotId, true)
		elseif jb.vars.showLoot then
			d(jb.chatTag .. "Looted " .. itemName)
		end
    end
end

function jb.getAction(item)
	for k,v in ipairs(jb.vars.ruleOrder) do
		if v.Type == JB_RTYPE_SAVE and jb.matchesRule(item, jb.vars.saveRules[v.Idx]) then 
			return v.Type, k
		elseif v.Type == JB_RTYPE_DESTROY and jb.matchesRule(item, jb.vars.destroyRules[v.Idx]) then 
			return v.Type, k
		elseif v.Type == JB_RTYPE_JUNK and jb.matchesRule(item, jb.vars.junkRules[v.Idx]) then 
			return v.Type, k
		end
	end
    return 0, 0
end

function jb.matchesRule(item, rule)
    if rule.namePattern and (not string.match(string.lower(item.name), utils.esc(string.lower(rule.namePattern)))) then return false end

    if rule.minPrice and (item.price < rule.minPrice) then return false end
    if rule.maxPrice and (item.price > rule.maxPrice) then return false end
    if rule.minLevel and (item.level < rule.minLevel) then return false end
    if rule.maxLevel and (item.level > rule.maxLevel) then return false end
	
    if rule.minReqLevel and (item.reqLevel < rule.minReqLevel) then return false end
    if rule.maxReqLevel and (item.reqLevel > rule.maxReqLevel) then return false end
    if rule.minReqCP and (item.reqCP < rule.minReqCP) then return false end
    if rule.maxReqCP and (item.reqCP > rule.maxReqCP) then return false end

    if rule.quality and (item.quality ~= rule.quality) then return false end
    if rule.itemType and (item.itemType ~= rule.itemType) then return false end
	if rule.specType and (item.specType ~= rule.specType) then return false end
    if rule.equipType and (item.equipType ~= rule.equipType) then return false end
    if rule.craft and (item.craft ~= rule.craft) then return false end
    if rule.trait and (item.trait ~= rule.trait) then return false end
    if rule.weaponType and (item.weaponType ~= rule.weaponType) then return false end
    if rule.armorType and (item.armorType ~= rule.armorType) then return false end
	if rule.actorType and (item.actorType ~= rule.actorType) then return false end

	if not rule.isCrafted and item.isCrafted then return false end
	if rule.isCrafted and (not item.isCrafted and rule.isCrafted == JB_FILTER_IS_CRAFTED) then return false end
	
	if rule.isStolen and (item.isStolen and rule.isStolen == JB_FILTER_IS_NOT_STOLEN) then return false end
	if rule.isStolen and (not item.isStolen and rule.isStolen == JB_FILTER_IS_STOLEN) then return false end
	
	if rule.hasSet and (item.hasSet and rule.hasSet == JB_FILTER_HAS_NO_SET) then return false end
	if rule.hasSet and (not item.hasSet and rule.hasSet == JB_FILTER_HAS_SET) then return false end
	
	if rule.isKnown and (item.isKnown and rule.isKnown == JB_FILTER_REC_IS_NOT_KNOWN) then return false end
	if rule.isKnown and (not item.isKnown and rule.isKnown == JB_FILTER_REC_IS_KNOWN) then return false end
	
    return true
end

function jb.getStringInfo(item)
    local res = ""
    if item.stack > 1 then
        res = res .. item.stack .. "x"
    end
	
    res = res .. item.link

    if jb.vars.debugPrint then
        res = res .. " (" .. item.price .. "g rL"
		res = res .. item.reqLevel .. " rCP" .. item.reqCP .. " "
        res = res .. utils.qualityNames[item.quality] .. " quality "

        local itemTypeStr = utils.typeNames[item.itemType]
        if (item.itemType > 0) and itemTypeStr then
			res = res .. itemTypeStr
			local specTypeStr = utils.specTypeNames.all[item.specType]
			if item.specType > 0 and specTypeStr and specTypeStr ~= "<None>" then
				res = res .. "/" .. specTypeStr
			end
        else
            res = res .. "item"
        end
		local equipTypeStr = utils.equipTypeNames[item.equipType]
		local armorTypeStr = utils.armorTypeNames[item.armorType]
		local weaponTypeStr = utils.weaponTypeNames[item.weaponType]
		if item.itemType == ITEMTYPE_ARMOR and (equipTypeStr or armorTypeStr) then
			res = res .. " ("
			if armorTypeStr then
				res = res .. armorTypeStr
				if equipTypeStr then
					res = res .. ", " .. equipTypeStr .. ")"
				end
			else
				res = res .. equipTypeStr .. ")"
			end
		elseif item.itemType == ITEMTYPE_WEAPON and (equipTypeStr or weaponTypeStr) then
			res = res .. " ("
			if weaponTypeStr then
				res = res .. weaponTypeStr
				if equipTypeStr then
					res = res .. ", " .. equipTypeStr .. ")"
				end
			else
				res = res .. equipTypeStr .. ")"
			end
		end

        local craft = utils.craftNames[item.craft]
        if (item.craft > 0) and craft then
            res = res .. " for " .. craft
        end

        local trait = utils.traitNames[item.trait]
        if (item.trait > 0) and trait then
            res = res .. " with trait " .. trait
        end
		
		local actorType = utils.actorTypeNames[item.actorType]
		if (item.actorType > 0) and actorType then
			res = res .. " for " .. actorType
		end
		
		res = res .. " Crafted=" .. utils.boolStr[item.isCrafted]
		res = res .. " Stolen=" .. utils.boolStr[item.isStolen]
		res = res .. " Set Bonus=" .. utils.boolStr[item.hasSet]
		if (item.itemType == ITEMTYPE_RECIPE) then
			res = res .. " IsKnown=" .. utils.boolStr[item.isKnown]
		end

        res = res .. ")"
    end

    return res
end

function jb.openMerchant()
	if jb.vars.autoSellJunk and HasAnyJunk(BAG_BACKPACK, true) then
		jb.sellJunk(false)
	end
end

function jb.openFence(salesAllowed, launderAllowed)
	if jb.vars.autoSellJunk and salesAllowed and AreAnyItemsStolen(BAG_BACKPACK) and HasAnyJunk(BAG_BACKPACK, false) then
		jb.sellJunk(true)
	end
end

function jb.sellJunk(isFence)
	local totalPrice = 0
	local totalCount = 0
	local priceMult = 1.0
	local actSales = 0
--	local maxSales = 89
	local itemSellStr = {}
	local sellStrCnt = 0

	local invItems = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)

	if isFence then
		priceMult = priceMult + (GetNonCombatBonus(NON_COMBAT_BONUS_HAGGLING) / 100.0)
		invItems = jb.sortInvItemsByPrice(invItems)
	end
	
	for slotId, item in pairs(invItems) do
		if item.isJunk then
			local itemLink = GetItemLink(BAG_BACKPACK, item.slotIndex, LINK_STYLE_BRACKETS)
			if IsItemPlayerLocked(BAG_BACKPACK, item.slotIndex) then
				SetItemIsJunk(BAG_BACKPACK, item.slotIndex, false)
				itemSellStr[sellStrCnt] = item.stackCount .. "x " .. itemLink .. " is protected -> din't sell"
				sellStrCnt = sellStrCnt + 1
			else
				if item.stolen == isFence then
					local itemSellCount = item.stackCount
					
					if isFence then
						local maxFenceSales, usedFenceSales, fenceSalesResetTime = GetFenceSellTransactionInfo()
						if usedFenceSales >= maxFenceSales then
							itemSellStr[sellStrCnt] = "All Fence sales used"
							sellStrCnt = sellStrCnt + 1
							break
						elseif itemSellCount + usedFenceSales > maxFenceSales then
							itemSellCount = maxFenceSales - usedFenceSales
						end
					end
					
					SellInventoryItem(BAG_BACKPACK, item.slotIndex, itemSellCount)
					totalCount = totalCount + itemSellCount
					local itemSellPrice = zo_round(itemSellCount * item.sellPrice * priceMult)
					totalPrice = totalPrice + itemSellPrice
					
					if jb.vars.showDetailedSummary then
						itemSellStr[sellStrCnt] = item.stackCount .. "x " .. itemLink .. " sold for " .. itemSellPrice .. "g"
						sellStrCnt = sellStrCnt + 1
					end
					
					actSales = actSales + 1
					if actSales >= jb.vars.maxAutoSales then
						itemSellStr[sellStrCnt] = "ZoS limit of " .. actSales .. " sales per transaction reached, wait 10 seconds before trying again"
						sellStrCnt = sellStrCnt + 1
						break
					end
				end
			end
		end
	end
	
	if jb.vars.showSellSummary and (totalCount > 0 or sellStrCnt > 0) then
		if sellStrCnt > 0 then
			for cnt = 0, (sellStrCnt - 1) do
				d(jb.chatTag .. itemSellStr[cnt])
			end
		end
		local iStr
		if totalCount == 1 then iStr = "item" else iStr = "items" end
		d(jb.chatTag .. totalCount .. " junk " .. iStr .. " sold for a total of " .. totalPrice .. "g")
	end
end

function jb.sortInvItemsByPrice(invItems)
	local sorted = {}
	for key, item in pairs(invItems) do 
		table.insert(sorted, item) 
	end
	
	function sortByPrice(a, b)
		return a.sellPrice > b.sellPrice
	end
	
	table.sort(sorted, sortByPrice)
	return sorted
end
