-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

EASLoreLibrary.LOREBOOK = 1
EASLoreLibrary.EIDETICBOOK = 2

-- temporary marker pin for the book selected via "Show On Map" (see
-- Pins/MarkerPin.lua). Listed last: unlike LOREBOOK/EIDETICBOOK, no book is
-- ever inserted into a ZoneCache under this pin type (GetPinTypeForBookId
-- below never returns it), so its block in every ZoneCache stays permanently
-- empty - keeping it last means it never has to participate in the
-- cascading-insert shuffle ZoneCache:AddBook does for the two real pin
-- types. Still listed in PINTYPES (unlike a purely private id) so it gets a
-- FilterMenu checkbox like any other pin type.
EASLoreLibrary.MARKER = 3

EASLoreLibrary.PINTYPES = {
	EASLoreLibrary.LOREBOOK,
	EASLoreLibrary.EIDETICBOOK,
	EASLoreLibrary.MARKER,
}

-- GetLoreBookIndicesFromBookId returns the lore category a book belongs to.
-- category 1 is "Shalidor's Library" (regular lore books), category 3 is "Eidetic Memory".
-- see HarvestMap's Main/Interaction.lua for reference.
local SHALIDOR_CATEGORY = 1
local EIDETIC_CATEGORY = 3
local LoreCategoryIndexToPinTypeId = {
	[SHALIDOR_CATEGORY] = EASLoreLibrary.LOREBOOK,
	[EIDETIC_CATEGORY] = EASLoreLibrary.EIDETICBOOK,
}

-- returns nil if the bookId does not belong to a lore category we display pins for,
-- or if the book has already been discovered
function EASLoreLibrary.GetPinTypeForBookId(bookId)
	local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
	if not categoryIndex then
		return nil
	end

	local _, _, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	if known then
		return nil
	end

	return LoreCategoryIndexToPinTypeId[categoryIndex]
end

EASLoreLibrary.pinTypeLabels = {
	[EASLoreLibrary.LOREBOOK] = "Lore Books",
	[EASLoreLibrary.EIDETICBOOK] = "Eidetic Memory",
	[EASLoreLibrary.MARKER] = "Tracked Book",
}

EASLoreLibrary.mapPinLayout = {
	[EASLoreLibrary.LOREBOOK] = {
		texture = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
		level = 1,
		size = 24,
		tint = nil,
	},
	[EASLoreLibrary.EIDETICBOOK] = {
		texture = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
		level = 1,
		size = 24,
		tint = nil,
	},
	[EASLoreLibrary.MARKER] = {
		texture = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
		level = 10,
		size = 36,
		tint = ZO_ColorDef:New(1, 0.15, 0.15),
	},
}
