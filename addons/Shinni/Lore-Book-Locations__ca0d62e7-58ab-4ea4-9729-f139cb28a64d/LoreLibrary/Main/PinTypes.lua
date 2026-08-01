
LoreLibrary.LOREBOOK = 1
LoreLibrary.EIDETICBOOK = 2

LoreLibrary.PINTYPES = {
	LoreLibrary.LOREBOOK,
	LoreLibrary.EIDETICBOOK,
}

-- GetLoreBookIndicesFromBookId returns the lore category a book belongs to.
-- category 1 is "Shalidor's Library" (regular lore books), category 3 is "Eidetic Memory".
-- see HarvestMap's Main/Interaction.lua for reference.
local SHALIDOR_CATEGORY = 1
local EIDETIC_CATEGORY = 3
local LoreCategoryIndexToPinTypeId = {
	[SHALIDOR_CATEGORY] = LoreLibrary.LOREBOOK,
	[EIDETIC_CATEGORY] = LoreLibrary.EIDETICBOOK,
}

-- returns nil if the bookId does not belong to a lore category we display pins for,
-- or if the book has already been discovered
function LoreLibrary.GetPinTypeForBookId(bookId)
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

LoreLibrary.pinTypeLabels = {
	[LoreLibrary.LOREBOOK] = "Lore Books",
	[LoreLibrary.EIDETICBOOK] = "Eidetic Memory",
}

LoreLibrary.mapPinLayout = {
	[LoreLibrary.LOREBOOK] = {
		texture = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
		level = 1,
		size = 24,
		tint = ZO_ColorDef:New(0.4, 0.8, 1),
	},
	[LoreLibrary.EIDETICBOOK] = {
		texture = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
		level = 1,
		size = 24,
	},
}
