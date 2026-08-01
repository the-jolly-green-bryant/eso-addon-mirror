if (not AdvancedFilters) then return end

local LCCC = LibCodesCommonCode
local LMAC = LibMultiAccountCollectibles

LCCC.RunAfterInitialLoadscreen(function( )
	local currentAccount = GetDisplayName()
	local util = AdvancedFilters.util

	local GetFilterCallbackForCollectibles = function( targetAccount )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			local collectibleId = GetItemLinkContainerCollectibleId(GetItemLink(slot.bagId, slot.slotIndex))

			if (collectibleId == 0) then
				return false
			else
				local bindType = GetItemBindType(slot.bagId, slot.slotIndex)

				if (targetAccount == "Any") then
					-- Checking against all accounts
					for _, account in ipairs(LMAC.GetServerAndAccountList(true)[1].accounts) do
						if (account == currentAccount or (bindType ~= BIND_TYPE_ON_PICKUP and bindType ~= BIND_TYPE_ON_PICKUP_BACKPACK)) then
							if (not LMAC.IsCollectibleOwnedByAccount(nil, account, collectibleId)) then
								return true
							end
						end
					end
					return false
				else
					-- Checking against a single account
					return not LMAC.IsCollectibleOwnedByAccount(nil, targetAccount, collectibleId)
				end
			end
		end
	end

	local filterInformation = {
		submenuName = "Collectible",

		callbackTable = { },

		enStrings = {
			["Collectible"] = GetString(SI_MACAF_COLLECTIBLE),
			["AnyAccount"] = GetString(SI_MACAF_ANY_ACCOUNT),
		},

		filterType = ITEMFILTERTYPE_ALL,
		subfilters = { "Container", "Trophy" },
		onlyGroups = { "Consumables", "Junk" },
	}

	for i, account in ipairs(LMAC.GetServerAndAccountList(true)[1].accounts) do
		table.insert(filterInformation.callbackTable, {
			name = account,
			filterCallback = GetFilterCallbackForCollectibles(account),
		})
		filterInformation.enStrings[account] = account

		-- Add the any option
		if (i == 1) then
			table.insert(filterInformation.callbackTable, {
				name = "AnyAccount",
				filterCallback = GetFilterCallbackForCollectibles("Any"),
			})
		end
	end

	AdvancedFilters_RegisterFilter(filterInformation)
end)
