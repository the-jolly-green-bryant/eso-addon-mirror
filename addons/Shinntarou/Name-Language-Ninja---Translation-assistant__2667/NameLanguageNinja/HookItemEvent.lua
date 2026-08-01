local ADDON = NameLanguageNinja
local LMN = LibMultilingualName

--------
-- in this file local use, private
--------

local function getColoredText(langCode, text)
	return ADDON.GetColoredText(langCode, text)
end

local function getSetBonus(langCode, setId, itemLink)
	-- TODO
	local bonus, abilityId, fuzzyLevel, debugStr = LMN.SearchSetItemBonus(langCode, setId, itemLink)

	if not abilityId then
		ADDON.develop(" abilityId is false. setId: " .. setId)
		ADDON.develop(" langCode:" .. langCode)
		ADDON.develop(" debugStr:" .. debugStr)
		return false
	end
	if string.len(bonus) < 1 then
		return false
	end
	if fuzzyLevel < 0 then
		bonus = "|cff0000[!]|r" .. bonus
		ADDON.develop(" setId: ".. setId .. " debugStr:" .. debugStr .. " bonus:" .. bonus)
	else
		ADDON.develop(" setId: ".. setId .. " abilityId: " .. abilityId .. " bonus:" .. bonus)
	end
	if fuzzyLevel > 1 then
		bonus = "|cffff00[!".. fuzzyLevel .. "]|r" .. bonus
		ADDON.develop(" setId: ".. setId .. " debugStr:" .. debugStr)
	end

	return bonus
end

