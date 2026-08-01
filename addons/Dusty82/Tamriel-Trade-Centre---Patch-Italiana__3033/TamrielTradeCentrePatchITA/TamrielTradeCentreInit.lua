
function TamrielTradeCentre_ItemInfo:New(itemLink)
	if (not TamrielTradeCentre:IsItemLink(itemLink)) then
		TamrielTradeCentre:DebugWriteLine("tabella dei prezzi vuota o non c'è nessun collegamento all'oggetto")
		return nil
	end

	local itemName = GetItemLinkName(itemLink)
	local itemQuality = GetItemLinkQuality(itemLink)
	local requiredLevel = GetItemLinkRequiredLevel(itemLink)
	local requiredChampionPoint = GetItemLinkRequiredChampionPoints(itemLink)
	local traitType, _ = GetItemLinkTraitInfo(itemLink)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	local armorType = GetItemLinkArmorType(itemLink)
	local itemLinkParams = {ZO_LinkHandler_ParseLink(itemLink)}
	local lastParam = itemLinkParams[24]

	local itemInfo = {}
	itemInfo.ItemLink = itemLink
	itemInfo.Name = zo_strformat(Babel.getItemName(itemLink) or SI_TOOLTIP_ITEM_NAME, itemName)
	itemInfo.QualityID = itemQuality - 1
	itemInfo.ID = self:NameSpecializedItemTypeToItemID(itemInfo.Name, specializedItemType)
	if (itemInfo.QualityID < 0) then
		itemInfo.QualityID = 0
	end

	itemInfo.Level = requiredLevel
	if (requiredChampionPoint > 0) then
		itemInfo.Level = 50 + requiredChampionPoint
	end

	itemInfo.TraitID = self:TraitTypeToTraitID(traitType)
	itemInfo.ItemType = itemType
	itemInfo.Category2IDOverWrite = self:ArmorTypeToCategory2OverWrite(armorType)
	
	if (itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) then
		local isPoison = itemType == ITEMTYPE_POISON
		if (lastParam ~= 0) then
			itemInfo.PotionEffects = {}

			for i = 0, 2 do
				local potionEffectCode = BitAnd(BitRightShift(lastParam, i * 8), 0xFF)
				local potionEffectID = self:PotionEffectCodeToID(isPoison, potionEffectCode)
				if (potionEffectID ~= nil) then
					table.insert(itemInfo.PotionEffects, potionEffectID)
				end
			end

			table.sort(itemInfo.PotionEffects)
		end
	elseif (itemType == ITEMTYPE_MASTER_WRIT) then
		itemInfo.MasterWritInfo = TamrielTradeCentre_MasterWritInfo:New(itemLink)
		if (itemInfo.MasterWritInfo == nil) then
			itemInfo.ID = nil
		end
	end

	return itemInfo
end

function TamrielTradeCentre_MasterWritInfo:New(itemLink)
	local itemType, _ = GetItemLinkItemType(itemLink)
	if (itemType ~= ITEMTYPE_MASTER_WRIT) then
		return nil
	end

	local itemLinkParams = {ZO_LinkHandler_ParseLink(itemLink)}
	for key, value in pairs(itemLinkParams) do
		local num = tonumber(value)
		if (num ~= nil) then
			itemLinkParams[key] = num
		end
	end

	local masterWritInfo = {}

	--10 to 15
	local itemName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, Babel.getItemName(itemLink) or GetItemLinkName(itemLink)))
	local requiredQualityID = -1
	masterWritInfo.NumVoucher = math.ceil(itemLinkParams[24] / 10000 - 0.5)

	local requiredItemNameRegex = nil

	if (string.find(itemName, GetString(TTC_ALCHEMY))) then
		requiredItemNameRegex = GetString(TTC_MASTER_WRIT_ALCHEMYREGEX)

		local isPoison = itemLinkParams[10] == 239
		local potionEffectIDs = {}
		table.insert(potionEffectIDs, TamrielTradeCentre_ItemInfo:PotionEffectCodeToID(isPoison, itemLinkParams[11]))
		table.insert(potionEffectIDs, TamrielTradeCentre_ItemInfo:PotionEffectCodeToID(isPoison, itemLinkParams[12]))
		table.insert(potionEffectIDs, TamrielTradeCentre_ItemInfo:PotionEffectCodeToID(isPoison, itemLinkParams[13]))

		table.sort(potionEffectIDs)
		masterWritInfo.RequiredPotionEffectIDs = potionEffectIDs
	elseif (string.find(itemName, GetString(TTC_ENCHANTING))) then
		requiredItemNameRegex = GetString(TTC_MASTER_WRIT_ENCHANTINGREGEX)

		requiredQualityID = itemLinkParams[12] - 1
	elseif (string.find(itemName, GetString(TTC_PROVISIONING))) then
		requiredItemNameRegex = GetString(TTC_MASTER_WRIT_PROVISIONINGREGEX)
	else
		requiredItemNameRegex = GetString(TTC_MASTER_WRIT_CRAFTINGREGEX)

		requiredQualityID = itemLinkParams[12] - 1
		masterWritInfo.RequiredSetID = TamrielTradeCentre_ItemInfo:SetCodeToID(itemLinkParams[13])
		masterWritInfo.RequiredTraitID = TamrielTradeCentre_ItemInfo:TraitTypeToTraitID(itemLinkParams[14])
		masterWritInfo.RequiredStyleID = TamrielTradeCentre_ItemInfo:StyleCodeToID(itemLinkParams[15])
	end

	local masterWritDescription = GenerateMasterWritBaseText(itemLink)
	local tokens = {}
	for str in string.gmatch(masterWritDescription, "([^;]+)") do
		table.insert(tokens, str)
	end

	local requiredItemName = nil
	for _, token in pairs(tokens) do
		local _, _, matchedName = string.find(token, requiredItemNameRegex)
		if (not TamrielTradeCentre:IsStringNilOrEmpty(matchedName)) then
			requiredItemName = matchedName
			break
		end
	end

	masterWritInfo.RequiredItemID = TamrielTradeCentre_ItemInfo:NameSpecializedItemTypeToItemID(requiredItemName)
	if (masterWritInfo.RequiredItemID == nil) then
		return nil
	end
	
	if (requiredQualityID >= 0) then
		masterWritInfo.RequiredQualityID = requiredQualityID
	end

	return masterWritInfo
end

