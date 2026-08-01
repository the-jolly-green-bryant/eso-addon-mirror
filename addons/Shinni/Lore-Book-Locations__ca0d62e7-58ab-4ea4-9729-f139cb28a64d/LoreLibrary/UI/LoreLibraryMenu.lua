
local LoreLibraryMenu = {}
LoreLibrary:RegisterModule("loreLibraryMenu", LoreLibraryMenu)

--[[
Adds one "Show On Map: <zone name>" entry per zone an undiscovered book can
still be found in to the base game's Lore Library book right-click menu.
Reuses SI_QUEST_JOURNAL_SHOW_ON_MAP (the Quest Journal's "Show On Map" label)
since it's already localized.

Keyboard-only: right-click context menus are a mouse concept, and LORE_LIBRARY
(the keyboard Lore Library screen) doesn't exist when the keyboard UI isn't
loaded (i.e. on console). ZO_IsConsoleOrGameCoreUI() is true there, so Initialize bails
out immediately.
]]--

function LoreLibraryMenu:Initialize()
	if ZO_IsConsoleOrGameCoreUI() then return end

	ZO_PostHook(LORE_LIBRARY.list, "OnRowMouseUp", function(list, control, button)
		self:OnRowMouseUp(control, button)
	end)
	self.showOnMapPrefix = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP) .. ": "
end

function LoreLibraryMenu:OnRowMouseUp(control, button)
	if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
	if control.known or control.bookIndex == nil then return end

	local _, _, _, bookId = GetLoreBookInfo(control.categoryIndex, control.collectionIndex, control.bookIndex)
	if not bookId then return end

	local locations = LoreLibrary.data:GetBookLocations(bookId)
	if #locations == 0 then return end

	for _, entry in ipairs(locations) do
		if entry.mapId > 0 then
			AddMenuItem(self.showOnMapPrefix .. entry.zoneName, function()
				LoreLibrary.ShowLocationOnMap(entry)
			end)
		else
			AddMenuItem("Found in " .. entry.zoneName, function()
				--ZO_WorldMap_ShowWorldMap()
				--WORLD_MAP_MANAGER:SetMapById(entry.mapId)
			end)
		end
	end

	ShowMenu(control)
end