local function getNames(itemLink)
	ADDON.develop(" ItemEvent getNames")
	--ADDON.var_keys_dump(GetItemLinkInfo(itemLink))

	local itemId = GetItemLinkItemId(itemLink)
	local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
	if isSet then
		ADDON.develop(" setName: " .. setName)
		ADDON.develop(" numBonuses: " .. numBonuses)
		ADDON.develop(" setId: " .. setId)
		ADDON.develop(" numEquipped: " .. numEquipped)
		ADDON.develop(" maxEquipped: " .. maxEquipped)
	else
		ADDON.develop(" isSet: maybe false ")
	end
	local names = {}
	local bonuses = {}
	local clientLangCode = string.lower(GetCVar("language.2"))

	-- get item's names in your selected languages for tooltip
	for key, langCode in ipairs(LMN.ALL_LANG_CODES) do
		if ADDON.SaveData.Languages[langCode] then
			if not ADDON.SaveData.DontShowClientLanguage or clientLangCode ~= langCode then
				if LMN.GetRawItemName(langCode, itemId) then
					local planeText
					if isSet and ADDON.SaveData.OutputSetItemName then
						local setItemName = LMN.GetSetItemName(langCode, setId)
						if not setItemName then
							setItemName = "unknown set item id:" .. setId 
						end
						planeText = LMN.GetItemName(langCode, itemId) .. "(" .. setItemName .. ")"
					else
						planeText = LMN.GetItemName(langCode, itemId)
					end
					local coloredText = getColoredText(langCode, planeText)

					names[#names + 1] = coloredText
				else
					ADDON.develop(" LMN.GetRawItemName(langCode, itemId): maybe false ")
					ADDON.develop(" itemId:" .. itemId)
					ADDON.develop(" langCode:" .. langCode)

					local tableLen, tailId, tailVal = LMN.GetItemNameTableLen(langCode)
					ADDON.develop(" GetItemNameTableLen:" .. tableLen)
					ADDON.develop(" tailId:" .. tailId)
					ADDON.develop(" tailVal:" .. tailVal)

					local tableLen, tailId, tailVal = LMN.GetAbilityDescriptionTableLen(langCode)
					ADDON.develop(" GetAbilityDescriptionTableLen:" .. tableLen)
					ADDON.develop(" tailId:" .. tailId)
					ADDON.develop(" tailVal:" .. tailVal)
					
				end
			end
		end
	end
	if ADDON.SaveData.OutputItemId then
		names[#names + 1] = "ID:" .. itemId
	end
	ADDON.develop(" ItemEvent getNames: OutputSetBonus ")

	if isSet and ADDON.SaveData.Description.OutputSetBonus then
		for key, langCode in ipairs(LMN.ALL_LANG_CODES) do
			ADDON.develop(" ItemEvent getNames: OutputSetBonus: langCode " .. langCode)
			if LMN.IsLoaded(langCode) and ADDON.SaveData.Description.Languages[langCode] then
				if (not ADDON.SaveData.DontShowClientLanguage) or (clientLangCode ~= langCode) then
					if LMN.SearchRawSetItemBonus(langCode, setId) then
						-- !!! bonus descriptions might have own color format.
						local tmpText = getSetBonus(langCode, setId, itemLink)
						if tmpText then
							bonuses[#bonuses + 1] = tmpText
						end
					else
						ADDON.develop(" ItemEvent getNames: try to SearchRawSetItemBonus ... false")
					end
				end
			end
		end
	end

	ADDON.develop(" ItemEvent getNames: end")
	--ADDON.var_keys_dump(names)
	--ADDON.var_keys_dump(bonuses)
	return names, bonuses
end

local function getFormattedItemLink(_BagIdOrLink, _iSlotId)
	if _iSlotId then
		return zo_strformat("<<t:1>>", GetItemLink(_BagIdOrLink, _iSlotId))
	end

	return zo_strformat("<<t:1>>", _BagIdOrLink)
end

local function returnWornItemLink(_equipSlot)
	return getFormattedItemLink(BAG_WORN, _equipSlot)
end

local function returnItemLink(itemLink)
	return itemLink
end

local function tooltipHook(tooltipControl, functionName, getItemLinkFunction)
	local base = tooltipControl[functionName]
	tooltipControl[functionName] = function(control, ...)
		local itemLink = getItemLinkFunction(...)
		--local itemName = GetItemLinkName(itemLink)
		local names, bonuses = getNames(itemLink)

		ADDON.develop("tooltipHook functionName: " .. functionName)
		--ADDON.var_keys_dump(names)
		--ADDON.var_keys_dump(bonuses)
		-- TODO if companion, return.
		if functionName == "SetWornItem" then
			--ADDON.develop("SetWornItem")
		end

		-- add1: before tooltip create
		--[[

		if (#names > 0) then
			if ADDON.SaveData.To.Item.Tooltip.Title then
				if ("useTitle" and false) then
					-- TODO it's better to use TITLE

					local newTitle = itemName
					for key, val in ipairs(names) do
						newTitle = newTitle .. "\n" .. val
					end
				else
					-- TODO style collapse

					-- avoid tooltip's icon and type and (unique) messages.(2 line.)
					tooltipControl:AddLine("")
					tooltipControl:AddLine("")

					-- names
					for key, val in ipairs(names) do
						tooltipControl:AddLine(val)
					end
					-- divider
					if (not ADDON.SaveData.DontShowDivider) then
						ZO_Tooltip_AddDivider(control)
					end
				end
			end
		end
		]]

		-- base tooltip creation
		base(control, ...)

		-- add2: after tooltip created
		if ADDON.SaveData.To.Item.Tooltip.Body then
			if (#names > 0) then
				if (not ADDON.SaveData.DontShowDivider) then
					ZO_Tooltip_AddDivider(control)
				end
				for key, val in ipairs(names) do
					if string.len(val) > 0 then
						tooltipControl:AddLine(val)
					end
				end
			end
			if ADDON.SaveData.Description.OutputSetBonus then
				if (#bonuses > 0) then
					-- divider
					if (not ADDON.SaveData.DontShowDivider) then
						ZO_Tooltip_AddDivider(control)
					end
					for key, val in ipairs(bonuses) do
						if string.len(val) > 0 then
							tooltipControl:AddLine(val)
						end
					end
				end
			end
		end
	end
end

local function update_ItemBrowserListRow_OnMouseEnter()

	local base = ItemBrowserListRow_OnMouseEnter
	ItemBrowserListRow_OnMouseEnter = function(control)
		if not ADDON.SaveData.ItemBrowserIntegration then
			return base(control)
		end
		ADDON.develop("update_ItemBrowserListRow_OnMouseEnter")

		local LEJ = LibExtendedJournal
		--local LEJI = LibExtendedJournalInternal
		local data = ZO_ScrollList_GetData(control)
		local itemLink = data.itemLink
		local collectible = IsItemLinkSetCollectionPiece(itemLink)
		--local itemName = GetItemLinkName(itemLink)
		local names, bonuses = getNames(itemLink)

		-- TODO add1: before tooltip create

		-- base tooltip creation
		local ret = base(control)

		if (not collectible) then
			-- dummy Section for craftable set
			local Tooltip = LEJ.ItemTooltip(itemLink)
			LEJ.TooltipExtensionInitialize(true)
			LEJ.TooltipExtensionAddSection("")
			LEJ.TooltipExtensionFinalize(Tooltip)
		end

		-- add2: after tooltip created
		if ADDON.SaveData.To.Item.Tooltip.Body then
			if (#names > 0) or (#bonuses > 0) then
				if (not ADDON.SaveData.DontShowDivider) then
					-- TODO divider
					LEJ.TooltipExtensionAddSection(" ")
				end
				LEJ.TooltipExtensionAddSection(
					table.concat(names, "\n"),
					table.concat(bonuses, "\n")
				)
			end
		end

		return ret
	end

end
--------
-- in this ADDON use, protected
--------

function ADDON.HookItemEvent()
	ADDON.develop("HookItemEvent")

	tooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
	tooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	tooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	tooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	tooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	tooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
	tooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	tooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	tooltipHook(ItemTooltip, "SetLink", returnItemLink)
	tooltipHook(ItemTooltip, "SetWornItem", returnWornItemLink)
	tooltipHook(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	tooltipHook(ItemTooltip, "SetItemSetCollectionPieceLink", returnItemLink, 4)

	tooltipHook(PopupTooltip, "SetLink", returnItemLink)

	if ItemBrowser ~= nil then
		update_ItemBrowserListRow_OnMouseEnter()
	end
end
