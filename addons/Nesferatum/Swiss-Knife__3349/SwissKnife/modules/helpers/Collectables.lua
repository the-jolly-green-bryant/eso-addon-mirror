local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local WM = WINDOW_MANAGER

local CollectablesIconControlName = "SKCollectablesIcon"

local function isItemLinkCollectables(itemLink)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    if not hasSet then return end
    local itemSlot = GetItemLinkItemSetCollectionSlot(itemLink)
    if itemSlot == 0 then return end
    return true, setId, itemSlot
end

local function isItemSetCurrentCollectionsFull(setId)
	local unlockedSlots = GetNumItemSetCollectionSlotsUnlocked(setId)
	local allSlots = GetNumItemSetCollectionPieces(setId)
	return unlockedSlots == allSlots
end

local function isItemSetStoredCollectionsFull(setId)
	local isStoredFull  = true
	if SK.savedVars.trackAccountsCollectionsItems then
		local trackedAccountsCollectionsItems = SK.globalSV.trackedAccountsCollectionsItems
		for _, accName in ipairs(SK.AllAccountsExcludeSelf) do
			if SK.savedVars.trackItemsAccountsNames[accName] == SK.TRUE then
				if SK.HasOneServer or string.find(accName, "["..SK.ServerCode.."]") then
					local accountData = trackedAccountsCollectionsItems[accName]
					if accountData ~= nil and accountData[setId] ~= nil then
						local locked = accountData[setId].l
						if isStoredFull then
							isStoredFull = not(locked ~= nil and #locked ~= 0)
						end
					end
				end
			end
		end
	end
	return isStoredFull
end

local function isItemSetCollectionsFull(setId)
	return isItemSetCurrentCollectionsFull(setId) and isItemSetStoredCollectionsFull(setId)
end

local function getReconstructionCost(setId)
	for i = 1, GetNumItemReconstructionCurrencyOptions() do
		local currencyType = GetItemReconstructionCurrencyOptionType(i)
		local reconstructionCost = GetItemReconstructionCurrencyOptionCost(setId, currencyType)
		if reconstructionCost then
			return SKH.getFormattedCurrency(reconstructionCost, currencyType, true)
		end
	end
end

local function composeSpecialItemName(itemLink, piecesCount)
	local name = SKH.getItemTypeName(itemLink)
	local isMonsterSet = piecesCount == 6
	local isSpecialSet = piecesCount > 22
    if isMonsterSet or isSpecialSet then
	    local _, armorType = SKH.getTrackedSetItemArmorType(itemLink)
	    if armorType ~= nil then name = name.." "..armorType end
    end
	return name
end

local function getSetIdCollectablesInfo(setId, accName, needFillCache)
	local pieces = {unlocked = {}, locked = {}}
	local isFull = true
	if accName == nil then
		local piecesCount = GetNumItemSetCollectionPieces(setId)
		for i = 1, piecesCount do
			local pieceId, slot = GetItemSetCollectionPieceInfo(setId, i)
			local isUnlocked = IsItemSetCollectionSlotUnlocked(setId, slot)
			if isUnlocked then
				table.insert(pieces.unlocked, pieceId)
			else
				table.insert(pieces.locked, pieceId)
			end
			if needFillCache then
				local pieceLink = GetItemSetCollectionPieceItemLink(pieceId)
				local name = composeSpecialItemName(pieceLink, piecesCount)
				if not SKH.hasTableChild(SK.ITEM_NAME_PIECE_ID_MAP, {setId, name}) then
					SKH.setTableChild(SK.ITEM_NAME_PIECE_ID_MAP, {setId, name}, pieceId)
				end
			end
		end
		if #pieces.locked ~= 0 then isFull = false end
	else
		local trackedAccountsCollectionsItems = SK.globalSV.trackedAccountsCollectionsItems
		if trackedAccountsCollectionsItems[accName] ~= nil and trackedAccountsCollectionsItems[accName][setId] ~= nil then
			local unlocked = trackedAccountsCollectionsItems[accName][setId].u
			local locked = trackedAccountsCollectionsItems[accName][setId].l
			pieces.unlocked = unlocked
			pieces.locked = locked
			if #pieces.locked ~= 0 then isFull = false end
		end
	end
	return pieces, isFull
end

local function getCollectablesItemTypeName(itemLink, pieceId, piecesCount)
	local itemLinkName = composeSpecialItemName(itemLink, piecesCount)
	local pieceLink = GetItemSetCollectionPieceItemLink(pieceId)
	local name = composeSpecialItemName(pieceLink, piecesCount)
	local isCurrent = name == itemLinkName
	return name, isCurrent
end

local function getItemLinkCollectablesInfo(itemLink, accName)
    local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local piecesCount = GetNumItemSetCollectionPieces(setId)
	local piecesInfo, isFull = getSetIdCollectablesInfo(setId, accName)
	local pieces = {unlocked = {}, locked = {}}
	if not isFull then
		if piecesInfo.unlocked then
			for _, pieceId in ipairs(piecesInfo.unlocked) do
			    local name, isCurrent = getCollectablesItemTypeName(itemLink, pieceId, piecesCount)
			    if name then
				    if isCurrent then name = SK.COLOR.LIGHT_YELLOW:Colorize(name) end
				    table.insert(pieces.unlocked, name)
			    end
			end
		end
		if piecesInfo.locked then
			for _, pieceId in ipairs(piecesInfo.locked) do
			    local name, isCurrent = getCollectablesItemTypeName(itemLink, pieceId, piecesCount)
			    if name then
				    if isCurrent then name = SK.COLOR.LIGHT_OLIVE_GREEN:Colorize(name) end
				    table.insert(pieces.locked, name)
			    end
			end
		end
	end
	return pieces, piecesCount, isFull
end

local function isItemNeedForAnotherAccount(itemLink, setId)
	if not SK.savedVars.trackAccountsCollectionsItems then return false end
	local piecesCount = GetNumItemSetCollectionPieces(setId)
	local name = composeSpecialItemName(itemLink, piecesCount)
	if SKH.hasTableChild(SK.ITEM_NAME_PIECE_ID_MAP, {setId, name}) then
		local itemLinkPieceId = SK.ITEM_NAME_PIECE_ID_MAP[setId][name]
		if itemLinkPieceId ~= nil then
			for _, accName in ipairs(SK.AllAccountsExcludeSelf) do
				if SK.savedVars.trackItemsAccountsNames[accName] == SK.TRUE then
					if SK.HasOneServer or string.find(accName, "["..SK.ServerCode.."]") then
						local pieces = getSetIdCollectablesInfo(setId, accName)
						if pieces.locked ~= nil then
							if SKH.isValueInList(pieces.locked, itemLinkPieceId) then return true end
						end
					end
				end
			end
		end
	end
	return false
end

local function composeOneAccountCollectablesTooltipData(tooltip, itemLink, accName)
	local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local pieces, allSlots, isFull = getItemLinkCollectablesInfo(itemLink, accName)
	local unlockedSlots = 0
	if pieces.unlocked ~= nil then unlockedSlots = #pieces.unlocked end
    local SET_TO_FULL_SIZE = true
	local costString = getReconstructionCost(setId)
	if accName then
		if not SK.HasOneServer and not string.find(accName, "["..SK.ServerCode.."]") then return end
		local r, g, b = SK.COLOR.YELLOW:UnpackRGB()
		local a = string.gsub(accName, "@", "", 1)
		tooltip:AddVerticalPadding(3)
		tooltip:AddLine(a, "ZoFontWinT1", r, g, b, LEFT,
				MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		tooltip:AddVerticalPadding(-7)
	end
	if isFull or unlockedSlots == allSlots then
		if accName then
			local r, g, b = SK.COLOR.ORANGE_RED:UnpackRGB()
			tooltip:AddLine(GetString(SI_SK_AUT_SET_COLLECTIONS_FULL_TEXT),
					"ZoFontWinT2", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		else
			tooltip:AddHeaderLine(GetString(SI_SK_AUT_SET_COLLECTIONS_FULL_TEXT),
					"ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LIGHT, SK.COLOR.ORANGE_RED:UnpackRGB())
		end
	else
		if accName then
			local r, g, b = SK.COLOR.WHITE:UnpackRGB()
			tooltip:AddLine(GetString(SI_SK_INTERFACE_I_PROGRESS_MESSAGE)..": "..unlockedSlots.."/"..allSlots,
					"ZoFontWinT2", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		else
			local r, g, b = ZO_HIGHLIGHT_TEXT:UnpackRGB()
			tooltip:AddHeaderLine(GetString(SI_SK_INTERFACE_I_PROGRESS_MESSAGE)..": "..unlockedSlots.."/"..allSlots,
					"ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, r, g, b)
			if costString then
				tooltip:AddHeaderLine(GetString(SI_SK_INTERFACE_I_RECONSTRUCTION_COST_MESSAGE)..": "..costString,
						"ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
			end
		end
		local unlockedParts = ""
		if not SK.savedVars.hideUnlockedCollectablesSetItemOnTooltip then
			for i, name in pairs(pieces.unlocked) do
				unlockedParts = unlockedParts..name
				if i < #pieces.unlocked then unlockedParts = unlockedParts..", " end
			end
			if unlockedParts ~= "" then
				local r, g, b = ZO_HIGHLIGHT_TEXT:UnpackRGB()
				tooltip:AddVerticalPadding(-4)
			    tooltip:AddLine(unlockedParts, "ZoFontGame", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE,
					    TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE)
				tooltip:AddVerticalPadding(-2)
			end
		end
		local lockedParts = ""
		for i, name in pairs(pieces.locked) do
			lockedParts = lockedParts..name
			if i < #pieces.locked then lockedParts = lockedParts..", " end
		end
		if lockedParts ~= "" then
		    local r, g, b = ZO_DISABLED_TEXT:UnpackRGB()
			tooltip:AddVerticalPadding(-4)
		    tooltip:AddLine(lockedParts, "ZoFontGame", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE,
				    TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE)
		end
	end
end

local function composeCollectablesTooltipData(tooltip, itemLink)
	local isCollectables = isItemLinkCollectables(itemLink)
	if isCollectables then
		composeOneAccountCollectablesTooltipData(tooltip, itemLink)
		if SK.savedVars.trackAccountsCollectionsItems then
			for _, accName in ipairs(SK.AllAccountsExcludeSelf) do
				if SK.savedVars.trackItemsAccountsNames[accName] == SK.TRUE then
					composeOneAccountCollectablesTooltipData(tooltip, itemLink, accName)
				end
			end
		end
	end
end

local function showCollectablesTooltip(control, bagId, slotIndex, itemLink)
	local point, relativePoint, offsetX, offsetY = TOPRIGHT, TOPLEFT, -10, 0
	local tooltip = InformationTooltip
	if not itemLink then
		itemLink = GetItemLink(bagId, slotIndex)
	else
		point, relativePoint, offsetX, offsetY = TOP, CENTER, 0, 0
		tooltip = PopupTooltip
	end
	InitializeTooltip(tooltip, control, point, offsetX, offsetY, relativePoint)
	local _, setName = GetItemLinkSetInfo(itemLink)
	local itemQuality = GetItemLinkFunctionalQuality(itemLink)
	if SK.savedVars.showEnSetNameToo then
		setName = SKH.getSetName(itemLink, false, true)
	end
	local r, g, b = SK.QUALITY_MAP[itemQuality]:UnpackRGB()
	tooltip:AddLine(setName, "ZoFontAnnounceMedium", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	composeCollectablesTooltipData(tooltip, itemLink)
end

local function addCollectablesUnlockedOrLocked(parentControl, bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)
	local isCollectables, setId, itemSlot = isItemLinkCollectables(itemLink)
    local itemIconControl = parentControl:GetNamedChild(CollectablesIconControlName)
    if not itemIconControl then
        itemIconControl = WM:CreateControl(parentControl:GetName()..CollectablesIconControlName,
		        parentControl, CT_TEXTURE)
        itemIconControl:SetDrawTier(DT_HIGH)
    end
    itemIconControl:SetHidden(true)

	if not SK.savedVars.showCollectablesSetItemExtraTooltip then return end
	if isCollectables then
		local isAllCollectionsFull = isItemSetCollectionsFull(setId)
		if isAllCollectionsFull then return end
	else
		return
	end

	local controlName = WM:GetControlByName(parentControl:GetName() .. "Name")
	itemIconControl:SetAnchor(LEFT, controlName, RIGHT,
		SK.savedVars.collectablesSetItemIconX, SK.savedVars.collectablesSetItemIconY)
    itemIconControl:SetDimensions(18, 18)
    itemIconControl:SetTextureCoords(0.1, 0.9, 0.1, 0.9)
    itemIconControl:SetTexture("esoui/art/collections/collections_tabIcon_itemSets_down.dds")

	if not IsItemSetCollectionSlotUnlocked(setId, itemSlot) then
		local r, g, b = SK.COLOR.GREEN:UnpackRGB()
		itemIconControl:SetColor(r, g ,b, 0.9)
	else
		local o = 0.6
		local r, g, b = SK.COLOR.GRAY:UnpackRGB()
		if not IsItemLinkBound(itemLink) and not IsItemBoPAndTradeable(bagId, slotIndex)
				and isItemNeedForAnotherAccount(itemLink, setId)
		then
			o = 0.9
			r, g, b = SK.COLOR.LIGHT_YELLOW:UnpackRGB()
		end
		itemIconControl:SetColor(r, g ,b, o)
	end
    itemIconControl:SetHidden(false)
    itemIconControl:SetMouseEnabled(true)
	itemIconControl:SetHandler("OnMouseEnter",
	    function(self) showCollectablesTooltip(self, bagId, slotIndex) end
    )
    itemIconControl:SetHandler("OnMouseExit",
	    function() ClearTooltip(InformationTooltip) end
    )
end

local function getCompanionNameById(id)
    local name = SKDC.COMPANION_NAMES[id]
    if name == nil then name = GetString(SI_SK_MESSAGE_UNKNOWN) end
    return name
end

local function getCurrentCompanionName()
	local companionId = GetActiveCompanionDefId()
	if companionId > 0 then return getCompanionNameById(companionId) end
end

local function getCurrentCompanionOwnerName()
	local companionId = GetActiveCompanionDefId()
	if companionId > 0 then return ""..SK.companionOwnerNamePrefix..companionId end
end

local function summonCompanion(id)
    local collectibleId = GetCompanionCollectibleId(id)
    local isBlocked = IsCollectibleBlocked(collectibleId) or not IsCollectibleUsable(collectibleId)
	if isBlocked then
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKA,
            SI_SK_AUT_UNAVAILABLE_COMPANION_MESSAGE,
	        getCompanionNameById(id)
        )
	else
		local cooldownTime = GetCollectibleCooldownAndDuration(collectibleId) or 0
        if cooldownTime > 0 then
			SKH.sendMessageToChat(
	            SK.COLORED_PREFIXES.SKA,
	            SI_SK_AUT_UNAVAILABLE_COMPANION_DELAY,
	            math.floor(cooldownTime / 1000)
	        )
        end
		zo_callLater(function() UseCollectible(collectibleId) end, cooldownTime)
	end
end

-- Export helper functions
SK.HelperFunctions.isItemLinkCollectables = isItemLinkCollectables
SK.HelperFunctions.isItemSetCollectionsFull = isItemSetCollectionsFull
SK.HelperFunctions.getItemLinkCollectablesInfo = getItemLinkCollectablesInfo
SK.HelperFunctions.getSetIdCollectablesInfo = getSetIdCollectablesInfo
SK.HelperFunctions.showCollectablesTooltip = showCollectablesTooltip
SK.HelperFunctions.addCollectablesUnlockedOrLocked = addCollectablesUnlockedOrLocked
SK.HelperFunctions.getCompanionNameById = getCompanionNameById
SK.HelperFunctions.getCurrentCompanionName = getCurrentCompanionName
SK.HelperFunctions.getCurrentCompanionOwnerName = getCurrentCompanionOwnerName
SK.HelperFunctions.summonCompanion = summonCompanion
