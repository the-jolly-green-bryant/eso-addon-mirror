------------------------------------------------
-- English localization for IsJustaCollectibleRandomizer
------------------------------------------------

local random = GetString(SI_PATHFOLLOWTYPE2)
local tooltipDefault = zo_strformat("Enabled: adds a collectible called \"<<1>>\" in ", random) .. '<<1>>'

local strings = {
	SI_IJA_RANDOM_TOOLTIP_TITLE	= 'Randomizer',
	SI_IJA_RANDOM_TOOLTIP_DESCRIPTION1	= "Uses a random Favorite <<1>>.",
	SI_IJA_RANDOM_TOOLTIP_DESCRIPTION2	= "Uses a random unlocked <<1>>.",
	
	SI_IJA_RANDOM_MOUNT_TOOLTIP = "Enabled: randomizes your selected mount on dismount.",

	SI_IJA_RANDOM_FAVORITE	= "Favorites Only.",
	SI_IJA_RANDOM_FAVORITE_TOOLTIP = "Enabled: will only use collectibles marked as \"Favorite\" in \"IsJusta Favorite Collectibles\".",
	SI_IJA_RANDOM_REQUIRES_TOOLTIP = "Requires \"IsJusta Favorite Collectibles\".",
	
	SI_IJA_RANDOM_RANDOMIZER_TOOLTIP3 = zo_strformat(tooltipDefault, 'the first subcategory of Non-combat Pets.'),
	SI_IJA_RANDOM_RANDOMIZER_TOOLTIP4 = zo_strformat(tooltipDefault, 'the first subcategory of Mounts.'),
	SI_IJA_RANDOM_RANDOMIZER_TOOLTIP5 = zo_strformat(tooltipDefault, 'Mementos.'),
	SI_IJA_RANDOM_RANDOMIZER_TOOLTIP13 = zo_strformat(tooltipDefault, 'each of the subcategories in Appearance.'),

	SI_IJA_RANDOM_RANDOMIZERS	= "Randomizers",
	
	SI_IJA_RANDOM_COLLECTIBLE1	= "Random Favorite Collectible",
	SI_IJA_RANDOM_COLLECTIBLE2	= "Random Collectible",
	
	SI_IJA_ACTIVE_RANDOM_COLLECTIBLE	= "Active Collectible: <<1>>",
	SI_IJA_BLOCK_REASON_NOT_ATIVE		= "Requires an active <<1>>.",
	SI_IJA_BROWSTO		= "Browse to..",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
--ZO_CreateStringId('SI_BINDING_NAME_IJA_CollectibleRandomizer_ToggleMount', "ToggleMount")