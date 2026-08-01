local name = "ImprovedItemSetCollection"
local IISC = {
	showLocked = true,
	showUnlocked = true,
	showPerfectedOnly = true,
	showMisingPerfectedOnly = true,
}

local function Initialize()
	local STICKER_BOOK = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD

	local filterContainer = STICKER_BOOK.filtersContainer
	local showLockedFilterBox = filterContainer:GetNamedChild("ShowLocked")
	
	-- Create new combobox
	local comboboxcontrol = WINDOW_MANAGER:CreateControlFromVirtual(filterContainer:GetName() .. "ShowFilterTypes", filterContainer, "ZO_ComboBox")
	comboboxcontrol:SetAnchor(LEFT, filterContainer:GetNamedChild("WeaponFilterTypes"), RIGHT, 20)
	comboboxcontrol:SetWidth(175)
	
	local function OnFilterChanged(combobox, entryText, entry)
		IISC.showLocked = false
		IISC.showUnlocked = false
		IISC.showPerfectedOnly = false
		IISC.showMisingPerfectedOnly = false
	
		if entry.filterType == IISC_ITEMSETS_FILTER_SHOW_ALL then
			IISC.showLocked = true
			IISC.showUnlocked = true
		elseif entry.filterType == IISC_ITEMSETS_FILTER_HIDE_LOCKED then
			IISC.showUnlocked = true
		elseif entry.filterType == IISC_ITEMSETS_FILTER_HIDE_UNLOCKED then
			IISC.showLocked = true
		elseif entry.filterType == IISC_ITEMSETS_FILTER_SHOW_PERFECTED then
			IISC.showPerfectedOnly = true
		elseif entry.filterType == IISC_ITEMSETS_FILTER_SHOW_PERFECTED_MISSING then
			IISC.showMisingPerfectedOnly = true
		end
		
		STICKER_BOOK:RefreshFilters()
    end
	
	-- Get combobox code-component
	local combobox = ZO_ComboBox_ObjectFromContainer(comboboxcontrol)
	
	local entries = {
		IISC_ITEMSETS_FILTER_SHOW_ALL,
		IISC_ITEMSETS_FILTER_HIDE_LOCKED,
		IISC_ITEMSETS_FILTER_HIDE_UNLOCKED,
		IISC_ITEMSETS_FILTER_SHOW_PERFECTED,
		IISC_ITEMSETS_FILTER_SHOW_PERFECTED_MISSING,
	}
	
	-- Populate combobox
	for i, stringId in ipairs(entries) do
        local entry = combobox:CreateItemEntry(GetString(stringId), OnFilterChanged)
        entry.filterType = stringId
        combobox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
	combobox:SelectItemByIndex(1) -- Select "Show All" by default
	
	-- Add to base object, for good measure
	STICKER_BOOK.showFilterTypesControl = comboboxcontrol
	STICKER_BOOK.showFilterTypesDropdown = combobox
	
	-- Hook updating function, to not show the original checkbox and show our added combobox
	ZO_PostHook(STICKER_BOOK, "SetFiltersHidden", function(self, hidden)
		self.showFilterTypesControl:SetHidden(hidden)
		self.showLockedCheckBox:SetHidden(true)
	end)
	
	-- Append the filter functions that get applied with our own
	ZO_PostHook(STICKER_BOOK, "RefreshPieceFilters", function(self)
		if IISC.showUnlocked and not IISC.showLocked then
			table.insert(self.pieceFilters, ZO_ItemSetCollectionPieceData.IsUnlocked)
		end
		
		if IISC.showLocked and not IISC.showUnlocked then
			table.insert(self.pieceFilters, ZO_ItemSetCollectionPieceData.IsLocked)
		end
		
		if IISC.showPerfectedOnly then
			table.insert(self.pieceFilters, function(data) return GetItemSetUnperfectedSetId(ZO_ItemSetCollectionPieceData.GetSetId(data)) ~= 0 end)
		end
		
		if IISC.showMisingPerfectedOnly then
			table.insert(self.pieceFilters, function(data) return GetItemSetUnperfectedSetId(ZO_ItemSetCollectionPieceData.GetSetId(data)) ~= 0 and ZO_ItemSetCollectionPieceData.IsLocked(data) end)
		end
	end)
	
	--ZO_PostHook(STICKER_BOOK, "RefreshFilters", function(self)
	--	if IISC.showComplete then
	--		table.insert(self.categoryFilters, function(data)
	--			-- This does not work, needs more research on how data is passed between functions
	--			return data:GetNumPieces() == data:GetNumUnlockedPieces()
	--		end)
	--	end
	--	self.categoriesRefreshGroup:MarkDirty("List")
	--end)
	
	STICKER_BOOK.GetShowLocked = function() return false end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= name then return end
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED) 
    
    Initialize()
end
EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, OnAddonLoaded)