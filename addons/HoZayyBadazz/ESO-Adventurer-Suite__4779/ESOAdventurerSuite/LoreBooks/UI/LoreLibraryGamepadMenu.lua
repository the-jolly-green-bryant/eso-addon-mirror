-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local EASLoreLibraryGamepadMenu = {}
EASLoreLibrary:RegisterModule("loreLibraryGamepadMenu", EASLoreLibraryGamepadMenu)

--[[
Gamepad equivalent of EASLoreLibraryMenu.lua's keyboard right-click menu. The
gamepad Lore Library's book list screen (ZO_EASLoreLibraryBookSet_Gamepad) has a
keybind strip with "Back", "Read"/UI_SHORTCUT_PRIMARY, and
"Open in Achievements"/UI_SHORTCUT_SECONDARY (only shown for collections that
have a linked achievement, which never applies to Lore Books/Eidetic Memory).
Since that third keybind is otherwise unused for our tracked categories, we
reuse the same slot: for a Lore/Eidetic book with a known map location, it
instead reads "Show On Map: <zone name>" and jumps/zooms there, using the
same keybind/alignment layout and localized "Show On Map" string
(SI_QUEST_JOURNAL_SHOW_ON_MAP) as the Quest Journal's own Show On Map keybind.
It also starts tracking that book (see Pins/MarkerPin.lua): temporary marker
pins for every one of its locations. Useful for known books especially,
since their regular map pin is gone once they've been read, but works the
same for undiscovered ones too.
]]--

local function GetSelectedBookId(screen)
	local selectedData = screen:GetMainList():GetTargetData()
	if not selectedData or not selectedData.bookIndex or screen.mailListIndex then
		return nil
	end

	local _, _, _, bookId = GetLoreBookInfo(screen.categoryIndex, screen.collectionIndex, selectedData.bookIndex)
	return bookId, selectedData.enabled
end

-- returns the full array (see Data:GetBookLocations) of known locations for
-- the currently selected book, or nil if it has none / isn't one of our
-- tracked categories
local function GetSelectedBookLocations(screen)
	local bookId = GetSelectedBookId(screen)
	if not bookId then return nil end

	return EASLoreLibrary.data:GetBookLocations(bookId)
end

local function GetSelectedBookLocation(screen)
	local locations = GetSelectedBookLocations(screen)
	return locations and locations[1]
end

function EASLoreLibraryGamepadMenu:Initialize()
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
		-- visible whenever there's any location at all, even one whose mapId
		-- stayed 0 after Data:GetBookLocations' parent-zone fallback (e.g. a
		-- zone nested deeper than one level of parenting) - ShowLocationOnMap
		-- itself already no-ops for an invalid mapId, but the book can still
		-- be tracked (compass/world pins only key off zoneId)
		visible = function()
			local locations = GetSelectedBookLocations(screen)
			return locations ~= nil and #locations > 0
		end,
		callback = function()
			local bookId = GetSelectedBookId(screen)
			local locations = GetSelectedBookLocations(screen)
			if not locations then return end
			EASLoreLibrary.ShowLocationOnMap(locations[1])
			EASLoreLibrary.markerPin:Track(bookId, locations)
		end,
	})
end
