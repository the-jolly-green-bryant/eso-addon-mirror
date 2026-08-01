local name = "AF_UncollectedSetItems"

local LMAS = LibMultiAccountSets

local function OnPlayerActivated( eventCode, initial )
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)

	local util = AdvancedFilters.util

	local GetFilterCallbackForUncollectedSetItems = function( account )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			if (account == "Any") then
				-- Checking against all accounts
				local results = LMAS.GetItemCollectionAndTradabilityStatus(LMAS.GetAccountList(), nil, slot)
				if (results ~= LMAS.ITEM_UNCOLLECTIBLE) then
					for account, status in pairs(results) do
						if (status == LMAS.ITEM_UNCOLLECTED_TRADE) then
							return true
						end
					end
				end
				return false
			elseif (account) then
				-- Checking against other accounts
				return LMAS.GetItemCollectionAndTradabilityStatus(account, nil, slot) == LMAS.ITEM_UNCOLLECTED_TRADE
			else
				-- Checking against the current account
				local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
				return IsItemLinkSetCollectionPiece(itemLink) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))
			end
		end
	end

	local filterInformation = {
		callbackTable = {
			{ name = "UncollectedSetItems", filterCallback = GetFilterCallbackForUncollectedSetItems() },
		},

		enStrings = {
			["UncollectedSetItems"] = "Uncollected",
			["AnyAccount"] = "(Any)",
		},

		deStrings = {
			["UncollectedSetItems"] = "Nicht gesammelt",
			["AnyAccount"] = "(Beliebige)",
		},

		filterType = ITEMFILTERTYPE_ALL,
		subfilters = { "All" },
		onlyGroups = { "Weapons", "Armor", "Jewelry", "Junk", "AllUniversalDecon" },
	}

	if (LMAS) then
		local otherAccounts = LMAS.GetAccountList(true)

		if (#otherAccounts > 0) then
			-- Set up submenu
			filterInformation.submenuName = "UncollectedSetItems"
			filterInformation.callbackTable[1].name = GetDisplayName()
			filterInformation.enStrings[GetDisplayName()] = GetDisplayName()

			-- Add the any option
			table.insert(filterInformation.callbackTable, {
				name = "AnyAccount",
				filterCallback = GetFilterCallbackForUncollectedSetItems("Any"),
			})

			-- Add the other accounts
			for _, account in ipairs(otherAccounts) do
				table.insert(filterInformation.callbackTable, {
					name = account,
					filterCallback = GetFilterCallbackForUncollectedSetItems(account),
				})
				filterInformation.enStrings[account] = account
			end
		end
	end

	AdvancedFilters_RegisterFilter(filterInformation)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
