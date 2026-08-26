-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local EASLoreLibraryMenu = {}
EASLoreLibrary:RegisterModule("loreLibraryMenu", EASLoreLibraryMenu)

--[[
Adds one "Show On Map: <zone name>" entry per zone a book can be found in to
the base game's Lore Library book right-click menu - for undiscovered books,
this is the same context menu the game already lets you find every remaining
copy from. Selecting any entry also starts tracking that book (see
Pins/MarkerPin.lua): temporary marker pins for every one of its locations,
not just the one clicked. Useful for known books especially, since their
regular map pin is gone once they've been read, but works the same for
undiscovered ones too.
Reuses SI_QUEST_JOURNAL_SHOW_ON_MAP (the Quest Journal's "Show On Map" label)
since it's already localized.

Keyboard-only: right-click context menus are a mouse concept, and LORE_LIBRARY
(the keyboard Lore Library screen) doesn't exist when the keyboard UI isn't
loaded (i.e. on console). ZO_IsConsoleOrGameCoreUI() is true there, so Initialize bails
out immediately.
]]--

function EASLoreLibraryMenu:Initialize()
	if ZO_IsConsoleOrGameCoreUI() then return end

	SecurePostHook(LORE_LIBRARY.list, "OnRowMouseUp", function(list, control, button)
		self:OnRowMouseUp(control, button)
	end)
	self.showOnMapPrefix = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP) .. ": "
end

function EASLoreLibraryMenu:OnRowMouseUp(control, button)
	if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
	if control.bookIndex == nil then return end

	local _, _, _, bookId = GetLoreBookInfo(control.categoryIndex, control.collectionIndex, control.bookIndex)
	if not bookId then return end

	local locations = EASLoreLibrary.data:GetBookLocations(bookId)
	if #locations == 0 then return end

	for _, location in ipairs(locations) do
		-- location.mapId can still be 0 even after Data:GetBookLocations' parent-
		-- zone fallback (e.g. a zone nested deeper than one level of
		-- parenting) - ShowLocationOnMap falls back to the Aurbis/cosmic map
		-- for those, so the label is the only thing that differs
		local label = self.showOnMapPrefix .. (location and location.zoneName or "")
		AddMenuItem(label, function()
			EASLoreLibrary.ShowLocationOnMap(location)
			EASLoreLibrary.markerPin:Track(bookId, locations)
		end)
	end

	ShowMenu(control)
end
