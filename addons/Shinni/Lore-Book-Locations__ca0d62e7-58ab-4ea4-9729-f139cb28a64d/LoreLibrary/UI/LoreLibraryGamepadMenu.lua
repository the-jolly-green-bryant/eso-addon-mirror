
local LoreLibraryGamepadMenu = {}
LoreLibrary:RegisterModule("loreLibraryGamepadMenu", LoreLibraryGamepadMenu)

--[[
Gamepad equivalent of LoreLibraryMenu.lua's keyboard right-click menu. The
gamepad Lore Library's book list screen (ZO_LoreLibraryBookSet_Gamepad) has a
keybind strip with "Back", "Read"/UI_SHORTCUT_PRIMARY, and
"Open in Achievements"/UI_SHORTCUT_SECONDARY (only shown for collections that
have a linked achievement, which never applies to Lore Books/Eidetic Memory).
Since that third keybind is otherwise unused for our tracked categories, we
reuse the same slot: for an undiscovered Lore/Eidetic book with a known map
location, it instead reads "Show On Map: <zone name>" and jumps/zooms there,
using the same keybind/alignment layout and localized "Show On Map" string
(SI_QUEST_JOURNAL_SHOW_ON_MAP) as the Quest Journal's own Show On Map keybind.
]]--

local function GetSelectedBookId(screen)
	local selectedData = screen:GetMainList():GetTargetData()
	if not selectedData or not selectedData.bookIndex or selectedData.enabled or screen.mailListIndex then
		return nil
	end

	local _, _, _, bookId = GetLoreBookInfo(screen.categoryIndex, screen.collectionIndex, selectedData.bookIndex)
	return bookId
end

-- returns the best (see Data:GetBookLocations) known location for the
-- currently selected book, or nil if it has none / isn't one of our tracked,
-- still-undiscovered books
local function GetSelectedBookLocation(screen)
	local bookId = GetSelectedBookId(screen)
	if not bookId then return nil end

	local locations = LoreLibrary.data:GetBookLocations(bookId)
	return locations[1]
end

function LoreLibraryGamepadMenu:Initialize()
	local screen = LORE_LIBRARY_BOOK_SET_GAMEPAD
	if not screen then return end

	self.showOnMapPrefix = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP) .. ": "

	table.insert(screen.keybindStripDescriptor, {
		name = function()
			local location = GetSelectedBookLocation(screen)
			return self.showOnMapPrefix .. (location and location.zoneName or "")
		end,
		keybind = "UI_SHORTCUT_SECONDARY",
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		visible = function()
			local location = GetSelectedBookLocation(screen)
			return location ~= nil and location.mapId > 0
		end,
		callback = function()
			LoreLibrary.ShowLocationOnMap(GetSelectedBookLocation(screen))
		end,
	})
end
