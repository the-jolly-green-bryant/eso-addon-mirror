local NAME = "ProvisioningStationSortByLevel"

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function( eventCode, addonName )
	if (addonName ~= NAME) then return end
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

	local maxLevel = GetMaxLevel()

	local GetLevelFromItemId = function( itemId )
		local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
		local level = GetItemLinkRequiredLevel(itemLink)
		if (level == maxLevel) then
			level = level + GetItemLinkRequiredChampionPoints(itemLink)
		end
		return level
	end

	local RecipeComparator = function( a, b )
		if (not a.level) then a.level = GetLevelFromItemId(a.resultItemId) end
		if (not b.level) then b.level = GetLevelFromItemId(b.resultItemId) end
		if (a.level ~= b.level) then
			return a.level < b.level
		else
			return a.name < b.name
		end
	end

	SecurePostHook(PROVISIONER_MANAGER, "BuildRecipeListData", function( self, ... )
		for recipeListIndex = 1, GetNumRecipeLists() do
			local recipeList = self.recipeLists[recipeListIndex]
			if (recipeList) then
				table.sort(recipeList.recipes, RecipeComparator)
			end
		end
	end)
end)
