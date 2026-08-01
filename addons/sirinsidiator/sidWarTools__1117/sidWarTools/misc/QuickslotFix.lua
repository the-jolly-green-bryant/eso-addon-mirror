local function Initialize(saveData)
	if(saveData.quickslotFix) then
		local WrapFunction = sidWarTools.WrapFunction

		local originalZO_ScrollList_ResetToTop = ZO_ScrollList_ResetToTop
		local noop = function() end
		local itemListed
		
		WrapFunction(QUICKSLOT_WINDOW, "UpdateList", function(originalFunction, self)
			itemListed = {}
			ZO_ScrollList_ResetToTop = noop
			originalFunction(self)
			ZO_ScrollList_ResetToTop = originalZO_ScrollList_ResetToTop
		end)

		WrapFunction(QUICKSLOT_WINDOW, "ShouldAddItemToList", function(originalFunction, self, itemData)
			if(originalFunction(self, itemData)) then
				local itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
				if(saveData.quickSlotConsolidateItems and itemListed[itemLink]) then
					itemListed[itemLink].stackCount = itemData.stackCount + itemListed[itemLink].stackCount
					return false
				else
					itemListed[itemLink] = itemData
				end
				return true
			end
			return false
		end)
	end
end

sidWarTools.InitializeQuickslotFixes = Initialize
